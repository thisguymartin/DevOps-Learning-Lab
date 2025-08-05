#!/bin/bash

# UFW + Docker Security Setup Script
# This script configures UFW firewall rules for Docker containers

set -e

echo "🔥 Setting up UFW firewall for Docker containers..."

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "⚠️  This script must be run as root (use sudo)" 
   exit 1
fi

# Install UFW if not already installed
if ! command -v ufw &> /dev/null; then
    echo "📦 Installing UFW..."
    apt-get update
    apt-get install -y ufw
fi

# Reset UFW to default settings
echo "🔄 Resetting UFW to defaults..."
ufw --force reset

# Default policies
echo "🛡️  Setting default policies..."
ufw default deny incoming
ufw default allow outgoing

# Allow SSH (important to not lock yourself out!)
echo "🔑 Allowing SSH access..."
ufw allow ssh
ufw allow 22/tcp

# Allow loopback
echo "🔄 Allowing loopback traffic..."
ufw allow in on lo
ufw allow out on lo

# Allow Docker daemon API (if needed for remote access)
# Uncomment next line if you need remote Docker API access
# ufw allow 2376/tcp comment 'Docker daemon API'

# Allow specific ports for our applications
echo "🌐 Configuring application ports..."

# Web application
ufw allow 8080/tcp comment 'Secure Web App'

# API service  
ufw allow 8081/tcp comment 'Secure API'

# SSH server (custom port)
ufw allow 2222/tcp comment 'SSH Server'

# Monitoring (Node Exporter)
ufw allow 9100/tcp comment 'Node Exporter'

# Docker network configuration
echo "🐳 Configuring Docker network rules..."

# Allow communication within Docker networks
# This allows containers to communicate with each other
ufw allow in on docker0
ufw allow out on docker0

# Allow Docker bridge network
# Adjust subnet as needed (172.30.0.0/16 matches our docker-compose network)
ufw allow from 172.30.0.0/16

# Docker-specific UFW configuration
echo "⚙️  Configuring UFW for Docker compatibility..."

# Create UFW configuration for Docker
cat << 'EOF' > /etc/ufw/after.rules
# Docker rules - allow containers to communicate
*filter
:ufw-user-forward - [0:0]
:DOCKER-USER - [0:0]
-A DOCKER-USER -j ufw-user-forward

# Allow all traffic from Docker networks
-A DOCKER-USER -s 172.16.0.0/12 -j ACCEPT
-A DOCKER-USER -s 10.0.0.0/8 -j ACCEPT

# Drop everything else
-A DOCKER-USER -j DROP

COMMIT
EOF

# Rate limiting for security
echo "⏱️  Setting up rate limiting..."
ufw limit ssh comment 'Rate limit SSH'
ufw limit 8080/tcp comment 'Rate limit Web App'
ufw limit 8081/tcp comment 'Rate limit API'

# Logging configuration
echo "📝 Enabling UFW logging..."
ufw logging on

# Enable UFW
echo "✅ Enabling UFW firewall..."
ufw --force enable

# Display status
echo ""
echo "🎉 UFW configuration complete!"
echo ""
echo "📊 Current UFW status:"
ufw status verbose

echo ""
echo "🔍 To monitor firewall activity:"
echo "   sudo tail -f /var/log/ufw.log"
echo ""
echo "🚀 Start Docker containers:"
echo "   docker-compose up -d"
echo ""
echo "🧪 Test firewall rules:"
echo "   nmap -p 1-10000 localhost"
echo ""

# Additional security recommendations
cat << 'EOF'
🛡️  Additional Security Recommendations:

1. 📋 Monitor firewall logs regularly:
   sudo tail -f /var/log/ufw.log

2. 🔍 Check for failed connection attempts:
   sudo grep "DPT" /var/log/ufw.log | grep -v "ALLOW"

3. 🎯 Test specific ports:
   nc -zv localhost 8080  # Should succeed
   nc -zv localhost 3000  # Should fail (port not allowed)

4. 📊 Monitor with fail2ban (optional):
   sudo apt install fail2ban

5. 🔄 Regular security updates:
   sudo apt update && sudo apt upgrade

6. 🏷️  Use Docker networks instead of host networking
   when possible to improve isolation

7. 🔐 Consider using secrets management for sensitive data
   instead of environment variables

EOF

echo "⚠️  IMPORTANT: Test your configuration before deploying to production!"
echo "   Make sure you can still access your system remotely if applicable."