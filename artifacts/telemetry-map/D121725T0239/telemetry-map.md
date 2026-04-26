# Telemetry Map

Source: `/srv/artifacts/telemetry-map/D121725T0239`

## Containers
```
100,netbox,
[1mNetBox LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mnetbox[m
    💡  [m[33m IP Address: [1;92m192.168.4.140[m
192.168.4.140
102,grafana,
[1mGrafana LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mgrafana[m
    💡  [m[33m IP Address: [1;92m192.168.4.129[m
192.168.4.129
103,prometheus,
[1mPrometheus LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mprometheus[m
    💡  [m[33m IP Address: [1;92m192.168.4.132[m
192.168.4.132
104,prometheus-pve-exporter,
[1mPrometheus-PVE-Exporter LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mprometheus-pve-exporter[m
    💡  [m[33m IP Address: [1;92m192.168.4.131[m
192.168.4.131
105,influxdb,
[1mInfluxDB LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92minfluxdb[m
    💡  [m[33m IP Address: [1;92m192.168.4.130[m
192.168.4.130
109,pihole,
[1mPihole LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mpihole[m
    💡  [m[33m IP Address: [1;92m192.168.4.208[m
192.168.4.208
```

## Catchers (listeners: who is receiving)

### listeners-100-netbox.txt
```

tcp LISTEN 0 100 127.0.0.1:25 0.0.0.0:*
tcp LISTEN 0 200 127.0.0.1:5432 0.0.0.0:*
tcp LISTEN 0 4096 127.0.0.1:12345 0.0.0.0:*
tcp LISTEN 0 4096 127.0.0.1:8125 0.0.0.0:*
tcp LISTEN 0 511 127.0.0.1:6379 0.0.0.0:*
tcp LISTEN 0 4096 0.0.0.0:19999 0.0.0.0:*
tcp LISTEN 0 100 [::1]:25 [::]:*
tcp LISTEN 0 4096 *:8080 *:*
tcp LISTEN 0 511 *:443 *:*
tcp LISTEN 0 511 *:80 *:*
tcp LISTEN 0 4096 *:22 *:*
tcp LISTEN 0 1024 *:8443 *:*
tcp LISTEN 0 4096 *:9080 *:*
tcp LISTEN 0 4096 *:9095 *:*
tcp LISTEN 0 4096 *:9100 *:*
tcp LISTEN 0 511 [::1]:6379 [::]:*
tcp LISTEN 0 4096 [::1]:8125 [::]:*
tcp LISTEN 0 200 [::1]:5432 [::]:*
tcp LISTEN 0 4096 [::]:19999 [::]:*
```

### listeners-102-grafana.txt
```

tcp LISTEN 0 100 127.0.0.1:25 0.0.0.0:*
tcp LISTEN 0 511 0.0.0.0:8680 0.0.0.0:*
tcp LISTEN 0 100 [::1]:25 [::]:*
tcp LISTEN 0 4096 *:3000 *:*
tcp LISTEN 0 4096 *:3100 *:*
tcp LISTEN 0 4096 *:9095 *:*
tcp LISTEN 0 4096 *:9096 *:*
tcp LISTEN 0 4096 *:9100 *:*
tcp LISTEN 0 4096 *:9080 *:*
tcp LISTEN 0 4096 *:22 *:*
```

### listeners-103-prometheus.txt
```

tcp LISTEN 0 100 127.0.0.1:25 0.0.0.0:*
tcp LISTEN 0 4096 *:8080 *:*
tcp LISTEN 0 100 [::1]:25 [::]:*
tcp LISTEN 0 4096 *:9090 *:*
tcp LISTEN 0 4096 *:9100 *:*
tcp LISTEN 0 4096 *:22 *:*
```

### listeners-104-prometheus-pve-exporter.txt
```

tcp LISTEN 0 2048 0.0.0.0:9221 0.0.0.0:*
tcp LISTEN 0 100 127.0.0.1:25 0.0.0.0:*
tcp LISTEN 0 100 [::1]:25 [::]:*
tcp LISTEN 0 4096 *:9100 *:*
tcp LISTEN 0 4096 *:22 *:*
```

