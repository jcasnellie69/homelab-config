#!/usr/bin/env python3
"""Create and optionally push policy-approved repository checkpoint commits."""

from __future__ import annotations

import argparse
import fnmatch
import hashlib
import json
import os
import re
import shutil
import socket
import subprocess
import tempfile
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


AGENT_NAME = "Repository Health Agent"
AGENT_EMAIL = "repository-health@localhost"
COMMAND_TIMEOUT_SECONDS = 300
OUTPUT_LIMIT = 12000
SECRET_PATTERNS = {
    "private-key": re.compile(
        rb"-----BEGIN (?:RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----"
    ),
    "github-token": re.compile(
        rb"(?:gh[pousr]_[A-Za-z0-9]{36,255}|github_pat_[A-Za-z0-9_]{40,255})"
    ),
    "aws-access-key": re.compile(rb"(?:A3T[A-Z0-9]|AKIA|ASIA)[A-Z0-9]{16}"),
    "slack-token": re.compile(rb"xox[baprs]-[A-Za-z0-9-]{20,}"),
}
SECRET_PATH_NAMES = {
    ".env",
    "credentials",
    "credentials.json",
    "id_dsa",
    "id_ecdsa",
    "id_ed25519",
    "id_rsa",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--policy",
        default="/mnt/repos/homelab-config/configs/repository-curator.json",
    )
    parser.add_argument("--artifact-dir", default="/srv/artifacts/hc")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--only", action="append", default=[])
    return parser.parse_args()


def run(
    command: list[str],
    *,
    cwd: Path,
    timeout: int = COMMAND_TIMEOUT_SECONDS,
    env: dict[str, str] | None = None,
) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        command,
        cwd=cwd,
        check=False,
        capture_output=True,
        text=True,
        timeout=timeout,
        env={
            **os.environ,
            "LC_ALL": "C.UTF-8",
            "GIT_TERMINAL_PROMPT": "0",
            **(env or {}),
        },
    )


def git(repository: Path, *arguments: str) -> subprocess.CompletedProcess[str]:
    return run(["git", *arguments], cwd=repository)


def git_text(repository: Path, *arguments: str) -> str | None:
    result = git(repository, *arguments)
    return result.stdout.strip() if result.returncode == 0 else None


def changed_paths(repository: Path, include_untracked: bool) -> list[Path]:
    tracked = git(repository, "diff", "--name-only", "-z", "HEAD")
    cached = git(repository, "diff", "--cached", "--name-only", "-z", "HEAD")
    paths: set[str] = set()
    for result in (tracked, cached):
        if result.returncode == 0:
            paths.update(value for value in result.stdout.split("\0") if value)
    if include_untracked:
        untracked = git(repository, "ls-files", "--others", "--exclude-standard", "-z")
        if untracked.returncode == 0:
            paths.update(value for value in untracked.stdout.split("\0") if value)
    return [Path(value) for value in sorted(paths)]


