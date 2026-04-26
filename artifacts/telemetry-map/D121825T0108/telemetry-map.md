# Telemetry Map

Source: `/srv/artifacts/telemetry-map/D121825T0108`

## Containers
```
CT,NAME,IP
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
106,homepage,
[1mHomepage LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mhomepage[m
    💡  [m[33m IP Address: [1;92m192.168.4.139[m
192.168.4.139
108,unknown,unknown
109,pihole,
[1mPihole LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mpihole[m
    💡  [m[33m IP Address: [1;92m192.168.4.208[m
192.168.4.208
110,unknown,unknown
111,unknown,unknown
```

## Catchers (listeners: who is receiving)

### listeners-100.txt
```

<<<<<<< HEAD
LISTEN 0      100        127.0.0.1:25         0.0.0.0:*
LISTEN 0      200        127.0.0.1:5432       0.0.0.0:*
LISTEN 0      4096       127.0.0.1:12345      0.0.0.0:*
LISTEN 0      4096       127.0.0.1:8125       0.0.0.0:*
LISTEN 0      511        127.0.0.1:6379       0.0.0.0:*
LISTEN 0      4096         0.0.0.0:19999      0.0.0.0:*
LISTEN 0      100            [::1]:25            [::]:*
LISTEN 0      4096               *:8080             *:*
LISTEN 0      511                *:443              *:*
LISTEN 0      511                *:80               *:*
LISTEN 0      4096               *:22               *:*
LISTEN 0      1024               *:8443             *:*
LISTEN 0      4096               *:9080             *:*
LISTEN 0      4096               *:9095             *:*
LISTEN 0      4096               *:9100             *:*
LISTEN 0      511            [::1]:6379          [::]:*
LISTEN 0      4096           [::1]:8125          [::]:*
LISTEN 0      200            [::1]:5432          [::]:*
LISTEN 0      4096            [::]:19999         [::]:*
=======
LISTEN 0      100        127.0.0.1:25         0.0.0.0:*
LISTEN 0      200        127.0.0.1:5432       0.0.0.0:*
LISTEN 0      4096       127.0.0.1:12345      0.0.0.0:*
LISTEN 0      4096       127.0.0.1:8125       0.0.0.0:*
LISTEN 0      511        127.0.0.1:6379       0.0.0.0:*
LISTEN 0      4096         0.0.0.0:19999      0.0.0.0:*
LISTEN 0      100            [::1]:25            [::]:*
LISTEN 0      4096               *:8080             *:*
LISTEN 0      511                *:443              *:*
LISTEN 0      511                *:80               *:*
LISTEN 0      4096               *:22               *:*
LISTEN 0      1024               *:8443             *:*
LISTEN 0      4096               *:9080             *:*
LISTEN 0      4096               *:9095             *:*
LISTEN 0      4096               *:9100             *:*
LISTEN 0      511            [::1]:6379          [::]:*
LISTEN 0      4096           [::1]:8125          [::]:*
LISTEN 0      200            [::1]:5432          [::]:*
LISTEN 0      4096            [::]:19999         [::]:*
>>>>>>> origin/main
```

### listeners-102.txt
```

<<<<<<< HEAD
LISTEN 0      100        127.0.0.1:25        0.0.0.0:*
LISTEN 0      511          0.0.0.0:8680      0.0.0.0:*
LISTEN 0      100            [::1]:25           [::]:*
LISTEN 0      4096               *:3000            *:*
LISTEN 0      4096               *:3100            *:*
LISTEN 0      4096               *:9095            *:*
LISTEN 0      4096               *:9096            *:*
LISTEN 0      4096               *:9100            *:*
LISTEN 0      4096               *:9080            *:*
LISTEN 0      4096               *:22              *:*
=======
LISTEN 0      100        127.0.0.1:25        0.0.0.0:*
LISTEN 0      511          0.0.0.0:8680      0.0.0.0:*
LISTEN 0      100            [::1]:25           [::]:*
LISTEN 0      4096               *:3000            *:*
LISTEN 0      4096               *:3100            *:*
LISTEN 0      4096               *:9095            *:*
LISTEN 0      4096               *:9096            *:*
LISTEN 0      4096               *:9100            *:*
LISTEN 0      4096               *:9080            *:*
LISTEN 0      4096               *:22              *:*
>>>>>>> origin/main
```

### listeners-103.txt
```

<<<<<<< HEAD
LISTEN 0      100        127.0.0.1:25        0.0.0.0:*
LISTEN 0      4096               *:8080            *:*
LISTEN 0      100            [::1]:25           [::]:*
LISTEN 0      4096               *:9090            *:*
LISTEN 0      4096               *:9100            *:*
LISTEN 0      4096               *:22              *:*
=======
LISTEN 0      100        127.0.0.1:25        0.0.0.0:*
LISTEN 0      4096               *:8080            *:*
LISTEN 0      100            [::1]:25           [::]:*
LISTEN 0      4096               *:9090            *:*
LISTEN 0      4096               *:9100            *:*
LISTEN 0      4096               *:22              *:*
>>>>>>> origin/main
```

### listeners-104.txt
```

<<<<<<< HEAD
LISTEN 0      2048         0.0.0.0:9221      0.0.0.0:*
LISTEN 0      100        127.0.0.1:25        0.0.0.0:*
LISTEN 0      100            [::1]:25           [::]:*
LISTEN 0      4096               *:9100            *:*
LISTEN 0      4096               *:22              *:*
=======
LISTEN 0      2048         0.0.0.0:9221      0.0.0.0:*
LISTEN 0      100        127.0.0.1:25        0.0.0.0:*
LISTEN 0      100            [::1]:25           [::]:*
LISTEN 0      4096               *:9100            *:*
LISTEN 0      4096               *:22              *:*
>>>>>>> origin/main
```

### listeners-105.txt
```

<<<<<<< HEAD
LISTEN 0      100        127.0.0.1:25        0.0.0.0:*
LISTEN 0      511          0.0.0.0:8680      0.0.0.0:*
LISTEN 0      4096               *:8086            *:*
LISTEN 0      4096               *:8081            *:*
LISTEN 0      4096               *:7946            *:*
LISTEN 0      4096               *:9095            *:*
LISTEN 0      4096               *:9100            *:*
LISTEN 0      4096               *:9096            *:*
LISTEN 0      4096               *:9080            *:*
LISTEN 0      4096               *:22              *:*
LISTEN 0      4096               *:3100            *:*
LISTEN 0      100            [::1]:25           [::]:*
=======
LISTEN 0      100        127.0.0.1:25        0.0.0.0:*
LISTEN 0      511          0.0.0.0:8680      0.0.0.0:*
LISTEN 0      4096               *:8086            *:*
LISTEN 0      4096               *:8081            *:*
LISTEN 0      4096               *:7946            *:*
LISTEN 0      4096               *:9095            *:*
LISTEN 0      4096               *:9100            *:*
LISTEN 0      4096               *:9096            *:*
LISTEN 0      4096               *:9080            *:*
LISTEN 0      4096               *:22              *:*
LISTEN 0      4096               *:3100            *:*
LISTEN 0      100            [::1]:25           [::]:*
>>>>>>> origin/main
```

