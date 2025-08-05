#!/bin/bash

# Security Testing Script
# Tests UFW firewall rules and Docker container security

set -e

echo "🔍 Starting security tests for UFW + Docker setup..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test function
test_port() {
    local port=$1
    local description=$2
    local expected=$3
    
    echo -n "Testing $description (port $port): "
    
    if nc -z -w3 localhost $port 2>/dev/null; then
        if [ "$expected" = "open" ]; then
            echo -e "${GREEN}✅ PASS${NC} (port is accessible)"
        else
            echo -e "${RED}❌ FAIL${NC} (port should be blocked)"
        fi
    else
        if [ "$expected" = "closed" ]; then
            echo -e "${GREEN}✅ PASS${NC} (port is properly blocked)"
        else
            echo -e "${RED}❌ FAIL${NC} (port should be accessible)"
        fi
    fi
}

echo ""
echo "🔧 Checking if required tools are installed..."

# Check for netcat
if ! command -v nc &> /dev/null; then
    echo "⚠️  Installing netcat for port testing..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get install -y netcat
    elif command -v brew &> /dev/null; then
        brew install netcat
    else
        echo "❌ Could not install netcat. Please install manually."
        exit 1
    fi
fi

# Check if nmap is available
if ! command -v nmap &> /dev/null; then
    echo "💡 Installing nmap for comprehensive port scanning..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get install -y nmap
    elif command -v brew &> /dev/null; then
        brew install nmap
    else
        echo "⚠️  nmap not available. Skipping comprehensive scan."
    fi
fi

echo ""
echo "🐳 Checking Docker containers status..."
docker-compose ps

echo ""
echo "🚪 Testing port accessibility..."

# Test allowed ports (should be accessible)
test_port 8080 "Web Application" "open"
test_port 8081 "API Service" "open"
test_port 2222 "SSH Server" "open"
test_port 9100 "Node Exporter" "open"

echo ""
echo "🚫 Testing blocked ports (should be inaccessible)..."

# Test some ports that should be blocked
test_port 3000 "Blocked port 3000" "closed"
test_port 5432 "Database port (should be internal)" "closed"
test_port 8888 "Random port 8888" "closed"
test_port 9999 "Random port 9999" "closed"

echo ""
echo "🔥 UFW Status:"
if command -v ufw &> /dev/null; then
    sudo ufw status numbered
else
    echo "⚠️  UFW not installed on this system"
fi

echo ""
echo "🌐 Network connectivity tests..."

# Test HTTP connectivity to allowed services
echo -n "Web App HTTP test: "
if curl -s -m 5 http://localhost:8080 > /dev/null; then
    echo -e "${GREEN}✅ ACCESSIBLE${NC}"
else
    echo -e "${RED}❌ NOT ACCESSIBLE${NC}"
fi

echo -n "API Service HTTP test: "
if curl -s -m 5 http://localhost:8081 > /dev/null; then
    echo -e "${GREEN}✅ ACCESSIBLE${NC}"
else
    echo -e "${RED}❌ NOT ACCESSIBLE${NC}"
fi

echo -n "Node Exporter metrics test: "
if curl -s -m 5 http://localhost:9100/metrics > /dev/null; then
    echo -e "${GREEN}✅ ACCESSIBLE${NC}"
else
    echo -e "${RED}❌ NOT ACCESSIBLE${NC}"
fi

echo ""
echo "🔍 Docker network inspection..."

# Check Docker networks
echo "Docker networks:"
docker network ls | grep -E "(NETWORK|secure)"

# Check container network settings
echo ""
echo "Container network details:"
docker inspect $(docker-compose ps -q) | jq -r '.[] | .Name + ": " + .NetworkSettings.Networks | keys | join(", ")'

echo ""
echo "📊 Port scan summary (if nmap is available):"
if command -v nmap &> /dev/null; then
    echo "Scanning localhost ports 1-10000..."
    nmap -p 1-10000 localhost 2>/dev/null | grep -E "(open|filtered)" | head -20
else
    echo "⚠️  nmap not available - skipping comprehensive port scan"
fi

echo ""
echo "🚨 Security recommendations:"
echo "1. ✅ Only necessary ports should be open"
echo "2. ✅ Database ports should not be accessible from outside"
echo "3. ✅ Monitor UFW logs: sudo tail -f /var/log/ufw.log"
echo "4. ✅ Regular security updates: sudo apt update && sudo apt upgrade"
echo "5. ✅ Use strong passwords and key-based authentication"

echo ""
echo "📝 Log monitoring commands:"
echo "   sudo tail -f /var/log/ufw.log                    # UFW firewall logs"
echo "   docker-compose logs                              # Container logs"
echo "   sudo netstat -tulpn | grep LISTEN                # All listening ports"
echo "   sudo ss -tulpn | grep LISTEN                     # Alternative to netstat"

echo ""
echo "🧪 Manual testing suggestions:"
echo "1. Try accessing blocked ports from another machine"
echo "2. Monitor logs while running port scans"
echo "3. Test SSH access with wrong credentials (should be rate-limited)"
echo "4. Simulate DoS attacks to test rate limiting"

echo ""
echo -e "${GREEN}🎉 Security testing complete!${NC}"
echo "Review the results above and ensure your security configuration meets your requirements."