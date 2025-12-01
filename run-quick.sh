#!/bin/bash

# Quick Run Script - Uses official Flutter Docker image
# This is faster than building from scratch

echo "🚀 Quick Start - ServiceMaster Application"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

echo "📦 Using official Flutter Docker image..."
echo "🏃 Starting the application..."
echo ""

# Run Flutter in a container with the current directory mounted
docker run -d \
    --name servicemaster-app \
    -p 8081:8081 \
    -v "$(pwd):/app" \
    -w /app \
    --rm \
    ghcr.io/cirruslabs/flutter:latest \
    sh -c "flutter pub get && flutter run -d web-server --web-port=8081 --web-hostname=0.0.0.0"

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
echo "   - View logs: docker logs -f servicemaster-app"
echo "   - Stop app: docker stop servicemaster-app"
echo "   - Restart app: docker restart servicemaster-app"
echo ""
echo "⏳ Waiting for application to initialize (this may take 30-60 seconds)..."
echo ""
sleep 15

echo "📊 Current status:"
docker logs servicemaster-app | tail -20
