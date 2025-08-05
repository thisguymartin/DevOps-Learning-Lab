# Prometheus + Grafana Monitoring Stack

## Learning Objectives
- Understand modern monitoring and observability
- Learn Prometheus metrics collection and querying
- Practice Grafana dashboard creation and visualization
- Explore alerting with AlertManager
- Monitor containerized applications

## Architecture Overview

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Grafana   │◄───│ Prometheus  │◄───│   Targets   │
│ Dashboards  │    │   Server    │    │ (Exporters) │
└─────────────┘    └─────────────┘    └─────────────┘
       ▲                   │
       │                   ▼
┌─────────────┐    ┌─────────────┐
│   Users     │    │AlertManager │
│  (Alerts)   │    │   (Alerts)  │
└─────────────┘    └─────────────┘
```

## Setup Instructions

1. **Start the monitoring stack**:
   ```bash
   docker-compose up -d
   ```

2. **Wait for services to initialize** (2-3 minutes)

3. **Access interfaces**:
   - **Grafana**: http://localhost:3000 (admin/admin123)
   - **Prometheus**: http://localhost:9090
   - **AlertManager**: http://localhost:9093
   - **Node Exporter**: http://localhost:9100/metrics
   - **cAdvisor**: http://localhost:8080
   - **Demo Web App**: http://localhost:8081
   - **Demo API**: http://localhost:8082

## Key Components

### Prometheus
- **Time-series database** for metrics storage
- **Pull-based** metrics collection
- **PromQL** query language
- **Service discovery** capabilities

### Grafana
- **Visualization platform** for metrics
- **Dashboard creation** and sharing
- **Alerting** and notification
- **Multiple data sources** support

### Exporters
- **Node Exporter**: System metrics (CPU, memory, disk)
- **cAdvisor**: Container metrics (Docker stats)
- **Custom exporters**: Application-specific metrics

### AlertManager
- **Alert routing** and grouping
- **Notification management** (email, Slack, webhooks)
- **Silence and inhibition** rules

## Essential Prometheus Queries (PromQL)

### System Metrics
```promql
# CPU usage percentage
100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory usage percentage
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# Disk usage percentage
100 - ((node_filesystem_avail_bytes * 100) / node_filesystem_size_bytes)

# Network traffic (bytes per second)
rate(node_network_receive_bytes_total[5m])
rate(node_network_transmit_bytes_total[5m])
```

### Container Metrics
```promql
# Container CPU usage
rate(container_cpu_usage_seconds_total[5m])

# Container memory usage
container_memory_usage_bytes

# Container network I/O
rate(container_network_receive_bytes_total[5m])
rate(container_network_transmit_bytes_total[5m])
```

### Application Metrics
```promql
# HTTP request rate
rate(http_requests_total[5m])

# HTTP error rate
rate(http_requests_total{status=~"5.*"}[5m])

# Response time percentiles
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

## Grafana Dashboard Creation

### Basic Dashboard Setup
1. **Login to Grafana** (admin/admin123)
2. **Create new dashboard** (+) → Dashboard
3. **Add panel** → Add new panel
4. **Configure data source** (Prometheus should be auto-configured)
5. **Write PromQL query**
6. **Configure visualization** (Graph, Stat, Gauge, etc.)

### Recommended Dashboards

#### System Overview Dashboard
- CPU usage over time
- Memory utilization
- Disk space usage
- Network I/O
- System load average

#### Container Monitoring Dashboard
- Running containers count
- Container CPU usage
- Container memory usage
- Container restart count
- Docker daemon status

#### Application Performance Dashboard
- HTTP request rate
- Response time percentiles
- Error rate
- Active connections
- Queue lengths

## Alerting Configuration

### Prometheus Alert Rules
Create `alerts/system.yml`:
```yaml
groups:
- name: system
  rules:
  - alert: HighCPUUsage
    expr: 100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High CPU usage detected"
      description: "CPU usage is above 80% for more than 5 minutes"
  
  - alert: HighMemoryUsage
    expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 85
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "High memory usage detected"
      description: "Memory usage is above 85% for more than 5 minutes"
```

### AlertManager Configuration
Configure notification channels in `alertmanager.yml`:
```yaml
receivers:
- name: 'slack'
  slack_configs:
  - api_url: 'YOUR_SLACK_WEBHOOK_URL'
    channel: '#alerts'
    title: 'Alert: {{ .GroupLabels.alertname }}'
    text: '{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'
```

