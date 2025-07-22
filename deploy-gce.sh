#!/bin/bash

# Risk Agents Landing Page - GCE Deployment Script
# For deployment on Google Compute Engine with Nginx reverse proxy

set -e  # Exit on any error

echo "🌐 Risk Agents Landing Page - GCE Deployment"
echo "============================================"

# Configuration
DOMAIN="www.risk-agents.com"
REPO_URL="https://github.com/gavraq/risk-agents-landing.git"
PROJECT_DIR="/home/gavin_n_slater/risk-agents-landing"
NGINX_CONF="/etc/nginx/sites-available/risk-agents"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as the correct user
if [ "$USER" != "gavin_n_slater" ]; then
    print_error "Please run this script as gavin_n_slater user"
    exit 1
fi

# Update system packages
print_status "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install required packages
print_status "Installing required packages..."
sudo apt install -y git curl docker.io docker-compose-plugin certbot python3-certbot-nginx

# Add user to docker group
print_status "Adding user to docker group..."
sudo usermod -aG docker gavin_n_slater
print_warning "You may need to log out and back in for docker group changes to take effect"

# Enable and start Docker
print_status "Starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# Clone or update the repository
if [ -d "$PROJECT_DIR" ]; then
    print_status "Updating existing repository..."
    cd "$PROJECT_DIR"
    git pull origin main
else
    print_status "Cloning repository..."
    git clone "$REPO_URL" "$PROJECT_DIR"
    cd "$PROJECT_DIR"
fi

# Build and start the Docker container
print_status "Building and starting Docker container..."
docker compose down --remove-orphans 2>/dev/null || true
docker compose build --no-cache
docker compose up -d

# Wait for container to be healthy
print_status "Waiting for container to be healthy..."
sleep 10

# Check container health
if docker compose ps | grep -q "healthy\|Up"; then
    print_success "Container is running successfully"
else
    print_error "Container failed to start properly"
    docker compose logs
    exit 1
fi

# Create Nginx configuration
print_status "Configuring Nginx reverse proxy..."
sudo tee "$NGINX_CONF" > /dev/null <<EOF
server {
    listen 80;
    server_name risk-agents.com www.risk-agents.com;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    
    # Redirect non-www to www
    if (\$host = risk-agents.com) {
        return 301 https://www.risk-agents.com\$request_uri;
    }
    
    # Proxy to Docker container
    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # Health check endpoint
    location /health {
        proxy_pass http://127.0.0.1:8080/health;
        access_log off;
    }
}
EOF

# Enable the site
print_status "Enabling Nginx site..."
sudo ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default  # Remove default site

# Test Nginx configuration
print_status "Testing Nginx configuration..."
if sudo nginx -t; then
    print_success "Nginx configuration is valid"
    sudo systemctl reload nginx
else
    print_error "Nginx configuration is invalid"
    exit 1
fi

# Configure firewall (if ufw is active)
if sudo ufw status | grep -q "Status: active"; then
    print_status "Configuring firewall..."
    sudo ufw allow 'Nginx Full'
    sudo ufw allow ssh
fi

# Setup SSL with Let's Encrypt (optional - requires domain to be pointing to server)
read -p "Do you want to set up SSL with Let's Encrypt? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Setting up SSL certificate..."
    sudo certbot --nginx -d www.risk-agents.com -d risk-agents.com --non-interactive --agree-tos --email your-email@example.com
    print_warning "Please update the email address in the certbot command above"
fi

# Create systemd service for auto-start
print_status "Creating systemd service..."
sudo tee /etc/systemd/system/risk-agents-landing.service > /dev/null <<EOF
[Unit]
Description=Risk Agents Landing Page
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$PROJECT_DIR
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
TimeoutStartSec=0
User=gavin_n_slater

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable risk-agents-landing.service

# Display final status
print_success "Deployment completed successfully!"
echo ""
echo "📊 Service Status:"
echo "=================="
echo "🐳 Docker Container:"
docker compose ps
echo ""
echo "🌐 Nginx Status:"
sudo systemctl status nginx --no-pager -l
echo ""
echo "🔗 Access URLs:"
echo "  Local: http://localhost:8080"
echo "  Public: http://$(curl -s ifconfig.me)"
echo "  Domain: http://www.risk-agents.com (once DNS is configured)"
echo ""
echo "📋 Management Commands:"
echo "  View logs: cd $PROJECT_DIR && docker compose logs -f"
echo "  Restart: cd $PROJECT_DIR && docker compose restart"
echo "  Update: cd $PROJECT_DIR && git pull && docker compose up -d --build"
echo ""
echo "🔒 Next Steps:"
echo "  1. Point www.risk-agents.com DNS to your server IP: $(curl -s ifconfig.me)"
echo "  2. Update the repository URL in this script"
echo "  3. Configure SSL certificate with: sudo certbot --nginx -d www.risk-agents.com"

print_success "Repository configured for https://github.com/gavraq/risk-agents-landing.git"
