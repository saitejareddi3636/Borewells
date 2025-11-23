#!/bin/bash

# Complete Build and Run Script
# This script builds the Flutter web app and serves it

echo "🚀 ServiceMaster - Complete Build and Run"
echo ""

set -e  # Exit on error

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

echo "Step 1: Getting Flutter dependencies..."
docker run --rm -v "$(pwd):/app" -w /app ghcr.io/cirruslabs/flutter:latest flutter pub get

echo ""
echo "Step 2: Building Flutter web application..."
echo "   (This may take a few minutes...)"

# Try to build with local web SDK if available
docker run --rm -v "$(pwd):/app" -w /app ghcr.io/cirruslabs/flutter:latest sh -c "
    # Try to use cached web SDK or skip precache if blocked
    flutter config --enable-web || true
    
    # Build the app
    flutter build web --release --no-tree-shake-icons
" || {
    echo "⚠️ Build with release mode failed, trying debug mode..."
    docker run --rm -v "$(pwd):/app" -w /app ghcr.io/cirruslabs/flutter:latest sh -c "
        flutter config --enable-web || true
        flutter build web --debug --no-tree-shake-icons
    "
}

if [ -d "build/web" ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "Step 3: Starting web server on port 8081..."
    
    cd build/web
    python3 -m http.server 8081 &
    SERVER_PID=$!
    
    echo ""
    echo "✅ Application is running!"
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
    echo "🛑 To stop the server, press Ctrl+C or run: kill $SERVER_PID"
    echo ""
    
    # Keep script running
    wait $SERVER_PID
else
    echo ""
    echo "❌ Build failed - build/web directory not created"
    echo "   Please check the error messages above"
    exit 1
fi
