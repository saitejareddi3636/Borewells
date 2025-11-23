#!/bin/bash

# System Check Script
# Verifies that all prerequisites are met to run the application

echo "🔍 ServiceMaster - System Check"
echo "================================"
echo ""

check_command() {
    if command -v $1 &> /dev/null; then
        echo "✅ $1 is installed"
        if [ "$2" != "" ]; then
            echo "   Version: $($2)"
        fi
        return 0
    else
        echo "❌ $1 is NOT installed"
        return 1
    fi
}

echo "Checking Docker..."
if check_command docker "docker --version"; then
    if docker info &> /dev/null; then
        echo "✅ Docker is running"
    else
        echo "⚠️  Docker is installed but not running"
    fi
fi

echo ""
echo "Checking Flutter (optional)..."
check_command flutter "flutter --version | head -1"

echo ""
echo "Checking Python..."
check_command python3 "python3 --version"

echo ""
echo "Checking Git..."
check_command git "git --version"

echo ""
echo "Checking Node.js (optional)..."
check_command node "node --version"

echo ""
echo "================================"
echo "📋 Application Files Check"
echo "================================"
echo ""

check_file() {
    if [ -f "$1" ]; then
        echo "✅ $1"
        return 0
    else
        echo "❌ $1 (missing)"
        return 1
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        echo "✅ $1/"
        return 0
    else
        echo "❌ $1/ (missing)"
        return 1
    fi
}

# Check key files
check_file "pubspec.yaml"
check_file "lib/main.dart"
check_file "README.md"
check_file "Dockerfile"
check_file "docker-compose.yml"
check_file "run-quick.sh"
check_file "build-and-run.sh"

echo ""

# Check directories
check_dir "lib"
check_dir "web"

if [ -d "build/web" ]; then
    echo "✅ build/web/ (application is built)"
else
    echo "ℹ️  build/web/ (not built yet - run './build-and-run.sh' to build)"
fi

echo ""
echo "================================"
echo "🎯 Recommendations"
echo "================================"
echo ""

HAS_DOCKER=false
HAS_FLUTTER=false
HAS_PYTHON=false

command -v docker &> /dev/null && docker info &> /dev/null 2>&1 && HAS_DOCKER=true
command -v flutter &> /dev/null && HAS_FLUTTER=true
command -v python3 &> /dev/null && HAS_PYTHON=true

if [ "$HAS_DOCKER" = true ]; then
    echo "✅ You can run the application with Docker"
    echo "   Recommended: ./run-quick.sh"
    echo ""
fi

if [ "$HAS_FLUTTER" = true ]; then
    echo "✅ You can run the application with Flutter directly"
    echo "   Command: flutter run -d web-server --web-port=8081"
    echo ""
fi

if [ "$HAS_PYTHON" = true ]; then
    echo "✅ You can serve pre-built files with Python"
    echo "   First build: flutter build web --release"
    echo "   Then serve: ./run-simple.sh"
    echo ""
fi

if [ "$HAS_DOCKER" = false ] && [ "$HAS_FLUTTER" = false ]; then
    echo "⚠️  Neither Docker nor Flutter is available"
    echo "   Please install Docker (recommended) or Flutter SDK"
    echo ""
    echo "   Docker: https://docs.docker.com/get-docker/"
    echo "   Flutter: https://docs.flutter.dev/get-started/install"
    echo ""
fi

echo "================================"
echo "📖 For more information, see:"
echo "   - README.md"
echo "   - SETUP_GUIDE.md"
echo "   - index.html (open in browser)"
echo "================================"
