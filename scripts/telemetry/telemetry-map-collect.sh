#!/usr/bin/env bash
set -euo pipefail

DIR="${1:-/srv/artifacts/telemetry-map/D$(date +%m%d%yT%H%M)}"
mkdir -p "$DIR"

echo "Writing to: $DIR"

# Index containers (CT only)
{
  echo "CT,NAME,IP"
  for CT in $(pct list | awk 'NR>1{print $1}' | sort -n); do
    NAME="$(pct exec "$CT" -- hostname 2>/dev/null | head -n1 || true)"
    IP="$(pct exec "$CT" -- bash -lc "ip -4 -o addr show scope global | awk '{print \$4}' | cut -d/ -f1 | head -n1" 2>/dev/null || true)"
    echo "${CT},${NAME:-unknown},${IP:-unknown}"
  done
} > "$DIR/ct-index.csv"

# Listeners (catchers)
for CT in $(pct list | awk 'NR>1{print $1}' | sort -n); do
  OUT="$DIR/listeners-${CT}.txt"
  pct exec "$CT" -- bash -lc '
    set -euo pipefail
    echo "# CT '"$CT"' ($(hostname))"
    date
    echo
    ss -lntp || true
  ' > "$OUT" 2>&1 || true
done

# Edges (pitchers) - capture the “who is pushing to where” from common configs
for CT in $(pct list | awk 'NR>1{print $1}' | sort -n); do
  OUT="$DIR/edges-${CT}.txt"
  pct exec "$CT" -- bash -lc '
    set -euo pipefail
    echo "# CT '"$CT"' ($(hostname))"
    date
    echo

    # Promtail → Loki
    if [[ -f /etc/promtail/config.yml ]]; then
      echo "## /etc/promtail/config.yml"
      grep -nE "url:|loki/api/v1/push|client:" /etc/promtail/config.yml || true
      echo
    fi

    # Prometheus scrape targets
    if [[ -f /etc/prometheus/prometheus.yml ]]; then
      echo "## /etc/prometheus/prometheus.yml"
      grep -nE "job_name:|targets:" /etc/prometheus/prometheus.yml || true
      echo
    fi

    # Telegraf outputs
    if [[ -f /etc/telegraf/telegraf.conf ]]; then
      echo "## /etc/telegraf/telegraf.conf (outputs)"
      grep -nE "outputs\.influxdb_v2|urls =|url =|token|organization|bucket" /etc/telegraf/telegraf.conf || true
      echo
    fi
    if compgen -G "/etc/telegraf/telegraf.d/*.conf" > /dev/null; then
      echo "## /etc/telegraf/telegraf.d/*.conf (outputs)"
      grep -RInE "outputs\.influxdb_v2|urls =|url =|token|organization|bucket" /etc/telegraf/telegraf.d/*.conf 2>/dev/null || true
      echo
    fi
  ' > "$OUT" 2>&1 || true
done

echo "Wrote: $DIR/ct-index.csv"
echo "Wrote: $DIR/listeners-*.txt"
echo "Wrote: $DIR/edges-*.txt"
