# AtonixCorp Platform - Unified Container Setup

This setup allows you to run both the Django backend and React frontend in a single container, making deployment and development much simpler.

## [START] Quick Start

### Prerequisites
- nerdctl (or Docker)
- Git

### Option 1: Automated Setup
```bash
# Clone and enter the project
git clone <repository-url>
cd atonixcorp-platform

# Build and run everything
./build.sh run
```

### Option 2: Manual Setup
```bash
# Build the unified container
nerdctl build -f Dockerfile.fullstack -t atonixcorp-platform:latest .

# Start all services
nerdctl compose -f docker-compose.unified.yml up -d
```

## 🌐 Access Points

Once running, you can access:

- **Full Application**: http://localhost
- **Django Admin**: http://localhost/admin/
- **API Endpoints**: http://localhost/api/
- **Health Check**: http://localhost/health/
- **RabbitMQ UI**: http://localhost:15672 (admin/rabbitmq_password)
- **MailHog UI**: http://localhost:8025

## 🏗️ Architecture

### Single Container Approach
```
┌─────────────────────────────────────┐
│         Unified Container          │
├─────────────────────────────────────┤
│  Nginx (Port 80)                   │
│  ├── Serves React Frontend         │
│  └── Proxies /api/ to Django       │
├─────────────────────────────────────┤
│  Django Backend (Port 8000)        │
│  ├── REST API                      │
│  ├── Admin Interface               │
│  └── Health Checks                 │
└─────────────────────────────────────┘
```

### External Services
- PostgreSQL Database (Port 5432)
- Redis Cache (Port 6379)
- Zookeeper (Port 2181)
- Kafka (Port 9092)
- RabbitMQ (Ports 5672, 15672)
- MailHog (Ports 1025, 8025)

## 🔧 Build Scripts

### Available Commands
```bash
./build.sh build     # Build the unified container
./build.sh run       # Build and run everything
./build.sh dev       # Run in development mode
./build.sh stop      # Stop all containers
./build.sh logs      # Show container logs
./build.sh clean     # Clean up everything
```

### Development Mode
```bash
./build.sh dev
```
This mounts your source code for live development.

## 📁 Container Structure

### Inside the Container:
```
/app/
├── manage.py              # Django management
├── atonixcorp/           # Django project
├── core/                 # Core Django app
├── projects/             # Projects app
├── teams/                # Teams app
├── focus_areas/          # Focus areas app
├── resources/            # Resources app
├── contact/              # Contact app
├── dashboard/            # Dashboard app
├── static/               # Built React frontend
├── media/                # User uploads
└── logs/                 # Application logs
```

### Configuration Files:
```
/app/
├── start.sh              # Startup script
└── /etc/
    ├── nginx/sites-available/default  # Nginx config
    └── supervisor/conf.d/supervisord.conf  # Supervisor config
```

## 🐳 Dockerfile Options

### 1. Full Build (Dockerfile.fullstack)
- Builds React frontend from source
- Builds Django backend
- Multi-stage build for optimization
- **Use this for**: Production deployments

### 2. Simple Build (Dockerfile.simple)
- Uses pre-built React frontend
- Faster build times
- **Use this for**: Quick testing when frontend is already built

## 🔍 Health Monitoring

### Health Check Endpoint
```bash
curl http://localhost/health/
```

Returns:
```json
{
  "status": "healthy",
  "checks": {
    "database": "healthy",
    "redis": "healthy",
    "zookeeper": "healthy",
    "kafka": "healthy",
    "rabbitmq": "healthy"
  }
}
```

### Container Health
```bash
# Check container status
nerdctl ps

# View logs
./build.sh logs

# View specific service logs
nerdctl compose -f docker-compose.unified.yml logs app
nerdctl compose -f docker-compose.unified.yml logs nginx
```

## 🛠️ Customization

### Environment Variables
Edit `docker-compose.unified.yml` to customize:

```yaml
environment:
  - DEBUG=False
  - SECRET_KEY=your-secret-key
  - ALLOWED_HOSTS=localhost,yourdomain.com
  - DATABASE_URL=postgresql://user:pass@host:port/db
  - REDIS_URL=redis://host:port/db
```

### Nginx Configuration
Modify `docker/nginx.conf` to:
- Add SSL/TLS
- Configure custom domains
- Adjust proxy settings
- Add additional routes

### Supervisor Configuration
Modify `docker/supervisord.conf` to:
- Add new processes
- Adjust logging
- Configure auto-restart behavior

## [DEPLOY] Production Deployment

### 1. Build for Production
```bash
# Set production environment
export DEBUG=False
export SECRET_KEY=your-production-secret

# Build optimized container
nerdctl build -f Dockerfile.fullstack -t atonixcorp-platform:prod .
```

### 2. Use External Database
```yaml
# In docker-compose.production.yml
services:
  app:
    environment:
      - DATABASE_URL=postgresql://user:pass@prod-db:5432/atonixcorp
      - REDIS_URL=redis://prod-redis:6379/0
```

### 3. Add SSL/TLS
- Configure reverse proxy (nginx, traefik, etc.)
- Use Let's Encrypt certificates
- Update ALLOWED_HOSTS

## 🔧 Troubleshooting

### Common Issues

#### Container Won't Start
```bash
# Check logs
./build.sh logs

# Check individual services
nerdctl compose -f docker-compose.unified.yml logs app
```

#### Database Connection Issues
```bash
# Verify database is running
nerdctl compose -f docker-compose.unified.yml ps db

# Check database logs
nerdctl compose -f docker-compose.unified.yml logs db
```

#### Frontend Not Loading
```bash
# Verify nginx configuration
nerdctl exec atonixcorp_app nginx -t

# Check static files
nerdctl exec atonixcorp_app ls -la /app/static/
```

#### Service Dependencies
```bash
# Check all service health
curl http://localhost/health/

# Restart specific services
nerdctl compose -f docker-compose.unified.yml restart app
```

### Getting Help
1. Check logs: `./build.sh logs`
2. Verify health: `curl http://localhost/health/`
3. Rebuild: `./build.sh clean && ./build.sh run`

## 📊 Monitoring

### Application Metrics
- Health endpoint: `/health/`
- Django admin: `/admin/`
- Application logs: `/app/logs/`

### External Services
- RabbitMQ: http://localhost:15672
- MailHog: http://localhost:8025
- Database: localhost:5432

---

This unified container approach significantly simplifies deployment while maintaining all the powerful features of the AtonixCorp platform!