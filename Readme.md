 <div align="center">

# 🏠 homelab-config

<img src="https://img.shields.io/badge/ZFS-tank0-0075FF?style=for-the-badge&logo=openzfs&logoColor=white" alt="ZFS tank0"/>
<img src="https://img.shields.io/badge/Proxmox_VE-GitOps-E57000?style=for-the-badge&logo=proxmox&logoColor=white" alt="Proxmox VE"/>
<img src="https://img.shields.io/badge/MkDocs-Material-526CFE?style=for-the-badge&logo=materialdesign&logoColor=white" alt="MkDocs Material"/>
<img src="https://img.shields.io/badge/Docker-Orchestrated-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker"/>
<img src="https://img.shields.io/badge/Grafana-Observability-F46800?style=for-the-badge&logo=grafana&logoColor=white" alt="Grafana"/>
<img src="https://img.shields.io/badge/InfluxDB-Telemetry-22ADF6?style=for-the-badge&logo=influxdb&logoColor=white" alt="InfluxDB"/>
<img src="https://img.shields.io/github/last-commit/jcasnellie69/homelab-config?style=for-the-badge&color=brightgreen" alt="Last Commit"/>

> **Infrastructure-as-Code for a production-grade homelab.**
> ZFS-tiered storage · Proxmox LXC/CT orchestration · Full-stack observability · GitOps-driven automation.