def fingerprint(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def secret_findings(repository: Path, paths: list[Path]) -> list[dict[str, str]]:
    findings: list[dict[str, str]] = []
    for relative_path in paths:
        full_path = repository / relative_path
        name = relative_path.name.lower()
        environment_template = name in {".env.example", ".env.sample", ".env.template"}
        if name in SECRET_PATH_NAMES or (name.startswith(".env.") and not environment_template):
            findings.append(
                {
                    "path": str(relative_path),
                    "detector": "secret-path",
                    "fingerprint": fingerprint(str(relative_path).encode()),
                }
            )
            continue
        if not full_path.is_file() or full_path.is_symlink():
            continue
        try:
            content = full_path.read_bytes()
        except OSError:
            continue
        for detector, pattern in SECRET_PATTERNS.items():
            for match in pattern.finditer(content):
                findings.append(
                    {
                        "path": str(relative_path),
                        "detector": detector,
                        "fingerprint": fingerprint(match.group(0)),
                    }
                )
    return findings


def in_progress_operations(repository: Path) -> list[str]:
    git_dir_text = git_text(repository, "rev-parse", "--git-dir")
    if not git_dir_text:
        return ["invalid-git-directory"]
    git_dir = (repository / git_dir_text).resolve()
    markers = {
        "MERGE_HEAD": "merge",
        "CHERRY_PICK_HEAD": "cherry-pick",
        "REVERT_HEAD": "revert",
        "rebase-apply": "rebase",
        "rebase-merge": "rebase",
        "BISECT_LOG": "bisect",
    }
    return [label for marker, label in markers.items() if (git_dir / marker).exists()]


def validation_results(
    repository: Path, commands: list[str], hard: bool
) -> list[dict[str, Any]]:
    results: list[dict[str, Any]] = []
    for command in commands:
        try:
            result = run(["/bin/bash", "-c", command], cwd=repository)
            output = (result.stdout + result.stderr)[-OUTPUT_LIMIT:]
            results.append(
                {
                    "command": command,
                    "exit_code": result.returncode,
                    "hard": hard,
                    "output": output,
                }
            )
        except subprocess.TimeoutExpired:
            results.append(
                {
                    "command": command,
                    "exit_code": 124,
                    "hard": hard,
                    "output": "validation timed out",
                }
            )
    return results


def remote_allowed(url: str, allowed_patterns: list[str]) -> bool:
    return any(fnmatch.fnmatch(url, pattern) for pattern in allowed_patterns)


def restore_index(repository: Path, backup: Path | None, index_path: Path) -> None:
    if backup and backup.exists():
        shutil.copy2(backup, index_path)
    elif index_path.exists():
        index_path.unlink()


def process_repository(
    item: dict[str, Any], *, dry_run: bool, timestamp: str, host: str
) -> dict[str, Any]:
    repository = Path(item["path"]).resolve()
    report: dict[str, Any] = {
        "path": str(repository),
        "mode": item.get("mode", "report"),
        "state": "unknown",
        "warnings": [],
        "hard_stops": [],
        "validations": [],
        "commit": None,
        "pushed_ref": None,
    }
    if not repository.is_dir():
        report["state"] = "blocked"
        report["hard_stops"].append("repository path missing")
        return report
    if git_text(repository, "rev-parse", "--is-inside-work-tree") != "true":
        report["state"] = "blocked"
        report["hard_stops"].append("not a Git worktree")
        return report

    branch = git_text(repository, "symbolic-ref", "--quiet", "--short", "HEAD")
    report["branch"] = branch
    if not branch:
        report["hard_stops"].append("detached or unborn HEAD")
    report["hard_stops"].extend(in_progress_operations(repository))
    conflicts = git_text(repository, "diff", "--name-only", "--diff-filter=U")
    if conflicts:
        report["hard_stops"].append("unmerged paths")

    paths = changed_paths(repository, item.get("include_untracked", True))
    report["change_count"] = len(paths)
    report["changed_paths"] = [str(path) for path in paths[:200]]
    report["changes_truncated"] = len(paths) > 200
    if not paths:
        report["state"] = "clean"
        return report

    maximum = int(item.get("max_file_bytes", 10_485_760))
    for path in paths:
        full_path = repository / path
        if full_path.is_file() and full_path.stat().st_size > maximum:
            report["hard_stops"].append(f"oversized file: {path}")

    secrets = secret_findings(repository, paths)
    report["secret_findings"] = secrets
    if secrets:
        report["hard_stops"].append("high-confidence secret finding")

    hard_commands = item.get("hard_validations", [])
    advisory_commands = item.get("advisory_validations", [])
    report["validations"] = validation_results(repository, hard_commands, True)
    report["validations"] += validation_results(repository, advisory_commands, False)
    if any(
        result["hard"] and result["exit_code"] != 0
        for result in report["validations"]
    ):
        report["hard_stops"].append("hard validation failed")
    report["warnings"] = [
        f"advisory validation failed: {result['command']}"
        for result in report["validations"]
        if not result["hard"] and result["exit_code"] != 0
    ]

    if report["hard_stops"]:
        report["state"] = "blocked"
        return report
    if report["mode"] == "report" or dry_run:
        report["state"] = "dry-run" if dry_run else "reported"
        return report

    index_text = git_text(repository, "rev-parse", "--git-path", "index")
    if not index_text:
        report["state"] = "blocked"
        report["hard_stops"].append("cannot resolve Git index")
        return report
    index_path = (repository / index_text).resolve()
    backup_path: Path | None = None
    temporary_directory = Path(tempfile.mkdtemp(prefix="repo-health-index-"))
    try:
        if index_path.exists():
            backup_path = temporary_directory / "index"
            shutil.copy2(index_path, backup_path)

        add = git(
            repository,
            "add",
            "-A" if item.get("include_untracked", True) else "-u",
        )
        if add.returncode != 0:
            restore_index(repository, backup_path, index_path)
            report["state"] = "blocked"
            report["hard_stops"].append(add.stderr.strip() or "git add failed")
            return report

        message = f"chore(repo-health): checkpoint {host} {timestamp}"
        body = (
            f"Automated recovery checkpoint for {len(paths)} changed paths.\n\n"
            f"Advisory warnings: {len(report['warnings'])}.\n"
            "Remote protected branches are not updated by this commit."
        )
        commit = run(
            [
                "git",
                "-c",
                f"user.name={AGENT_NAME}",
                "-c",
                f"user.email={AGENT_EMAIL}",
                "commit",
                "-m",
                message,
                "-m",
                body,
            ],
            cwd=repository,
        )
        if commit.returncode != 0:
            restore_index(repository, backup_path, index_path)
            report["state"] = "blocked"
            report["hard_stops"].append(commit.stderr.strip() or "git commit failed")
            return report
        report["commit"] = git_text(repository, "rev-parse", "HEAD")
    finally:
        shutil.rmtree(temporary_directory, ignore_errors=True)

    if report["mode"] != "checkpoint-push":
        report["state"] = "checkpointed"
        return report

    remote = item.get("remote", "origin")
    remote_url = git_text(repository, "remote", "get-url", remote)
    if not remote_url or not remote_allowed(
        remote_url, item.get("allowed_remote_patterns", [])
    ):
        report["state"] = "checkpointed-push-failed"
        report["hard_stops"].append("push remote is missing or outside allowlist")
        return report

    prefix = item.get("branch_prefix", "repo-health").strip("/")
    pushed_ref = f"{prefix}/{host}/{timestamp}"
    push = git(repository, "push", remote, f"HEAD:refs/heads/{pushed_ref}")
    if push.returncode != 0:
        report["state"] = "checkpointed-push-failed"
        report["warnings"].append(push.stderr.strip()[-OUTPUT_LIMIT:])
        return report
    report["pushed_ref"] = pushed_ref
    report["state"] = "checkpointed-pushed"
    return report


def write_atomic(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as handle:
            json.dump(payload, handle, indent=2, sort_keys=True)
            handle.write("\n")
        os.chmod(temporary, 0o640)
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def main() -> int:
    arguments = parse_args()
    policy_path = Path(arguments.policy)
    policy = json.loads(policy_path.read_text(encoding="utf-8"))
    timestamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    host = socket.gethostname().split(".")[0]
    only = {str(Path(path).resolve()) for path in arguments.only}
    repositories = [
        item
        for item in policy.get("repositories", [])
        if not only or str(Path(item["path"]).resolve()) in only
    ]
    reports = [
        process_repository(item, dry_run=arguments.dry_run, timestamp=timestamp, host=host)
        for item in repositories
    ]
    payload = {
        "schema": "homelab.repository-curator/v1",
        "collected_at": datetime.now(timezone.utc).isoformat(),
        "host": host,
        "dry_run": arguments.dry_run,
        "policy": str(policy_path),
        "summary": {
            "repository_count": len(reports),
            "clean_count": sum(report["state"] == "clean" for report in reports),
            "pushed_count": sum(
                report["state"] == "checkpointed-pushed" for report in reports
            ),
            "blocked_count": sum(report["state"] == "blocked" for report in reports),
            "warning_count": sum(len(report["warnings"]) for report in reports),
        },
        "repositories": reports,
    }
    artifact_dir = Path(arguments.artifact_dir)
    write_atomic(artifact_dir / "repository-curator-latest.json", payload)
    print(json.dumps(payload["summary"], sort_keys=True))
    return 1 if payload["summary"]["blocked_count"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
