#!/bin/bash
# AtonixCorp Platform Infrastructure Setup
# Puppet + Gerrit + CNI Configuration and Deployment

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRASTRUCTURE_DIR="${SCRIPT_DIR}/infrastructure"
PUPPET_DIR="${INFRASTRUCTURE_DIR}/puppet"
GERRIT_DIR="${INFRASTRUCTURE_DIR}/gerrit"
CNI_DIR="${INFRASTRUCTURE_DIR}/cni"

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
    exit 1
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO:${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root"
    fi
}

# Print banner
print_banner() {
    echo -e "${BLUE}"
    cat << 'EOF'
    ╔══════════════════════════════════════════════════════════════╗
    ║              AtonixCorp Platform Infrastructure              ║
    ║          Puppet + Gerrit + CNI Setup & Configuration        ║
    ║                                                              ║
    ║  🔧 Puppet Configuration Management                          ║
    ║  🔄 Gerrit Code Review & CI/CD                              ║
    ║  🌐 CNI Container Networking                                ║
    ║  📊 Comprehensive Monitoring                                ║
    ╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Install prerequisites
install_prerequisites() {
    log "Installing prerequisites..."
    
    # Update package lists
    apt-get update
    
    # Install required packages
    apt-get install -y \
        wget \
        curl \
        git \
        docker.io \
        docker-compose \
        ruby \
        ruby-dev \
        build-essential \
        python3 \
        python3-pip \
        openjdk-11-jdk \
        postgresql \
        postgresql-contrib \
        nginx \
        iptables \
        bridge-utils \
        net-tools
    
    # Install Puppet
    wget https://apt.puppet.com/puppet7-release-focal.deb
    dpkg -i puppet7-release-focal.deb
    apt-get update
    apt-get install -y puppet-agent
    
    # Add Puppet to PATH
    export PATH="/opt/puppetlabs/bin:$PATH"
    echo 'export PATH="/opt/puppetlabs/bin:$PATH"' >> /etc/environment
    
    log "Prerequisites installed successfully"
}

# Setup Puppet
setup_puppet() {
    log "Setting up Puppet configuration management..."
    
    # Create Puppet directory structure
    mkdir -p /etc/puppetlabs/code/environments/production/{manifests,modules,hieradata}
    
    # Copy Puppet manifests and modules
    cp -r "${PUPPET_DIR}/manifests/"* /etc/puppetlabs/code/environments/production/manifests/
    cp -r "${PUPPET_DIR}/modules/"* /etc/puppetlabs/code/environments/production/modules/
    
    # Set proper ownership
    chown -R puppet:puppet /etc/puppetlabs/code/environments/production/
    
    # Create Puppet configuration
    cat > /etc/puppetlabs/puppet/puppet.conf << EOF
[main]
    vardir = /opt/puppetlabs/puppet/cache
    logdir = /var/log/puppetlabs/puppet
    rundir = /var/run/puppetlabs
    ssldir = /etc/puppetlabs/puppet/ssl
    server = localhost
    environment = production

[agent]
    pluginsync = true
    report = true
    ignoreschedules = true
    daemon = false
    ca_server = localhost
    certname = $(hostname -f)
    environment = production
    server = localhost
EOF
    
    # Test Puppet configuration
    /opt/puppetlabs/bin/puppet parser validate /etc/puppetlabs/code/environments/production/manifests/site.pp
    
    log "Puppet setup completed"
}

# Setup CNI networking
setup_cni() {
    log "Setting up CNI container networking..."
    
    # Make CNI setup script executable and run it
    chmod +x "${CNI_DIR}/setup-cni.sh"
    "${CNI_DIR}/setup-cni.sh"
    
    log "CNI networking setup completed"
}

# Setup Gerrit CI/CD
setup_gerrit() {
    log "Setting up Gerrit CI/CD system..."
    
    # Create Gerrit directory
    mkdir -p /opt/gerrit
    
    # Start Gerrit services using Docker Compose
    cd "${GERRIT_DIR}"
    docker-compose up -d
    
    # Wait for services to start
    info "Waiting for Gerrit services to start..."
    sleep 30
    
    # Check if Gerrit is running
    if curl -f http://localhost:8081 > /dev/null 2>&1; then
        log "Gerrit is running successfully"
    else
        warn "Gerrit may not be fully started yet. Check logs with: docker-compose -f ${GERRIT_DIR}/docker-compose.yml logs"
    fi
    
    log "Gerrit CI/CD setup completed"
}

# Setup monitoring
setup_monitoring() {
    log "Setting up monitoring infrastructure..."
    
    # Apply Puppet monitoring module
    /opt/puppetlabs/bin/puppet apply -e "include atonixcorp::monitoring"
    
    log "Monitoring setup completed"
}

# Create management scripts
create_management_scripts() {
    log "Creating management scripts..."
    
    # Main management script
    cat > /usr/local/bin/atonixcorp-infra-manage << 'EOF'
#!/bin/bash
# AtonixCorp Infrastructure Management Script

case "$1" in
    status)
        echo "AtonixCorp Infrastructure Status"
        echo "================================"
        echo
        echo "Puppet Status:"
        systemctl status puppet --no-pager -l
        echo
        echo "Gerrit Services:"
        cd /opt/atonixcorp-platform/infrastructure/gerrit
        docker-compose ps
        echo
        echo "CNI Status:"
        /usr/local/bin/atonixcorp-cni-manage status
        echo
        echo "Monitoring Status:"
        systemctl status prometheus --no-pager -l
        systemctl status node-exporter --no-pager -l
        ;;
    puppet-run)
        echo "Running Puppet configuration..."
        /opt/puppetlabs/bin/puppet apply /etc/puppetlabs/code/environments/production/manifests/site.pp
        ;;
    gerrit-restart)
        echo "Restarting Gerrit services..."
        cd /opt/atonixcorp-platform/infrastructure/gerrit
        docker-compose restart
        ;;
    cni-restart)
        echo "Restarting CNI networking..."
        /usr/local/bin/atonixcorp-cni-manage restart
        ;;
    logs)
        echo "Viewing infrastructure logs..."
        echo "Puppet logs:"
        tail -20 /var/log/puppetlabs/puppet/puppet.log
        echo
        echo "Gerrit logs:"
        cd /opt/atonixcorp-platform/infrastructure/gerrit
        docker-compose logs --tail=20
        ;;
    *)
        echo "AtonixCorp Infrastructure Management"
        echo "Usage: $0 {status|puppet-run|gerrit-restart|cni-restart|logs}"
        echo
        echo "Commands:"
        echo "  status         - Show status of all infrastructure components"
        echo "  puppet-run     - Run Puppet configuration management"
        echo "  gerrit-restart - Restart Gerrit CI/CD services"
        echo "  cni-restart    - Restart CNI networking"
        echo "  logs           - View infrastructure logs"
        exit 1
        ;;
