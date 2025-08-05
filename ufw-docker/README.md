# UFW + Docker Security Learning Environment

## Learning Objectives
- Understand Linux firewall configuration with UFW
- Learn Docker network security best practices
- Practice container isolation and access control
- Explore intrusion detection and monitoring
- Implement defense-in-depth security strategies

## Security Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    UFW Firewall                        │
├─────────────────────────────────────────────────────────┤
│  ✅ Port 22   (SSH)           🚪 Allowed              │
│  ✅ Port 8080 (Web App)       🚪 Allowed              │
│  ✅ Port 8081 (API)           🚪 Allowed              │
│  ✅ Port 2222 (SSH Server)    🚪 Allowed              │
│  ✅ Port 9100 (Monitoring)    🚪 Allowed              │
│  ❌ All Other Ports           🚫 Blocked              │
└─────────────────────────────────────────────────────────┘
           │
    ┌──────▼──────┐
    │ Docker Host │
    └──────┬──────┘
           │
┌──────────▼───────────┐
│  Secure Network     │
│  (172.30.0.0/16)    │
├─────────────────────┤
│  🌐 web-app:8080    │
│  🔧 api-service     │
│  🗄️  database       │
│  🔑 ssh-server      │
│  📊 monitor         │
└─────────────────────┘
```

## Prerequisites

### Ubuntu/Debian Systems
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y ufw docker.io docker-compose netcat nmap curl jq

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

### macOS Systems
```bash
# Install Docker Desktop and ensure UFW-like security
brew install --cask docker
brew install netcat nmap curl jq

# Note: macOS uses different firewall (pf), but concepts are similar
```

## Setup Instructions

### 1. Automatic Setup (Recommended)
```bash
# Run the automated firewall setup (Ubuntu/Debian only)
sudo ./setup-firewall.sh
```

### 2. Manual Setup
```bash
# Install and configure UFW
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (critical - don't lock yourself out!)
sudo ufw allow ssh

# Allow application ports
sudo ufw allow 8080/tcp comment 'Secure Web App'
sudo ufw allow 8081/tcp comment 'Secure API'
sudo ufw allow 2222/tcp comment 'SSH Server'
sudo ufw allow 9100/tcp comment 'Node Exporter'

# Enable UFW
sudo ufw enable

# Start containers
docker-compose up -d
```

### 3. Access Applications
- **Secure Web App**: http://localhost:8080
- **Secure API**: http://localhost:8081
- **SSH Server**: `ssh -p 2222 testuser@localhost` (password: sshpass123)
- **Node Exporter**: http://localhost:9100/metrics

## Key Security Concepts

### Defense in Depth
1. **Network Firewall** (UFW) - First line of defense
2. **Container Isolation** - Process and network separation
3. **Access Control** - Authentication and authorization
4. **Monitoring** - Detection and alerting
5. **Logging** - Audit trails and forensics

### UFW (Uncomplicated Firewall)
- **iptables frontend** - Simplified firewall management
- **Default deny** - Block all incoming traffic by default
- **Explicit allow** - Only allow necessary ports/services
- **Rate limiting** - Prevent brute force attacks
- **Logging** - Track connection attempts

### Docker Security Features
- **Network isolation** - Containers in private networks
- **Resource limits** - CPU/memory constraints
- **No root privileges** - Run as non-root users when possible
- **Read-only filesystems** - Prevent tampering
- **Secrets management** - Secure credential handling

## Security Testing

### Run Automated Tests
```bash
# Execute security test suite
./test-security.sh
```

### Manual Security Tests

#### Port Scanning
```bash
# Test open ports
nmap -p 1-10000 localhost

# Test specific ports
nc -zv localhost 8080  # Should succeed
nc -zv localhost 3000  # Should fail

# Test from external machine
nmap -p 1-10000 <your-server-ip>
```

#### Firewall Testing
```bash
# Check UFW status
sudo ufw status verbose

# Monitor firewall logs
sudo tail -f /var/log/ufw.log

# Test rate limiting
for i in {1..10}; do ssh -p 2222 testuser@localhost; done
```

#### Container Security
```bash
# Check container network isolation
docker exec secure-web-app ping secure-db  # Should work
docker exec secure-web-app ping 8.8.8.8    # Should work
docker exec secure-web-app nmap localhost  # Limited visibility

# Check resource limits
docker stats

# Verify no root privileges
docker exec secure-web-app whoami
```

## Advanced Security Configuration

### Intrusion Detection with fail2ban
```bash
# Install fail2ban
sudo apt install fail2ban

# Configure fail2ban for SSH
sudo cat > /etc/fail2ban/jail.local << EOF
[sshd]
enabled = true
port = ssh,2222
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
EOF

sudo systemctl restart fail2ban
```

### Network Monitoring
```bash
# Monitor network connections
sudo netstat -tulpn | grep LISTEN

# Monitor network traffic
sudo tcpdump -i any port 8080

# Check established connections
sudo ss -tulpn | grep ESTABLISHED
```

### Container Security Scanning
```bash
# Scan images for vulnerabilities (if Docker Scout is available)
docker scout cves nginx:alpine
docker scout cves httpd:alpine

# Check for security best practices
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd):/host \
  aquasec/trivy fs /host