### listeners-106.txt
```

<<<<<<< HEAD
LISTEN 0      511          0.0.0.0:8080      0.0.0.0:*
LISTEN 0      100        127.0.0.1:25        0.0.0.0:*
LISTEN 0      511        127.0.0.1:7400      0.0.0.0:*
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*
LISTEN 0      511             [::]:8080         [::]:*
LISTEN 0      100            [::1]:25           [::]:*
LISTEN 0      4096               *:22              *:*
LISTEN 0      511             [::]:80           [::]:*
LISTEN 0      4096               *:9100            *:*
LISTEN 0      511                *:3000            *:*
=======
LISTEN 0      511          0.0.0.0:8080      0.0.0.0:*
LISTEN 0      100        127.0.0.1:25        0.0.0.0:*
LISTEN 0      511        127.0.0.1:7400      0.0.0.0:*
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*
LISTEN 0      511             [::]:8080         [::]:*
LISTEN 0      100            [::1]:25           [::]:*
LISTEN 0      4096               *:22              *:*
LISTEN 0      511             [::]:80           [::]:*
LISTEN 0      4096               *:9100            *:*
LISTEN 0      511                *:3000            *:*
>>>>>>> origin/main
```

### listeners-108.txt
```
container '108' not running!
```

### listeners-109.txt
```

<<<<<<< HEAD
LISTEN 0      128        127.0.0.1:4317       0.0.0.0:*
LISTEN 0      32           0.0.0.0:53         0.0.0.0:*
LISTEN 0      200          0.0.0.0:80         0.0.0.0:*
LISTEN 0      200          0.0.0.0:443        0.0.0.0:*
LISTEN 0      4096         0.0.0.0:19999      0.0.0.0:*
LISTEN 0      4096       127.0.0.1:8125       0.0.0.0:*
LISTEN 0      100        127.0.0.1:25         0.0.0.0:*
LISTEN 0      32              [::]:53            [::]:*
LISTEN 0      4096               *:22               *:*
LISTEN 0      200             [::]:80            [::]:*
LISTEN 0      200             [::]:443           [::]:*
LISTEN 0      4096           [::1]:8125          [::]:*
LISTEN 0      4096            [::]:19999         [::]:*
LISTEN 0      100            [::1]:25            [::]:*
=======
LISTEN 0      128        127.0.0.1:4317       0.0.0.0:*
LISTEN 0      32           0.0.0.0:53         0.0.0.0:*
LISTEN 0      200          0.0.0.0:80         0.0.0.0:*
LISTEN 0      200          0.0.0.0:443        0.0.0.0:*
LISTEN 0      4096         0.0.0.0:19999      0.0.0.0:*
LISTEN 0      4096       127.0.0.1:8125       0.0.0.0:*
LISTEN 0      100        127.0.0.1:25         0.0.0.0:*
LISTEN 0      32              [::]:53            [::]:*
LISTEN 0      4096               *:22               *:*
LISTEN 0      200             [::]:80            [::]:*
LISTEN 0      200             [::]:443           [::]:*
LISTEN 0      4096           [::1]:8125          [::]:*
LISTEN 0      4096            [::]:19999         [::]:*
LISTEN 0      100            [::1]:25            [::]:*
>>>>>>> origin/main
```

### listeners-110.txt
```
container '110' not running!
```

### listeners-111.txt
```
container '111' not running!
```

## Pitchers (edges: who is pushing/scraping where)

