#!/bin/bash
# GitHub setup script for Risk Agents Landing Page

echo "🚀 Setting up GitHub repository..."

# Initialize git repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: Risk Agents landing page with Docker setup

- Updated branding from Gavin Slater to Risk Agents
- Added Docker containerization with health checks
- Configured for www.risk-agents.com domain
- Production-ready server with security headers
- Docker Compose setup with Nginx reverse proxy support"

echo "✅ Local repository initialized!"
echo ""
echo "Next steps:"
echo "1. Create a new repository on GitHub named 'risk-agents-landing'"
echo "2. Copy and run these commands:"
echo ""
echo "git branch -M main"
echo "git remote add origin https://github.com/gavraq/risk-agents-landing.git"
echo "git push -u origin main"
echo ""
echo "Replace YOUR_USERNAME with your actual GitHub username"
