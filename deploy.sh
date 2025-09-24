#!/bin/bash

# AtonixCorp Platform Deployment Script
# Usage: ./deploy.sh [environment]

set -e

ENVIRONMENT=${1:-production}
PROJECT_DIR="/home/atonixdev/atonixcorp-platform"

echo "[DEPLOY] Deploying AtonixCorp Platform to $ENVIRONMENT environment..."

# Change to project directory
cd $PROJECT_DIR

# Load environment variables
if [ -f ".env.$ENVIRONMENT" ]; then
    echo "[INFO] Loading environment variables from .env.$ENVIRONMENT"
    export $(cat .env.$ENVIRONMENT | xargs)
else
    echo "[WARN] Warning: .env.$ENVIRONMENT file not found, using defaults"
fi

# Function to check if Docker is running
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo "[ERROR] Docker is not installed"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        echo "[ERROR] Docker is not running"
        exit 1
    fi
    
    echo "✅ Docker is ready"
}

# Function to build images
build_images() {
    echo "🔨 Building Docker images..."
    
    if [ "$ENVIRONMENT" = "production" ]; then
        docker-compose -f docker-compose.yml -f docker-compose.prod.yml build --no-cache
    else
        docker-compose build --no-cache
    fi
    
    echo "✅ Images built successfully"
}

# Function to run database migrations
run_migrations() {
    echo "🗄️  Running database migrations..."
    
    if [ "$ENVIRONMENT" = "production" ]; then
        docker-compose -f docker-compose.yml -f docker-compose.prod.yml run --rm backend python manage.py migrate
    else
        docker-compose run --rm backend python manage.py migrate
    fi
    
    echo "✅ Migrations completed"
}

# Function to collect static files
collect_static() {
    echo "📦 Collecting static files..."
    
    if [ "$ENVIRONMENT" = "production" ]; then
        docker-compose -f docker-compose.yml -f docker-compose.prod.yml run --rm backend python manage.py collectstatic --noinput
    else
        docker-compose run --rm backend python manage.py collectstatic --noinput
    fi
    
    echo "✅ Static files collected"
}

# Function to start services
start_services() {
    echo "🎯 Starting services..."
    
    if [ "$ENVIRONMENT" = "production" ]; then
        docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
    else
        docker-compose up -d
    fi
    
    echo "✅ Services started"
}

# Function to wait for services to be healthy
wait_for_health() {
    echo "🏥 Waiting for services to be healthy..."
    
    # Wait for backend health check
    for i in {1..30}; do
        if curl -f http://localhost:8080/api/health/ &> /dev/null; then
            echo "✅ Backend is healthy"
            break
        else
            echo "⏳ Waiting for backend... ($i/30)"
            sleep 10
        fi
    done
    
    # Wait for frontend
    for i in {1..30}; do
        if curl -f http://localhost:8080/ &> /dev/null; then
            echo "✅ Frontend is healthy"
            break
        else
            echo "⏳ Waiting for frontend... ($i/30)"
            sleep 10
        fi
    done
}

# Function to run post-deployment tasks
post_deployment() {
    echo "🔧 Running post-deployment tasks..."
    
    # Create superuser if it doesn't exist (production only)
    if [ "$ENVIRONMENT" = "production" ]; then
        echo "👤 Creating superuser if needed..."
        docker-compose -f docker-compose.yml -f docker-compose.prod.yml exec -T backend python manage.py shell -c "
from django.contrib.auth.models import User
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@atonixcorp.com', 'admin123')
    print('Superuser created')
else:
    print('Superuser already exists')
"
    fi
    
    echo "✅ Post-deployment tasks completed"
}

# Function to display status
show_status() {
    echo ""
    echo "🎉 Deployment completed successfully!"
    echo ""
    echo "📍 Access your platform:"
    echo "   Frontend: http://localhost:8080"
    echo "   Backend API: http://localhost:8080/api/"
    echo "   Admin Panel: http://localhost:8080/admin/"
    echo "   Health Check: http://localhost:8080/api/health/"
    echo ""
    echo "🔧 Useful commands:"
    echo "   View logs: docker-compose logs -f"
    echo "   Stop services: docker-compose down"
    echo "   Restart services: docker-compose restart"
    echo ""
}

# Main deployment flow
main() {
    echo "Environment: $ENVIRONMENT"
    echo "Project Directory: $PROJECT_DIR"
    echo ""
    
    check_docker
    build_images
    run_migrations
    collect_static
    start_services
    wait_for_health
    post_deployment
    show_status
}

# Run main function
main