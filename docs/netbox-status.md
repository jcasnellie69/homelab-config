# NetBox Status

## Status

- **NETBOX:** `ABSENT`

## Evidence

1. The operator confirmed that NetBox is **not currently deployed**.
2. The historical IP `192.168.4.140` does not expose the expected service ports:
   - `80/tcp` → closed
   - `443/tcp` → closed
   - `22/tcp` → closed
3. The current ARP identity for `192.168.4.140` is `9C:C8:E9:6B:B4:AB`, which
   does not represent a validated NetBox endpoint.
4. The `network-inventory` artifact shows `192.168.4.140` as a transient client
   entry rather than a stable infrastructure service, so the old NetBox IP
   reference must not be reused automatically.

## Current conclusion

Historical CT `100` / `netbox` references in the repo are **stale**. No current
live deployment was verified from the controller view.

## Clean deployment plan

### Preferred form factor

- **Preferred default:** LXC on `alpha`
- **Use a VM instead** only if you want stronger isolation or a future appliance-style build

### Stable IP assignment

- Reserve a **new unused static management IP** from the current management
  subnet `192.168.4.0/24`
- Do **not** reuse `192.168.4.140` without explicitly reclaiming and re-validating it
- Record the reserved IP in DHCP/static reservation and then update the workspace
  MCP config to match

### Service layout

- PostgreSQL
- Redis
- NetBox application
- `gunicorn` bound to localhost or a unix socket
- `nginx` exposing `80` and `443`

### Validation steps after deployment

```bash
ss -ltnp | egrep ':80|:443'
curl -I http://<new-netbox-ip>/
curl -kI https://<new-netbox-ip>/
```

Optional API validation once a read-only token exists:

```bash
curl -k -H "Authorization: Token <redacted>" https://<new-netbox-ip>/api/
```

### Repo follow-up after deployment

1. update `.vscode/mcp.json` and `mcp.json` with the new `NETBOX_URL`
2. set `NETBOX_API_TOKEN` securely via prompt or environment variables
3. re-run `workspace: netbox mcp validate`
