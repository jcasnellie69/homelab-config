#!/usr/bin/env python3
"""Read-only scheduled inventory of Git repositories on server storage."""

from __future__ import annotations

import argparse
import fcntl
import json
import os
import shutil
import socket
import subprocess
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


DEFAULT_ROOTS = ("/home", "/mnt/repos", "/srv")
EXCLUDED_DIRECTORIES = {
    ".cache",
    ".npm",
    ".tox",
    ".venv",
    ".recycle",
    "__pycache__",
    "node_modules",
    "proc",
    "sys",
    "dev",
    "run",
}
COMMAND_TIMEOUT_SECONDS = 30


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--root",
        action="append",
        dest="roots",
        help="Root to scan; repeat for multiple roots.",
    )
    parser.add_argument(
        "--output-dir",
        default="/srv/artifacts/hc",
        help="Directory for repository-scan-latest.json and .md.",
    )
    parser.add_argument(
        "--max-depth",
        type=int,
        default=5,
        help="Maximum directory depth below each scan root.",
    )
    return parser.parse_args()


def run_git(repository: Path, *arguments: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["git", "-C", str(repository), *arguments],
        check=False,
        capture_output=True,
        text=True,
        timeout=COMMAND_TIMEOUT_SECONDS,
        env={**os.environ, "LC_ALL": "C", "GIT_TERMINAL_PROMPT": "0"},
    )


def git_output(repository: Path, *arguments: str) -> str | None:
    result = run_git(repository, *arguments)
    if result.returncode != 0:
        return None
    return result.stdout.strip()


def is_bare_repository(path: Path) -> bool:
    return (
        path.name.endswith(".git")
        and (path / "HEAD").is_file()
        and (path / "objects").is_dir()
        and (path / "refs").is_dir()
    )


def discover_repositories(
    roots: list[Path], max_depth: int
) -> tuple[list[Path], list[str]]:
    repositories: set[Path] = set()
    warnings: list[str] = []

    def on_error(error: OSError) -> None:
        warnings.append(f"scan: {error.filename}: {error.strerror}")

    for root in roots:
        if not root.exists():
            warnings.append(f"scan root does not exist: {root}")
            continue

        for current, directories, files in os.walk(
            root, topdown=True, followlinks=False, onerror=on_error
        ):
            current_path = Path(current)
            depth = len(current_path.relative_to(root).parts)

            if is_bare_repository(current_path):
                repositories.add(current_path.resolve())
                directories[:] = []
                continue

            git_directory = current_path / ".git"
            has_git_directory = (
                ".git" in directories and (git_directory / "HEAD").is_file()
            )
            has_git_file = ".git" in files and git_directory.is_file()
            if has_git_directory or has_git_file:
                repositories.add(current_path.resolve())
                # A repository is one inventory unit. Avoid traversing its
                # potentially massive object, dependency, and artifact trees.
                directories[:] = []
                continue

            if depth >= max_depth:
                directories[:] = []
                continue

            directories[:] = [
                name
                for name in directories
                if name != ".git"
                and name not in EXCLUDED_DIRECTORIES
                and not (current_path / name).is_symlink()
            ]

    return sorted(repositories), sorted(set(warnings))


def parse_status(lines: list[str]) -> dict[str, Any]:
    untracked = sum(line.startswith("??") for line in lines)
    conflicts = sum(
        line[:2] in {"DD", "AU", "UD", "UA", "DU", "AA", "UU"}
        for line in lines
    )
    return {
        "dirty": bool(lines),
        "change_count": len(lines),
        "untracked_count": untracked,
        "conflict_count": conflicts,
        "changes": lines[:200],
        "changes_truncated": len(lines) > 200,
    }