### edges-100.txt
```

[1mNetBox LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mnetbox[m
    💡  [m[33m IP Address: [1;92m192.168.4.140[m
# CT 100 (netbox)
Wed Dec 17 08:08:51 PM HST 2025

## /etc/promtail/config.yml
6:  - url: http://192.168.4.140:3100/loki/api/v1/push

## /etc/telegraf/telegraf.conf (outputs)
114:  ##   ex: urls = ["https://us-west-2-1.aws.cloud2.influxdata.com"]
<<<<<<< HEAD
115:[[outputs.influxdb_v2]]
=======
115:[[outputs.influxdb_v2]]
>>>>>>> origin/main
116:  urls = ["$INFLUX_HOST"]
117:  token = "$INFLUX_TOKEN"
118:  organization = "$INFLUX_ORG"
119:  bucket = "$INFLUX_BUCKET"
121:  ## The value of this tag will be used to determine the bucket.  If this
122:  ## tag is not set the 'bucket' option is used as the default.
123:  # bucket_tag = ""
125:  ## If true, the bucket tag will not be added to the metric.
126:  # exclude_bucket_tag = false
301:#   url = "http://localhost/secrets"
307:#   ## "Authorization: Bearer <token>" header
308:#   # token = "your-token"
314:#   ## OAuth2 Client Credentials. The options 'client_id', 'client_secret', and 'token_url' are required to use OAuth2.
317:#   # token_url = "https://indentityprovider/oauth2/v1/token"
322:#   # http_proxy_url = ""
334:#   # cookie_auth_url = "https://localhost/authMe"
395:# # Secret-store to retrieve and maintain tokens from various OAuth2 services
402:#   ## Service to retrieve the token(s) from
406:#   ## Setting to overwrite the queried token-endpoint
410:#   # token_endpoint = ""
415:#   ## Minimal remaining time until the token expires
416:#   ## If a token expires less than the set duration in the future, the token is
417:#   ## renewed. This is useful to avoid race-condition issues where a token is
419:#   ## your service using the token.
420:#   # token_expiry_margin = "1s"
422:#   ## Section for defining a token secret
423:#   [[secretstores.oauth2.token]]
424:#     ## Unique secret-key used for referencing the token via @{<id>:<secret_key>}
432:#     ## Additional (optional) parameters to include in the token request
435:#     # [secretstores.oauth2.token.parameters]
488:# [[outputs.influxdb_v2]]
493:#   ##   ex: urls = ["https://us-west-2-1.aws.cloud2.influxdata.com"]
494:#   urls = ["http://127.0.0.1:8086"]
501:#   token = ""
503:#   ## Organization is the name of the organization you wish to write to.
504:#   organization = ""
506:#   ## Destination bucket to write into.
507:#   bucket = ""
509:#   ## The value of this tag will be used to determine the bucket.  If this
510:#   ## tag is not set the 'bucket' option is used as the default.
511:#   # bucket_tag = ""
513:#   ## If true, the bucket tag will not be added to the metric.
514:#   # exclude_bucket_tag = false
653:#   # proxy_url = "localhost:8888"
681:#   # endpoint_url = "https://dc.services.visualstudio.com/v2/track"
705:#   ## ex: endpoint_url = https://myadxresource.australiasoutheast.kusto.windows.net
706:#   endpoint_url = ""
763:#   # endpoint_url = "https://monitoring.core.usgovcloudapi.net"
878:#   ##    web_identity_token_file are specified
887:#   #token = ""
889:#   #web_identity_token_file = ""
897:#   ##   ex: endpoint_url = "http://localhost:8000"
898:#   # endpoint_url = ""
902:#   # http_proxy_url = "http://localhost:8888"
936:#   ##    web_identity_token_file are specified
945:#   #token = ""
947:#   #web_identity_token_file = ""
954:#   ## default, e.g endpoint_url = "http://localhost:8000"
955:#   # endpoint_url = ""
988:#   url = "postgres://user:password@localhost/schema?sslmode=disable"
1014:#   # url = "https://app.datadoghq.com/api/v1/series"
1018:#   # http_proxy_url = "http://localhost:8888"
1041:#   ## Only setup environment url and token if you want to monitor a Host without the OneAgent present.
1047:#   url = ""
1049:#   ## Your Dynatrace API token.
1050:#   ## Create an API token within your Dynatrace environment, by navigating to Settings > Integration > Dynatrace API
1051:#   ## The API token needs data ingest scope permission. When using OneAgent, no API token is required.
1052:#   api_token = ""
1088:#   urls = [ "http://node1.es.example.com:9200" ] # required.
1104:#   ## HTTP bearer token authentication details
1105:#   # auth_bearer_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"
1406:#   url = "https://groundwork.example.com"
1483:#   url = "http://127.0.0.1:8080/telegraf"
1498:#   # token_url = "https://indentityprovider/oauth2/v1/token"
1507:#   # http_proxy_url = ""
1517:#   # cookie_auth_url = "https://localhost/authMe"
1565:#   ## 1) Web identity provider credentials via STS if role_arn and web_identity_token_file are specified
1574:#   #token = ""
1576:#   #web_identity_token_file = ""
1600:#   # urls = ["unix:///var/run/influxdb.sock"]
1601:#   # urls = ["udp://127.0.0.1:8089"]
1602:#   # urls = ["http://127.0.0.1:8086"]
1686:#   url = "http://127.0.0.1:8083"
1704:#   api_token = "API Token"  # required
1904:#   ## Access token used if sasl_mechanism is OAUTHBEARER
1905:#   # sasl_access_token = ""
1989:#   ## 1) Web identity provider credentials via STS if role_arn and web_identity_token_file are specified
1998:#   #token = ""
2000:#   #web_identity_token_file = ""
2008:#   ##   ex: endpoint_url = "http://localhost:8000"
2009:#   # endpoint_url = ""
2056:#   ## Librato API token
2057:#   api_token = "my-secret-token" # required.
2062:#   ## Output source Template (same as graphite buckets)
2078:#   ## Logz.io account token
2079:#   token = "your logz.io token" # required
2082:#   # url = "https://listener.logz.io:8071"
2395:#   # metric_url = "https://metric-api.newrelic.com/metric/v1"
2418:#   urls = ["http://node1.os.example.com:9200"]
2453:#   ## HTTP bearer token authentication details
2454:#   # auth_bearer_token = ""
2769:#   # url = "https://portal-api.platform.quix.io"
2775:#   ## Authentication token created in Quix
2776:#   token = "your_auth_token"
2812:#   ##   remote = 's3,provider=AWS,access_key_id=...,secret_access_key=...,session_token=...,region=us-east-1:mybucket'
2860:#   url = "tcp://localhost:5555"
2913:#   # backend_api_url = "http://127.0.0.1:8080"
2914:#   # agent_api_url = "http://127.0.0.1:3031"
2916:#   ## API KEY is the Sensu Backend API token
2917:#   ## Generate a new API token via:
2924:#   ## For more information on Sensu RBAC profiles & API tokens, please visit:
2989:#   access_token = "my-secret-token"
2991:#   ## The SignalFx realm that your organization resides in
2997:#   ingest_url = "https://my-custom-ingest/"
3218:#   # url = "https://events.sumologic.net/receiver/v1/http/<UniqueHTTPCollectorCode>"
3353:#   ##    web_identity_token_file are specified
3362:#   #token = ""
3364:#   #web_identity_token_file = ""
3372:#   ##   ex: endpoint_url = "http://localhost:8000"
3373:#   # endpoint_url = ""
3445:#   warp_url = "http://localhost:8080"
3447:#   # Write token to access your app on warp 10
3448:#   token = "Token"
3470:#   url = "https://metrics.wavefront.com"
3550:#   ## Direct Ingestion requires one of: `token`,`auth_csp_api_token`, or
3559:#   # token = "YOUR_TOKEN"
3562:#   ## Wavefront API token.
3566:#   # auth_csp_api_token=CSP_API_TOKEN_HERE
3580:#   url = "ws://127.0.0.1:3000/telegraf"
3605:#   # http_proxy_url = "http://localhost:8888"
3628:#   # endpoint_url = "https://monitoring.api.cloud.yandex.net/monitoring/v2/data/write"
4646:#   ## How many top buckets to return per field
4649:#   ## aggregation will return k buckets. If a metric does not have a defined
4784:#   ## Whether bucket values should be accumulated. If set to false, "gt" tag will be added.
4789:#   ## there are no changes in any buckets for this time interval. 0 == no expiration.
4798:#   #   ## Right borders of buckets (with +Inf implicitly added).
4799:#   #   buckets = [0.0, 15.6, 34.5, 49.1, 71.5, 80.5, 94.5, 100.0]
4805:#   #   ## Right borders of buckets (with +Inf implicitly added).
4806:#   #   buckets = [0.0, 10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0]
5012:#   url = "http://127.0.0.1:8161"
5068:#   # by default, aerospike produces a 100 bucket histogram
5070:#   # the ability to squash this to a smaller number of buckets
5071:#   # To have a balanced histogram, the number of buckets chosen
5073:#   # num_histogram_buckets = 100 # default: 10
5081:#   urls = ["http://localhost/server-status?auto"]
5251:#   url = "http://127.0.0.1:5066"
5286:#   # urls = ["http://localhost:8053/xml/v3"]
5432:#   ##    web_identity_token_file are specified
5441:#   # token = ""
5443:#   # web_identity_token_file = ""
5456:#   ##   ex: endpoint_url = "http://localhost:8000"
5457:#   # endpoint_url = ""
5461:#   # http_proxy_url = "http://localhost:8888"
5585:#   ## ACL token used in every request
5586:#   # token = ""
5611:#   # url = "http://127.0.0.1:8500"
5613:#   ## Use auth token for authorization.
5615:#   ## If both are empty, no token will be used.
5616:#   # token_file = "/path/to/auth/token"
5618:#   # token = "a1234567-40c7-9048-7bae-378687048181"
5629:# # Read per-node and per-bucket metrics from Couchbase
5642:#   ## Filter bucket fields to include only here.
5643:#   # bucket_stats_included = ["quota_percent_used", "ops_per_sec", "disk_fetches", "item_count", "disk_used", "data_used", "mem_used"]
5653:#   ## Whether to collect cluster-wide bucket statistics
5656:#   # cluster_bucket_stats = true
5658:#   ## Whether to collect bucket stats for each individual node
5659:#   # node_bucket_stats = false
5692:#   cluster_url = "https://dcos-master-1"
5699:#   ## Path containing login token.  If set, will read on every gather.
5700:#   # token_file = "/home/dcos/.dcos/token"
5861:#   # endpoint_url = ""
5971:#   url = "http://<controller>:80"
6067:#   ## Specify auth token for your account
6068:#   auth_token = "invalidAuthToken"
6070:#   # url = https://fireboard.io/api/v1/devices.json
6096:#   urls = [ "http://user:password@fritz.box:49000/" ]
6127:#   ## Github API access token.  Unauthenticated requests are limited to 60 per hour.
6128:#   # access_token = ""
6131:#   # enterprise_base_url = ""
6147:#   ## Required. Name of Cloud Storage bucket to ingest metrics from.
6148:#   bucket = "my-bucket"
6150:#   ## Optional. Prefix of Cloud Storage bucket keys to list metrics from.
6151:#   # key_prefix = "my-bucket"
6255:#   # urls = ["http://localhost"]
6270:#   ## Optional file with Bearer token
6272:#   # bearer_token = "/path/to/file"
6337:#   # cookie_auth_url = "https://localhost/authMe"
6425:#   urls = [
6691:#   url = "http://my-jenkins-instance:8080"
6749:#   urls = ["http://localhost:8080/jolokia"]
6778:#   url = "http://localhost:8080/jolokia"
6797:#     url = "service:jmx:rmi:///jndi/rmi://targethost:9999/jmxrmi"
6812:#   urls = [
6836:#   ## If empty in-cluster config with POD's service account token will be used.
6837:#   # url = ""
6848:#   ## Use bearer token for authorization.
6850:#   # bearer_token = "/var/run/secrets/kubernetes.io/serviceaccount/token"
6891:#   url = "http://127.0.0.1:10255"
6893:#   ## Use bearer token for authorization. ('bearer_token' takes priority)
6895:#   ## at: /var/run/secrets/kubernetes.io/serviceaccount/token
6897:#   ## To re-read the token at each interval, please use a file with the
6898:#   ## bearer_token option. If given a string, Telegraf will always use that
6899:#   ## token.
6900:#   # bearer_token = "/var/run/secrets/kubernetes.io/serviceaccount/token"
```

