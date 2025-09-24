# AtonixCorp Platform - Kubernetes Infrastructure

This directory contains Terraform configurations for deploying the AtonixCorp Platform to Kubernetes clusters.

## [ARCHITECTURE] Architecture Overview

The infrastructure is organized into modular components:

- **Namespace**: Isolated namespace with resource quotas and limits
- **PostgreSQL**: Primary database with monitoring and backups
- **Redis**: Cache and message broker for Celery
- **Zookeeper**: Distributed coordination and configuration management
- **Backend**: Django application with auto-scaling
- **Frontend**: React application served by Nginx
- **Celery**: Background task processing (workers + scheduler)
- **Ingress**: Traffic routing with SSL termination
- **Monitoring**: Prometheus-based monitoring stack

## [STRUCTURE] Directory Structure

```
terraform/kubernetes/
├── main.tf                    # Main Terraform configuration
├── variables.tf              # Variable definitions
├── outputs.tf               # Output definitions
├── terraform.tfvars.dev     # Development environment config
├── terraform.tfvars.prod    # Production environment config
├── README.md                # This file
└── modules/                 # Terraform modules
    ├── namespace/           # Namespace with resource controls
    ├── postgresql/          # PostgreSQL database
    ├── redis/              # Redis cache
    ├── zookeeper/          # Apache Zookeeper coordination service
    ├── backend/            # Django backend application
    ├── frontend/           # React frontend application
    ├── celery/             # Celery task processing
    ├── ingress/            # Ingress controller configuration
    └── monitoring/         # Prometheus monitoring
```

## [START] Quick Start

### Prerequisites

1. **Kubernetes Cluster**: EKS, GKE, AKS, or local cluster (minikube/kind)
2. **kubectl**: Configured to access your cluster
3. **Terraform**: Version 1.0 or later
4. **Helm** (optional): For easier monitoring stack deployment

### Required Kubernetes Components

Install these components in your cluster before deploying:

```bash
# Nginx Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

# Cert-Manager (for SSL certificates)
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Create ClusterIssuer for Let's Encrypt (production)
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@atonixcorp.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
```

### Deployment Steps