### listeners-105-influxdb.txt
```

tcp LISTEN 0 100 127.0.0.1:25 0.0.0.0:*
tcp LISTEN 0 511 0.0.0.0:8680 0.0.0.0:*
tcp LISTEN 0 4096 *:8086 *:*
tcp LISTEN 0 4096 *:8081 *:*
tcp LISTEN 0 4096 *:7946 *:*
tcp LISTEN 0 4096 *:9095 *:*
tcp LISTEN 0 4096 *:9100 *:*
tcp LISTEN 0 4096 *:9096 *:*
tcp LISTEN 0 4096 *:9080 *:*
tcp LISTEN 0 4096 *:22 *:*
tcp LISTEN 0 4096 *:3100 *:*
tcp LISTEN 0 100 [::1]:25 [::]:*
```

### listeners-109-pihole.txt
```

tcp LISTEN 0 128 127.0.0.1:4317 0.0.0.0:*
tcp LISTEN 0 32 0.0.0.0:53 0.0.0.0:*
tcp LISTEN 0 200 0.0.0.0:80 0.0.0.0:*
tcp LISTEN 0 200 0.0.0.0:443 0.0.0.0:*
tcp LISTEN 0 4096 0.0.0.0:19999 0.0.0.0:*
tcp LISTEN 0 4096 127.0.0.1:8125 0.0.0.0:*
tcp LISTEN 0 100 127.0.0.1:25 0.0.0.0:*
tcp LISTEN 0 32 [::]:53 [::]:*
tcp LISTEN 0 4096 *:22 *:*
tcp LISTEN 0 200 [::]:80 [::]:*
tcp LISTEN 0 200 [::]:443 [::]:*
tcp LISTEN 0 4096 [::1]:8125 [::]:*
tcp LISTEN 0 4096 [::]:19999 [::]:*
tcp LISTEN 0 100 [::1]:25 [::]:*
```


## Pitchers (edges: who is pushing/scraping where)

### edges-100-netbox.txt
```
<<<<<<< HEAD
# CT 100 (netbox)
=======
# CT 100 (netbox)
>>>>>>> origin/main
[1mNetBox LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mnetbox[m
    💡  [m[33m IP Address: [1;92m192.168.4.140[m
192.168.4.140

## Telegraf -> outputs (push destinations)

[1mNetBox LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mnetbox[m
    💡  [m[33m IP Address: [1;92m192.168.4.140[m
<<<<<<< HEAD
/etc/telegraf/telegraf.conf:115:[[outputs.influxdb_v2]]
=======
/etc/telegraf/telegraf.conf:115:[[outputs.influxdb_v2]]
>>>>>>> origin/main
/etc/telegraf/telegraf.conf:116:  urls = ["$INFLUX_HOST"]

## Prometheus -> scrape targets (pull sources)

[1mNetBox LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mnetbox[m
    💡  [m[33m IP Address: [1;92m192.168.4.140[m

## Promtail -> Loki clients (push)

[1mNetBox LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mnetbox[m
    💡  [m[33m IP Address: [1;92m192.168.4.140[m
/etc/promtail/config.yml:5:clients:
/etc/promtail/config.yml:6:  - url: http://192.168.7.116:3100/loki/api/v1/push
/etc/promtail/config.yml:5:clients:
/etc/promtail/config.yml:6:  - url: http://192.168.7.116:3100/loki/api/v1/push

## Loki listen ports (sanity if Loki exists here)

[1mNetBox LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mnetbox[m
    💡  [m[33m IP Address: [1;92m192.168.4.140[m
/etc/loki/config.yml:5:  http_listen_port: 3100
/etc/loki/config.yml:6:  grpc_listen_port: 9095
/etc/loki/config.yml:5:  http_listen_port: 3100
/etc/loki/config.yml:6:  grpc_listen_port: 9095
```

