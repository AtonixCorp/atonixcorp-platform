#!/bin/bash

# AtonixCorp Platform - OpenTelemetry Setup Script
# This script sets up comprehensive observability for the AtonixCorp platform

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
OBSERVABILITY_DIR="infrastructure/observability"
BACKEND_DIR="backend"
FRONTEND_DIR="frontend"

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check required commands
    local required_commands=("docker" "docker-compose" "python3" "node" "npm")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            log_error "Required command '$cmd' not found. Please install it and try again."
            exit 1
        fi
    done
    
    log_success "Prerequisites check completed"
}

# Install backend dependencies
install_backend_dependencies() {
    log_info "Installing backend OpenTelemetry dependencies..."
    
    cd "$BACKEND_DIR"
    
    # Check if virtual environment exists
    if [ ! -d ".venv" ] && [ ! -d "../.venv" ]; then
        log_info "Creating Python virtual environment..."
        python3 -m venv .venv
    fi
    
    # Activate virtual environment
    if [ -d ".venv" ]; then
        source .venv/bin/activate
    elif [ -d "../.venv" ]; then
        source ../.venv/bin/activate
    fi
    
    # Install OpenTelemetry dependencies
    pip install -r requirements-opentelemetry.txt
    
    cd ..
    log_success "Backend dependencies installed"
}

# Install frontend dependencies
install_frontend_dependencies() {
    log_info "Installing frontend OpenTelemetry dependencies..."
    
    cd "$FRONTEND_DIR"
    npm install
    cd ..
    
    log_success "Frontend dependencies installed"
}

# Create environment configuration
create_environment_config() {
    log_info "Creating environment configuration..."
    
    # Backend environment variables
    cat > .env.observability << EOF
# OpenTelemetry Backend Configuration
OTEL_ENABLED=true
OTEL_SERVICE_NAME=atonixcorp-platform
OTEL_SERVICE_VERSION=1.0.0
OTEL_RESOURCE_ATTRIBUTES=service.namespace=atonixcorp,deployment.environment=development

# Tracing Configuration
OTEL_ENABLE_CONSOLE=true
OTEL_ENABLE_JAEGER=true
OTEL_ENABLE_OTLP=true
JAEGER_ENDPOINT=http://localhost:14268/api/traces
JAEGER_AGENT_HOST=localhost
JAEGER_AGENT_PORT=6831

# Metrics Configuration
OTEL_ENABLE_PROMETHEUS=true
PROMETHEUS_METRICS_PORT=8001

# OTLP Configuration
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
OTEL_EXPORTER_OTLP_HEADERS=

# Sampling Configuration
OTEL_TRACES_SAMPLER=parentbased_traceidratio
OTEL_TRACES_SAMPLER_ARG=1.0

# Environment
ENVIRONMENT=development
EOF

    # Frontend environment variables
    cat > "$FRONTEND_DIR/.env.local" << EOF
# OpenTelemetry Frontend Configuration
REACT_APP_OTEL_ENABLED=true
REACT_APP_OTEL_SERVICE_NAME=atonixcorp-frontend
REACT_APP_OTEL_SERVICE_VERSION=1.0.0
REACT_APP_ENVIRONMENT=development

# Tracing Configuration
REACT_APP_OTEL_ENABLE_CONSOLE=true
REACT_APP_OTEL_ENABLE_JAEGER=true
REACT_APP_OTEL_ENABLE_OTLP=true
REACT_APP_JAEGER_ENDPOINT=http://localhost:14268/api/traces
REACT_APP_OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318/v1/traces
EOF

    log_success "Environment configuration created"
}

