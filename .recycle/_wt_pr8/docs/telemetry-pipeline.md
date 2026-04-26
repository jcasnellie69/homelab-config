# Telemetry Pipeline Architecture
#-------------------------------------------------------------------------------
# DATE       | CHGID   | REASON
# 2025-12-10 | CR-0021 | Formalize observability pipeline for Netify, Netflow,
#                      | and Pi-hole flows → Influx via CT105 Telegraf.
# USER: JC  | TARGET: Homelab Telemetry
#-------------------------------------------------------------------------------

This document defines the end-to-end telemetry pipeline for the homelab.

Telemetry overview:

    PVE Host (netifyd DPI)
           |
      bind-mount logs
           v
    CT105 (InfluxDB + Telegraf)
       ^                 ^
       |                 |
  HTTP API          stats/files
       |                 |
    CT109              CT110
   (Pi-hole)        (Netflow/nfdump)

---

## Data Inputs

### Netify DPI (Host)
- Source: /var/log/netifyd/*
- Transport: bind-mounted into CT105
- Telegraf plugin: inputs.tail

### Netflow (CT110)
- Source: nfdump statistics/flows
- Transport: stats file or nfdump exec output made visible to CT105
- Telegraf plugin: inputs.exec or inputs.tail

### Pi-hole (CT109)
Two supported ingestion methods:

1. API metrics  
   - Endpoint: http://<pihole>/admin/api.php?summaryRaw&auth=TOKEN  
   - Telegraf plugin: inputs.http  

2. DNS query logs  
   - Source: /var/log/pihole.log (or FTL log)  
   - Transport: bind-mounted into CT105  
   - Telegraf plugin: inputs.tail  

---

## Design Rules

- CT105 is the canonical telemetry hub (InfluxDB + Telegraf).
- Other containers expose logs or HTTP APIs; they do not write directly to InfluxDB.
- New sources must document:
  - origin container
  - transport method
  - Telegraf input plugin
  - measurement/tag scheme

