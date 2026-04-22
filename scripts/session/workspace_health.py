#!/usr/bin/env python3
"""Workspace health audit for docs, JSON configs, and secret hygiene."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Iterable

ROOT = Path(__file__).resolve().parents[2]
MARKDOWN_ROOTS = [ROOT / "docs", ROOT / "WIKI"]
JSON_FILES = [
    ROOT / "mcp.json",
    ROOT / ".vscode" / "mcp.json",
    ROOT / ".vscode" / "settings.json",
    ROOT / ".vscode" / "extensions.json",
    ROOT / ".devcontainer" / "devcontainer.json",
    ROOT / "configs" / "automation-metadata.json",
]
SECRET_SCAN_ROOTS = [
    ROOT / ".github",
    ROOT / ".vscode",
    ROOT / ".devcontainer",
    ROOT / "configs",
    ROOT / "scripts",
    ROOT / "deploy",
    ROOT / "docs",
    ROOT / "mcp.json",
]
LINK_RE = re.compile(r"\[[^\]]+\]\(([^)]+)\)")
SECRET_RE = re.compile(
    r"Bearer\s+(?!\$\{input:)(?!\{\{env\.)"
    r"(eyJ[\w.-]+|ndc\.[\w.-]+|ghp_[\w]+|github_pat_[\w_]+)",
    re.IGNORECASE,
)


def iter_markdown_files() -> Iterable[Path]:
    for root in MARKDOWN_ROOTS:
        if root.exists():
            yield from root.rglob("*.md")


def check_markdown_links() -> list[dict[str, str]]:
    missing: list[dict[str, str]] = []
    for md_file in iter_markdown_files():
        text = md_file.read_text(encoding="utf-8", errors="ignore")
        for raw in LINK_RE.findall(text):
            link = raw.strip().split()[0]
            if not link or link.startswith(("http://", "https://", "mailto:", "#", "<")):
                continue
            link = link.split("#", 1)[0]
            target = (md_file.parent / link).resolve() if not link.startswith("/") else (ROOT / link.lstrip("/")).resolve()
            if not target.exists():
                missing.append({
                    "file": str(md_file.relative_to(ROOT)),
                    "link": raw,
                })
    return missing


def check_json_files() -> list[dict[str, str]]:
    errors: list[dict[str, str]] = []
    for json_file in JSON_FILES:
        if not json_file.exists():
            errors.append({"file": str(json_file.relative_to(ROOT)), "error": "missing file"})
            continue
        try:
            json.loads(json_file.read_text(encoding="utf-8"))
        except Exception as exc:  # pragma: no cover - defensive
            errors.append({"file": str(json_file.relative_to(ROOT)), "error": str(exc)})
    return errors


def iter_secret_scan_files() -> Iterable[Path]:
    for entry in SECRET_SCAN_ROOTS:
        if entry.is_file():
            yield entry
            continue
        if entry.exists():
            for file_path in entry.rglob("*"):
                if file_path.is_file() and file_path.suffix.lower() in {".json", ".yml", ".yaml", ".md", ".sh"}:
                    yield file_path


def check_secret_hygiene() -> list[dict[str, str]]:
    findings: list[dict[str, str]] = []
    for file_path in iter_secret_scan_files():
        text = file_path.read_text(encoding="utf-8", errors="ignore")
        for match in SECRET_RE.finditer(text):
            findings.append({
                "file": str(file_path.relative_to(ROOT)),
                "match": match.group(0)[:80],
            })
    return findings


def build_report() -> dict[str, object]:
    missing_links = check_markdown_links()
    json_errors = check_json_files()
    secret_findings = check_secret_hygiene()
    artifact_dir = ROOT / "artifacts" / "hc"
    return {
        "root": str(ROOT),
        "checks": {
            "missing_markdown_links": missing_links,
            "json_errors": json_errors,
            "secret_findings": secret_findings,
            "artifact_directory_exists": artifact_dir.exists(),
            "artifact_file_count": len(list(artifact_dir.glob("*.txt"))) if artifact_dir.exists() else 0,
        },
        "summary": {
            "missing_markdown_links": len(missing_links),
            "json_errors": len(json_errors),
            "secret_findings": len(secret_findings),
        },
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Audit workspace health for docs, JSON, and tracked secrets.")
    parser.add_argument("--strict", action="store_true", help="Return non-zero if any issues are found.")
    parser.add_argument("--report", type=Path, help="Optional path to write a JSON report.")
    args = parser.parse_args()

    report = build_report()
    summary = report["summary"]

    print(f"[health] missing markdown links: {summary['missing_markdown_links']}")
    print(f"[health] json errors: {summary['json_errors']}")
    print(f"[health] secret findings: {summary['secret_findings']}")
    print(f"[health] artifact directory exists: {report['checks']['artifact_directory_exists']}")
    print(f"[health] artifact text files: {report['checks']['artifact_file_count']}")

    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(json.dumps(report, indent=2), encoding="utf-8")
        print(f"[health] wrote report: {args.report}")

    if args.strict and any(summary.values()):
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