### edges-102.txt
```

[1mGrafana LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mgrafana[m
    💡  [m[33m IP Address: [1;92m192.168.4.129[m
# CT 102 (grafana)
Wed Dec 17 08:08:52 PM HST 2025

## /etc/promtail/config.yml
6:  - url: http://192.168.4.140:3100/loki/api/v1/push

## /etc/telegraf/telegraf.conf (outputs)
160:#   url = "http://localhost/secrets"
166:#   ## "Authorization: Bearer <token>" header
167:#   # token = "your-token"
173:#   ## OAuth2 Client Credentials. The options 'client_id', 'client_secret', and 'token_url' are required to use OAuth2.
176:#   # token_url = "https://indentityprovider/oauth2/v1/token"
181:#   # http_proxy_url = ""
193:#   # cookie_auth_url = "https://localhost/authMe"
254:# # Secret-store to retrieve and maintain tokens from various OAuth2 services
261:#   ## Service to retrieve the token(s) from
265:#   ## Setting to overwrite the queried token-endpoint
269:#   # token_endpoint = ""
274:#   ## Minimal remaining time until the token expires
275:#   ## If a token expires less than the set duration in the future, the token is
276:#   ## renewed. This is useful to avoid race-condition issues where a token is
278:#   ## your service using the token.
279:#   # token_expiry_margin = "1s"
281:#   ## Section for defining a token secret
282:#   [[secretstores.oauth2.token]]
283:#     ## Unique secret-key used for referencing the token via @{<id>:<secret_key>}
291:#     ## Additional (optional) parameters to include in the token request
294:#     # [secretstores.oauth2.token.parameters]
347:# [[outputs.influxdb_v2]]
352:#   ##   ex: urls = ["https://us-west-2-1.aws.cloud2.influxdata.com"]
353:#   urls = ["http://127.0.0.1:8086"]
360:#   token = ""
362:#   ## Organization is the name of the organization you wish to write to.
363:#   organization = ""
365:#   ## Destination bucket to write into.
366:#   bucket = ""
368:#   ## The value of this tag will be used to determine the bucket.  If this
369:#   ## tag is not set the 'bucket' option is used as the default.
370:#   # bucket_tag = ""
372:#   ## If true, the bucket tag will not be added to the metric.
373:#   # exclude_bucket_tag = false
512:#   # proxy_url = "localhost:8888"
540:#   # endpoint_url = "https://dc.services.visualstudio.com/v2/track"
564:#   ## ex: endpoint_url = https://myadxresource.australiasoutheast.kusto.windows.net
565:#   endpoint_url = ""
622:#   # endpoint_url = "https://monitoring.core.usgovcloudapi.net"
737:#   ##    web_identity_token_file are specified
746:#   #token = ""
748:#   #web_identity_token_file = ""
756:#   ##   ex: endpoint_url = "http://localhost:8000"
757:#   # endpoint_url = ""
761:#   # http_proxy_url = "http://localhost:8888"
795:#   ##    web_identity_token_file are specified
804:#   #token = ""
806:#   #web_identity_token_file = ""
813:#   ## default, e.g endpoint_url = "http://localhost:8000"
814:#   # endpoint_url = ""
847:#   url = "postgres://user:password@localhost/schema?sslmode=disable"
873:#   # url = "https://app.datadoghq.com/api/v1/series"
877:#   # http_proxy_url = "http://localhost:8888"
900:#   ## Only setup environment url and token if you want to monitor a Host without the OneAgent present.
906:#   url = ""
908:#   ## Your Dynatrace API token.
909:#   ## Create an API token within your Dynatrace environment, by navigating to Settings > Integration > Dynatrace API
910:#   ## The API token needs data ingest scope permission. When using OneAgent, no API token is required.
911:#   api_token = ""
947:#   urls = [ "http://node1.es.example.com:9200" ] # required.
964:#   ## HTTP bearer token authentication details
965:#   # auth_bearer_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"
1266:#   url = "https://groundwork.example.com"
1344:#   url = "http://127.0.0.1:8080/telegraf"
1359:#   # token_url = "https://indentityprovider/oauth2/v1/token"
1368:#   # http_proxy_url = ""
1378:#   # cookie_auth_url = "https://localhost/authMe"
1426:#   ## 1) Web identity provider credentials via STS if role_arn and web_identity_token_file are specified
1435:#   #token = ""
1437:#   #web_identity_token_file = ""
1461:#   # urls = ["unix:///var/run/influxdb.sock"]
1462:#   # urls = ["udp://127.0.0.1:8089"]
1463:#   # urls = ["http://127.0.0.1:8086"]
1547:#   url = "http://127.0.0.1:8083"
1565:#   api_token = "API Token"  # required
1765:#   ## Access token used if sasl_mechanism is OAUTHBEARER
1766:#   # sasl_access_token = ""
1850:#   ## 1) Web identity provider credentials via STS if role_arn and web_identity_token_file are specified
1859:#   #token = ""
1861:#   #web_identity_token_file = ""
1869:#   ##   ex: endpoint_url = "http://localhost:8000"
1870:#   # endpoint_url = ""
1917:#   ## Librato API token
1918:#   api_token = "my-secret-token" # required.
1923:#   ## Output source Template (same as graphite buckets)
1939:#   ## Logz.io account token
1940:#   token = "your logz.io token" # required
1943:#   # url = "https://listener.logz.io:8071"
2256:#   # metric_url = "https://metric-api.newrelic.com/metric/v1"
2279:#   urls = ["http://node1.os.example.com:9200"]
2314:#   ## HTTP bearer token authentication details
2315:#   # auth_bearer_token = ""
2633:#   # url = "https://portal-api.platform.quix.io"
2639:#   ## Authentication token created in Quix
2640:#   token = "your_auth_token"
2676:#   ##   remote = 's3,provider=AWS,access_key_id=...,secret_access_key=...,session_token=...,region=us-east-1:mybucket'
2724:#   url = "tcp://localhost:5555"
2777:#   # backend_api_url = "http://127.0.0.1:8080"
2778:#   # agent_api_url = "http://127.0.0.1:3031"
2780:#   ## API KEY is the Sensu Backend API token
2781:#   ## Generate a new API token via:
2788:#   ## For more information on Sensu RBAC profiles & API tokens, please visit:
2853:#   access_token = "my-secret-token"
2855:#   ## The SignalFx realm that your organization resides in
2861:#   ingest_url = "https://my-custom-ingest/"
3082:#   # url = "https://events.sumologic.net/receiver/v1/http/<UniqueHTTPCollectorCode>"
3217:#   ##    web_identity_token_file are specified
3226:#   #token = ""
3228:#   #web_identity_token_file = ""
3236:#   ##   ex: endpoint_url = "http://localhost:8000"
3237:#   # endpoint_url = ""
3309:#   warp_url = "http://localhost:8080"
3311:#   # Write token to access your app on warp 10
3312:#   token = "Token"
3334:#   url = "https://metrics.wavefront.com"
3414:#   ## Direct Ingestion requires one of: `token`,`auth_csp_api_token`, or
3423:#   # token = "YOUR_TOKEN"
3426:#   ## Wavefront API token.
3430:#   # auth_csp_api_token=CSP_API_TOKEN_HERE
3444:#   url = "ws://127.0.0.1:3000/telegraf"
3469:#   # http_proxy_url = "http://localhost:8888"
3492:#   # endpoint_url = "https://monitoring.api.cloud.yandex.net/monitoring/v2/data/write"
4509:#   ## How many top buckets to return per field
4511:#   ## For example, 1 field with k of 10 will return 10 buckets. While 2 fields
4512:#   ## with k of 3 will return 6 buckets.
4522:#   ## aggregation will return k buckets. If a metric does not have a defined
4649:#   ## Whether bucket values should be accumulated. If set to false, "gt" tag will be added.
4654:#   ## there are no changes in any buckets for this time interval. 0 == no expiration.
4663:#   #   ## Right borders of buckets (with +Inf implicitly added).
4664:#   #   buckets = [0.0, 15.6, 34.5, 49.1, 71.5, 80.5, 94.5, 100.0]
4670:#   #   ## Right borders of buckets (with +Inf implicitly added).
4671:#   #   buckets = [0.0, 10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0]
4877:#   url = "http://127.0.0.1:8161"
4933:#   # by default, aerospike produces a 100 bucket histogram
4935:#   # the ability to squash this to a smaller number of buckets
4936:#   # To have a balanced histogram, the number of buckets chosen
4938:#   # num_histogram_buckets = 100 # default: 10
4946:#   urls = ["http://localhost/server-status?auto"]
5115:#   url = "http://127.0.0.1:5066"
5150:#   # urls = ["http://localhost:8053/xml/v3"]
5296:#   ##    web_identity_token_file are specified
5305:#   # token = ""
5307:#   # web_identity_token_file = ""
5320:#   ##   ex: endpoint_url = "http://localhost:8000"
5321:#   # endpoint_url = ""
5325:#   # http_proxy_url = "http://localhost:8888"
5449:#   ## ACL token used in every request
5450:#   # token = ""
5475:#   # url = "http://127.0.0.1:8500"
5477:#   ## Use auth token for authorization.
5479:#   ## If both are empty, no token will be used.
5480:#   # token_file = "/path/to/auth/token"
5482:#   # token = "a1234567-40c7-9048-7bae-378687048181"
5493:# # Read per-node and per-bucket metrics from Couchbase
5506:#   ## Filter bucket fields to include only here.
5507:#   # bucket_stats_included = ["quota_percent_used", "ops_per_sec", "disk_fetches", "item_count", "disk_used", "data_used", "mem_used"]
5517:#   ## Whether to collect cluster-wide bucket statistics
5520:#   # cluster_bucket_stats = true
5522:#   ## Whether to collect bucket stats for each individual node
5523:#   # node_bucket_stats = false
5556:#   cluster_url = "https://dcos-master-1"
5563:#   ## Path containing login token.  If set, will read on every gather.
5564:#   # token_file = "/home/dcos/.dcos/token"
5725:#   # endpoint_url = ""
5835:#   url = "http://<controller>:80"
5931:#   ## Specify auth token for your account
5932:#   auth_token = "invalidAuthToken"
5934:#   # url = https://fireboard.io/api/v1/devices.json
5960:#   urls = [ "http://user:password@fritz.box:49000/" ]
5991:#   ## Github API access token.  Unauthenticated requests are limited to 60 per hour.
5992:#   # access_token = ""
5995:#   # enterprise_base_url = ""
6011:#   ## Required. Name of Cloud Storage bucket to ingest metrics from.
6012:#   bucket = "my-bucket"
6014:#   ## Optional. Prefix of Cloud Storage bucket keys to list metrics from.
6015:#   # key_prefix = "my-bucket"
6119:#   # urls = ["http://localhost"]
6134:#   ## Optional file with Bearer token
6136:#   # bearer_token = "/path/to/file"
6201:#   # cookie_auth_url = "https://localhost/authMe"
6289:#   urls = [
6555:#   url = "http://my-jenkins-instance:8080"
6613:#   urls = ["http://localhost:8080/jolokia"]
6642:#   url = "http://localhost:8080/jolokia"
6661:#     url = "service:jmx:rmi:///jndi/rmi://targethost:9999/jmxrmi"
6676:#   urls = [
6700:#   ## If empty in-cluster config with POD's service account token will be used.
6701:#   # url = ""
6712:#   ## Use bearer token for authorization.
6714:#   # bearer_token = "/var/run/secrets/kubernetes.io/serviceaccount/token"
6755:#   url = "http://127.0.0.1:10255"
6757:#   ## Use bearer token for authorization. ('bearer_token' takes priority)
6759:#   ## at: /var/run/secrets/kubernetes.io/serviceaccount/token
6761:#   ## To re-read the token at each interval, please use a file with the
6762:#   ## bearer_token option. If given a string, Telegraf will always use that
6763:#   ## token.
6764:#   # bearer_token = "/var/run/secrets/kubernetes.io/serviceaccount/token"
6766:#   # bearer_token_string = "abc_123"
6957:#   url = "http://localhost:8002"
7720:#   urls = ["http://localhost/server_status"]
7736:#   urls = ["http://localhost/status"]
7752:#   urls = ["http://localhost/api"]
7770:#   urls = ["http://localhost/status"]
7787:#   url = "http://127.0.0.1/status?format=json"
7816:#   urls = ["http://localhost/status"]
7832:#   # url = "http://127.0.0.1:4646"
```

