#!/bin/bash

# Risk Agents Landing Page Deployment Script

set -e  # Exit on any error

echo "🌐 Risk Agents Landing Page Deployment"
echo "======================================"

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose >/dev/null 2>&1; then
    echo "❌ docker-compose is not installed. Please install it first."
    exit 1
fi

echo "📦 Building Docker image..."
docker-compose build --no-cache

echo "🚀 Starting the application..."
docker-compose up -d

echo "⏳ Waiting for health check..."
sleep 10

# Check if container is healthy
if docker-compose ps | grep -q "healthy"; then
    echo "✅ Deployment successful!"
    echo ""
    echo "🔗 Your landing page is now available at:"
    echo "   Local: http://localhost:8080"
    echo "   Production: https://www.risk-agents.com (once DNS is configured)"
    echo ""
    echo "📊 Container status:"
    docker-compose ps
    echo ""
    echo "📋 View logs with: docker-compose logs -f"
    echo "🛑 Stop with: docker-compose down"
else
    echo "❌ Deployment failed. Check logs:"
    docker-compose logs
    exit 1
fi