# Start observability stack
start_observability_stack() {
    log_info "Starting observability stack..."
    
    cd "$OBSERVABILITY_DIR"
    
    # Create required directories
    mkdir -p grafana/provisioning/datasources
    mkdir -p grafana/provisioning/dashboards
    mkdir -p grafana/dashboards
    mkdir -p prometheus/rules
    mkdir -p alertmanager
    mkdir -p loki
    mkdir -p promtail
    mkdir -p traefik
    
    # Create basic Grafana datasource configuration
    cat > grafana/provisioning/datasources/datasources.yml << EOF
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true

  - name: Jaeger
    type: jaeger
    access: proxy
    url: http://jaeger:16686

  - name: Loki
    type: loki
    access: proxy
    url: http://loki:3100
EOF

    # Create basic Loki configuration
    cat > loki/loki-config.yml << EOF
auth_enabled: false

server:
  http_listen_port: 3100

ingester:
  lifecycler:
    address: 127.0.0.1
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1
    final_sleep: 0s

schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 168h

storage_config:
  boltdb:
    directory: /loki/index

  filesystem:
    directory: /loki/chunks

limits_config:
  enforce_metric_name: false
  reject_old_samples: true
  reject_old_samples_max_age: 168h

chunk_store_config:
  max_look_back_period: 0s

table_manager:
  retention_deletes_enabled: false
  retention_period: 0s
EOF

    # Create basic Promtail configuration
    cat > promtail/promtail-config.yml << EOF
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://loki:3100/loki/api/v1/push

scrape_configs:
  - job_name: containers
    static_configs:
      - targets:
          - localhost
        labels:
          job: containerlogs
          __path__: /var/lib/docker/containers/*/*log

    pipeline_stages:
      - json:
          expressions:
            output: log
            stream: stream
            attrs:
      - json:
          source: attrs
          expressions:
            tag:
      - regex:
          source: tag
          expression: (?P<container_name>(?:[^|]*))\|(?P<image_name>(?:[^|]*))\|(?P<image_id>(?:[^|]*))\|(?P<container_id>(?:[^|]*))
      - timestamp:
          source: time
          format: RFC3339Nano
      - labels:
          stream:
          container_name:
          image_name:
          image_id:
          container_id:
      - output:
          source: output
EOF

    # Create basic Alertmanager configuration
    cat > alertmanager/alertmanager.yml << EOF
global:
  smtp_smarthost: 'localhost:587'
  smtp_from: 'alertmanager@atonixcorp.com'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'

receivers:
  - name: 'web.hook'
    webhook_configs:
      - url: 'http://localhost:5001/'
EOF

    # Create basic Traefik configuration
    cat > traefik/traefik.yml << EOF
api:
  dashboard: true
  insecure: true

entryPoints:
  web:
    address: ":80"

providers:
  docker:
    exposedByDefault: false
EOF

    # Start the observability stack
    docker-compose up -d
    
    cd ..
    log_success "Observability stack started"
}

# Wait for services to be ready
wait_for_services() {
    log_info "Waiting for services to be ready..."
    
    # Wait for Jaeger
    log_info "Waiting for Jaeger..."
    timeout=60
    while ! curl -s http://localhost:16686 > /dev/null && [ $timeout -gt 0 ]; do
        sleep 2
        timeout=$((timeout - 2))
    done
    
    # Wait for Prometheus
    log_info "Waiting for Prometheus..."
    timeout=60
    while ! curl -s http://localhost:9090 > /dev/null && [ $timeout -gt 0 ]; do
        sleep 2
        timeout=$((timeout - 2))
    done
    
    # Wait for Grafana
    log_info "Waiting for Grafana..."
    timeout=60
    while ! curl -s http://localhost:3000 > /dev/null && [ $timeout -gt 0 ]; do
        sleep 2
        timeout=$((timeout - 2))
    done
    
    log_success "Services are ready"
}

# Print access information
print_access_info() {
    log_info "OpenTelemetry setup completed! Here's how to access your observability stack:"
    
    echo ""
    echo "🎯 Access Information:"
    echo "====================="
    echo "📊 Jaeger UI:           http://localhost:16686"
    echo "📈 Prometheus:          http://localhost:9090"
    echo "📊 Grafana:             http://localhost:3000 (admin/atonix2024!)"
    echo "🚨 Alertmanager:        http://localhost:9093"
    echo "📋 Loki:               http://localhost:3100"
    echo "⚙️  OpenTelemetry UI:   http://localhost:55679"
    echo "🔍 Elasticsearch:      http://localhost:9200"
    echo "📊 Kibana:             http://localhost:5601"
    echo ""
    echo "🔧 Configuration:"
    echo "=================="
    echo "📁 Backend config:      .env.observability"
    echo "📁 Frontend config:     frontend/.env.local"
    echo "📁 Stack config:        infrastructure/observability/"
    echo ""
    echo "⚠️  Next Steps:"
    echo "==============="
    echo "1. Start your Django backend with the virtual environment activated"
    echo "2. Start your React frontend: cd frontend && npm start"
    echo "3. Make some requests to generate telemetry data"
    echo "4. View traces in Jaeger: http://localhost:16686"
    echo "5. View metrics in Grafana: http://localhost:3000"
    echo "6. Check logs in Loki/Grafana"
    echo ""
    echo "📚 Documentation:"
    echo "=================="
    echo "- Backend instrumentation: backend/observability/"
    echo "- Frontend instrumentation: frontend/src/observability/"
    echo "- Stack configuration: infrastructure/observability/"
    echo ""
    echo "🎮 Test Commands:"
    echo "================="
    echo "# Test backend tracing"
    echo "curl http://localhost:8000/api/health/"
    echo ""
    echo "# Test frontend (open browser)"
    echo "open http://localhost:3000"
    echo ""
    echo "# View traces"
    echo "open http://localhost:16686"
}

# Main execution
main() {
    echo "🔭 AtonixCorp OpenTelemetry Setup"
    echo "================================="
    echo ""
    
    check_prerequisites
    install_backend_dependencies
    install_frontend_dependencies
    create_environment_config
    start_observability_stack
    wait_for_services
    print_access_info
    
    echo ""
    log_success "🎉 OpenTelemetry setup completed successfully!"
}

# Run main function
main "$@"