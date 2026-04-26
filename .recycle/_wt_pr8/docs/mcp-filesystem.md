# MCP Filesystem (Artifacts + homelab-config)

## What this provides
An MCP endpoint fronted by nginx at `mcp.lab` that exposes filesystem tools scoped to:
- `/srv/artifacts`
- `/mnt/homelab-config`

## Topology
- nginx:
  - `/sse` -> `http://127.0.0.1:7400/sse`
  - `/mcp` -> `http://127.0.0.1:7400/mcp`
- systemd (homepage LXC):
  - `mcp-artifacts-sse.service`
- backend server:
  - `@modelcontextprotocol/server-filesystem /srv/artifacts /mnt/homelab-config`

## Validate
- `systemctl status mcp-artifacts-sse.service`
- `ss -ltnp | grep :7400`
- `curl -i --max-time 2 -H 'Host: mcp.lab' http://127.0.0.1:8080/sse`
