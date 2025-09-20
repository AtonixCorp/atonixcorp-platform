#!/bin/bash
# Build and run script for AtonixCorp Platform unified container

set -e

echo "🚀 AtonixCorp Platform - Unified Container Builder"
echo "=================================================="

# Function to show usage
show_usage() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  build     - Build the unified container"
    echo "  run       - Run the unified container with dependencies"
    echo "  dev       - Run in development mode (with code mounting)"
    echo "  stop      - Stop all containers"
    echo "  logs      - Show container logs"
    echo "  clean     - Clean up containers and images"
    echo "  help      - Show this help message"
    echo ""
}

# Function to build the container
build_container() {
    echo "📦 Building unified container..."
    nerdctl build -f Dockerfile.fullstack -t atonixcorp-platform:latest .
    echo "✅ Container built successfully!"
}

# Function to run the unified stack
run_stack() {
    echo "🏃 Starting AtonixCorp Platform..."
    nerdctl compose -f docker-compose.unified.yml up -d
    echo "✅ Platform started successfully!"
    echo ""
    echo "🌐 Access URLs:"
    echo "   Frontend + API: http://localhost"
    echo "   Django Admin:   http://localhost/admin/"
    echo "   API Direct:     http://localhost:8000/api/"
    echo "   RabbitMQ UI:    http://localhost:15672 (admin/rabbitmq_password)"
    echo "   MailHog UI:     http://localhost:8025"
    echo "   Health Check:   http://localhost/health/"
}

# Function to run in development mode
run_dev() {
    echo "🔧 Starting in development mode..."
    # Create development override
    cat > docker-compose.dev.yml << 'EOF'
version: '3.8'
services:
  app:
    volumes:
      - ./backend:/app:rw
      - ./frontend/src:/app/frontend_src:ro
    environment:
      - DEBUG=True
      - DJANGO_SETTINGS_MODULE=atonixcorp.settings
EOF
    
    nerdctl compose -f docker-compose.unified.yml -f docker-compose.dev.yml up -d
    echo "✅ Development environment started!"
}

# Function to stop containers
stop_containers() {
    echo "🛑 Stopping containers..."
    nerdctl compose -f docker-compose.unified.yml down
    echo "✅ Containers stopped!"
}

# Function to show logs
show_logs() {
    echo "📋 Showing container logs..."
    nerdctl compose -f docker-compose.unified.yml logs -f "${2:-app}"
}

# Function to clean up
clean_up() {
    echo "🧹 Cleaning up..."
    nerdctl compose -f docker-compose.unified.yml down -v
    nerdctl image rm atonixcorp-platform:latest 2>/dev/null || true
    echo "✅ Cleanup completed!"
}

# Function to check requirements
check_requirements() {
    echo "🔍 Checking requirements..."
    
    # Check if nerdctl is available
    if ! command -v nerdctl &> /dev/null; then
        echo "❌ nerdctl is not installed or not in PATH"
        exit 1
    fi
    
    # Check if frontend directory exists
    if [ ! -d "frontend" ]; then
        echo "❌ Frontend directory not found"
        exit 1
    fi
    
    # Check if backend directory exists
    if [ ! -d "backend" ]; then
        echo "❌ Backend directory not found"
        exit 1
    fi
    
    echo "✅ Requirements check passed!"
}

# Main script logic
case "${1:-help}" in
    "build")
        check_requirements
        build_container
        ;;
    "run")
        check_requirements
        build_container
        run_stack
        ;;
    "dev")
        check_requirements
        build_container
        run_dev
        ;;
    "stop")
        stop_containers
        ;;
    "logs")
        show_logs "$@"
        ;;
    "clean")
        clean_up
        ;;
    "help"|*)
        show_usage
        ;;
esac