# Docker Swarm Learning Environment

## Learning Objectives
- Understand container orchestration fundamentals
- Learn Docker Swarm cluster management
- Practice service scaling and updates
- Explore service discovery and networking

## Setup Instructions

### Initialize Swarm Mode
```bash
# Initialize swarm (manager node)
docker swarm init

# If you have multiple network interfaces, specify one:
# docker swarm init --advertise-addr <MANAGER-IP>

# Join additional nodes (optional)
# docker swarm join --token <TOKEN> <MANAGER-IP>:2377
```

### Deploy the Stack
```bash
# Deploy all services
docker stack deploy -c docker-compose.yml swarm-demo

# Or deploy individual services
docker service create --name web --replicas 3 nginx:alpine
```

### Access Services
- **Web App**: http://localhost
- **Load Balancer**: http://localhost:8081  
- **API**: http://localhost:8081/api
- **Visualizer**: http://localhost:8080

## Key Concepts

### Services vs Containers
- **Service**: Desired state definition (replicas, constraints, etc.)
- **Tasks**: Individual container instances of a service
- **Swarm**: Cluster of Docker nodes working together

### Node Types
- **Manager Nodes**: Control the swarm, schedule services
- **Worker Nodes**: Run service tasks
- **Leader**: One manager acts as the leader (Raft consensus)

### Networking
- **Overlay Networks**: Multi-host networking for services
- **Service Discovery**: Services can find each other by name
- **Load Balancing**: Built-in request distribution

## Essential Commands

### Swarm Management
```bash
# View swarm status
docker info | grep Swarm

# List nodes
docker node ls

# Leave swarm
docker swarm leave --force
```

### Service Management
```bash
# List services
docker service ls

# View service details
docker service inspect swarm-demo_web

# View service logs
docker service logs swarm-demo_web

# Scale service
docker service scale swarm-demo_web=5

# Update service
docker service update --image nginx:latest swarm-demo_web
```

### Stack Management
```bash
# List stacks
docker stack ls

# View stack services
docker stack services swarm-demo

# Remove stack
docker stack rm swarm-demo
```

## Practice Exercises

### 1. Service Scaling
```bash
# Scale web service to 5 replicas
docker service scale swarm-demo_web=5

# Watch scaling in visualizer
# Scale down to 2 replicas
docker service scale swarm-demo_web=2
```

### 2. Rolling Updates
```bash
# Update web service image
docker service update --image nginx:1.21 swarm-demo_web

# Monitor update progress
docker service ps swarm-demo_web

# Rollback update
docker service rollback swarm-demo_web
```

### 3. Node Management
```bash
# Drain a node (move services away)
docker node update --availability drain <NODE-ID>

# Bring node back online
docker node update --availability active <NODE-ID>
```

### 4. Service Constraints
```bash
# Create service with placement constraints
docker service create --name manager-only \
  --constraint 'node.role==manager' \
  --replicas 1 \
  nginx:alpine
```

## Advanced Features

### Health Checks
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

### Resource Limits
```yaml
deploy:
  resources:
    limits:
      cpus: '0.50'
      memory: 512M
    reservations:
      cpus: '0.25'
      memory: 256M
```

### Secrets Management
```bash
# Create secret
echo "my-secret-password" | docker secret create db-password -

# Use in service
docker service create --name app \
  --secret db-password \
  my-app:latest
```

### Configs Management
```bash
# Create config
docker config create nginx-config nginx.conf

# Use in service
docker service create --name web \
  --config source=nginx-config,target=/etc/nginx/nginx.conf \
  nginx:alpine
```

## Monitoring and Debugging

### Service Inspection
```bash
# Detailed service info
docker service inspect --pretty swarm-demo_web

# Service task states
docker service ps swarm-demo_web

# Node resource usage
docker node inspect self --pretty
```

### Troubleshooting
```bash
# Check service logs
docker service logs -f swarm-demo_web

# Inspect failed tasks
docker service ps --no-trunc swarm-demo_web

# Network debugging
docker network ls
docker network inspect swarm-demo_swarm-network
```

## Security Best Practices

### TLS Configuration
- Swarm uses mutual TLS by default
- Certificates auto-rotate every 90 days
- Control plane traffic encrypted

### Access Control
```bash
# Create user-defined overlay network
docker network create --driver overlay --encrypted secure-network

# Use secrets for sensitive data
docker secret create api-key api-key.txt
```

## Production Considerations

### High Availability
- Odd number of manager nodes (3, 5, 7)
- Separate manager and worker nodes
- Regular backups of swarm state

### Monitoring Integration
- Prometheus node-exporter
- Container logs aggregation
- Health check endpoints

### Update Strategies
```yaml
deploy:
  update_config:
    parallelism: 1
    delay: 10s
    failure_action: rollback
    monitor: 60s
```

## Cleanup
```bash
# Remove stack
docker stack rm swarm-demo

# Leave swarm mode
docker swarm leave --force

# Clean up volumes and networks
docker volume prune
docker network prune
```

## Next Steps
- Compare with Kubernetes
- Integrate monitoring solutions
- Implement CI/CD pipelines
- Explore Docker Swarm in production environments