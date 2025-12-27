# Netify Configuration Matrix (Settings & Defaults)
#-------------------------------------------------------------------------------
# DATE       | CHGID   | REASON
# 2025-12-11 | CR-0025 | Capture netifyd.conf / JSON settings vs vendor defaults
#                      | to manage a correct, repeatable Netify config.
# USER: JC   | TARGET: PVE Host (netifyd)
#-------------------------------------------------------------------------------

This matrix defines the **golden configuration** for Netify on the PVE host.

It maps:
- **Vendor defaults** → **Our chosen values**
- The **reason** we override (or keep) each setting
- What the **HC scripts should assert** on each run

The goal is: *no ambiguity* when re-installing, auditing, or debugging Netify.

---

## 1. Core Identity & API Behaviour

| Setting           | File / Section               | Vendor Default                 | Our Value / Target                         | Reason / Policy                                                 | HC Check                                         |
|-------------------|-----------------------------|--------------------------------|--------------------------------------------|------------------------------------------------------------------|--------------------------------------------------|
| `site_uuid`       | `/etc/netifyd/netifyd.conf` | *Unset → auto-generated*       | **Pinned UUID** (e.g. `47de4c87_...`)      | Stable identity for DPI site; avoids surprise re-enrollment.     | Value matches documented UUID in registry.       |
| `agent_uuid`      | auto / `netifyd -s`         | Auto-generated                 | Accept vendor default                      | OK for agent to be unique per host instance.                     | Present and consistent across restarts.          |
| `site_name`       | `/etc/netifyd/netifyd.conf` | Derived / generic              | `pve-netify` (or homelab naming standard)  | Human-friendly; used in dashboards / evidence.                   | Matches naming convention in docs.               |
| `api_url`         | `/etc/netifyd/netifyd.conf` | Netify cloud URL               | Vendor default (unless self-hosted later)  | Keep vendor endpoint stable unless we move to on-prem.           | Reachable and consistent with docs.              |
| `api_updates` / `enable_api_updates` | `netifyd.conf` | **Enabled**                    | **Disabled**                                | No surprise config drifts from cloud; change control enforced.   | HC checks value is explicitly `false/0`.         |
| `log_level`       | `netifyd.conf`              | `info`                         | `info` (or `notice`)                       | Default is fine; debug only for short troubleshooting windows.   | Not left at `debug` in steady state.            |

---

## 2. Capture Behaviour & Interfaces

| Setting              | File / Section           | Vendor Default         | Our Value / Target                | Reason / Policy                                           | HC Check                                           |
|----------------------|--------------------------|------------------------|-----------------------------------|----------------------------------------------------------|----------------------------------------------------|
| `capture_iface`      | `netifyd.conf`          | First active interface | `vmbr0` (or bond used for LAN)    | Ensure DPI sees LAN traffic, not just WAN/NIC artifact.  | HC verifies iface in config = expected bridge.     |
| `promiscuous_mode`   | implied / kernel flags  | Enabled when needed    | Enabled                           | Required for seeing flows on bridge.                     | NIC flags on vmbr0 show `PROMISC`.                 |
| `dns_cache_enable`   | `netifyd.conf`          | Enabled                | Enabled                           | DNS cache helps App/Domain classification.               | HC checks key set and non-zero cache size.         |
| `flow_timeout`       | `netifyd.conf`          | Vendor default (e.g. 60s/300s) | Keep default                     | Fine for home–scale; tune only if SMF-style analysis needs. | Optionally log current value for trend.            |
| `include_localhost`  | `netifyd.conf`          | Often disabled         | Disabled                          | We care about LAN traffic, not PVE localhost chatter.    | HC asserts value = disabled.                       |

---

## 3. Sinks & Pipelines (Logs → Artifacts → Influx)

| Setting / Component     | File / Section                      | Vendor Default                  | Our Value / Target                                      | Reason / Policy                                                     | HC Check                                                  |
|-------------------------|--------------------------------------|---------------------------------|---------------------------------------------------------|---------------------------------------------------------------------|-----------------------------------------------------------|
| `sink-log`              | `netifyd.conf`                      | Sometimes off or minimal        | **Enabled**                                              | We want durable flat files under `/var/log/netifyd/`.               | Files rotate correctly and are non-empty.                |
| `sink-log path`         | `netifyd.conf`                      | `/var/log/netifyd/`             | `/var/log/netifyd/`                                     | Use standard path; easy to bind-mount into CT105.                   | HC checks directory exists and writable.                 |
| `sink-log rotate`       | `netifyd.conf`                      | Vendor default (size/time)      | Keep default → enforce logrotate.d if needed            | Avoid custom behaviour unless log volume becomes a problem.         | HC checks for `/etc/logrotate.d/netifyd` presence.       |
| `sink-http`             | `netifyd.conf`                      | Might be enabled to cloud       | **Disabled (for now)**                                  | We are not posting flows to external HTTP API yet.                  | HC confirms sink-http disabled.                          |
| `sink-files` / exports  | `netifyd.conf` or separate config   | Off                             | Optional, for structured JSON if we later want it       | Future: structured exports for Splunk/Influx direct ingestion.      | HC reports if any sink-files are configured.             |
| `/srv/artifacts` bind   | PVE mount + `netifyd` log location  | N/A                             | `/var/log/netifyd` → `/srv/artifacts/netify-logs/`      | Evidence and HC artifacts share one, read-only view of Netify logs. | HC verifies mount entry and path readability in CT105.   |

---

## 4. Performance / DPI Settings

| Setting                | File / Section           | Vendor Default          | Our Value / Target                    | Reason / Policy                                                 | HC Check                                     |
|------------------------|--------------------------|-------------------------|---------------------------------------|------------------------------------------------------------------|----------------------------------------------|
| `dpi_enable`           | `netifyd.conf`           | Enabled                 | Enabled                               | DPI is the whole point; never turn off in steady state.         | HC ensures not disabled.                     |
| `classification_depth` | `netifyd.conf` / JSON    | Vendor default          | Default with occasional tuning        | Deeper classification has CPU cost; OK on current PVE host.     | Optional: log CPU vs DPI stats from `netifyd -s`. |
| `flow_limit`           | `netifyd.conf`           | Vendor default          | Default                               | Home network unlikely to hit vendor limits.                     | Optional: alert if near flow limit.          |
| `threading/workers`    | `netifyd.conf`           | Auto                    | Auto                                  | Let Netify size workers; revisit if CPU contention observed.    | HC: capture `netifyd -s` and store for review. |

---

## 5. Change Control & Registry Linkage

This matrix is meant to be kept in sync with:

- `docs/netify-config-changelog.md`  
  → human-readable, evidence-grade record of *when* changes were made.  
- Any future HC script:
  - `scripts/hc/hc-netify-config-check.sh`
  - Which will:
    - Parse `netifyd.conf`
    - Compare to “Our Value / Target”
    - Emit a **PASS / WARN / FAIL** per row above
    - Update the changelog when it detects a real config delta.

**Rule:**  
If a Netify setting differs from this matrix, either:

1. Update the **config** back to match the matrix, or  
2. Intentionally change policy:
   - Update this matrix (with a new CHGID row)
   - Update `netify-config-changelog.md`
   - Re-run HC and capture the new state in `/srv/artifacts`.

