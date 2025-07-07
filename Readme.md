 Homelab ZFS Pool: tank0

Overview

tank0 is the main ZFS storage pool for the homelab environment. This pool is designed with redundancy, tiered storage, and container hosting in mind. It supports a structured file layout across multiple tech domains and provides optimized datasets for Docker volumes, configuration backups, media storage, and monitored workloads.

Pool Layout

Pool Name: tank0

Redundancy: Mirrored vdevs (RAID1 equivalent)

Tiering Strategy:

SSDs for higher IO/latency-sensitive workloads

HDDs for media and archive storage

External USBs for backup tiers (cold/immutable copy)

Devices

Device

Type

Model

Capacity

Role

nvme1n1

SSD

CT2000P310SSD8

2 TB

Primary high-speed

nvme2n1

SSD

WD Blue SN5000 2

2 TB

Mirror for nvme1n1

sda

HDD

WDC WD20PURX

2 TB

Media/archive tier

sdc

SSD

CT2000BX500SSD1

2 TB

General use / staging

sdb

HDD

ST1000VX001

1 TB

Boot (Linux)

nvme0n1

SSD

AirDisk 1TB SSD

1 TB

ZFS cold spare

Dataset Layout

Datasets are organized by function and domain alignment.

/opt/
├── baseOS
├── business
├── infra/
│   ├── application
│   ├── automation
│   ├── development
│   ├── language
│   ├── network
│   ├── observability
│   ├── output
│   ├── security
│   ├── storage
│   ├── utility
│   ├── virtualization
│   └── web
└── user/
    ├── configs
    └── ux

/srv/
└── shares

/var/lib/docker/volumes -> tank0/docker-volumes

Backup Strategy

Snapshots: Enabled on key datasets (automation, configs, storage, business)

External USBs: Used for immutable ZFS send/receive backups

Tiered Data Handling: CCTV (Tapo) & low-priority content moved to HDDs

Monitoring (KPIs)

Performance of tank0 is tracked via:

zpool iostat for latency, queue depth

iostat for device-level throughput

Grafana dashboards (hosted via container) for live metrics

Key Metrics:

Mirror IO balancing behavior

Write latency spikes

Snapshot storage growth

Disk temperature & SMART status

GitOps Integration

Git repo initialized under ~/homelab-config/ for:

Mount point definitions

Post-install scripts

Container orchestration

Monitoring dashboards

Inventory & system audit info

Next Steps

Update /etc/fstab if required (ZFS mountpoints typically managed by zfs-mount)

Document NIC layout and assess whether bonding is needed

Evaluate storage classes for k8s, LXC, and Docker needs

Finalize and add structured documentation to ~/homelab-config repo

UML (Planned)

A diagram is planned to visually represent:

Physical devices (with model info)

vdev layout

Dataset structure

Backup flows

(To be generated in PNG and `` formats)

Maintained by: Joe Casnellie Last updated: July 2025

