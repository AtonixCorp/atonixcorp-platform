# 🚀 AtonixCorp Platform - Production Deployment Guide

## 📦 Main Production Image

**Image to push to production:** `atonixcorp-platform:latest`

This is your **unified container** that contains both backend and frontend in a single deployable unit.

## 🏗️ Architecture Overview

### Single Unified Container: `atonixcorp-platform:latest`

This container includes:

#### 🎯 **Frontend (React)**
- **Location**: Built React app stored in `/app/static/` inside the container
- **Build process**: Multi-stage Docker build compiles React → static files
- **Served by**: Nginx on port 8080
- **Entry point**: `http://localhost:8080/` serves the React SPA

#### 🔧 **Backend (Django)**
- **Location**: Django application running on port 8000 inside container
- **Process manager**: Supervised by supervisord
- **API endpoints**: Proxied through Nginx from port 8080
- **Access**: `http://localhost:8080/api/`, `http://localhost:8080/admin/`

#### 🌐 **Web Server (Nginx)**
- **Port**: 8080 (exposed from container)
- **Function**: 
  - Serves React static files for `/`
  - Proxies API requests to Django backend
  - Handles static/media file serving
  - Provides gzip compression and security headers

#### 📋 **Process Management (Supervisor)**
- **Django server**: Python development server on :8000
- **Nginx**: Web server on :8080  
- **Django migrations**: Runs automatically on startup
- **Static files collection**: Runs automatically on startup

## 🗃️ External Dependencies (Separate Containers)

### Database: `postgres:15-alpine`
- **Purpose**: Main application database
- **Port**: 5433 (external) → 5432 (internal)
- **Connection**: `postgresql://atonixcorp:atonixpass@db:5432/atonixcorp`

### Cache: `redis:7-alpine`
- **Purpose**: Caching and session storage
- **Port**: 6380 (external) → 6379 (internal)
- **Connection**: `redis://redis:6379`

## 🚢 Production Deployment

### Option 1: Deploy Unified Container Only
```bash
# Export the main image
nerdctl save atonixcorp-platform:latest -o atonixcorp-platform.tar

# On production server
docker load -i atonixcorp-platform.tar
docker run -d -p 8080:8080 \
  -e DATABASE_URL="postgresql://user:pass@your-db:5432/dbname" \
  -e REDIS_URL="redis://your-redis:6379" \
  --name atonixcorp-app \
  atonixcorp-platform:latest
```

### Option 2: Deploy Full Stack with Docker Compose
```bash
# Copy these files to production:
# - docker-compose.simple.yml
# - .env (with production settings)

# On production
docker-compose -f docker-compose.simple.yml up -d
```

### Option 3: Push to Container Registry
```bash
# Tag for your registry
nerdctl tag atonixcorp-platform:latest your-registry.com/atonixcorp-platform:latest

# Push to registry
nerdctl push your-registry.com/atonixcorp-platform:latest

# Deploy from registry
docker pull your-registry.com/atonixcorp-platform:latest
docker run -d -p 8080:8080 your-registry.com/atonixcorp-platform:latest
```

## 🔗 Access Points in Production

- **Main Application**: `https://your-domain.com/`
- **API Endpoints**: `https://your-domain.com/api/`
- **Admin Interface**: `https://your-domain.com/admin/`
- **Health Check**: `https://your-domain.com/health/`

## ⚙️ Environment Variables for Production

```bash
# Database
DATABASE_URL=postgresql://user:password@db-host:5432/dbname

# Redis  
REDIS_URL=redis://redis-host:6379

# Django
DJANGO_SETTINGS_MODULE=atonixcorp.settings
DEBUG=False
SECRET_KEY=your-secret-key
ALLOWED_HOSTS=your-domain.com,www.your-domain.com

# Email (if using external SMTP)
EMAIL_HOST=smtp.your-provider.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@domain.com
EMAIL_HOST_PASSWORD=your-email-password
```

## 📊 Container Size and Performance

```
Image: atonixcorp-platform:latest
Size: ~505 MB
Components:
- Python 3.11 base: ~140 MB
- Node.js build artifacts: ~50 MB  
- Django + dependencies: ~200 MB
- Nginx + system deps: ~115 MB
```

## 🔍 Verification Commands

```bash
# Check container health
curl http://localhost:8080/health/

# Check frontend is served
curl -I http://localhost:8080/

# Check API is proxied  
curl -I http://localhost:8080/api/

# View container logs
docker logs atonixcorp-platform-app-1
```

## 🎯 Key Benefits of This Architecture

1. **Single Deployment Unit**: One container with both frontend and backend
2. **No CORS Issues**: Frontend and backend served from same origin
3. **Simplified Routing**: Nginx handles all traffic routing
4. **Production Ready**: Includes process management, logging, health checks
5. **Scalable**: Can be easily replicated behind a load balancer
6. **Self-Contained**: Only requires external database and cache

## 📝 Important Notes

- The **frontend is NOT running as a separate server** - it's built into static files and served by Nginx
- The **main container** (`atonixcorp-platform:latest`) is what you deploy to production  
- Database and Redis can be external managed services or separate containers
- The container runs on port 8080 to avoid requiring root privileges
- Health checks are built-in at `/health/` endpoint

---

**🎉 This unified approach gives you a production-ready, single-container deployment that's easy to scale and manage!**