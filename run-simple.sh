#!/bin/bash

# Alternative Run Script - Serves the application using Python HTTP server
# This approach builds the app once and serves static files

echo "🚀 ServiceMaster Application - Static Server Mode"
echo ""

cd "$(dirname "$0")"

# Check if build directory exists
if [ ! -d "build/web" ]; then
    echo "❌ Build directory not found."
    echo "📦 Please build the application first or use Docker to build it."
    echo ""
    echo "To build with Docker:"
    echo "  docker run --rm -v \"\$(pwd):/app\" -w /app ghcr.io/cirruslabs/flutter:latest flutter build web --release"
    echo ""
    exit 1
fi

echo "✅ Build directory found!"
echo "🌐 Starting web server on port 8081..."
echo ""

# Start Python HTTP server
cd build/web
python3 -m http.server 8081 &
SERVER_PID=$!

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

# Wait for server
wait $SERVER_PID
