# LXC Agent and MCP Matrix

| CTID | Service | Current role | Recommended agent/MCP model | Validation checks | Status |
| --- | --- | --- | --- | --- | --- |
| 100 | `netbox` | IPAM / DCIM | Use `homelab-netbox-ipam` MCP; no extra agent until web service recovers | ICMP to `192.168.4.140`; TCP `80/443`; NetBox token test | Blocked |
| 102 | `grafana-code-server` | Monitoring UI (stopped) | Keep agenting disabled until the CT is intentionally restarted | Confirm CT power state; validate UI ports only if re-enabled | Scaffolded |
| 103 | `prometheus` | Metrics store | Use Prometheus scrape validation and read-only service checks | ICMP to `192.168.4.132`; TCP `9090` | Partial |
| 104 | `prometheus-pve-exporter` | Proxmox exporter | Keep lightweight exporter role only; no MCP required | Reachability to `192.168.4.131`; exporter port `9221` | Blocked |
| 105 | `influxdb` | Telemetry hub | Prefer data-source validation and Telegraf checks; no custom MCP needed | ICMP to `192.168.4.130`; TCP `8086` | Partial |
| 106 | `homepage` | Docs / portal | Optional docs agent only; keep as stable user-facing endpoint | SSH `22`; HTTP `80` | Ready |
| 108 | `watchyourlan` | Network discovery (stopped) | Re-enable only when discovery scans are needed | Confirm CT state and UI reachability if started | Scaffolded |
| 109 | `pihole` | DNS / infra | Keep DNS-focused validation only; no extra MCP required | SSH `22`; DNS `53`; HTTP `80` | Ready |
| 110 | `netflow-collector` | NetFlow intake (stopped) | Keep passive collector pattern only | Confirm CT state and nfdump listeners if started | Scaffolded |
| 111 | `ansible` | Control plane | Preferred home for Ansible execution once started; can host control-node bootstrap | Start CT; run `bootstrap-control-node.sh`; verify `ansible-playbook --version` | Blocked |

## Notes

- This matrix describes the target operating model, not a claim that agents are
  already installed everywhere.
- MCP is preferred where it already exists (`NetBox`) instead of adding custom
  one-off agent logic.
- All recommendations remain read-only until connectivity and credentials are
  confirmed.