def inspect_repository(repository: Path) -> dict[str, Any]:
    errors: list[str] = []
    bare = git_output(repository, "rev-parse", "--is-bare-repository") == "true"
    branch = git_output(repository, "symbolic-ref", "--quiet", "--short", "HEAD")
    head = git_output(repository, "rev-parse", "--short=12", "HEAD")
    if branch is None:
        branch = f"detached:{head}" if head else "unborn"

    status_lines: list[str] = []
    if not bare:
        try:
            status = run_git(
                repository,
                "status",
                "--porcelain=v1",
                "--untracked-files=normal",
            )
            if status.returncode == 0:
                status_lines = status.stdout.splitlines()
            else:
                errors.append(status.stderr.strip() or "git status failed")
        except subprocess.TimeoutExpired:
            errors.append("git status timed out")

    upstream = git_output(
        repository, "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}"
    )
    ahead = 0
    behind = 0
    if upstream:
        divergence = git_output(
            repository,
            "rev-list",
            "--left-right",
            "--count",
            "HEAD...@{upstream}",
        )
        if divergence:
            fields = divergence.split()
            if len(fields) == 2:
                ahead, behind = (int(fields[0]), int(fields[1]))

    last_commit = git_output(
        repository,
        "log",
        "-1",
        "--format=%H%x1f%cI%x1f%s",
    )
    last_commit_data: dict[str, str] | None = None
    if last_commit:
        fields = last_commit.split("\x1f", 2)
        if len(fields) == 3:
            last_commit_data = {
                "sha": fields[0],
                "committed_at": fields[1],
                "subject": fields[2],
            }

    try:
        disk = shutil.disk_usage(repository)
        filesystem = {
            "total_bytes": disk.total,
            "used_bytes": disk.used,
            "free_bytes": disk.free,
            "utilization_percent": round((disk.used / disk.total) * 100, 2),
        }
    except OSError as error:
        filesystem = None
        errors.append(f"disk usage: {error}")

    return {
        "path": str(repository),
        "bare": bare,
        "branch": branch,
        "head": head,
        "upstream": upstream,
        "ahead": ahead,
        "behind": behind,
        **parse_status(status_lines),
        "last_commit": last_commit_data,
        "filesystem": filesystem,
        "errors": errors,
    }


def write_atomic(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary_name = tempfile.mkstemp(
        prefix=f".{path.name}.", dir=path.parent, text=True
    )
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as handle:
            handle.write(content)
            handle.flush()
            os.fsync(handle.fileno())
        os.chmod(temporary_name, 0o640)
        os.replace(temporary_name, path)
    finally:
        if os.path.exists(temporary_name):
            os.unlink(temporary_name)


def markdown_report(payload: dict[str, Any]) -> str:
    lines = [
        "# Repository Scan",
        "",
        f"- Collected: `{payload['collected_at']}`",
        f"- Host: `{payload['host']}`",
        f"- Repositories: `{payload['summary']['repository_count']}`",
        f"- Dirty: `{payload['summary']['dirty_count']}`",
        f"- Ahead of upstream: `{payload['summary']['ahead_count']}`",
        f"- Behind upstream: `{payload['summary']['behind_count']}`",
        "",
        "| Path | Branch | Dirty | Ahead | Behind | Disk |",
        "| --- | --- | ---: | ---: | ---: | ---: |",
    ]
    for repository in payload["repositories"]:
        path = repository["path"].replace("|", "\\|")
        branch = repository["branch"].replace("|", "\\|")
        utilization = repository.get("filesystem") or {}
        lines.append(
            f"| `{path}` | `{branch}` | "
            f"{repository['change_count']} | {repository['ahead']} | "
            f"{repository['behind']} | "
            f"{utilization.get('utilization_percent', 'unknown')}% |"
        )
    if payload["warnings"]:
        lines.extend(["", "## Scanner warnings", ""])
        lines.extend(f"- {warning}" for warning in payload["warnings"])
    return "\n".join(lines) + "\n"


def main() -> int:
    arguments = parse_args()
    roots = [Path(value) for value in (arguments.roots or DEFAULT_ROOTS)]
    output_directory = Path(arguments.output_dir)
    output_directory.mkdir(parents=True, exist_ok=True)

    with (output_directory / ".repository-scan.lock").open("w") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            print("repository scan already running", file=sys.stderr)
            return 0

        repository_paths, warnings = discover_repositories(roots, arguments.max_depth)
        valid_repository_paths: list[Path] = []
        for path in repository_paths:
            if git_output(path, "rev-parse", "--git-dir") is None:
                warnings.append(f"ignored invalid Git metadata candidate: {path}")
                continue
            valid_repository_paths.append(path)
        repositories = [inspect_repository(path) for path in valid_repository_paths]
        payload = {
            "schema": "homelab.repository-scan/v1",
            "collected_at": datetime.now(timezone.utc).isoformat(),
            "host": socket.gethostname(),
            "roots": [str(root) for root in roots],
            "max_depth": arguments.max_depth,
            "mode": "read-only",
            "summary": {
                "repository_count": len(repositories),
                "dirty_count": sum(repo["dirty"] for repo in repositories),
                "ahead_count": sum(repo["ahead"] > 0 for repo in repositories),
                "behind_count": sum(repo["behind"] > 0 for repo in repositories),
                "error_count": sum(bool(repo["errors"]) for repo in repositories),
            },
            "repositories": repositories,
            "warnings": warnings,
        }

        write_atomic(
            output_directory / "repository-scan-latest.json",
            json.dumps(payload, indent=2, sort_keys=True) + "\n",
        )
        write_atomic(
            output_directory / "repository-scan-latest.md",
            markdown_report(payload),
        )

    print(json.dumps(payload["summary"], sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
