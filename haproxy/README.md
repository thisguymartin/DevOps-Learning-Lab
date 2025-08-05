# HAProxy Load Balancer Learning

## Learning Objectives
- Understand enterprise-grade load balancing
- Learn different load balancing algorithms
- Practice health checking and failover
- Explore advanced HAProxy features

## Setup Instructions

1. **Generate SSL certificate** (for HTTPS):
   ```bash
   mkdir ssl
   openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
     -keyout ssl/haproxy.key -out ssl/haproxy.crt \
     -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
   
   # Combine for HAProxy
   cat ssl/haproxy.crt ssl/haproxy.key > ssl/haproxy.pem
   ```

2. **Start the services**:
   ```bash
   docker-compose up -d
   ```

3. **Access the services**:
   - Web app: http://localhost (redirects to HTTPS)
   - API: http://localhost/api
   - HAProxy Stats: http://localhost:8888/stats (admin/password)

## Key Concepts

### Load Balancing Algorithms

1. **Round Robin**: Requests distributed evenly across servers
2. **Least Connections**: Route to server with fewest active connections
3. **Weighted**: Servers handle traffic based on assigned weights
4. **Static Round Robin**: Weighted round robin with static weights

### Health Checking
- **HTTP Checks**: Verify service responds to HTTP requests
- **TCP Checks**: Check if port is accepting connections
- **Custom Checks**: Application-specific health endpoints

### High Availability Features
- **Failover**: Automatic removal of failed servers
- **Session Persistence**: Stick sessions to specific servers
- **Circuit Breaker**: Temporarily bypass failing services

## Configuration Examples

### Basic Backend
```
backend web_servers
    balance roundrobin
    option httpchk GET /health
    
    server web1 web1:80 check
    server web2 web2:80 check backup
```

### Advanced ACL Routing
```
frontend main
    bind *:80
    
    acl is_api path_beg /api
    acl is_admin src 192.168.1.0/24
    
    use_backend api_servers if is_api
    use_backend admin_servers if is_admin
    default_backend web_servers
```

### SSL/TLS Configuration
```
frontend ssl_frontend
    bind *:443 ssl crt /etc/ssl/certs/
    redirect scheme https if !{ ssl_fc }
```

## Practice Exercises

1. **Algorithm Testing**: 
   - Change balance algorithms and observe distribution
   - Test with `curl` or browser refresh

2. **Health Checks**: 
   - Stop a backend container and watch failover
   - Monitor stats page during failures

3. **Weighted Load Balancing**: 
   - Assign different weights to servers
   - Measure traffic distribution

4. **SSL Termination**: 
   - Configure HTTPS frontend
   - Test HTTP to HTTPS redirects

5. **Advanced Routing**: 
   - Add path-based routing rules
   - Implement header-based routing

## Monitoring & Statistics

### Stats Page Features
- Real-time server status
- Request/response metrics  
- Error rates and response times
- Manual server enable/disable

### Key Metrics to Monitor
- **Queue time**: Time requests wait for backend
- **Connect time**: Time to establish backend connection
- **Response time**: Total request processing time
- **Error rates**: 4xx/5xx response percentages

## Advanced Configuration

### Stick Tables (Session Persistence)
```
backend web_servers
    balance roundrobin
    stick-table type ip size 200k expire 30m
    stick on src
```

### Rate Limiting
```
frontend main
    stick-table type ip size 100k expire 30s store http_req_rate(10s)
    http-request track-sc0 src
    http-request deny if { sc_http_req_rate(0) gt 20 }
```

## Useful Commands

```bash
# View HAProxy logs
docker-compose logs haproxy

# Test load balancing
for i in {1..10}; do curl -s http://localhost | grep "Server"; done

# Check configuration syntax
docker exec haproxy-lb haproxy -c -f /usr/local/etc/haproxy/haproxy.cfg

# Reload configuration (zero downtime)
docker exec haproxy-lb haproxy -sf $(pidof haproxy) -f /usr/local/etc/haproxy/haproxy.cfg

# Monitor real-time stats
watch -n 1 'curl -s http://admin:password@localhost:8888/stats\;csv'
```

## Troubleshooting

- **503 Errors**: Check backend server health and connectivity
- **SSL Issues**: Verify certificate format and file permissions
- **Routing Problems**: Review ACL rules and backend selection
- **Performance Issues**: Monitor queue times and connection limits

## Next Steps
- Integrate with service discovery (Consul, etcd)
- Configure logging and monitoring integration
- Implement custom error pages
- Explore HAProxy Data Plane API