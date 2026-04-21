#!/usr/bin/env python3
"""Build a machine-readable metadata summary for future automation stages."""

from __future__ import annotations

import argparse
import json
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
NETWORK_INVENTORY = ROOT / "artifacts" / "network-inventory.json"
OBSERVABILITY_MAP = ROOT / "docs" / "observability-service-map.md"
DEFAULT_OUTPUT = ROOT / "artifacts" / "automation" / "pipeline-metadata-summary.json"


def load_network_inventory() -> dict:
    if not NETWORK_INVENTORY.exists():
        return {"metadata": {}, "devices": [], "summary": {}}
    return json.loads(NETWORK_INVENTORY.read_text(encoding="utf-8"))


def parse_service_map() -> list[dict[str, str]]:
    if not OBSERVABILITY_MAP.exists():
        return []

    services: list[dict[str, str]] = []
    for line in OBSERVABILITY_MAP.read_text(encoding="utf-8", errors="ignore").splitlines():
        if not line.startswith("|"):
            continue
        stripped = [part.strip() for part in line.strip().strip("|").split("|")]
        if len(stripped) != 5:
            continue
        ctid = stripped[0]
        if ctid in {"CTID", "-------"}:
            continue
        services.append(
            {
                "ctid": ctid,
                "role": stripped[1],
                "services": stripped[2],
                "should_be_running": stripped[3],
                "notes": stripped[4],
            }
        )
    return services


def summarize_devices(devices: list[dict]) -> dict:
    category_counts = Counter(device.get("category", "Unknown") for device in devices)
    status_counts = Counter(device.get("status", "Unknown") for device in devices)
    port_counts = Counter(device.get("switchPort", "Unknown") for device in devices)
    return {
        "total_devices": len(devices),
        "top_categories": category_counts.most_common(10),
        "status_counts": dict(status_counts),
        "top_ports": port_counts.most_common(10),
        "high_priority_devices": [
            {
                "ip": device.get("ip"),
                "hostname": device.get("hostname"),
                "priority": device.get("priority"),
                "status": device.get("status"),
            }
            for device in devices
            if device.get("priority") in {"Critical", "High"}
        ][:25],
    }


def build_summary() -> dict:
    inventory = load_network_inventory()
    devices = inventory.get("devices", [])
    services = parse_service_map()

    return {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "sources": {
            "network_inventory": str(NETWORK_INVENTORY.relative_to(ROOT)),
            "observability_service_map": str(OBSERVABILITY_MAP.relative_to(ROOT)),
        },
        "network": summarize_devices(devices),
        "observability": {
            "service_count": len(services),
            "required_services": [service for service in services if service.get("should_be_running") == "YES"],
        },
        "pipeline_targets": {
            "github_actions_context": "artifacts/automation/pipeline-metadata-summary.json",
            "workspace_health_report": "artifacts/automation/workspace-health-report.json",
            "ansible_inventory": "reports/automation/ansible-inventory.json",
            "terraform_vars": "reports/automation/terraform.auto.tfvars.json",
            "opnsense_seed": "reports/automation/opnsense-hosts.json",
            "netbox_export": "reports/automation/netbox-sync.json"
        },
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Build metadata summary JSON for automation pipelines.")
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT, help="Output path for generated metadata summary JSON.")
    args = parser.parse_args()

    summary = build_summary()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(summary, indent=2), encoding="utf-8")

    print(f"[metadata] wrote summary: {args.output}")
    print(f"[metadata] total devices: {summary['network']['total_devices']}")
    print(f"[metadata] observability services: {summary['observability']['service_count']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