### edges-102-grafana.txt
```
<<<<<<< HEAD
# CT 102 (grafana)
=======
# CT 102 (grafana)
>>>>>>> origin/main
[1mGrafana LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mgrafana[m
    💡  [m[33m IP Address: [1;92m192.168.4.129[m
192.168.4.129

## Telegraf -> outputs (push destinations)

[1mGrafana LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mgrafana[m
    💡  [m[33m IP Address: [1;92m192.168.4.129[m

## Prometheus -> scrape targets (pull sources)

[1mGrafana LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mgrafana[m
    💡  [m[33m IP Address: [1;92m192.168.4.129[m

## Promtail -> Loki clients (push)

[1mGrafana LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mgrafana[m
    💡  [m[33m IP Address: [1;92m192.168.4.129[m
/etc/promtail/config.yml:5:clients:
/etc/promtail/config.yml:6:  - url: http://192.168.7.116:3100/loki/api/v1/push
/etc/promtail/config.yml:5:clients:
/etc/promtail/config.yml:6:  - url: http://192.168.7.116:3100/loki/api/v1/push

## Loki listen ports (sanity if Loki exists here)

[1mGrafana LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mgrafana[m
    💡  [m[33m IP Address: [1;92m192.168.4.129[m
/etc/loki/config.yml:3:  http_listen_port: 3100
/etc/loki/config.yml:4:  grpc_listen_port: 9096
/etc/loki/config.yml:3:  http_listen_port: 3100
/etc/loki/config.yml:4:  grpc_listen_port: 9096
```

### edges-103-prometheus.txt
```
<<<<<<< HEAD
# CT 103 (prometheus)
=======
# CT 103 (prometheus)
>>>>>>> origin/main
[1mPrometheus LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mprometheus[m
    💡  [m[33m IP Address: [1;92m192.168.4.132[m
192.168.4.132

## Telegraf -> outputs (push destinations)

[1mPrometheus LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mprometheus[m
    💡  [m[33m IP Address: [1;92m192.168.4.132[m
/etc/telegraf/telegraf.d/prom.conf:5:  urls = [
/etc/telegraf/telegraf.d/prom.conf:17:[[outputs.influxdb_v2]]
/etc/telegraf/telegraf.d/prom.conf:18:  urls         = ["${INFLUX_URL}"]

## Prometheus -> scrape targets (pull sources)

[1mPrometheus LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mprometheus[m
    💡  [m[33m IP Address: [1;92m192.168.4.132[m
/etc/prometheus/prometheus.yml:5:scrape_configs:
/etc/prometheus/prometheus.yml:6:  - job_name: prometheus
/etc/prometheus/prometheus.yml:8:      - targets: ['192.168.7.114:9090']
/etc/prometheus/prometheus.yml:12:  - job_name: node-exporter
/etc/prometheus/prometheus.yml:5:scrape_configs:
/etc/prometheus/prometheus.yml:6:  - job_name: prometheus
/etc/prometheus/prometheus.yml:8:      - targets: ['192.168.7.114:9090']
/etc/prometheus/prometheus.yml:12:  - job_name: node-exporter

## Promtail -> Loki clients (push)

[1mPrometheus LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mprometheus[m
    💡  [m[33m IP Address: [1;92m192.168.4.132[m

## Loki listen ports (sanity if Loki exists here)

[1mPrometheus LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mprometheus[m
    💡  [m[33m IP Address: [1;92m192.168.4.132[m
```

### edges-104-prometheus-pve-exporter.txt
```
<<<<<<< HEAD
# CT 104 (prometheus-pve-exporter)
=======
# CT 104 (prometheus-pve-exporter)
>>>>>>> origin/main
[1mPrometheus-PVE-Exporter LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mprometheus-pve-exporter[m
    💡  [m[33m IP Address: [1;92m192.168.4.131[m
192.168.4.131

## Telegraf -> outputs (push destinations)

[1mPrometheus-PVE-Exporter LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mprometheus-pve-exporter[m
    💡  [m[33m IP Address: [1;92m192.168.4.131[m

## Prometheus -> scrape targets (pull sources)

[1mPrometheus-PVE-Exporter LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mprometheus-pve-exporter[m
    💡  [m[33m IP Address: [1;92m192.168.4.131[m

## Promtail -> Loki clients (push)

[1mPrometheus-PVE-Exporter LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mprometheus-pve-exporter[m
    💡  [m[33m IP Address: [1;92m192.168.4.131[m

## Loki listen ports (sanity if Loki exists here)

[1mPrometheus-PVE-Exporter LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mprometheus-pve-exporter[m
    💡  [m[33m IP Address: [1;92m192.168.4.131[m
```

