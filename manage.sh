#!/bin/bash

# AtonixCorp Platform Management Script
# Usage: ./manage.sh [command] [options]

set -e

PROJECT_DIR="/home/atonixdev/atonixcorp-platform"
cd $PROJECT_DIR

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo "AtonixCorp Platform Management Script"
    echo ""
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  start [env]     Start the platform (dev/prod)"
    echo "  stop            Stop all services"
    echo "  restart [env]   Restart all services"
    echo "  status          Show service status"
    echo "  logs [service]  Show logs for a service"
    echo "  shell [service] Access service shell"
    echo "  backup          Create database backup"
    echo "  restore [file]  Restore database from backup"
    echo "  migrate         Run database migrations"
    echo "  test            Run tests"
    echo "  clean           Clean up containers and volumes"
    echo "  build           Build all images"
    echo "  help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start dev            # Start development environment"
    echo "  $0 start prod           # Start production environment"
    echo "  $0 logs backend         # Show backend logs"
    echo "  $0 shell backend        # Access backend shell"
    echo "  $0 backup               # Create database backup"
    echo ""
}

# Function to start services
start_services() {
    local env=${1:-dev}
    echo -e "${GREEN}🚀 Starting AtonixCorp Platform ($env environment)...${NC}"
    
    if [ "$env" = "prod" ]; then
        docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
    else
        docker-compose up -d
    fi
    
    echo -e "${GREEN}✅ Platform started successfully!${NC}"
    show_access_info
}

# Function to stop services
stop_services() {
    echo -e "${YELLOW}🛑 Stopping AtonixCorp Platform...${NC}"
    docker-compose down
    echo -e "${GREEN}✅ Platform stopped successfully!${NC}"
}

# Function to restart services
restart_services() {
    local env=${1:-dev}
    echo -e "${BLUE}🔄 Restarting AtonixCorp Platform...${NC}"
    stop_services
    start_services $env
}

# Function to show service status
show_status() {
    echo -e "${BLUE}📊 Service Status:${NC}"
    docker-compose ps
    echo ""
    echo -e "${BLUE}🏥 Health Checks:${NC}"
    
    # Check backend health
    if curl -s http://localhost:8080/api/health/ > /dev/null 2>&1; then
        echo -e "Backend: ${GREEN}✅ Healthy${NC}"
    else
        echo -e "Backend: ${RED}❌ Unhealthy${NC}"
    fi
    
    # Check frontend
    if curl -s http://localhost:8080/ > /dev/null 2>&1; then
        echo -e "Frontend: ${GREEN}✅ Healthy${NC}"
    else
        echo -e "Frontend: ${RED}❌ Unhealthy${NC}"
    fi
    
    # Check database
    if docker-compose exec -T db pg_isready -U atonixcorp_user > /dev/null 2>&1; then
        echo -e "Database: ${GREEN}✅ Healthy${NC}"
    else
        echo -e "Database: ${RED}❌ Unhealthy${NC}"
    fi
    
    # Check Redis
    if docker-compose exec -T redis redis-cli ping > /dev/null 2>&1; then
        echo -e "Redis: ${GREEN}✅ Healthy${NC}"
    else
        echo -e "Redis: ${RED}❌ Unhealthy${NC}"
    fi
}

# Function to show logs
show_logs() {
    local service=${1:-}
    if [ -z "$service" ]; then
        echo -e "${BLUE}📋 Showing logs for all services:${NC}"
        docker-compose logs -f --tail=100
    else
        echo -e "${BLUE}📋 Showing logs for $service:${NC}"
        docker-compose logs -f --tail=100 $service
    fi
}

