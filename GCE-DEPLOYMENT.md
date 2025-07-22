# Risk Agents Landing Page - GCE Deployment

Quick deployment guide for Google Compute Engine with Nginx reverse proxy.

## Prerequisites

- Google Compute Engine VM running Ubuntu
- Domain name pointing to your VM's external IP
- SSH access to the VM

## Quick Deployment

### 1. Push to GitHub (Run locally)

```bash
# From your local project directory
cd /Users/gavinslater/projects/landingpage
chmod +x setup-github.sh
./setup-github.sh

# Follow the instructions to create GitHub repo and push
```

### 2. Deploy on GCE VM

SSH into your GCE VM and run:

```bash
# Download the deployment script
curl -O https://raw.githubusercontent.com/gavraq/risk-agents-landing/main/deploy-gce.sh

# Make it executable
chmod +x deploy-gce.sh

# Edit to update your repository URL
nano deploy-gce.sh  # Update REPO_URL with your GitHub repository

# Run deployment
./deploy-gce.sh
```

### 3. Configure DNS

Point your domain to your GCE VM's external IP:
- `A` record: `www.risk-agents.com` → `YOUR_VM_EXTERNAL_IP`
- `A` record: `risk-agents.com` → `YOUR_VM_EXTERNAL_IP`

### 4. Test Access

- Health check: `curl http://YOUR_VM_IP:8080/health`
- Local access: `http://YOUR_VM_IP`
- Domain access: `http://www.risk-agents.com` (after DNS propagation)

## Architecture

```
Internet → Nginx (Port 80/443) → Docker Container (Port 8080) → Python HTTP Server
```

## Management

```bash
# View application logs
cd /home/gavin_n_slater/risk-agents-landing
docker compose logs -f

# Restart application
docker compose restart

# Update from GitHub
git pull origin main
docker compose up -d --build

# View Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

## Security Features

- Container runs as non-root user
- Nginx security headers
- Docker container isolated networking
- Automatic SSL with Let's Encrypt (optional)
- Health check monitoring

## Firewall Configuration (GCE)

In Google Cloud Console, configure firewall rules:
- Allow HTTP (port 80)
- Allow HTTPS (port 443)
- Allow SSH (port 22)

Or using gcloud CLI:
```bash
gcloud compute firewall-rules create allow-http --allow tcp:80 --source-ranges 0.0.0.0/0
gcloud compute firewall-rules create allow-https --allow tcp:443 --source-ranges 0.0.0.0/0
```

## SSL Certificate

After DNS is configured:
```bash
sudo certbot --nginx -d www.risk-agents.com -d risk-agents.com
```

## Monitoring

- Container health: `docker compose ps`
- Nginx status: `sudo systemctl status nginx`
- Application health: `curl http://localhost:8080/health`

## Troubleshooting

### Container not starting
```bash
docker compose logs
docker compose ps
```

### Nginx issues
```bash
sudo nginx -t  # Test configuration
sudo systemctl status nginx
sudo tail -f /var/log/nginx/error.log
```

### DNS not resolving
```bash
nslookup www.risk-agents.com
dig www.risk-agents.com
```
