# ServiceMaster - Setup & Deployment Guide

## 🎯 Overview

ServiceMaster is a Flutter web application for vehicle maintenance management. This guide provides multiple ways to run the application.

## 📋 Prerequisites

Choose one of the following setups:

### Option A: Docker (Recommended - Easiest)
- Docker installed and running
- No Flutter installation needed

### Option B: Local Flutter Development
- Flutter SDK 3.10.0 or higher
- Dart SDK 3.10.0 or higher
- Chrome browser (for `flutter run`)

### Option C: Pre-built Static Files
- Python 3 (built-in HTTP server)
- Pre-built `build/web` directory

---

## 🚀 Running the Application

### Method 1: Docker with Flutter Runtime (Development Mode)

This method runs Flutter in development mode inside a Docker container.

**Command:**
```bash
docker run -d \
  --name servicemaster-app \
  -p 8081:8081 \
  -v "$(pwd):/app" \
  -w /app \
  ghcr.io/cirruslabs/flutter:latest \
  sh -c "flutter pub get && flutter run -d web-server --web-port=8081 --web-hostname=0.0.0.0"
```

**Or use the convenience script:**
```bash
./run-quick.sh
```

**Check logs:**
```bash
docker logs -f servicemaster-app
```

**Stop:**
```bash
docker stop servicemaster-app
```

**Note:** This method requires access to Flutter's Web SDK download. If you encounter a 403 error when downloading the Web SDK, use Method 2 or 3 instead.

---

### Method 2: Build and Serve (Production Mode)

This method builds the Flutter app once and serves the static files.

**Step 1: Build the application**

With local Flutter installation:
```bash
flutter pub get
flutter build web --release
```

Or with Docker:
```bash
docker run --rm \
  -v "$(pwd):/app" \
  -w /app \
  ghcr.io/cirruslabs/flutter:latest \
  sh -c "flutter pub get && flutter build web --release"
```

**Step 2: Serve the built files**

With Python:
```bash
cd build/web
python3 -m http.server 8081
```

Or use the convenience script:
```bash
./run-simple.sh  # Requires build/web directory to exist
```

Or use the combined script:
```bash
./build-and-run.sh  # Builds and serves in one command
```

---

### Method 3: Docker Compose (Full Container Setup)

Uses docker-compose for container orchestration.

**Command:**
```bash
docker-compose up --build
```

Or use the script:
```bash
./run.sh
```

**Stop:**
```bash
docker-compose down
```

---

### Method 4: Local Flutter Development

For active development with hot reload.

**Prerequisites:**
- Flutter SDK installed locally
- Chrome browser installed

**Commands:**
```bash
# Install dependencies
flutter pub get

# Run in development mode (with hot reload)
flutter run -d chrome --web-port=8081

# Or run as web server (headless)
flutter run -d web-server --web-port=8081
```

**For production build:**
```bash
flutter build web --release
```

---

## 🌐 Accessing the Application

Once running, access the application at:
```
http://localhost:8081
```

## 👥 Test Credentials

### Admin User
- **Email:** `admin@servicemaster.com`
- **Password:** `123456`

### Regular User
- **Email:** `driver@servicemaster.com`
- **Password:** `123456`

Or simply click the colored login buttons in the app!

---

## 🛠️ Troubleshooting

### Issue: "Failed to download Web SDK" (403 Error)

**Cause:** Network restrictions blocking access to Flutter's CDN (`storage.googleapis.com`)

**Solutions:**

1. **Use pre-built files:** Build the app on a machine with internet access, then copy the `build/web` directory to your server and serve it with Python/Node.js/nginx.

2. **Use a different network:** Try building on a different network or machine that has access to Google's storage.

3. **Manual Web SDK installation:**
   ```bash
   # Download Web SDK manually on an unrestricted machine
   # Then copy to: ~/.flutter/bin/cache/flutter_web_sdk/
   ```

### Issue: Port 8081 Already in Use

**Solution:** Use a different port:
```bash
# With Flutter:
flutter run -d web-server --web-port=8082

# With Python:
python3 -m http.server 8082

# With Docker:
docker run -p 8082:8081 ...  # Map to different host port
```

### Issue: Docker Container Exits Immediately

**Check logs:**
```bash
docker logs servicemaster-app
```

**Common causes:**
- Port conflict
- Invalid command
- Network issues

### Issue: Application Won't Load in Browser

**Checklist:**
1. Is the server running? Check with `docker ps` or process list
2. Is the correct port open? Try `curl http://localhost:8081`
3. Check browser console for errors (F12)
4. Verify Firebase configuration in `lib/firebase_options.dart`

---

## 📦 Deployment Options

### Option 1: Static Hosting (Recommended)

Build once and deploy to static hosting:

```bash
flutter build web --release
```

Upload `build/web/` to:
- GitHub Pages
- Netlify
- Vercel
- Firebase Hosting
- AWS S3 + CloudFront
- Any static web host

### Option 2: Container Deployment

Deploy the Docker container to:
- AWS ECS/Fargate
- Google Cloud Run
- Azure Container Instances
- Kubernetes cluster
- Any Docker host

### Option 3: Server Deployment

Run on a VPS/server:

1. Install Flutter or use Docker
2. Build the application
3. Serve with nginx/Apache/Caddy
4. Set up systemd service for auto-start

**Example nginx configuration:**
```nginx
server {
    listen 80;
    server_name servicemaster.example.com;
    
    root /var/www/servicemaster/build/web;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

---

## 🔒 Production Considerations

### Security
- Enable HTTPS (use Let's Encrypt)
- Configure Firebase security rules
- Set up proper authentication
- Use environment variables for sensitive data

### Performance
- Enable gzip compression
- Set proper cache headers
- Use CDN for static assets
- Optimize images

### Monitoring
- Set up application monitoring
- Configure error tracking
- Monitor Firebase usage
- Set up uptime monitoring

---

## 📚 Additional Resources

- [Flutter Web Documentation](https://docs.flutter.dev/platform-integration/web)
- [Firebase Setup Guide](https://firebase.google.com/docs/flutter/setup)
- [Docker Documentation](https://docs.docker.com/)

---

## 💡 Quick Reference

| Action | Command |
|--------|---------|
| Quick Start | `./run-quick.sh` |
| Build App | `flutter build web --release` |
| Serve Built App | `python3 -m http.server 8081` |
| View Logs | `docker logs -f servicemaster-app` |
| Stop App | `docker stop servicemaster-app` |
| Clean Build | `flutter clean && flutter pub get` |

---

## 🆘 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review application logs
3. Verify all prerequisites are met
4. Check Flutter and Dart versions
5. Ensure Firebase is properly configured

---

**Built with Flutter • Powered by Firebase • Ready for Production**
