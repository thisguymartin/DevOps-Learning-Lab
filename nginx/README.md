# NGINX Reverse Proxy Learning

## Learning Objectives
- Understand reverse proxy concepts
- Configure NGINX as a load balancer
- Learn SSL termination
- Practice upstream configurations

## Setup Instructions

1. **Generate SSL certificates (for HTTPS)**:
   ```bash
   mkdir ssl
   openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
     -keyout ssl/nginx.key -out ssl/nginx.crt \
     -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
   ```

2. **Start the services**:
   ```bash
   docker-compose up -d
   ```

3. **Test the setup**:
   - Main page: https://localhost
   - App 1: https://localhost/app1
   - App 2: https://localhost/app2

## Key Concepts

- **Upstream**: Backend servers to proxy requests to
- **Proxy Headers**: Forward client information to backend
- **SSL Termination**: NGINX handles SSL, backends use HTTP
- **Load Balancing**: Distribute requests across multiple backends

## Commands to Practice

```bash
# View logs
docker-compose logs nginx

# Test configuration
docker exec nginx-reverse-proxy nginx -t

# Reload configuration
docker exec nginx-reverse-proxy nginx -s reload

# Stop services
docker-compose down
```

## Next Steps
- Try different load balancing methods (least_conn, ip_hash)
- Add more backend services
- Configure rate limiting
- Explore NGINX modules