# ServiceMaster - Vehicle Maintenance Management

A Flutter web app for easy vehicle maintenance tracking. Simplified interface for non-technical users.

## 🚀 Quick Start (Easiest Way - Using Docker)

**Prerequisites:** Docker must be installed and running

### Option 1: Quick Run with Docker (Recommended)
```bash
./run-quick.sh
```

This script will:
- Pull the Flutter Docker image (ghcr.io/cirruslabs/flutter:latest)
- Install dependencies automatically
- Start the application on port 8081

### Option 2: Docker Compose
```bash
docker-compose up --build
```

### Option 3: Manual Docker Command
```bash
docker run -d \
  --name servicemaster-app \
  -p 8081:8081 \
  -v "$(pwd):/app" \
  -w /app \
  ghcr.io/cirruslabs/flutter:latest \
  sh -c "flutter pub get && flutter run -d web-server --web-port=8081 --web-hostname=0.0.0.0"
```

**Access the app at:** `http://localhost:8081`

**View logs:**
```bash
docker logs -f servicemaster-app
```

**Stop the app:**
```bash
docker stop servicemaster-app
```

## 🔧 Alternative Setup (Without Docker)

### Prerequisites
- Flutter SDK 3.10.0 or higher
- Dart SDK 3.10.0 or higher

### Steps
```bash
# 1. Install Flutter from https://flutter.dev/docs/get-started/install

# 2. Get dependencies
flutter pub get

# 3. Run the application
flutter run -d web-server --web-port=8081

# 4. Open in browser
# http://localhost:8081
```

## 📋 Available Scripts

This repository includes several convenience scripts:

| Script | Description |
|--------|-------------|
| `./run-quick.sh` | Quick start with Docker (recommended) |
| `./run.sh` | Build and run with docker-compose |
| `./build-and-run.sh` | Build the app and serve with Python |
| `./run-simple.sh` | Serve pre-built app with Python |
| `index.html` | Information page about the application |

## 🌐 Demo Page

Open `index.html` in your browser to see detailed instructions and information about the application.

## 👥 Test Login

**Admin User**
- Email: `admin@servicemaster.com`  
- Password: `123456`

**Regular User** 
- Email: `driver@servicemaster.com`
- Password: `123456`

Or just click the colored login buttons!

## � Dependencies 

All dependencies are automatically installed with `flutter pub get`:

- **flutter**: Core framework
- **firebase_core**: ^3.6.0 (for authentication)
- **firebase_auth**: ^5.3.1 (user login)
- **cloud_firestore**: ^5.4.4 (database)
- **cupertino_icons**: ^1.0.8 (icons)

## ✨ Features

### For Admins
- Manage all vehicles and users
- View maintenance schedules  
- Complete system access

### For Users (Simplified)
- Log maintenance with dropdowns only
- Update vehicle hours/kilometers
- View maintenance status (Red/Yellow/Green)
- No complex typing required!

## 🚨 Troubleshooting

### Docker Issues

**App won't start?**
```bash
docker stop servicemaster-app
./run-quick.sh
```

**View logs:**
```bash
docker logs -f servicemaster-app
```

**Port busy?**
```bash
# Edit the port in run-quick.sh or run manually:
docker run -d --name servicemaster-app -p 8082:8082 -v "$(pwd):/app" -w /app \
  cirrusci/flutter:stable sh -c "flutter pub get && flutter run -d web-server --web-port=8082 --web-hostname=0.0.0.0"
```

### Flutter Direct Issues

**App won't start?**
```bash
flutter clean
flutter pub get
flutter run -d web-server --web-port=8081
```

**Port busy?** Try a different port:
```bash
flutter run -d web-server --web-port=8082
```

**Login not working?** Use the quick login buttons (Red = Admin, Green = User)

## 📝 Pre-defined Maintenance Items
1. Engine Oil Change (250 hrs/5,000 km)
2. Air Filter (500 hrs/10,000 km)  
3. Fuel Filter (500 hrs/12,000 km)
4. Hydraulic Oil (1,000 hrs/20,000 km)
5. Coolant Check (750 hrs/15,000 km)
6. Brake Inspection (600 hrs/12,000 km)
7. Tire Pressure (100 hrs/2,000 km)
8. General Inspection (300 hrs/6,000 km)

---
**Built with Flutter • Ready to use offline • No Firebase setup required**
