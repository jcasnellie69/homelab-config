# Homelab Documentation Index

#-------------------------------------------------------------------------------
# DATE       | CHGID   | REASON
# 2025-12-10 | CR-0021 | Create documentation index for observability files.
# USER: JC  | TARGET: Homelab Documentation
#-------------------------------------------------------------------------------

Welcome to the homelab documentation index.

This directory contains architecture, observability, and policy documentation
for the Proxmox VE + LXC infrastructure.

---

## Documents

1. Orchestration Source of Truth
   Defines the evidence-first onboarding method for new technology, MCPs, agents, tasks, and infrastructure capabilities.
   - File: orchestration.md

2. Observability Service Map
   Describes which observability services run on which nodes/containers.
   - File: observability-service-map.md

3. Telemetry Pipeline Architecture
   Describes the Netify / Netflow / Pi-hole telemetry path into Influx via CT105.
   - File: telemetry-pipeline.md

4. Observability Policy
   Defines governance for exporters, Telegraf placement, and pipeline integrity.
   - File: policy-observability.md

---

## Purpose of docs/

The docs/ directory is the single source of truth for:

- Service placement
- Telemetry and logging pipelines
- Design and architecture decisions
- Orchestration and onboarding methods
- Evidence-friendly documentation to pair with HC artifacts
