# Observability Policy
#-------------------------------------------------------------------------------
# DATE       | CHGID   | REASON
# 2025-12-10 | CR-0021 | Establish governance for telemetry agents, exporters,
#                      | and data flow in homelab observability stack.
# USER: JC  | TARGET: Homelab Observability
#-------------------------------------------------------------------------------

## Policy Summary

1. CT105 is the canonical telemetry hub  
   - Runs InfluxDB and the primary Telegraf agent.  
   - Only CT105 Telegraf may send metrics to InfluxDB.

2. Telegraf placement  
   - Telegraf services in other containers must be disabled, unless:  
     - documented in this policy, and  
     - required for a source that cannot expose logs or HTTP endpoints.

3. Exporter behavior  
   - Prefer pull-based ingestion (CT105 Telegraf calling APIs).  
   - Use bind-mounted logs where appropriate.  
   - Avoid unnecessary multi-hop chains of exporters.

4. Documentation requirements  
   - New telemetry sources must update:
     - observability-service-map.md  
     - telemetry-pipeline.md  
     - this policy file (if rules change)

5. Health-check evidence  
   - After changes to telemetry roles, run:
     - ~/homelab-config/scripts/hc/pve-lxc-systemd-scan.sh  
   - Store artifacts under:
     - /srv/artifacts/hc-lxc-systemd/
