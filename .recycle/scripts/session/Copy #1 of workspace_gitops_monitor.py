#!/usr/bin/env python3
"""Create a git drift report for the workspace."""

from __future__ import annotations

import argparse
import json
import subprocess
from datetime import datetime, UTC
from pathlib import Path


def run_git(repo: Path, *args: str) -> str:
    result = subprocess.run(
        ["git", "-C", str(repo), *args],
        check=True,
        capture_output=True,
        text=True,
    )
    return result.stdout.strip()


def parse_branch_line(branch_line: str) -> tuple[str, str | None]:
    if not branch_line.startswith("## "):
        return "unknown", None
    payload = branch_line[3:]
    if "..." in payload:
        branch, remainder = payload.split("...", 1)
        return branch.strip(), remainder.strip() or None
    return payload.strip(), None


def parse_status(lines: list[str]) -> dict[str, list[str]]:
    summary: dict[str, list[str]] = {
        "modified": [],
        "added": [],
        "deleted": [],
        "renamed": [],
        "untracked": [],
        "other": [],
    }

    for line in lines:
        if not line:
            continue
        if line.startswith("?? "):
            summary["untracked"].append(line[3:])
            continue

        code = line[:2]
        path = line[3:]

        if "R" in code:
            summary["renamed"].append(path)
        elif "D" in code:
            summary["deleted"].append(path)
        elif "A" in code:
            summary["added"].append(path)
        elif "M" in code:
            summary["modified"].append(path)
        else:
            summary["other"].append(f"{code} {path}")

    return summary


def build_recommendations(branch: str, tracking: str | None, summary: dict[str, list[str]]) -> list[str]:
    recommendations: list[str] = []
    total_changes = sum(len(items) for items in summary.values())

    if total_changes == 0:
        recommendations.append("Workspace is clean; no commit or push action is required.")
        return recommendations

    if branch == "main":
        recommendations.append("Create or switch to a dedicated branch before committing or pushing workspace changes.")

    if tracking and "behind" in tracking:
        recommendations.append("Remote tracking branch is behind; prefer pushing the work to a fresh feature branch.")

    if summary["untracked"]:
        recommendations.append("Review untracked files and include only the intended workspace assets in the next commit.")

    recommendations.append("Run workspace health and tooling currency audits before pushing.")
    return recommendations


def main() -> int:
    parser = argparse.ArgumentParser(description="Report git drift for the current workspace")
    parser.add_argument(
        "--repo",
        default=".",
        help="Repository root to inspect (default: current directory)",
    )
    parser.add_argument(
        "--report",
        default="artifacts/automation/workspace-gitops-monitor-report.json",
        help="Output path for the JSON report",
    )
    args = parser.parse_args()

    repo = Path(args.repo).resolve()
    report_path = (repo / args.report).resolve() if not Path(args.report).is_absolute() else Path(args.report)
    report_path.parent.mkdir(parents=True, exist_ok=True)

    porcelain = run_git(repo, "status", "--porcelain=v1", "--branch")
    lines = porcelain.splitlines()
    branch_line = lines[0] if lines and lines[0].startswith("## ") else ""
    branch, tracking = parse_branch_line(branch_line)
    status_lines = lines[1:] if branch_line else lines
    summary = parse_status(status_lines)
    counts = {name: len(items) for name, items in summary.items()}

    report = {
        "generated_at": datetime.now(UTC).isoformat(),
        "repo": str(repo),
        "branch": branch,
        "tracking": tracking,
        "is_clean": sum(counts.values()) == 0,
        "counts": counts,
        "files": summary,
        "recommendations": build_recommendations(branch, tracking, summary),
    }

    report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")

    print(f"[gitops-monitor] wrote report: {report_path}")
    print(f"[gitops-monitor] branch={branch}")
    print(f"[gitops-monitor] tracking={tracking}")
    print(f"[gitops-monitor] is_clean={report['is_clean']}")
    print(f"[gitops-monitor] counts={json.dumps(counts, sort_keys=True)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