### edges-103.txt
```

[1mPrometheus LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mprometheus[m
    💡  [m[33m IP Address: [1;92m192.168.4.132[m
# CT 103 (prometheus)
Wed Dec 17 08:08:53 PM HST 2025

## /etc/prometheus/prometheus.yml
6:  - job_name: prometheus
8:      - targets: ['192.168.7.114:9090']
12:  - job_name: node-exporter

## /etc/telegraf/telegraf.conf (outputs)
160:#   url = "http://localhost/secrets"
166:#   ## "Authorization: Bearer <token>" header
167:#   # token = "your-token"
173:#   ## OAuth2 Client Credentials. The options 'client_id', 'client_secret', and 'token_url' are required to use OAuth2.
176:#   # token_url = "https://indentityprovider/oauth2/v1/token"
181:#   # http_proxy_url = ""
193:#   # cookie_auth_url = "https://localhost/authMe"
254:# # Secret-store to retrieve and maintain tokens from various OAuth2 services
261:#   ## Service to retrieve the token(s) from
265:#   ## Setting to overwrite the queried token-endpoint
269:#   # token_endpoint = ""
274:#   ## Minimal remaining time until the token expires
275:#   ## If a token expires less than the set duration in the future, the token is
276:#   ## renewed. This is useful to avoid race-condition issues where a token is
278:#   ## your service using the token.
279:#   # token_expiry_margin = "1s"
281:#   ## Section for defining a token secret
282:#   [[secretstores.oauth2.token]]
283:#     ## Unique secret-key used for referencing the token via @{<id>:<secret_key>}
291:#     ## Additional (optional) parameters to include in the token request
294:#     # [secretstores.oauth2.token.parameters]
347:# [[outputs.influxdb_v2]]
352:#   ##   ex: urls = ["https://us-west-2-1.aws.cloud2.influxdata.com"]
353:#   urls = ["http://127.0.0.1:8086"]
360:#   token = ""
362:#   ## Organization is the name of the organization you wish to write to.
363:#   organization = ""
365:#   ## Destination bucket to write into.
366:#   bucket = ""
368:#   ## The value of this tag will be used to determine the bucket.  If this
369:#   ## tag is not set the 'bucket' option is used as the default.
370:#   # bucket_tag = ""
372:#   ## If true, the bucket tag will not be added to the metric.
373:#   # exclude_bucket_tag = false
512:#   # proxy_url = "localhost:8888"
540:#   # endpoint_url = "https://dc.services.visualstudio.com/v2/track"
564:#   ## ex: endpoint_url = https://myadxresource.australiasoutheast.kusto.windows.net
565:#   endpoint_url = ""
622:#   # endpoint_url = "https://monitoring.core.usgovcloudapi.net"
737:#   ##    web_identity_token_file are specified
746:#   #token = ""
748:#   #web_identity_token_file = ""
756:#   ##   ex: endpoint_url = "http://localhost:8000"
757:#   # endpoint_url = ""
761:#   # http_proxy_url = "http://localhost:8888"
795:#   ##    web_identity_token_file are specified
804:#   #token = ""
806:#   #web_identity_token_file = ""
813:#   ## default, e.g endpoint_url = "http://localhost:8000"
814:#   # endpoint_url = ""
847:#   url = "postgres://user:password@localhost/schema?sslmode=disable"
873:#   # url = "https://app.datadoghq.com/api/v1/series"
877:#   # http_proxy_url = "http://localhost:8888"
900:#   ## Only setup environment url and token if you want to monitor a Host without the OneAgent present.
906:#   url = ""
908:#   ## Your Dynatrace API token.
909:#   ## Create an API token within your Dynatrace environment, by navigating to Settings > Integration > Dynatrace API
910:#   ## The API token needs data ingest scope permission. When using OneAgent, no API token is required.
911:#   api_token = ""
947:#   urls = [ "http://node1.es.example.com:9200" ] # required.
964:#   ## HTTP bearer token authentication details
965:#   # auth_bearer_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"
1266:#   url = "https://groundwork.example.com"
1344:#   url = "http://127.0.0.1:8080/telegraf"
1359:#   # token_url = "https://indentityprovider/oauth2/v1/token"
1368:#   # http_proxy_url = ""
1378:#   # cookie_auth_url = "https://localhost/authMe"
1426:#   ## 1) Web identity provider credentials via STS if role_arn and web_identity_token_file are specified
1435:#   #token = ""
1437:#   #web_identity_token_file = ""
1461:#   # urls = ["unix:///var/run/influxdb.sock"]
1462:#   # urls = ["udp://127.0.0.1:8089"]
1463:#   # urls = ["http://127.0.0.1:8086"]
1547:#   url = "http://127.0.0.1:8083"
1565:#   api_token = "API Token"  # required
1765:#   ## Access token used if sasl_mechanism is OAUTHBEARER
1766:#   # sasl_access_token = ""
1850:#   ## 1) Web identity provider credentials via STS if role_arn and web_identity_token_file are specified
1859:#   #token = ""
1861:#   #web_identity_token_file = ""
1869:#   ##   ex: endpoint_url = "http://localhost:8000"
1870:#   # endpoint_url = ""
1917:#   ## Librato API token
1918:#   api_token = "my-secret-token" # required.
1923:#   ## Output source Template (same as graphite buckets)
1939:#   ## Logz.io account token
1940:#   token = "your logz.io token" # required
1943:#   # url = "https://listener.logz.io:8071"
2256:#   # metric_url = "https://metric-api.newrelic.com/metric/v1"
2279:#   urls = ["http://node1.os.example.com:9200"]
2314:#   ## HTTP bearer token authentication details
2315:#   # auth_bearer_token = ""
2633:#   # url = "https://portal-api.platform.quix.io"
2639:#   ## Authentication token created in Quix
2640:#   token = "your_auth_token"
2676:#   ##   remote = 's3,provider=AWS,access_key_id=...,secret_access_key=...,session_token=...,region=us-east-1:mybucket'
2724:#   url = "tcp://localhost:5555"
2777:#   # backend_api_url = "http://127.0.0.1:8080"
2778:#   # agent_api_url = "http://127.0.0.1:3031"
2780:#   ## API KEY is the Sensu Backend API token
2781:#   ## Generate a new API token via:
2788:#   ## For more information on Sensu RBAC profiles & API tokens, please visit:
2853:#   access_token = "my-secret-token"
2855:#   ## The SignalFx realm that your organization resides in
2861:#   ingest_url = "https://my-custom-ingest/"
3082:#   # url = "https://events.sumologic.net/receiver/v1/http/<UniqueHTTPCollectorCode>"
3217:#   ##    web_identity_token_file are specified
3226:#   #token = ""
3228:#   #web_identity_token_file = ""
3236:#   ##   ex: endpoint_url = "http://localhost:8000"
3237:#   # endpoint_url = ""
3309:#   warp_url = "http://localhost:8080"
3311:#   # Write token to access your app on warp 10
3312:#   token = "Token"
3334:#   url = "https://metrics.wavefront.com"
3414:#   ## Direct Ingestion requires one of: `token`,`auth_csp_api_token`, or
3423:#   # token = "YOUR_TOKEN"
3426:#   ## Wavefront API token.
3430:#   # auth_csp_api_token=CSP_API_TOKEN_HERE
3444:#   url = "ws://127.0.0.1:3000/telegraf"
3469:#   # http_proxy_url = "http://localhost:8888"
3492:#   # endpoint_url = "https://monitoring.api.cloud.yandex.net/monitoring/v2/data/write"
4509:#   ## How many top buckets to return per field
4511:#   ## For example, 1 field with k of 10 will return 10 buckets. While 2 fields
4512:#   ## with k of 3 will return 6 buckets.
4522:#   ## aggregation will return k buckets. If a metric does not have a defined
4649:#   ## Whether bucket values should be accumulated. If set to false, "gt" tag will be added.
4654:#   ## there are no changes in any buckets for this time interval. 0 == no expiration.
4663:#   #   ## Right borders of buckets (with +Inf implicitly added).
4664:#   #   buckets = [0.0, 15.6, 34.5, 49.1, 71.5, 80.5, 94.5, 100.0]
4670:#   #   ## Right borders of buckets (with +Inf implicitly added).
4671:#   #   buckets = [0.0, 10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0]
4877:#   url = "http://127.0.0.1:8161"
4933:#   # by default, aerospike produces a 100 bucket histogram
4935:#   # the ability to squash this to a smaller number of buckets
4936:#   # To have a balanced histogram, the number of buckets chosen
4938:#   # num_histogram_buckets = 100 # default: 10
4946:#   urls = ["http://localhost/server-status?auto"]
5115:#   url = "http://127.0.0.1:5066"
5150:#   # urls = ["http://localhost:8053/xml/v3"]
5296:#   ##    web_identity_token_file are specified
5305:#   # token = ""
5307:#   # web_identity_token_file = ""
5320:#   ##   ex: endpoint_url = "http://localhost:8000"
5321:#   # endpoint_url = ""
5325:#   # http_proxy_url = "http://localhost:8888"
5449:#   ## ACL token used in every request
5450:#   # token = ""
5475:#   # url = "http://127.0.0.1:8500"
5477:#   ## Use auth token for authorization.
5479:#   ## If both are empty, no token will be used.
5480:#   # token_file = "/path/to/auth/token"
5482:#   # token = "a1234567-40c7-9048-7bae-378687048181"
5493:# # Read per-node and per-bucket metrics from Couchbase
5506:#   ## Filter bucket fields to include only here.
5507:#   # bucket_stats_included = ["quota_percent_used", "ops_per_sec", "disk_fetches", "item_count", "disk_used", "data_used", "mem_used"]
5517:#   ## Whether to collect cluster-wide bucket statistics
5520:#   # cluster_bucket_stats = true
5522:#   ## Whether to collect bucket stats for each individual node
5523:#   # node_bucket_stats = false
5556:#   cluster_url = "https://dcos-master-1"
5563:#   ## Path containing login token.  If set, will read on every gather.
5564:#   # token_file = "/home/dcos/.dcos/token"
5725:#   # endpoint_url = ""
5835:#   url = "http://<controller>:80"
5931:#   ## Specify auth token for your account
5932:#   auth_token = "invalidAuthToken"
5934:#   # url = https://fireboard.io/api/v1/devices.json
5960:#   urls = [ "http://user:password@fritz.box:49000/" ]
5991:#   ## Github API access token.  Unauthenticated requests are limited to 60 per hour.
5992:#   # access_token = ""
5995:#   # enterprise_base_url = ""
6011:#   ## Required. Name of Cloud Storage bucket to ingest metrics from.
6012:#   bucket = "my-bucket"
6014:#   ## Optional. Prefix of Cloud Storage bucket keys to list metrics from.
6015:#   # key_prefix = "my-bucket"
6119:#   # urls = ["http://localhost"]
6134:#   ## Optional file with Bearer token
6136:#   # bearer_token = "/path/to/file"
6201:#   # cookie_auth_url = "https://localhost/authMe"
6289:#   urls = [
6555:#   url = "http://my-jenkins-instance:8080"
6613:#   urls = ["http://localhost:8080/jolokia"]
6642:#   url = "http://localhost:8080/jolokia"
6661:#     url = "service:jmx:rmi:///jndi/rmi://targethost:9999/jmxrmi"
6676:#   urls = [
6700:#   ## If empty in-cluster config with POD's service account token will be used.
6701:#   # url = ""
6712:#   ## Use bearer token for authorization.
6714:#   # bearer_token = "/var/run/secrets/kubernetes.io/serviceaccount/token"
6755:#   url = "http://127.0.0.1:10255"
6757:#   ## Use bearer token for authorization. ('bearer_token' takes priority)
6759:#   ## at: /var/run/secrets/kubernetes.io/serviceaccount/token
6761:#   ## To re-read the token at each interval, please use a file with the
6762:#   ## bearer_token option. If given a string, Telegraf will always use that
6763:#   ## token.
6764:#   # bearer_token = "/var/run/secrets/kubernetes.io/serviceaccount/token"
6766:#   # bearer_token_string = "abc_123"
6957:#   url = "http://localhost:8002"
7720:#   urls = ["http://localhost/server_status"]
7736:#   urls = ["http://localhost/status"]
7752:#   urls = ["http://localhost/api"]
7770:#   urls = ["http://localhost/status"]
7787:#   url = "http://127.0.0.1/status?format=json"
```

