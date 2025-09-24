#!/bin/bash

# AtonixCorp Platform - Simple Container Builder
# This script builds containers with sudo to avoid permission issues

set -e  # Exit on any error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_status "🚀 Building AtonixCorp Platform Containers..."

# Clean up existing containers
print_status "Cleaning up existing containers..."
sudo docker compose -f docker-compose.all-in-one.yml down --remove-orphans 2>/dev/null || true

# Build backend
print_status "Building backend container..."
if sudo docker compose -f docker-compose.all-in-one.yml build backend; then
    print_success "Backend container built successfully!"
else
    print_error "Backend build failed!"
    exit 1
fi

# Build frontend
print_status "Building frontend container..."
if sudo docker compose -f docker-compose.all-in-one.yml build frontend; then
    print_success "Frontend container built successfully!"
else
    print_error "Frontend build failed!"
    exit 1
fi

# Start the services
print_status "Starting core services..."
sudo docker compose -f docker-compose.all-in-one.yml up -d db redis

print_status "Waiting for database and Redis to be ready..."
sleep 15

print_status "Starting backend..."
sudo docker compose -f docker-compose.all-in-one.yml up -d backend

print_status "Waiting for backend to be ready..."
sleep 20

print_status "Starting frontend..."
sudo docker compose -f docker-compose.all-in-one.yml up -d frontend

print_status "Waiting for services to start..."
sleep 10

# Show status
print_status "Container Status:"
sudo docker compose -f docker-compose.all-in-one.yml ps

print_success "✅ Core containers built and started!"
echo ""
echo "🌐 Access URLs:"
echo "  Frontend: http://localhost:3000"
echo "  Backend API: http://localhost:8000/api/"
echo "  API Docs: http://localhost:8000/api/docs/"
echo "  Admin: http://localhost:8000/admin/"
echo ""
echo "📝 Useful commands:"
echo "  View logs: sudo docker compose -f docker-compose.all-in-one.yml logs -f"
echo "  Stop all: sudo docker compose -f docker-compose.all-in-one.yml down"
echo "  Restart: sudo docker compose -f docker-compose.all-in-one.yml restart [service]"