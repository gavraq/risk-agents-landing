#!/bin/bash
# Quick manual deployment for Risk Agents Landing Page

echo "🌐 Deploying Risk Agents Landing Page..."

# Install additional packages
echo "📦 Installing additional packages..."
sudo apt install -y git curl certbot python3-certbot-nginx

# Clone repository
echo "📥 Cloning repository..."
if [ -d "risk-agents-landing" ]; then
    cd risk-agents-landing
    git pull origin main
else
    git clone https://github.com/gavraq/risk-agents-landing.git
    cd risk-agents-landing
fi

# Build and start container
echo "🐳 Building and starting Docker container..."
sudo docker compose down --remove-orphans 2>/dev/null || true
sudo docker compose build --no-cache
sudo docker compose up -d

# Wait and check status
echo "⏳ Waiting for container to start..."
sleep 10

echo "📊 Container status:"
sudo docker compose ps

echo "🔍 Testing health endpoint..."
if curl -f http://localhost:8080/health >/dev/null 2>&1; then
    echo "✅ Application is running!"
else
    echo "❌ Health check failed. Checking logs..."
    sudo docker compose logs
    exit 1
fi

# Configure Nginx
echo "🌐 Configuring Nginx..."
sudo tee /etc/nginx/sites-available/risk-agents > /dev/null <<EOF
server {
    listen 80;
    server_name risk-agents.com www.risk-agents.com;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    
    # Redirect non-www to www for HTTPS
    if (\$scheme = https) {
        if (\$host = risk-agents.com) {
            return 301 https://www.risk-agents.com\$request_uri;
        }
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
echo "🔗 Enabling Nginx site..."
sudo ln -sf /etc/nginx/sites-available/risk-agents /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test and reload Nginx
echo "🧪 Testing Nginx configuration..."
if sudo nginx -t; then
    sudo systemctl reload nginx
    echo "✅ Nginx configured successfully!"
else
    echo "❌ Nginx configuration error!"
    exit 1
fi

# Get server IP
SERVER_IP=$(curl -s ifconfig.me)

echo ""
echo "🎉 Deployment Complete!"
echo "======================="
echo ""
echo "📍 Server IP: $SERVER_IP"
echo "🔗 Test URLs:"
echo "   Health: http://$SERVER_IP/health"
echo "   Website: http://$SERVER_IP"
echo ""
echo "🌐 Once DNS is configured:"
echo "   http://www.risk-agents.com"
echo ""
echo "📋 Management:"
echo "   Logs: sudo docker compose logs -f"
echo "   Restart: sudo docker compose restart"
echo "   Stop: sudo docker compose down"
echo ""
echo "🔒 Next: Configure DNS to point www.risk-agents.com to $SERVER_IP"