# Function to access service shell
access_shell() {
    local service=${1:-backend}
    echo -e "${BLUE}🐚 Accessing $service shell...${NC}"
    
    case $service in
        backend)
            docker-compose exec backend bash
            ;;
        frontend)
            docker-compose exec frontend sh
            ;;
        db)
            docker-compose exec db psql -U atonixcorp_user -d atonixcorp
            ;;
        redis)
            docker-compose exec redis redis-cli
            ;;
        *)
            echo -e "${RED}❌ Unknown service: $service${NC}"
            echo "Available services: backend, frontend, db, redis"
            ;;
    esac
}

# Function to create database backup
create_backup() {
    local backup_dir="./backups"
    local backup_file="$backup_dir/backup_$(date +%Y%m%d_%H%M%S).sql"
    
    echo -e "${BLUE}💾 Creating database backup...${NC}"
    mkdir -p $backup_dir
    
    docker-compose exec -T db pg_dump -U atonixcorp_user atonixcorp > $backup_file
    
    echo -e "${GREEN}✅ Backup created: $backup_file${NC}"
}

# Function to restore database
restore_backup() {
    local backup_file=$1
    
    if [ -z "$backup_file" ]; then
        echo -e "${RED}❌ Please specify backup file${NC}"
        echo "Usage: $0 restore path/to/backup.sql"
        return 1
    fi
    
    if [ ! -f "$backup_file" ]; then
        echo -e "${RED}❌ Backup file not found: $backup_file${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}⚠️  This will replace the current database. Continue? (y/N)${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Restore cancelled"
        return 0
    fi
    
    echo -e "${BLUE}🔄 Restoring database from $backup_file...${NC}"
    
    # Drop and recreate database
    docker-compose exec -T db psql -U atonixcorp_user -c "DROP DATABASE IF EXISTS atonixcorp;"
    docker-compose exec -T db psql -U atonixcorp_user -c "CREATE DATABASE atonixcorp;"
    
    # Restore from backup
    cat $backup_file | docker-compose exec -T db psql -U atonixcorp_user atonixcorp
    
    echo -e "${GREEN}✅ Database restored successfully${NC}"
}

# Function to run migrations
run_migrations() {
    echo -e "${BLUE}🗄️  Running database migrations...${NC}"
    docker-compose exec backend python manage.py migrate
    echo -e "${GREEN}✅ Migrations completed${NC}"
}

# Function to run tests
run_tests() {
    echo -e "${BLUE}🧪 Running tests...${NC}"
    docker-compose exec backend python manage.py test
    echo -e "${GREEN}✅ Tests completed${NC}"
}

# Function to clean up
cleanup() {
    echo -e "${YELLOW}🧹 Cleaning up containers and volumes...${NC}"
    echo -e "${RED}⚠️  This will remove all containers, images, and volumes. Continue? (y/N)${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Cleanup cancelled"
        return 0
    fi
    
    docker-compose down -v --rmi all
    docker system prune -f
    echo -e "${GREEN}✅ Cleanup completed${NC}"
}

# Function to build images
build_images() {
    echo -e "${BLUE}🔨 Building Docker images...${NC}"
    docker-compose build --no-cache
    echo -e "${GREEN}✅ Images built successfully${NC}"
}

# Function to show access information
show_access_info() {
    echo ""
    echo -e "${GREEN}🎉 Platform is running!${NC}"
    echo ""
    echo -e "${BLUE}📍 Access Points:${NC}"
    echo "   Frontend: http://localhost:8080"
    echo "   Backend API: http://localhost:8080/api/"
    echo "   Admin Panel: http://localhost:8080/admin/"
    echo "   Health Check: http://localhost:8080/api/health/"
    echo ""
}

# Main command handler
case ${1:-help} in
    start)
        start_services $2
        ;;
    stop)
        stop_services
        ;;
    restart)
        restart_services $2
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs $2
        ;;
    shell)
        access_shell $2
        ;;
    backup)
        create_backup
        ;;
    restore)
        restore_backup $2
        ;;
    migrate)
        run_migrations
        ;;
    test)
        run_tests
        ;;
    clean)
        cleanup
        ;;
    build)
        build_images
        ;;
    help|*)
        usage
        ;;
esac