```

## Security Monitoring

### Log Analysis
```bash
# UFW firewall logs
sudo tail -f /var/log/ufw.log

# SSH authentication logs
sudo tail -f /var/log/auth.log

# Container logs
docker-compose logs -f

# System logs
sudo journalctl -f -u docker
```

### Metrics Collection
```bash
# Node Exporter metrics
curl http://localhost:9100/metrics

# Container metrics
docker stats --no-stream

# Network metrics
cat /proc/net/dev
```

### Alerting Setup
```bash
# Simple email alert for failed SSH attempts
sudo cat > /usr/local/bin/ssh-alert.sh << 'EOF'
#!/bin/bash
tail -f /var/log/auth.log | grep --line-buffered "Failed password" | \
while read line; do
    echo "$line" | mail -s "SSH Failed Login" admin@example.com
done
EOF

sudo chmod +x /usr/local/bin/ssh-alert.sh
```

## Security Best Practices

### Container Security
```yaml
# Security-hardened service example
services:
  secure-app:
    image: nginx:alpine
    user: "1000:1000"          # Non-root user
    read_only: true            # Read-only filesystem
    tmpfs:
      - /tmp                   # Writable temp directory
    cap_drop:
      - ALL                    # Drop all capabilities
    cap_add:
      - NET_BIND_SERVICE       # Only needed capabilities
    security_opt:
      - no-new-privileges:true # Prevent privilege escalation
```

### Network Security
```yaml
networks:
  secure-network:
    driver: bridge
    internal: true             # No internet access
  dmz-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.31.0.0/16
```

### Secrets Management
```bash
# Use Docker secrets instead of environment variables
echo "secret-password" | docker secret create db-password -

# Mount secrets as files
volumes:
  - type: secret
    source: db-password
    target: /run/secrets/db-password
```

## Incident Response

### Security Incident Checklist
1. **Identify** - What happened? When? How?
2. **Contain** - Isolate affected systems
3. **Eradicate** - Remove threats and vulnerabilities
4. **Recover** - Restore systems and services
5. **Learn** - Document and improve security

### Emergency Commands
```bash
# Block all traffic immediately
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default deny outgoing
sudo ufw enable

# Stop all containers
docker-compose down

# Check for suspicious processes
ps aux | grep -E "(crypto|mining|ddos)"

# Check network connections
sudo netstat -tulpn | grep ESTABLISHED
```

## Compliance and Auditing

### Security Audit Script
```bash
#!/bin/bash
# Basic security audit

echo "=== Security Audit Report ==="
echo "Date: $(date)"
echo ""

echo "UFW Status:"
sudo ufw status verbose

echo ""
echo "Open Ports:"
sudo netstat -tulpn | grep LISTEN

echo ""
echo "Docker Security:"
docker ps --format "table {{.Names}}\t{{.Ports}}\t{{.Status}}"

echo ""
echo "Recent Failed Logins:"
sudo grep "Failed password" /var/log/auth.log | tail -10
```

### Documentation Requirements
- Network topology diagrams
- Firewall rule documentation
- Container security configurations
- Incident response procedures
- Regular security assessments

## Troubleshooting

### Common Issues
```bash
# UFW blocking legitimate traffic
sudo ufw status numbered
sudo ufw delete [rule-number]

# Docker containers can't communicate
docker network ls
docker network inspect secure-network

# Port conflicts
sudo netstat -tulpn | grep :8080
docker-compose down && docker-compose up -d
```

### Performance Impact
```bash
# Monitor firewall performance
sudo iptables -L -n -v

# Check system resources
htop
iostat -x 1

# Container resource usage
docker stats
```

## Cleanup and Reset

### Reset UFW Configuration
```bash
sudo ufw --force reset
sudo ufw default allow incoming
sudo ufw default allow outgoing
```

### Remove Containers and Networks
```bash
docker-compose down -v
docker system prune -a
```

### Restore Default Security
```bash
# Remove custom firewall rules
sudo ufw --force reset

# Stop all services
docker-compose down -v

# Clean up logs
sudo truncate -s 0 /var/log/ufw.log
```

## Next Steps
- Implement Web Application Firewall (WAF)
- Set up centralized logging with ELK stack
- Configure SIEM (Security Information and Event Management)
- Learn about container runtime security (AppArmor, SELinux)
- Explore service mesh security (Istio, Linkerd)
- Study compliance frameworks (SOC 2, PCI DSS, HIPAA)