### edges-105-influxdb.txt
```
<<<<<<< HEAD
# CT 105 (influxdb)
=======
# CT 105 (influxdb)
>>>>>>> origin/main
[1mInfluxDB LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92minfluxdb[m
    💡  [m[33m IP Address: [1;92m192.168.4.130[m
192.168.4.130

## Telegraf -> outputs (push destinations)

[1mInfluxDB LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92minfluxdb[m
    💡  [m[33m IP Address: [1;92m192.168.4.130[m
/etc/telegraf/telegraf.conf:45:[[outputs.influxdb_v2]]
/etc/telegraf/telegraf.conf:47:  urls = ["$INFLUX_HOST"]
/etc/telegraf/telegraf.d/netflow_input.conf:10:[[outputs.influxdb_v2]]
/etc/telegraf/telegraf.d/netflow_input.conf:12: urls = ["$INFLUX_HOST"]
/etc/telegraf/telegraf.d/system.conf:62:  [[outputs.influxdb_v2]]
/etc/telegraf/telegraf.d/system.conf:64:  urls = ["$INFLUX_HOST"]
/etc/telegraf/telegraf.d/timewarp_traffic.conf:73:[[outputs.influxdb_v2]]
/etc/telegraf/telegraf.d/timewarp_traffic.conf:74:  urls = ["$INFLUX_HOST"]

## Prometheus -> scrape targets (pull sources)

[1mInfluxDB LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92minfluxdb[m
    💡  [m[33m IP Address: [1;92m192.168.4.130[m

## Promtail -> Loki clients (push)

[1mInfluxDB LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92minfluxdb[m
    💡  [m[33m IP Address: [1;92m192.168.4.130[m
/etc/promtail/config.yml:5:clients:
/etc/promtail/config.yml:6:  - url: http://192.168.7.116:3100/loki/api/v1/push
/etc/promtail/config.yml:5:clients:
/etc/promtail/config.yml:6:  - url: http://192.168.7.116:3100/loki/api/v1/push

## Loki listen ports (sanity if Loki exists here)

[1mInfluxDB LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92minfluxdb[m
    💡  [m[33m IP Address: [1;92m192.168.4.130[m
/etc/loki/config.yml:5:  http_listen_port: 3100
/etc/loki/config.yml:6:  grpc_listen_port: 9096
/etc/loki/config.yml:5:  http_listen_port: 3100
/etc/loki/config.yml:6:  grpc_listen_port: 9096
/etc/loki/loki-config.yaml:4:  http_listen_port: 3100
```

### edges-109-pihole.txt
```
<<<<<<< HEAD
# CT 109 (pihole)
=======
# CT 109 (pihole)
>>>>>>> origin/main
[1mPihole LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mpihole[m
    💡  [m[33m IP Address: [1;92m192.168.4.208[m
192.168.4.208

## Telegraf -> outputs (push destinations)

[1mPihole LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mpihole[m
    💡  [m[33m IP Address: [1;92m192.168.4.208[m

## Prometheus -> scrape targets (pull sources)

[1mPihole LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mpihole[m
    💡  [m[33m IP Address: [1;92m192.168.4.208[m

## Promtail -> Loki clients (push)

[1mPihole LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mpihole[m
    💡  [m[33m IP Address: [1;92m192.168.4.208[m

## Loki listen ports (sanity if Loki exists here)

[1mPihole LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mpihole[m
    💡  [m[33m IP Address: [1;92m192.168.4.208[m
```
<<<<<<< HEAD
=======

>>>>>>> origin/main