[📖 Docs Site](https://jcasnellie69.github.io/homelab-config) · [🗂 Artifacts Index](docs/artifacts-index.md) · [📡 Telemetry Pipeline](docs/telemetry-pipeline.md) · [🤝 Contributing](CONTRIBUTING.md)

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [ZFS Storage Pool — tank0](#-zfs-storage-pool--tank0)
  - [Hardware Devices](#hardware-devices)
  - [Pool Topology](#pool-topology)
  - [Dataset Layout](#dataset-layout)
- [Container Infrastructure](#-container-infrastructure)
  - [Service Map](#service-map)
- [Observability Stack](#-observability-stack)
  - [Telemetry Pipeline](#telemetry-pipeline)
  - [Service Placement Matrix](#service-placement-matrix)
- [GitOps Workflow](#-gitops-workflow)
- [Backup Strategy](#-backup-strategy)
- [KPI Monitoring](#-kpi-monitoring)
- [Scripts Inventory](#-scripts-inventory)
- [Next Steps](#-next-steps)
- [Maintainer](#-maintainer)

---

## 🔭 Overview

This repository is the **single source of truth** for all homelab infrastructure configuration.
It covers everything from raw storage topology to container orchestration, telemetry ingestion,
and automated GitOps pipelines — all documented, version-controlled, and reproducible.

| Layer | Technology | Purpose |
|---|---|---|
| **Hypervisor** | Proxmox VE | LXC containers + VM host |
| **Storage** | ZFS (`tank0`) | Mirrored NVMe + HDD tiered pool |
| **Orchestration** | Docker / LXC | Service containers |
| **Observability** | Grafana · InfluxDB · Prometheus | Metrics, logs, dashboards |
| **DNS / Network** | Pi-hole · Netify DPI · Netflow | Traffic analysis & filtering |
| **GitOps** | GitHub Actions + MkDocs | Automated docs deploy & CI |
| **Config Mgmt** | This repo (`homelab-config`) | IaC, scripts, runbooks, artifacts |

---

## 💾 ZFS Storage Pool — `tank0`

> **Redundancy:** Mirrored vdevs (RAID-1 equivalent)
> **Tiering:** NVMe SSDs for latency-sensitive workloads · HDDs for media/archive · USB for cold backup

### Hardware Devices

| Device | Type | Model | Capacity | Role |
|---|---|---|---|---|
| `nvme1n1` | NVMe SSD | Crucial P310 CT2000P310SSD8 | 2 TB | Primary high-speed |
| `nvme2n1` | NVMe SSD | WD Blue SN5000 | 2 TB | Mirror of nvme1n1 |
| `sda` | HDD | WDC WD20PURX | 2 TB | Media / archive tier |
| `sdc` | SSD | Crucial BX500 CT2000BX500SSD1 | 2 TB | General use / staging |
| `sdb` | HDD | Seagate ST1000VX001 | 1 TB | OS boot (Linux) |
| `nvme0n1` | NVMe SSD | AirDisk 1TB SSD | 1 TB | ZFS cold spare |

### Pool Topology

```mermaid
graph TD
    subgraph tank0["🗄️ ZFS Pool: tank0"]
        direction TB
        subgraph mirror0["Mirror vdev 0 — NVMe Tier (4 TB raw)"]
            nvme1["💾 nvme1n1\nCrucial P310 · 2 TB"]
            nvme2["💾 nvme2n1\nWD Blue SN5000 · 2 TB"]
        end
        subgraph hdd_tier["HDD Tier — Media / Archive"]
            sda["🖴 sda\nWD20PURX · 2 TB"]
            sdc["💿 sdc\nCrucial BX500 · 2 TB"]
        end
        subgraph spare["Cold Spare"]
            nvme0["🧊 nvme0n1\nAirDisk · 1 TB"]
        end
    end
    subgraph mount["Mount Points"]
        opt["/opt — infra datasets"]
        srv["/srv — shares"]
        docker["/var/lib/docker/volumes"]
    end
    tank0 --> opt
    tank0 --> srv
    tank0 --> docker

    style mirror0 fill:#0075FF22,stroke:#0075FF
    style hdd_tier fill:#E5700022,stroke:#E57000
    style spare  fill:#22ADF622,stroke:#22ADF6
    style tank0  fill:#1a1a2e,stroke:#0075FF,color:#fff
```

### Dataset Layout

```
tank0
├── /opt/
│   ├── baseOS                  ← base OS overlays
│   ├── business                ← business workloads  📸 snapshots enabled
│   └── infra/
│       ├── application         ← app containers
│       ├── automation          ← cron / scripts      📸 snapshots enabled
│       ├── development         ← dev environments
│       ├── language            ← runtime envs (Python, Node, Go…)
│       ├── network             ← network tooling
│       ├── observability       ← monitoring stack
│       ├── output              ← rendered artefacts / exports
│       ├── security            ← certs, secrets mgmt
│       ├── storage             ← storage services     📸 snapshots enabled
│       ├── utility             ← general utilities
│       ├── virtualization      ← VM / container data
│       └── web                 ← web services
├── /opt/user/
│   ├── configs                 ← user-level configs   📸 snapshots enabled
│   └── ux                      ← user experience layer
├── /srv/
│   └── shares                  ← NAS / SMB shares
└── /var/lib/docker/volumes     ← Docker volume mount (tank0/docker-volumes)
```

---

## 🐳 Container Infrastructure

### Service Map

```mermaid
graph LR
    subgraph pve["🖥️ Proxmox VE Host"]
        netifyd["🔍 netifyd\nDPI Engine"]
    end

    subgraph lxc["LXC Containers"]
        ct100["CT100\nNetBox · Loki · Netdata"]
        ct102["CT102\nGrafana · Loki · Promtail"]
        ct103["CT103\nPrometheus · node-exporter"]
        ct105["CT105 ★\nInfluxDB · Telegraf\nTelemetry Hub"]
        ct106["CT106\nHomepage · nginx"]
        ct108["CT108\nWatchYourLAN"]
        ct109["CT109\nPi-hole · Netdata · MQTT"]
        ct110["CT110\nNetflow · nfdump"]
    end

    netifyd -- "bind-mount logs" --> ct105
    ct109   -- "HTTP API / log mount" --> ct105
    ct110   -- "stats file / exec" --> ct105
    ct103   -- "scrape metrics" --> ct102
    ct100   -- "Loki logs" --> ct102
    ct105   -- "InfluxDB datasource" --> ct102

    style ct105 fill:#22ADF633,stroke:#22ADF6,color:#fff
    style pve   fill:#E5700011,stroke:#E57000
    style lxc   fill:#0075FF11,stroke:#0075FF
```

---

## 📡 Observability Stack

### Telemetry Pipeline

```mermaid
flowchart TD
    A["🖥️ PVE Host\nnetifyd DPI\n/var/log/netifyd/*"] -->|bind-mount| T

    B["🌐 CT109 — Pi-hole\nDNS query logs\nHTTP API metrics"] -->|log mount\nor HTTP API| T

    C["🌊 CT110 — Netflow\nnfdump statistics\nflow records"] -->|stats file\nor exec| T

    T["⭐ CT105 — Telegraf\nInputs:\n• tail\n• http\n• exec"]

    T -->|"write points"| I["🗃️ CT105 — InfluxDB\nTime-series datastore"]

    I -->|"datasource"| G["📊 CT102 — Grafana\nDashboards & Alerts"]

    P["📈 CT103 — Prometheus\nnode-exporter scrape"] -->|"scrape"| G

    L["📋 CT100 — Loki\nLog aggregation"] -->|"log queries"| G

    style T fill:#22ADF622,stroke:#22ADF6,color:#fff
    style I fill:#22ADF633,stroke:#22ADF6,color:#fff
    style G fill:#F4680022,stroke:#F46800,color:#fff
```

### Service Placement Matrix

| CT | Role | Key Services | Required | Notes |
|---|---|---|:---:|---|
| 100 | NetBox · Loki · Netdata | netbox, loki, netdata | ✅ | Telegraf not required |
| 102 | Grafana · Loki · Promtail | grafana, loki, promtail | ✅ | Telegraf disabled |
| 103 | Prometheus server | prometheus, node-exporter | ✅ | Telegraf optional |
| **105** | **Telemetry Hub** ★ | **influxdb, telegraf, loki, promtail** | ✅ | Only Telegraf → InfluxDB |
| 106 | Homepage · nginx | homepage, nginx | ✅ | No telemetry agent |
| 108 | WatchYourLAN | watchyourlan | ✅ | No exporter needed |
| 109 | Pi-hole · Netdata · MQTT | pihole-FTL, netdata, wa-mqtt | ✅ | Feeds CT105 |
| 110 | Netflow Collector | nfdump, nfdump@default | ✅ | Feeds CT105 |
| HOST | Netify DPI Engine | netifyd | ✅ | Logs shipped into CT105 |

---

## 🔄 GitOps Workflow

```mermaid
flowchart LR
    E["👨‍💻 Engineer\nLocal VS Code\n(Remote-SSH → PVE)"] -->|git push| R

    subgraph R["📦 GitHub — homelab-config"]
        direction TB
        CI["⚙️ GitHub Actions\nlint.yml\nmkdocs-deploy.yml\npush-wiki.yml"]
    end

    R -->|"MkDocs deploy"| D["📖 GitHub Pages\nDocs Site"]
    R -->|"wiki sync"| W["📚 GitHub Wiki"]
    R -->|"pull / apply"| P["🖥️ PVE Host\n/root/homelab-config"]

    P -->|"ZFS datasets"| Z["🗄️ tank0"]
    P -->|"container configs"| LXC["🐳 LXC Stack\nCT100–CT110"]
    P -->|"scripts"| S["📜 ops/scripts"]

    style R fill:#1a1a2e,stroke:#0075FF,color:#fff
    style CI fill:#0075FF22,stroke:#0075FF
```

---

## 🛡️ Backup Strategy

| Method | Scope | Schedule | Storage Target |
|---|---|---|---|
| ZFS Snapshots | `automation`, `configs`, `storage`, `business` | Periodic (cron) | On-pool |
| ZFS Send/Receive | Full pool datasets | On-demand / scheduled | External USB (immutable) |
| Cold Spare | Full pool copy | As-needed | `nvme0n1` AirDisk |
| Tiered offload | CCTV (Tapo), low-priority media | Continuous | HDD tier (`sda`) |

> **Immutability:** External USB targets use ZFS send/receive in read-only mode to prevent accidental overwrites.

---

## 📊 KPI Monitoring

Performance of `tank0` and the full stack is tracked via:

| Signal | Tool | Location |
|---|---|---|
| Pool latency / queue depth | `zpool iostat` | PVE host CLI |
| Device throughput | `iostat` | PVE host CLI |
| Live dashboards | Grafana | CT102 |
| Mirror IO balance | Grafana + InfluxDB | CT102 / CT105 |
| Write latency spikes | Telegraf → InfluxDB alert | CT105 |
| Snapshot storage growth | ZFS `list -t snapshot` | PVE host |
| Disk temp & SMART | Netdata + SMART plugin | CT109 / host |
| DNS / DPI anomalies | Pi-hole + netifyd + CT102 | CT109 / host → CT102 |

---

## 📜 Scripts Inventory

| Script | Location | Purpose |
|---|---|---|
| `hc-master.sh` | `scripts/hc/` | Master health-check orchestrator |
| `hc-storage-zfs.sh` | `scripts/hc/` | ZFS pool & dataset health checks |
| `hc-pve-guests.sh` | `scripts/hc/` | PVE guest (LXC/VM) inventory |
| `hc-netflow-basic.sh` | `scripts/hc/` | Basic netflow collection |
| `hc-artifacts-index.sh` | `scripts/hc/` | Rebuild artifacts index |
| `pve-lxc-systemd-scan.sh` | `scripts/hc/` | Scan LXC systemd service health |
| `dhcp-discovery-collect.sh` | `scripts/dhcp/` | DHCP lease discovery & collection |
| `telemetry-map-collect.sh` | `scripts/telemetry/` | Collect telemetry topology data |
| `telemetry-map-render.sh` | `scripts/telemetry/` | Render telemetry service map |
| `new-session.sh` | `scripts/session/` | Bootstrap a new audit session |
| `PVE_HC.sh` | `scripts/util/` | PVE host health-check utility |
| `PVE_tools_install.sh` | `scripts/util/` | Install PVE tooling dependencies |
| `set-repo-secrets.sh` | `scripts/` | Configure GitHub repo secrets |

---

## 🚀 Next Steps

- [ ] Document NIC layout and assess whether bonding / LACP is needed
- [ ] Evaluate storage classes for Kubernetes, LXC, and Docker volume needs
- [ ] Export Grafana dashboards as JSON into `configs/` for GitOps tracking
- [ ] Implement automated ZFS snapshot pruning policy
- [ ] Add Renovate / Dependabot for container image version tracking
- [ ] Finalize MkDocs nav to reflect all new `docs/` content

---

## 🙋 Maintainer

<div align="center">

**Joe Casnellie** · [@jcasnellie69](https://github.com/jcasnellie69)

📖 [Docs Site](https://jcasnellie69.github.io/homelab-config) &nbsp;|&nbsp; 🗂 [Artifacts](artifacts/hc/) &nbsp;|&nbsp; 🤝 [Contributing](CONTRIBUTING.md)

_Last updated: April 2026_

</div>

