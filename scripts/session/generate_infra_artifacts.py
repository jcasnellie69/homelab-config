#!/usr/bin/env python3
"""Generate Ansible inventory, Terraform variables, and future NetBox/OPNsense seed files from artifact data."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
HC_DIR = ROOT / "artifacts" / "hc"
PCT_SUMMARY = ROOT / "artifacts" / "dhcp-discovery" / "D122225T0153" / "pct_configs_summary.txt"
PIPELINE_SUMMARY = ROOT / "artifacts" / "automation" / "pipeline-metadata-summary.json"
ANSIBLE_JSON = ROOT / "reports" / "automation" / "ansible-inventory.json"
ANSIBLE_YML = ROOT / "deploy" / "ansible" / "inventory" / "generated.yml"
TERRAFORM_TFVARS = ROOT / "reports" / "automation" / "terraform.auto.tfvars.json"
OPNSENSE_SEED = ROOT / "reports" / "automation" / "opnsense-hosts.json"
NETBOX_SYNC = ROOT / "reports" / "automation" / "netbox-sync.json"

GUEST_RE = re.compile(
    r'^VMID=(?P<vmid>\d+) TYPE=(?P<type>\w+) HOSTNAME=(?P<hostname>[^ ]+) '
    r'STATUS=(?P<status>[^ ]+) DESC="(?P<desc>[^"]*)" TAGS="(?P<tags>[^"]*)"$'
)
IP_RE = re.compile(r'(\d+\.\d+\.\d+\.\d+)')


def latest_guest_file() -> Path:
    candidates = sorted(HC_DIR.glob('pve-*/pve-guests.txt'))
    if not candidates:
        raise FileNotFoundError('No pve-guests.txt file found under artifacts/hc/')
    return candidates[-1]


def parse_guests() -> list[dict[str, object]]:
    guests: list[dict[str, object]] = []
    for line in latest_guest_file().read_text(encoding='utf-8', errors='ignore').splitlines():
        match = GUEST_RE.match(line.strip())
        if not match:
            continue
        data = match.groupdict()
        tags = [tag.strip() for tag in data['tags'].split(',') if tag.strip()]
        ip = next((tag for tag in tags if IP_RE.fullmatch(tag)), None)
        guests.append(
            {
                'vmid': int(data['vmid']),
                'type': data['type'],
                'hostname': data['hostname'],
                'status': data['status'],
                'description': data['desc'],
                'tags': tags,
                'ip': ip,
            }
        )
    return guests


def ansible_ct_from_summary() -> dict[str, object]:
    text = PCT_SUMMARY.read_text(encoding='utf-8', errors='ignore') if PCT_SUMMARY.exists() else ''
    if '==== CT 111 ====' not in text:
        return {
            'vmid': 111,
            'hostname': 'ansible',
            'status': 'stopped',
            'ip': None,
            'description': 'Automation control node',
            'tags': ['automation'],
        }
    return {
        'vmid': 111,
        'hostname': 'ansible',
        'status': 'stopped',
        'ip': None,
        'description': 'Automation control node',
        'tags': ['automation', 'dhcp'],
    }


def make_host_key(guest: dict[str, object], existing: set[str]) -> str:
    raw_name = str(guest.get('hostname', 'unknown')).replace('.pve.local', '').strip().lower()
    if raw_name in {'', 'unknown'}:
        desc = str(guest.get('description', 'guest')).lower()
        slug = re.sub(r'[^a-z0-9]+', '-', desc).strip('-') or 'guest'
        raw_name = f"ct{guest.get('vmid')}-{slug}"
    candidate = raw_name
    suffix = 1
    while candidate in existing:
        suffix += 1
        candidate = f"{raw_name}-{suffix}"
    existing.add(candidate)
    return candidate


def build_inventory(alpha_ip: str) -> dict[str, object]:
    guests = parse_guests()
    guests.append(ansible_ct_from_summary())

    hosts: dict[str, dict[str, object]] = {
        'alpha': {
            'ansible_host': alpha_ip,
            'role': 'proxmox_host',
            'source': 'user-confirmed + network inventory artifact',
            'services': ['pve', 'netifyd', 'softflowd'],
        }
    }
    existing_names = {'alpha'}

    groups: dict[str, list[str]] = {
        'proxmox': ['alpha'],
        'lxc': [],
        'monitoring': [],
        'docs': [],
        'dns': [],
        'automation': [],
        'netbox': [],
        'future_opnsense': [],
    }

    for guest in guests:
        name = make_host_key(guest, existing_names)
        hosts[name] = {
            'hostname': guest['hostname'],
            'vmid': guest['vmid'],
            'ansible_host': guest['ip'],
            'status': guest['status'],
            'description': guest['description'],
            'tags': guest['tags'],
        }
        groups['lxc'].append(name)

        joined = ' '.join([str(guest['description']), ' '.join(map(str, guest['tags']))]).lower()
        if 'monitor' in joined or 'prometheus' in joined or 'telemetry' in joined or 'netflow' in joined:
            groups['monitoring'].append(name)
        if 'docs' in joined or 'homepage' in joined:
            groups['docs'].append(name)
        if 'dns' in joined or 'pihole' in joined:
            groups['dns'].append(name)
        if 'automation' in joined or name == 'ansible':
            groups['automation'].append(name)
        if 'netbox' in joined:
            groups['netbox'].append(name)

    inventory = {
        'all': {
            'children': {
                group: {'hosts': {host: hosts[host] for host in hostnames}}
                for group, hostnames in groups.items() if hostnames
            },
            'hosts': hosts,
        }
    }
    return inventory


def inventory_to_yaml(inventory: dict[str, object]) -> str:
    lines = ['all:']
    hosts = inventory['all']['hosts']
    lines.append('  hosts:')
    for name, values in hosts.items():
        lines.append(f'    {name}:')
        for key, value in values.items():
            rendered = json.dumps(value) if isinstance(value, (dict, list)) else ('null' if value is None else str(value))
            lines.append(f'      {key}: {rendered}')
    lines.append('  children:')
    for group, block in inventory['all']['children'].items():
        lines.append(f'    {group}:')
        lines.append('      hosts:')
        for host in block['hosts'].keys():
            lines.append(f'        {host}: {{}}')
    return '\n'.join(lines) + '\n'


def build_supporting_outputs(alpha_ip: str) -> tuple[dict[str, object], dict[str, object], dict[str, object]]:
    pipeline = json.loads(PIPELINE_SUMMARY.read_text(encoding='utf-8')) if PIPELINE_SUMMARY.exists() else {}
    high_priority = pipeline.get('network', {}).get('high_priority_devices', [])
    top_ports = pipeline.get('network', {}).get('top_ports', [])
    guests = parse_guests()

    terraform = {
        'alpha_ip': alpha_ip,
        'use_netbox': True,
        'use_proxmox_ansible': True,
        'lxc_guests': guests,
        'priority_ports': top_ports,
        'future_opnsense': {
            'enabled': True,
            'target_host': 'alpha',
            'management_network_hint': alpha_ip.rsplit('.', 1)[0] + '.0/24',
            'ansible_collection': 'ansibleguy.opnsense',
        },
    }

    opnsense = {
        'alpha_host': {'hostname': 'alpha', 'ip': alpha_ip},
        'netbox_dependency': {'hostname': 'netbox', 'ip': next((g['ip'] for g in guests if g['hostname'] == 'netbox'), None)},
        'ansible_control_node': {'hostname': 'ansible', 'vmid': 111, 'status': 'stopped', 'ip': None},
        'candidate_seed_hosts': high_priority[:10],
        'notes': [
            'Use community.proxmox to manage the LXC lifecycle from Alpha.',
            'Use ansibleguy.opnsense for OPNsense API-driven provisioning once credentials are available.',
            'Use netbox.netbox to sync IPAM/DCIM records from NetBox CT 100.',
        ],
    }

    netbox_sync = {
        'netbox_url_hint': 'http://192.168.4.140/',
        'source_of_truth': 'artifacts/network-inventory.json',
        'sync_candidates': high_priority[:25],
        'top_ports': top_ports,
        'status_counts': pipeline.get('network', {}).get('status_counts', {}),
    }
    return terraform, opnsense, netbox_sync


def main() -> int:
    parser = argparse.ArgumentParser(description='Generate infrastructure artifacts from homelab records.')
    parser.add_argument('--alpha-ip', default='192.168.4.10', help='Alpha Proxmox host IP address.')
    args = parser.parse_args()

    inventory = build_inventory(args.alpha_ip)
    terraform, opnsense, netbox_sync = build_supporting_outputs(args.alpha_ip)

    for path in [ANSIBLE_JSON, ANSIBLE_YML, TERRAFORM_TFVARS, OPNSENSE_SEED, NETBOX_SYNC]:
        path.parent.mkdir(parents=True, exist_ok=True)

    ANSIBLE_JSON.write_text(json.dumps(inventory, indent=2), encoding='utf-8')
    ANSIBLE_YML.write_text(inventory_to_yaml(inventory), encoding='utf-8')
    TERRAFORM_TFVARS.write_text(json.dumps(terraform, indent=2), encoding='utf-8')
    OPNSENSE_SEED.write_text(json.dumps(opnsense, indent=2), encoding='utf-8')
    NETBOX_SYNC.write_text(json.dumps(netbox_sync, indent=2), encoding='utf-8')

    print(f'[infra] wrote {ANSIBLE_JSON}')
    print(f'[infra] wrote {ANSIBLE_YML}')
    print(f'[infra] wrote {TERRAFORM_TFVARS}')
    print(f'[infra] wrote {OPNSENSE_SEED}')
    print(f'[infra] wrote {NETBOX_SYNC}')
    print(f'[infra] alpha_ip={args.alpha_ip}')
    print(f'[infra] lxc_hosts={len(inventory["all"]["children"].get("lxc", {}).get("hosts", {}))}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