## Practice Exercises

### 1. System Monitoring
```bash
# Generate CPU load
stress --cpu 2 --timeout 300s

# Monitor memory usage
watch -n 1 'free -h'

# Check metrics in Prometheus: node_cpu_seconds_total
```

### 2. Container Monitoring
```bash
# Scale demo applications
docker-compose up -d --scale web-app=3 --scale api-app=2

# Monitor container metrics in cAdvisor
# Create dashboard showing container resource usage
```

### 3. Custom Metrics
```bash
# Add custom application metrics
# Instrument your application with Prometheus client libraries
# Create dashboard showing application-specific metrics
```

### 4. Alert Testing
```bash
# Trigger high CPU alert
stress --cpu 4 --timeout 600s

# Check AlertManager: http://localhost:9093
# Verify alert notifications
```

## Advanced Features

### Service Discovery
Configure Prometheus to auto-discover services:
```yaml
scrape_configs:
- job_name: 'docker-containers'
  docker_sd_configs:
  - host: unix:///var/run/docker.sock
  relabel_configs:
  - source_labels: [__meta_docker_container_label_prometheus_io_scrape]
    action: keep
    regex: true
```

### Recording Rules
Create `rules/aggregation.yml`:
```yaml
groups:
- name: aggregation
  interval: 30s
  rules:
  - record: instance:node_cpu_utilization:rate5m
    expr: 100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) by (instance) * 100)
```

### Grafana Provisioning
Auto-provision dashboards and data sources:
```yaml
# grafana/provisioning/dashboards/dashboard.yml
providers:
- name: 'default'
  folder: ''
  type: file
  options:
    path: /var/lib/grafana/dashboards
```

## Security Best Practices

### Authentication
```yaml
# docker-compose.yml
environment:
  GF_SECURITY_ADMIN_USER: ${ADMIN_USER}
  GF_SECURITY_ADMIN_PASSWORD: ${ADMIN_PASSWORD}
  GF_AUTH_ANONYMOUS_ENABLED: false
```

### Network Security
```yaml
networks:
  monitoring:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

### Secrets Management
```bash
# Use Docker secrets for sensitive data
echo "admin123" | docker secret create grafana_password -
```

## Performance Tuning

### Prometheus Configuration
```yaml
global:
  scrape_interval: 15s     # Adjust based on needs
  evaluation_interval: 15s

storage:
  tsdb:
    retention.time: 15d    # Adjust retention period
    retention.size: 10GB   # Limit storage size
```

### Grafana Optimization
```yaml
environment:
  GF_DATABASE_TYPE: postgres  # Use external database
  GF_SESSION_PROVIDER: redis  # Use Redis for sessions
```

## Troubleshooting

### Common Issues
```bash
# Check Prometheus targets
curl http://localhost:9090/api/v1/targets

# View Prometheus logs
docker-compose logs prometheus

# Check Grafana logs
docker-compose logs grafana

# Verify exporter metrics
curl http://localhost:9100/metrics
```

### Debugging Queries
```promql
# Check if metrics exist
{__name__=~"node_.*"}

# Find metrics by pattern
{__name__=~".*cpu.*"}

# Debug label values
label_values(node_cpu_seconds_total, mode)
```

## Production Considerations

### High Availability
- Multiple Prometheus instances
- Grafana cluster setup
- External storage (PostgreSQL/MySQL)
- Load balancing

### Scalability
- Prometheus federation
- Remote storage (Thanos, Cortex)
- Horizontal pod autoscaling

### Backup Strategy
```bash
# Backup Grafana dashboards
curl -u admin:admin123 http://localhost:3000/api/search > dashboards.json

# Backup Prometheus data
docker run --rm -v prometheus-data:/data -v $(pwd):/backup alpine tar czf /backup/prometheus-backup.tar.gz /data
```

## Cleanup
```bash
# Stop services
docker-compose down

# Remove volumes
docker-compose down -v

# Clean up images
docker system prune -a
```

## Next Steps
- Integrate with Kubernetes (Prometheus Operator)
- Explore advanced exporters (JMX, SNMP, custom)
- Implement distributed tracing (Jaeger, Zipkin)
- Set up centralized logging (ELK stack)
- Learn about SRE practices and SLIs/SLOs