1. **Clone and Navigate**:
   ```bash
   cd terraform/kubernetes
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Create Secret for Django**:
   ```bash
   # Generate a secret key
   DJANGO_SECRET_KEY=$(python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')
   
   # Set environment variable
   export TF_VAR_django_secret_key="$DJANGO_SECRET_KEY"
   ```

4. **Plan Deployment** (Development):
   ```bash
   terraform plan -var-file="terraform.tfvars.dev"
   ```

5. **Apply Configuration**:
   ```bash
   terraform apply -var-file="terraform.tfvars.dev"
   ```

6. **Access the Application**:
   ```bash
   # Get ingress IP
   kubectl get ingress -n atonixcorp-dev
   
   # Add to /etc/hosts (for development)
   echo "INGRESS_IP dev.atonixcorp.local" >> /etc/hosts
   ```

## [ENVIRONMENT] Environment Configurations

### Development Environment

- **File**: `terraform.tfvars.dev`
- **Domain**: `dev.atonixcorp.local`
- **Features**: Reduced resources, no TLS, minimal replicas
- **Usage**: Local development and testing

```bash
terraform apply -var-file="terraform.tfvars.dev"
```

### Production Environment

- **File**: `terraform.tfvars.prod`
- **Domain**: `atonixcorp.com`
- **Features**: High availability, auto-scaling, monitoring, SSL
- **Usage**: Production deployment

```bash
terraform apply -var-file="terraform.tfvars.prod"
```

## [CONFIG] Configuration

### Required Variables

Set these variables either in `.tfvars` files or as environment variables:

```bash
# Django secret key (required)
export TF_VAR_django_secret_key="your-secret-key-here"

# Optional: Custom domain
export TF_VAR_domain_name="yourdomain.com"

# Optional: Container registry
export TF_VAR_image_registry="your-registry.com"
```

### Key Configuration Options

| Variable | Description | Default |
|----------|-------------|---------|
| `project_name` | Project name prefix | `atonixcorp-platform` |
| `environment` | Environment (dev/staging/prod) | `dev` |
| `namespace` | Kubernetes namespace | `atonixcorp-platform` |
| `domain_name` | Primary domain | `atonixcorp.com` |
| `enable_monitoring` | Enable Prometheus monitoring | `true` |
| `enable_autoscaling` | Enable HPA | `true` |
| `backend_replicas` | Backend pod count | `2` |
| `frontend_replicas` | Frontend pod count | `2` |
| `zookeeper_client_port` | Zookeeper client port | `2181` |
| `zookeeper_storage_size` | Zookeeper storage size | `10Gi` |
| `zookeeper_enable_jmx` | Enable Zookeeper JMX monitoring | `true` |

## [MONITORING] Monitoring and Observability

### Prometheus Metrics

The platform exposes metrics for:
- Django application metrics
- PostgreSQL database metrics
- Redis cache metrics
- Zookeeper coordination metrics
- Celery task metrics
- Nginx frontend metrics
- Kubernetes cluster metrics

### Access Monitoring

```bash
# Port-forward to Prometheus
kubectl port-forward -n atonixcorp-platform svc/atonixcorp-platform-prometheus 9090:9090

# Access at http://localhost:9090
```

### Health Checks

- **Backend Health**: `https://yourdomain.com/api/health/`
- **Frontend Health**: `https://yourdomain.com/health`
- **Database**: Internal health checks via probes

## [SECURITY] Security Features

### Network Policies

- Pod-to-pod communication restrictions
- Ingress traffic controls
- Database access limitations

### Security Headers

- X-Frame-Options
- X-Content-Type-Options
- Strict-Transport-Security
- Content-Security-Policy

### TLS/SSL

- Automatic certificate management via cert-manager
- HTTPS redirect enforcement
- HSTS headers

## [SCALE] Scaling

### Horizontal Pod Autoscaler (HPA)

Automatic scaling based on:
- CPU utilization (70% threshold)
- Memory utilization (80% threshold)
- Custom metrics (optional)

### Manual Scaling

```bash
# Scale backend
kubectl scale deployment atonixcorp-platform-backend --replicas=5 -n atonixcorp-platform

# Scale frontend
kubectl scale deployment atonixcorp-platform-frontend --replicas=3 -n atonixcorp-platform
```

## [MAINTENANCE] Updates and Maintenance

### Rolling Updates

```bash
# Update backend image
terraform apply -var="backend_image_tag=v1.2.0" -var-file="terraform.tfvars.prod"

# Check rollout status
kubectl rollout status deployment/atonixcorp-platform-backend -n atonixcorp-platform
```

### Database Migrations

Migrations run automatically via init containers during deployments.

### Backup and Recovery

```bash
# Database backup (if backup is enabled)
kubectl exec -it atonixcorp-platform-postgresql-0 -n atonixcorp-platform -- pg_dump -U atonixuser atonixcorp_prod > backup.sql
```

## [TROUBLESHOOTING] Troubleshooting

### Common Issues

1. **Pods Stuck in Pending**:
   ```bash
   kubectl describe pod POD_NAME -n atonixcorp-platform
   # Check resource constraints and node capacity
   ```

2. **Database Connection Issues**:
   ```bash
   kubectl logs atonixcorp-platform-backend-xxx -n atonixcorp-platform
   # Check database service and credentials
   ```

3. **Ingress Not Working**:
   ```bash
   kubectl describe ingress atonixcorp-platform-ingress -n atonixcorp-platform
   # Verify ingress controller and DNS
   ```

### Useful Commands

```bash
# Get all resources
kubectl get all -n atonixcorp-platform

# Check pod logs
kubectl logs -f deployment/atonixcorp-platform-backend -n atonixcorp-platform

# Execute commands in pods
kubectl exec -it deployment/atonixcorp-platform-backend -n atonixcorp-platform -- python manage.py shell

# Port forwarding for local access
kubectl port-forward svc/atonixcorp-platform-backend 8000:8000 -n atonixcorp-platform
```

## 🧹 Cleanup

### Destroy Infrastructure

```bash
# Destroy everything
terraform destroy -var-file="terraform.tfvars.dev"

# Confirm destruction
# Type 'yes' when prompted
```

### Manual Cleanup

```bash
# Delete PVCs (if needed)
kubectl delete pvc --all -n atonixcorp-platform

# Delete namespace
kubectl delete namespace atonixcorp-platform
```

## [RESOURCES] Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
- [Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [Cert-Manager Documentation](https://cert-manager.io/docs/)
- [Prometheus Operator](https://prometheus-operator.dev/)

## 🆘 Support

For issues and questions:

1. Check the troubleshooting section above
2. Review Kubernetes and application logs
3. Consult the platform documentation
4. Contact the development team

---

**Note**: This infrastructure configuration is designed for production use but can be adapted for development and staging environments using the provided `.tfvars` files.