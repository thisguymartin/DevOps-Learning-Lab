# NGINX Proxy Manager Learning

## Learning Objectives
- GUI-based proxy management
- Automatic SSL certificate generation
- User-friendly interface for non-technical users
- Learn Let's Encrypt integration

## Setup Instructions

1. **Start the services**:
   ```bash
   docker-compose up -d
   ```

2. **Wait for initialization** (may take 2-3 minutes for first startup)

3. **Access the admin interface**:
   - URL: http://localhost:81
   - Default login:
     - Email: `admin@example.com`
     - Password: `changeme`

4. **Change default credentials immediately after first login**

## Configuration Steps

### Step 1: Create Proxy Hosts
1. Go to "Proxy Hosts" in the dashboard
2. Click "Add Proxy Host"
3. Configure:
   - Domain: `app1.local` (add to /etc/hosts: `127.0.0.1 app1.local`)
   - Forward to: `demo-app1:80`
   - Enable "Block Common Exploits"

### Step 2: Add SSL Certificate
1. Go to "SSL Certificates" tab
2. Request new certificate or upload custom
3. For testing, use self-signed certificates

### Step 3: Test Access
- App 1: http://app1.local
- App 2: Configure similarly with `app2.local`

## Key Features

- **Web Interface**: No need to edit config files
- **Let's Encrypt**: Automatic SSL certificates
- **Access Lists**: Control who can access services
- **Statistics**: Monitor proxy performance
- **Streams**: TCP/UDP proxy support

## Practice Exercises

1. **Basic Proxy**: Set up proxies for both demo apps
2. **Custom Domains**: Use `/etc/hosts` to test custom domains
3. **SSL Setup**: Generate and apply SSL certificates
4. **Access Control**: Create access lists with IP restrictions
5. **Load Balancing**: Add multiple backend servers

## Advanced Features

```bash
# View NPM logs
docker-compose logs nginx-proxy-manager

# Database backup
docker exec npm-db mysqldump -u npm -p npm > backup.sql

# Custom certificates
# Upload via web interface or mount volume
```

## Troubleshooting

- **503 Errors**: Check if backend containers are running
- **SSL Issues**: Verify certificate configuration
- **Login Problems**: Reset admin credentials via database
- **Port Conflicts**: Ensure ports 80, 81, 443 are available

## Next Steps
- Integrate with external services
- Configure custom error pages
- Set up monitoring and alerting
- Explore API for automation