# NetBox MCP Instructions

This is the repo-specific runbook for wiring NetBox into the workspace MCP inventory.

---

## ✅ Current validated state (2026-04-10)

- Workspace MCP entry: `.vscode/mcp.json` → `netbox-ipam`
- Root automation MCP entry: `mcp.json` → `NETBOX_MCP`
- Validated launch path on this workstation:

```powershell
uvx --from git+https://github.com/netboxlabs/netbox-mcp-server netbox-mcp-server --help
```

- Artifact-based NetBox host hint: `192.168.4.140`
- The host responds to ICMP from this workstation.
- During this session, application ports `80` and `443` were refusing connections, so authenticated NetBox MCP queries depend on CT 100 service availability.

---

## Required inputs

The NetBox MCP flow needs:

- `NETBOX_URL` — the base URL for your NetBox instance
- `NETBOX_API_TOKEN` — a read-only NetBox token used by the MCP entry and mapped to `NETBOX_TOKEN` at runtime

Do **not** store the token in tracked files.

---

## Workspace configuration standard

### `.vscode/mcp.json`

Use a prompt-backed stdio entry:

```json
"netbox-ipam": {
  "command": "uvx",
  "args": [
    "--from",
    "git+https://github.com/netboxlabs/netbox-mcp-server",
    "netbox-mcp-server",
    "--no-verify-ssl"
  ],
  "type": "stdio",
  "env": {
    "NETBOX_URL": "${input:NETBOX_URL}",
    "NETBOX_TOKEN": "${input:NETBOX_API_TOKEN}"
  }
}
```

### `mcp.json`

Use an environment-backed automation entry:

```json
"NETBOX_MCP": {
  "command": "uvx",
  "args": [
    "--from",
    "git+https://github.com/netboxlabs/netbox-mcp-server",
    "netbox-mcp-server",
    "--no-verify-ssl"
  ],
  "env": {
    "NETBOX_URL": "{{env.NETBOX_URL}}",
    "NETBOX_TOKEN": "{{env.NETBOX_API_TOKEN}}"
  },
  "type": "stdio"
}
```

---

## Validation commands

### 1. Confirm the runner works

```powershell
uvx --from git+https://github.com/netboxlabs/netbox-mcp-server netbox-mcp-server --help
```

### 2. Check host reachability

```powershell
Test-Connection 192.168.4.140 -Count 1
Test-NetConnection 192.168.4.140 -Port 80
Test-NetConnection 192.168.4.140 -Port 443
```

### 3. Use the workspace task

```text
workspace: netbox mcp validate
```

---

## Usage notes

- Prefer a read-only NetBox token.
- If NetBox uses a self-signed certificate, the workspace entry already includes `--no-verify-ssl` for homelab use.
- If the host answers ping but the web ports refuse connections, recover the NetBox service on CT 100 before expecting live MCP queries to succeed.

---

## Example prompts once the service is available

- "List my NetBox devices with name, status, site, and primary IP"
- "Show IPAM utilization for the homelab site"
- "Get recent NetBox change logs for core infrastructure objects"
