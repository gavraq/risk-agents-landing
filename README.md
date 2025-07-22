# Risk Agents Landing Page

A modern, responsive landing page for Risk Agents, containerized with Docker for easy deployment.

## Features

- 🎨 Modern gradient design with animated elements
- 📱 Fully responsive (mobile-friendly)
- 🐳 Docker containerized for easy deployment
- 🚀 Production-ready with security headers
- 🔍 Health check endpoints
- 📊 Proper logging and error handling
- 🔒 Security best practices

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- Port 8080 available (or modify in docker-compose.yml)

### Deployment

1. **Clone/navigate to the project:**
   ```bash
   cd /Users/gavinslater/projects/landingpage
   ```

2. **Deploy with the script:**
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

   Or manually:
   ```bash
   docker-compose up -d --build
   ```

3. **Verify deployment:**
   ```bash
   curl http://localhost:8080/health
   ```

### Access the Site

- **Local development:** http://localhost:8080
- **Production:** https://www.risk-agents.com (once DNS configured)

## File Structure

```
landingpage/
├── index.html              # Updated landing page HTML
├── server.py               # Production Python HTTP server
├── Dockerfile              # Container definition
├── docker-compose.yml      # Docker Compose configuration
├── .dockerignore           # Docker ignore rules
├── deploy.sh              # Deployment script
└── README.md              # This file
```

## Configuration

### Domain Migration

The landing page has been updated from `gavinslater.co.uk` to `risk-agents.com`:

- **Title:** "Risk Agents - Welcome"
- **Branding:** "RA" logo, Risk Agents theme
- **Links:** Updated to point to `*.risk-agents.com` subdomains
- **Content:** Tailored for risk management focus

### Docker Configuration

- **Base Image:** Python 3.11 slim
- **Port:** 8080 (configurable in docker-compose.yml)
- **Security:** Non-root user, security headers
- **Health Checks:** Built-in health monitoring
- **Logging:** Structured logging to stdout

### Reverse Proxy Integration

The docker-compose.yml includes Traefik labels for:
- SSL termination with Let's Encrypt
- Domain routing (www.risk-agents.com)
- Non-www to www redirects

## Management Commands

```bash
# View logs
docker-compose logs -f

# Restart the service
docker-compose restart

# Stop the service
docker-compose down

# Rebuild and restart
docker-compose up -d --build

# Check container health
docker-compose ps
```

## Production Deployment

1. **DNS Configuration:**
   - Point `risk-agents.com` and `www.risk-agents.com` to your server IP
   - Configure subdomains (`ai.risk-agents.com`, `credit.risk-agents.com`)

2. **Reverse Proxy:**
   - Use Nginx Proxy Manager, Traefik, or similar
   - Configure SSL certificates (Let's Encrypt recommended)
   - Route `www.risk-agents.com` to `localhost:8080`

3. **Firewall:**
   - Ensure port 8080 is accessible from your reverse proxy
   - Block direct external access to port 8080 if using a proxy

## Development

To modify the landing page:

1. Edit `index.html` for content changes
2. Modify `server.py` for server configuration
3. Rebuild: `docker-compose up -d --build`

## Troubleshooting

### Container won't start
```bash
# Check logs
docker-compose logs

# Check if port is in use
lsof -i :8080
```

### Health check failing
```bash
# Test health endpoint
curl http://localhost:8080/health

# Check container status
docker-compose ps
```

### Permission issues
```bash
# Ensure proper permissions
chmod +x deploy.sh
sudo chown -R $USER:$USER .
```

## Security Notes

- Container runs as non-root user
- Security headers implemented
- CORS configured for risk-agents.com domains
- Health check endpoint available at `/health`
- No sensitive data exposed in logs
