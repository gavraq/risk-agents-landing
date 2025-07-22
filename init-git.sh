#!/bin/bash
# Initialize git repository and prepare for GitHub push

set -e

echo "🚀 Preparing Risk Agents Landing Page for GitHub..."

# Initialize git repository
if [ ! -d ".git" ]; then
    git init
    echo "✅ Git repository initialized"
else
    echo "✅ Git repository already exists"
fi

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: Risk Agents landing page with Docker setup

Features:
- Updated branding from Gavin Slater to Risk Agents  
- Modern responsive design with animated elements
- Docker containerization with health checks
- Production-ready Python HTTP server with security headers
- Nginx reverse proxy configuration
- Google Compute Engine deployment automation
- SSL/TLS ready with Let's Encrypt integration
- Configured for www.risk-agents.com domain

Tech Stack:
- Python 3.11 HTTP server
- Docker & Docker Compose
- Nginx reverse proxy
- Let's Encrypt SSL certificates
- Systemd service integration"

# Set up remote and branch
git branch -M main
git remote add origin https://github.com/gavraq/risk-agents-landing.git 2>/dev/null || git remote set-url origin https://github.com/gavraq/risk-agents-landing.git

echo ""
echo "✅ Git repository prepared!"
echo ""
echo "📋 Next Steps:"
echo "1. Go to GitHub and create a new repository named 'risk-agents-landing'"
echo "   URL: https://github.com/new"
echo ""
echo "2. Push to GitHub:"
echo "   git push -u origin main"
echo ""
echo "3. Deploy to your GCE VM:"
echo "   ssh gavin_n_slater@YOUR_VM_IP"
echo "   curl -O https://raw.githubusercontent.com/gavraq/risk-agents-landing/main/deploy-gce.sh"
echo "   chmod +x deploy-gce.sh"
echo "   ./deploy-gce.sh"
echo ""
echo "🌐 Your landing page will be available at: https://www.risk-agents.com"
