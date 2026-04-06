# Proxmox Node Tooling

These scripts prepare and validate a baseline set of monitoring and diagnostic tools for your Proxmox host.

## Files
- **PVE_tools_install.sh** — Installs disk, system, network, and troubleshooting packages.
- **PVE_tools_check.sh** — Runs sanity checks to confirm tools are available and working.

## Usage

### 1. Copy scripts into place
```bash
mkdir -p /root/bin
cp PVE_tools_install.sh PVE_tools_check.sh /root/bin/
chmod +x /root/bin/PVE_tools_install.sh /root/bin/PVE_tools_check.sh
```

### 2. Run installer
```bash
/root/bin/PVE_tools_install.sh
```

### 3. Run checker
```bash
/root/bin/PVE_tools_check.sh
```

### Notes
- Run as **root** on the PVE node (no sudo required).
- `PVE_tools_install.sh` is safe to re-run if you add/remove packages later.
- `PVE_tools_check.sh` includes interactive tools (`htop`, `iotop`, `iftop`) — press `q` to exit.
- Extend these scripts or pair with `PVE_HC.sh` for full node + guest health reporting.
