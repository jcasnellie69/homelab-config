# MCP Filesystem Swim Lane — Start-to-Finish Notes (as-built)

## Goal
Expose authoritative config + artifacts content to an MCP-capable agent to speed upcoming workstreams, without copying repos off the Proxmox environment.

Exposed roots:
- /srv/artifacts
- /srv/homelab-share/homelab-config (mounted into LXC as /mnt/homelab-config)

## As-built topology (running state)
Agent/IDE
  -> nginx (mcp.lab)
     - /sse -> http://127.0.0.1:7400/sse
     - /mcp -> http://127.0.0.1:7400/mcp
  -> mcp-proxy (systemd in homepage LXC, 127.0.0.1:7400)
  -> @modelcontextprotocol/server-filesystem (stdio backend)
     - allowed dirs: /srv/artifacts, /mnt/homelab-config

## Chronological work summary
1) Confirmed authority + mount paths
- Repo lives on PVE: /srv/homelab-share/homelab-config
- Artifacts on PVE: /srv/artifacts
- CT 106 (homepage LXC) has:
  - mp0: /srv/artifacts -> /srv/artifacts
  - mp1: /srv/homelab-share/homelab-config -> /mnt/homelab-config

2) Resolved sandbox write needs (unprivileged LXC behavior)
- Observed RW mount but permission denied inside container.
- Root cause: unprivileged container UID mapping (container root -> host UID 100000).
- Fix: install `acl` on PVE and grant rwx ACL to u:100000 for the repo path (sandbox mode).

3) Avoided wrong FS MCP implementation
- A Python package named mcp-server-filesystem behaved like a demo app (calculator launch) and did not provide the desired HTTP/SSE listener.
- Dropped that path; used the official Node-based filesystem MCP server.

4) Extended existing MCP gateway instead of building a new one
- Discovered working nginx + mcp-proxy + filesystem MCP already present for /srv/artifacts.
- Updated the running systemd service to include /mnt/homelab-config as an additional allowed directory.

5) Validated running state
- systemd service active: mcp-artifacts-sse.service
- listener: 127.0.0.1:7400
- process args show: /srv/artifacts /mnt/homelab-config
- nginx /sse returns HTTP 200 + endpoint + “SSE Connection established”

6) Persisted configuration as code
- Copied unit file into repo: ops/systemd/mcp-artifacts-sse.service
- Committed change explicitly (no auto-commit behavior).

7) Cleanup
- Removed unused/incorrect python-based mcp-filesystem.service unit.

## Software installed (by location)

### PVE host
- acl (used to grant u:100000 sandbox write)
- Existing: git, pct tooling, etc.

### Homepage LXC (CT 106)
- git
- node + npm/npx (already present)
- mcp-proxy (Node)
- @modelcontextprotocol/server-filesystem (Node)
- systemd unit: mcp-artifacts-sse.service
- nginx config already routing /sse and /mcp to 127.0.0.1:7400

## Validation commands (quick)
- systemctl --no-pager --full status mcp-artifacts-sse.service
- ss -ltnp | grep ':7400'
- ps -ef | egrep -i 'mcp-proxy|mcp-server-filesystem|@modelcontextprotocol/server-filesystem' | grep -v egrep
- curl -i --max-time 2 -H 'Host: mcp.lab' http://127.0.0.1:8080/sse | head -n 40
