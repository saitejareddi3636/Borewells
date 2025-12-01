# Flutter Web Application Dockerfile
FROM ghcr.io/cirruslabs/flutter:latest

# Set working directory
WORKDIR /app

# Copy application files
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

# Expose port
EXPOSE 8081

# Run the application
CMD ["flutter", "run", "-d", "web-server", "--web-port=8081", "--web-hostname=0.0.0.0"]