### edges-104.txt
```

[1mPrometheus-PVE-Exporter LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mprometheus-pve-exporter[m
    💡  [m[33m IP Address: [1;92m192.168.4.131[m
# CT 104 (prometheus-pve-exporter)
Wed Dec 17 08:08:54 PM HST 2025

```

### edges-105.txt
```

[1mInfluxDB LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92minfluxdb[m
    💡  [m[33m IP Address: [1;92m192.168.4.130[m
# CT 105 (influxdb)
Wed Dec 17 08:08:55 PM HST 2025

## /etc/promtail/config.yml
6:  - url: http://192.168.4.140:3100/loki/api/v1/push

## /etc/telegraf/telegraf.conf (outputs)
45:[[outputs.influxdb_v2]]
47:  urls = ["$INFLUX_HOST"]
48:  token = "${INFLUX_TOKEN}"
49:  organization = "${INFLUX_ORG}"
50:  bucket = "${TELEGRAF_BUCKET}"
52:  ## The value of this tag will be used to determine the bucket.  If this
53:  ## tag is not set the 'bucket' option is used as the default.
54:  bucket_tag = "${TELEGRAF_BUCKET}"
56:  ## If true, the bucket tag will not be added to the metric.
57:   exclude_bucket_tag = false

## /etc/telegraf/telegraf.d/*.conf (outputs)
/etc/telegraf/telegraf.d/netflow_input.conf:10:[[outputs.influxdb_v2]]
/etc/telegraf/telegraf.d/netflow_input.conf:12: urls = ["$INFLUX_HOST"]
/etc/telegraf/telegraf.d/netflow_input.conf:13:  token = "${INFLUX_TOKEN}"
/etc/telegraf/telegraf.d/netflow_input.conf:14:  organization = "${INFLUX_ORG}"
/etc/telegraf/telegraf.d/netflow_input.conf:15:  bucket = "${NETFLOW_BUCKET}"
/etc/telegraf/telegraf.d/system.conf:62:  [[outputs.influxdb_v2]]
/etc/telegraf/telegraf.d/system.conf:64:  urls = ["$INFLUX_HOST"]
/etc/telegraf/telegraf.d/system.conf:65:  token = "${INFLUX_TOKEN}"
/etc/telegraf/telegraf.d/system.conf:66:  organization = "${INFLUX_ORG}"
/etc/telegraf/telegraf.d/system.conf:67:  bucket = "${LINUX_BUCKET}"
/etc/telegraf/telegraf.d/system.conf:69:  ## The value of this tag will be used to determine the bucket.  If this
/etc/telegraf/telegraf.d/system.conf:70:  ## tag is not set the 'bucket' option is used as the default.
/etc/telegraf/telegraf.d/system.conf:71:  bucket_tag = "${LINUX_BUCKET}"
/etc/telegraf/telegraf.d/timewarp_traffic.conf:51:# If you WANT this file to force-bucket routing, we can add a dedicated outputs.influxdb_v2
/etc/telegraf/telegraf.d/timewarp_traffic.conf:73:[[outputs.influxdb_v2]]
/etc/telegraf/telegraf.d/timewarp_traffic.conf:74:  urls = ["$INFLUX_HOST"]
/etc/telegraf/telegraf.d/timewarp_traffic.conf:75:#  token = "$INFLUX_TOKEN"
/etc/telegraf/telegraf.d/timewarp_traffic.conf:76:  token = "${INFLUX_TOKEN}"
/etc/telegraf/telegraf.d/timewarp_traffic.conf:77:  organization = "${INFLUX_ORG}"
/etc/telegraf/telegraf.d/timewarp_traffic.conf:78:  bucket = "${TIMEWARP_BUCKET}"
/etc/telegraf/telegraf.d/timewarp_traffic.conf:80:  ## The value of this tag will be used to determine the bucket.  If this
/etc/telegraf/telegraf.d/timewarp_traffic.conf:81:  ## tag is not set the 'bucket' option is used as the default.
/etc/telegraf/telegraf.d/timewarp_traffic.conf:82:  bucket_tag = "${TIMEWARP_BUCKET}"
/etc/telegraf/telegraf.d/timewarp_traffic.conf:85:  exclude_bucket_tag = false

```

### edges-106.txt
```

[1mHomepage LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mhomepage[m
    💡  [m[33m IP Address: [1;92m192.168.4.139[m
# CT 106 (homepage)
Thu Dec 18 01:08:56 AM EST 2025

```

### edges-108.txt
```
container '108' not running!
```

### edges-109.txt
```

[1mPihole LXC Container[m
    🌐  [m[33m Provided by: [1;92mcommunity-scripts ORG [33m| GitHub: [1;92mhttps://github.com/community-scripts/ProxmoxVE[m

    🖥️  [m[33m OS: [1;92mDebian GNU/Linux - Version: 12[m
    🏠  [m[33m Hostname: [1;92mpihole[m
    💡  [m[33m IP Address: [1;92m192.168.4.208[m
# CT 109 (pihole)
Thu Dec 18 01:08:58 AM EST 2025

```

### edges-110.txt
```
container '110' not running!
```

### edges-111.txt
```
container '111' not running!
```
<<<<<<< HEAD
=======

>>>>>>> origin/main
