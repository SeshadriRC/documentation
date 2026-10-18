# Observability & Monitoring Commands for DevOps Engineers

A comprehensive reference for Prometheus, Grafana, OpenTelemetry, Loki, and Elasticsearch/Kibana monitoring and diagnostics.

---

## 1. Prometheus API & PromQL Queries

### API Management

```bash
# Query Prometheus instantaneous value
curl -s -g 'http://localhost:9090/api/v1/query?query=up' | jq .

# Query Prometheus range (start, end, step)
curl -s -g 'http://localhost:9090/api/v1/query_range?query=rate(http_requests_total[5m])&start=2026-10-18T16:00:00Z&end=2026-10-18T17:00:00Z&step=15s' | jq .

# Reload Prometheus configuration dynamically without restarting process (--web.enable-lifecycle must be enabled)
curl -X POST http://localhost:9090/-/reload

# Check scraping target health and state (UP, DOWN)
curl -s http://localhost:9090/api/v1/targets | jq -r '.data.activeTargets[] | {job: .labels.job, instance: .labels.instance, health: .health}'

# List active firing alerts
curl -s http://localhost:9090/api/v1/alerts | jq -r '.data.alerts[] | {alertname: .labels.alertname, state: .state}'
```

### Essential PromQL Formulas for Production Monitoring

```promql
# Overall CPU Utilization % (Node Exporter)
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory Utilization %
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# Disk Space Used %
100 - ((node_filesystem_avail_bytes{mountpoint="/"} * 100) / node_filesystem_size_bytes{mountpoint="/"})

# Pod CPU Usage in Cores (cAdvisor / Kubernetes)
sum(rate(container_cpu_usage_seconds_total{container!="",container!="POD"}[5m])) by (pod, namespace)

# Pod Memory Working Set Bytes
sum(container_memory_working_set_bytes{container!="",container!="POD"}) by (pod, namespace)

# HTTP 5xx Error Rate %
(sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m]))) * 100

# HTTP 99th Percentile Latency (P99)
histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))
```

---

## 2. Grafana API & Dashboards

```bash
# Check Grafana health
curl -s http://admin:admin@localhost:3000/api/health

# List configured data sources
curl -s -u admin:admin http://localhost:3000/api/datasources | jq -r '.[] | {id: .id, name: .name, type: .type, url: .url}'

# Search dashboards by tag or query
curl -s -u admin:admin "http://localhost:3000/api/search?query=kubernetes" | jq .

# Export a dashboard configuration to JSON file
curl -s -u admin:admin http://localhost:3000/api/dashboards/uid/<dashboard-uid> | jq .dashboard > dashboard.json

# Import / Create a dashboard via JSON payload
curl -X POST -u admin:admin \
  -H "Content-Type: application/json" \
  -d '{"dashboard": '"$(cat dashboard.json)"', "overwrite": true}' \
  http://localhost:3000/api/dashboards/db
```

---

## 3. Grafana Loki & LogCLI

```bash
# Set Loki address
export LOKI_ADDR="http://localhost:3100"

# Follow logs in real time (similar to tail -f)
logcli query '{app="my-microservice"}' --tail

# Query logs matching specific namespace and filter by regex/content
logcli query '{namespace="production"} |= "OutOfMemoryError"' --since=2h

# Exclude noisy logs (!=)
logcli query '{app="nginx"} |= "500" != "healthcheck"' --limit=50

# Calculate log volume rate over time
logcli query --stats 'rate({app="payment-service"}[5m])'
```

---

## 4. OpenTelemetry Collector (`otelcol`)

```bash
# Validate OpenTelemetry Collector configuration file syntax
otelcol validate --config=/etc/otelcol/config.yaml

# Run OpenTelemetry Collector with custom configuration
otelcol --config=/etc/otelcol/config.yaml

# Test OTLP HTTP receiver endpoint for traces
curl -i -X POST http://localhost:4318/v1/traces \
  -H "Content-Type: application/json" \
  -d '{"resourceSpans": []}'

# Test OTLP HTTP receiver endpoint for metrics
curl -i -X POST http://localhost:4318/v1/metrics \
  -H "Content-Type: application/json" \
  -d '{"resourceMetrics": []}'
```

---

## 5. Elasticsearch & Kibana Operations

```bash
# Check Elasticsearch cluster health (green, yellow, red)
curl -s -u elastic:password http://localhost:9200/_cluster/health?pretty

# View all indices with document counts and storage size
curl -s -u elastic:password "http://localhost:9200/_cat/indices?v&s=pri.store.size:desc"

# View shard allocation and identify unassigned shards
curl -s -u elastic:password "http://localhost:9200/_cat/shards?v&h=index,shard,prirep,state,unassigned.reason"

# Explain why a shard is unassigned
curl -s -u elastic:password "http://localhost:9200/_cluster/allocation/explain?pretty"

# Search documents matching status 500
curl -s -u elastic:password -X GET "http://localhost:9200/app-logs-*/_search?pretty" \
  -H 'Content-Type: application/json' \
  -d '{
    "query": { "match": { "http.response.status_code": 500 } },
    "size": 5
  }'

# Check Kibana server status
curl -s http://localhost:5601/api/status | jq '{name: .name, version: .version.number, overall_status: .status.overall.state}'
```
