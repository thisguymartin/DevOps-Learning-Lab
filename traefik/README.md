# Traefik Cloud-Native Reverse Proxy

## Learning Objectives
- Understand cloud-native proxy concepts
- Learn automatic service discovery
- Practice label-based configuration
- Explore advanced routing rules

## Setup Instructions

1. **Create the external network**:
   ```bash
   docker network create traefik-network
   ```

2. **Add entries to /etc/hosts** (for local testing):
   ```bash
   echo "127.0.0.1 traefik.localhost app1.localhost app2.localhost demo.localhost web.localhost" | sudo tee -a /etc/hosts
   ```

3. **Start the services**:
   ```bash
   docker-compose up -d
   ```

4. **Access the services**:
   - Traefik Dashboard: http://localhost:8080 or https://traefik.localhost
   - App 1: https://app1.localhost
   - App 2: https://app2.localhost  
   - Path routing: https://demo.localhost/nginx
   - Load balanced: https://web.localhost

## Key Concepts

### Service Discovery
- Automatic detection of Docker containers
- No manual configuration files needed
- Labels define routing rules

### Routing Rules
- **Host-based**: `Host(`app1.localhost`)`
- **Path-based**: `PathPrefix(`/api`)`
- **Combined**: `Host(`api.localhost`) && PathPrefix(`/v1`)`

### Middlewares
- **StripPrefix**: Remove path segments
- **AddPrefix**: Add path segments  
- **BasicAuth**: Authentication
- **RateLimit**: Request throttling

## Configuration Examples

### Basic Service
```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.myapp.rule=Host(`myapp.localhost`)"
  - "traefik.http.routers.myapp.entrypoints=websecure"
  - "traefik.http.routers.myapp.tls=true"
```

### With Middleware
```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.api.rule=Host(`api.localhost`)"
  - "traefik.http.routers.api.middlewares=api-auth"
  - "traefik.http.middlewares.api-auth.basicauth.users=admin:$$2y$$10$$..."
```

## Practice Exercises

1. **Basic Routing**: Create a new service with custom domain
2. **Path-based Routing**: Route `/api` and `/web` to different services
3. **Middleware**: Add authentication to a service
4. **Load Balancing**: Scale services and observe traffic distribution
5. **HTTPS**: Configure Let's Encrypt for real domains

## Advanced Features

### File Provider Configuration
Create `traefik.yml` for static configuration:
```yaml
api:
  dashboard: true
  insecure: true

entryPoints:
  web:
    address: ":80"
  websecure:
    address: ":443"

providers:
  docker:
    exposedByDefault: false
  file:
    filename: /etc/traefik/dynamic.yml
```

### Monitoring Integration
```bash
# Prometheus metrics
- --metrics.prometheus=true
- --metrics.prometheus.address=:8082

# Access logs
- --accesslog=true
- --accesslog.format=json
```

## Useful Commands

```bash
# View Traefik logs
docker-compose logs traefik

# Scale a service
docker-compose up -d --scale web-app=5

# Check service discovery
curl -s http://localhost:8080/api/http/services | jq

# Test routing
curl -H "Host: app1.localhost" http://localhost

# Clean up
docker-compose down
docker network rm traefik-network
```

## Troubleshooting

- **404 Errors**: Check labels and network configuration
- **SSL Issues**: Verify TLS settings and certificate resolvers
- **Service Not Found**: Ensure container is on correct network
- **Dashboard Access**: Check API settings and port bindings

## Next Steps
- Integrate with Kubernetes
- Configure external providers (Consul, etcd)
- Set up centralized logging
- Implement custom middlewares