esac
EOF

    chmod +x /usr/local/bin/atonixcorp-infra-manage
    
    log "Management scripts created"
}

# Run infrastructure tests
run_tests() {
    log "Running infrastructure tests..."
    
    # Test Puppet
    info "Testing Puppet configuration..."
    /opt/puppetlabs/bin/puppet parser validate /etc/puppetlabs/code/environments/production/manifests/site.pp
    
    # Test CNI
    info "Testing CNI networking..."
    /usr/local/bin/atonixcorp-cni-manage test
    
    # Test Gerrit
    info "Testing Gerrit connectivity..."
    if curl -f http://localhost:8081 > /dev/null 2>&1; then
        info "✅ Gerrit is accessible"
    else
        warn "❌ Gerrit is not accessible"
    fi
    
    # Test monitoring
    info "Testing monitoring services..."
    if systemctl is-active prometheus > /dev/null 2>&1; then
        info "✅ Prometheus is running"
    else
        warn "❌ Prometheus is not running"
    fi
    
    log "Infrastructure tests completed"
}

# Create documentation
create_documentation() {
    log "Creating infrastructure documentation..."
    
    cat > /opt/atonixcorp-platform/INFRASTRUCTURE_GUIDE.md << 'EOF'
# AtonixCorp Platform Infrastructure Guide

## Overview
This guide covers the infrastructure components of the AtonixCorp platform:
- Puppet Configuration Management
- Gerrit Code Review & CI/CD
- CNI Container Networking
- Monitoring & Alerting

## Components

### Puppet Configuration Management
- **Location**: `/etc/puppetlabs/code/environments/production/`
- **Manifests**: Platform, Security, Monitoring modules
- **Usage**: `puppet apply manifests/site.pp`

### Gerrit CI/CD
- **Web Interface**: http://localhost:8081
- **SSH Port**: 29418
- **Configuration**: `/infrastructure/gerrit/config/`
- **Management**: `docker-compose -f infrastructure/gerrit/docker-compose.yml`

### CNI Networking
- **Configuration**: `/etc/cni/net.d/`
- **Bridge**: `atonix-br0` (10.100.0.0/16)
- **Management**: `atonixcorp-cni-manage`

### Monitoring
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000
- **Alertmanager**: http://localhost:9093
- **Node Exporter**: http://localhost:9100

## Management Commands

### Infrastructure Status
```bash
atonixcorp-infra-manage status
```

### Run Puppet
```bash
atonixcorp-infra-manage puppet-run
```

### Restart Services
```bash
atonixcorp-infra-manage gerrit-restart
atonixcorp-infra-manage cni-restart
```

### View Logs
```bash
atonixcorp-infra-manage logs
```

## CI/CD Workflow

1. **Code Review**: Submit changes to Gerrit
2. **Automated Testing**: Zuul runs tests and security scans
3. **Infrastructure Changes**: Puppet automatically applies approved changes
4. **Monitoring**: Prometheus/Grafana track deployment status

## Security Features

- Puppet-managed security configuration
- Gerrit authentication and authorization
- CNI network isolation and firewalling
- Comprehensive monitoring and alerting

## Troubleshooting

### Puppet Issues
```bash
puppet agent --test --verbose
tail -f /var/log/puppetlabs/puppet/puppet.log
```

### Gerrit Issues
```bash
docker-compose -f infrastructure/gerrit/docker-compose.yml logs gerrit
```

### CNI Issues
```bash
atonixcorp-cni-manage status
journalctl -u containerd -f
```

## Maintenance

### Daily
- Check infrastructure status
- Review monitoring alerts
- Validate Puppet runs

### Weekly
- Update security configurations
- Review Gerrit metrics
- Check CNI network performance

### Monthly
- Update infrastructure components
- Security audits
- Performance optimization
EOF

    log "Infrastructure documentation created"
}

# Main installation function
main() {
    print_banner
    
    log "Starting AtonixCorp Platform Infrastructure setup..."
    
    check_root
    install_prerequisites
    setup_puppet
    setup_cni
    setup_gerrit
    setup_monitoring
    create_management_scripts
    run_tests
    create_documentation
    
    log "🎉 AtonixCorp Platform Infrastructure setup completed successfully!"
    
    echo
    info "Infrastructure Services:"
    info "├── Puppet: Configuration management ready"
    info "├── Gerrit: http://localhost:8081 (CI/CD)"
    info "├── CNI: Container networking configured"
    info "└── Monitoring: Prometheus + Grafana"
    echo
    info "Management: Use 'atonixcorp-infra-manage status' to check all services"
    info "Documentation: See /opt/atonixcorp-platform/INFRASTRUCTURE_GUIDE.md"
    echo
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi