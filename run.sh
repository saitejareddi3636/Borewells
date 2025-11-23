#!/bin/bash

# ServiceMaster Application Runner
# This script builds and runs the Flutter web application using Docker

echo "🚀 Starting ServiceMaster Application..."
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Build and run with docker-compose
echo "📦 Building Docker image (this may take a few minutes on first run)..."
docker-compose build

echo ""
echo "🏃 Starting the application..."
docker-compose up -d

echo ""
echo "✅ Application is starting!"
echo ""
echo "📱 Access the application at: http://localhost:8081"
echo ""
echo "👥 Test Login Credentials:"
echo "   Admin User:"
echo "     - Email: admin@servicemaster.com"
echo "     - Password: 123456"
echo ""
echo "   Regular User:"
echo "     - Email: driver@servicemaster.com"
echo "     - Password: 123456"
echo ""
echo "📋 Useful commands:"
echo "   - View logs: docker-compose logs -f"
echo "   - Stop app: docker-compose down"
echo "   - Restart app: docker-compose restart"
echo ""
echo "⏳ Waiting for application to be ready (this may take 30-60 seconds)..."
sleep 10
docker-compose logs servicemaster | tail -20
