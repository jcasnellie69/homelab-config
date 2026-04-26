# Observability Service Map
#-------------------------------------------------------------------------------
# DATE       | CHGID   | REASON
# 2025-12-10 | CR-0021 | Document service placement to eliminate ambiguity in
#                      | telemetry roles and Telegraf duplication.
# USER: JC  | TARGET: Homelab (PVE + LXC stack)
#-------------------------------------------------------------------------------

This document provides a **single source of truth** for all observability-related
services across the Proxmox VE homelab. It defines **which container runs what**,
whether it is **required**, and how it connects to the unified telemetry pipeline.

---

## Service Placement Matrix

| CTID  | Role / Purpose              | Key Services Running                  | Should Be Running? | Notes                                   |
|-------|-----------------------------|---------------------------------------|---------------------|-----------------------------------------|
| 100   | NetBox + Loki + Netdata     | netbox, loki, netdata                 | YES                 | Telegraf not required                   |
| 102   | Grafana + Loki + code-server| grafana, loki, promtail              | YES                 | Telegraf not required (disable)         |
| 103   | Prometheus server           | prometheus, node-exporter             | YES                 | Telegraf optional                       |
| 105   | Telemetry Hub (canonical)   | influxdb, telegraf, loki, promtail    | YES                 | Only Telegraf sending → Influx          |
| 106   | Homepage + nginx            | homepage, nginx                       | YES                 | No telemetry agent needed               |
| 108   | WatchYourLAN                | watchyourlan                          | YES                 | No exporter needed                      |
| 109   | Pi-hole + Netdata + WA MQTT | pihole-FTL, netdata, wa-mqtt          | YES                 | Feeds CT105 via HTTP API or log mount   |
| 110   | Netflow Collector (nfdump)  | nfdump, nfdump@default                | YES                 | Feeds CT105 via stats file or exec      |
| HOST  | Netify DPI Engine           | netifyd                               | YES                 | Logs mounted or shipped into CT105      |


---

## Editing / Access Policy

- **Primary editor:** Local VS Code (Linux or Windows) using Remote-SSH → PVE.
- **Git source of truth:** `/root/homelab-config` on PVE host.
- **Browser code-server:**
  - Previously installed in CT102 (grafana) and CT105 (influxdb) for convenience
    while editing many JS/JSON dashboards and telemetry configs.
  - As of 2025-12-10, both `code-server@root` services are **disabled**.
  - Future standard: all edits occur via local VS Code → Remote-SSH into PVE.
