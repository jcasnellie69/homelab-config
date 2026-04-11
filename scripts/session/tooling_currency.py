#!/usr/bin/env python3
"""Report tooling parity, patch currency signals, and unpinned latest tags across the workspace."""

from __future__ import annotations

import argparse
import json
import re
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_REPORT = ROOT / 'artifacts' / 'automation' / 'tooling-currency-report.json'
IMAGE_RE = re.compile(r'image:\s*["\']?(?P<image>[^"\'\s]+)')
ACTION_RE = re.compile(r'uses:\s*(?P<action>[\w./-]+@v?[^\s]+)')
SCAN_ROOTS = [
    ROOT / '.github',
    ROOT / '.devcontainer',
    ROOT / '.vscode',
    ROOT / 'deploy',
    ROOT / 'configs',
    ROOT / 'mcp.json',
]


def scan_latest_images() -> list[dict[str, str]]:
    findings: list[dict[str, str]] = []
    for root in SCAN_ROOTS:
        files = [root] if root.is_file() else root.rglob('*') if root.exists() else []
        for file_path in files:
            if not file_path.is_file() or file_path.suffix.lower() not in {'.yml', '.yaml', '.json', '.md'}:
                continue
            text = file_path.read_text(encoding='utf-8', errors='ignore')
            for match in IMAGE_RE.finditer(text):
                image = match.group('image')
                if image.endswith(':latest'):
                    findings.append({'file': str(file_path.relative_to(ROOT)), 'image': image})
    return findings


def collect_actions() -> list[str]:
    actions: set[str] = set()
    workflows = ROOT / '.github' / 'workflows'
    if workflows.exists():
        for path in workflows.glob('*.y*ml'):
            text = path.read_text(encoding='utf-8', errors='ignore')
            for match in ACTION_RE.finditer(text):
                actions.add(match.group('action'))
    return sorted(actions)


def collect_summary() -> dict[str, object]:
    devcontainer = ROOT / '.devcontainer' / 'Dockerfile'
    extensions = ROOT / '.vscode' / 'extensions.json'
    mcp = ROOT / '.vscode' / 'mcp.json'
    root_mcp = ROOT / 'mcp.json'

    devcontainer_base = None
    if devcontainer.exists():
        for line in devcontainer.read_text(encoding='utf-8', errors='ignore').splitlines():
            if line.strip().startswith('FROM '):
                devcontainer_base = line.strip().split(None, 1)[1]
                break

    ext_count = 0
    if extensions.exists():
        ext_count = len(json.loads(extensions.read_text(encoding='utf-8')).get('recommendations', []))

    mcp_servers = []
    if mcp.exists():
        mcp_servers = sorted(json.loads(mcp.read_text(encoding='utf-8')).get('servers', {}).keys())

    root_mcp_servers = []
    if root_mcp.exists():
        root_mcp_servers = sorted(json.loads(root_mcp.read_text(encoding='utf-8')).get('mcp', {}).get('servers', {}).keys())

    workspace_mcp_naming_findings = [name for name in mcp_servers if not name.startswith('homelab-')]
    root_mcp_naming_findings = [name for name in root_mcp_servers if not name.startswith('HOMELAB_')]

    latest_images = scan_latest_images()
    return {
        'generated_at': datetime.now(timezone.utc).isoformat(),
        'devcontainer_base': devcontainer_base,
        'recommended_extension_count': ext_count,
        'mcp_servers': mcp_servers,
        'root_mcp_servers': root_mcp_servers,
        'workspace_mcp_naming_findings': workspace_mcp_naming_findings,
        'root_mcp_naming_findings': root_mcp_naming_findings,
        'github_actions': collect_actions(),
        'latest_tag_findings': latest_images,
        'summary': {
            'latest_tag_count': len(latest_images),
            'mcp_server_count': len(mcp_servers),
            'root_mcp_server_count': len(root_mcp_servers),
            'workspace_mcp_naming_issue_count': len(workspace_mcp_naming_findings),
            'root_mcp_naming_issue_count': len(root_mcp_naming_findings),
            'github_action_count': len(collect_actions()),
        },
    }


def main() -> int:
    parser = argparse.ArgumentParser(description='Generate tooling currency and parity report.')
    parser.add_argument('--report', type=Path, default=DEFAULT_REPORT)
    args = parser.parse_args()

    report = collect_summary()
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report, indent=2), encoding='utf-8')
    print(f"[currency] wrote report: {args.report}")
    print(f"[currency] latest tag findings: {report['summary']['latest_tag_count']}")
    print(f"[currency] mcp servers: {report['summary']['mcp_server_count']}")
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
