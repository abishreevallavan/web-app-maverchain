#!/bin/bash

# MedChain Deployment Script
# This script deploys the entire MedChain application with blockchain simulation
# and CNCF technologies (Kubernetes, Prometheus, Grafana)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="medchain"
FRONTEND_IMAGE="medchain/frontend:latest"
API_IMAGE="medchain/api:latest"
REGISTRY="localhost:5000"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command_exists kubectl; then
        print_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    
    if ! command_exists docker; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command_exists minikube && ! command_exists kind; then
        print_warning "Neither minikube nor kind is installed. Please install one of them for local development."
        print_status "You can install minikube with: brew install minikube (macOS) or follow the official docs."
        exit 1
    fi
    
    print_success "Prerequisites check passed!"
}

# Start local Kubernetes cluster
start_cluster() {
    print_status "Starting local Kubernetes cluster..."
    
    if command_exists minikube; then
        if ! minikube status | grep -q "Running"; then
            minikube start --cpus 4 --memory 8192 --disk-size 20g
            minikube addons enable ingress
            minikube addons enable metrics-server
        else
            print_status "Minikube is already running"
        fi
        eval $(minikube docker-env)
    elif command_exists kind; then
        if ! kind get clusters | grep -q "medchain-cluster"; then
            kind create cluster --name medchain-cluster --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
- role: worker
- role: worker
EOF
        else
            print_status "Kind cluster is already running"
        fi
    fi
    
    print_success "Kubernetes cluster is ready!"
}

# Build Docker images
build_images() {
    print_status "Building Docker images..."
    
    # Build frontend image
    print_status "Building frontend image..."
    cd frontend
    docker build -t $FRONTEND_IMAGE .
    cd ..
    
    # Build API image (if exists)
    if [ -d "api" ]; then
        print_status "Building API image..."
        cd api
        docker build -t $API_IMAGE .
        cd ..
    fi
    
    print_success "Docker images built successfully!"
}

# Deploy namespace
deploy_namespace() {
    print_status "Creating namespace..."
    kubectl apply -f k8s/namespace.yaml
    print_success "Namespace created!"
}

# Deploy monitoring stack
deploy_monitoring() {
    print_status "Deploying monitoring stack..."
    kubectl apply -f k8s/monitoring.yaml
    
    # Wait for monitoring to be ready
    print_status "Waiting for monitoring stack to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n $NAMESPACE
    kubectl wait --for=condition=available --timeout=300s deployment/grafana -n $NAMESPACE
    
    print_success "Monitoring stack deployed!"
}

# Deploy application
deploy_application() {
    print_status "Deploying MedChain application..."
    
    # Update image tags in deployment files
    sed -i.bak "s|medchain/frontend:latest|$FRONTEND_IMAGE|g" k8s/frontend-deployment.yaml
    sed -i.bak "s|medchain/api:latest|$API_IMAGE|g" k8s/frontend-deployment.yaml
    
    # Apply deployment
    kubectl apply -f k8s/frontend-deployment.yaml
    
    # Wait for deployment to be ready
    print_status "Waiting for application to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/medchain-frontend -n $NAMESPACE
    
    print_success "Application deployed!"
}

# Setup Istio (optional)
setup_istio() {
    print_status "Setting up Istio service mesh..."
    
    # Install Istio
    if ! command_exists istioctl; then
        print_warning "Istioctl not found. Installing Istio..."
        curl -L https://istio.io/downloadIstio | sh -
        export PATH=$PWD/istio-*/bin:$PATH
    fi
    
    # Install Istio with demo profile
    istioctl install --set profile=demo -y
    
    # Enable Istio injection for namespace
    kubectl label namespace $NAMESPACE istio-injection=enabled --overwrite
    
    print_success "Istio setup completed!"
}

# Setup Helm (optional)
setup_helm() {
    print_status "Setting up Helm..."
    
    if ! command_exists helm; then
        print_warning "Helm not found. Installing Helm..."
        curl https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz | tar xz
        sudo mv linux-amd64/helm /usr/local/bin/helm
    fi
    
    # Add Helm repositories
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update
    
    print_success "Helm setup completed!"
}

# Deploy with Helm (alternative)
deploy_with_helm() {
    print_status "Deploying with Helm..."
    
    # Create values file
    cat > helm-values.yaml <<EOF
frontend:
  image:
    repository: medchain/frontend
    tag: latest
  replicaCount: 3
  resources:
    requests:
      memory: 128Mi
      cpu: 100m
    limits:
      memory: 256Mi
      cpu: 200m

monitoring:
  prometheus:
    enabled: true
    retention: 7d
  grafana:
    enabled: true
    adminPassword: admin123
EOF
    
    # Install with Helm
    helm install medchain ./helm-chart -f helm-values.yaml -n $NAMESPACE --create-namespace
    
    print_success "Helm deployment completed!"
}

# Get application URLs
get_urls() {
    print_status "Getting application URLs..."
    
    if command_exists minikube; then
        FRONTEND_URL=$(minikube service medchain-frontend-service -n $NAMESPACE --url)
        GRAFANA_URL=$(minikube service grafana-service -n $NAMESPACE --url)
        PROMETHEUS_URL=$(minikube service prometheus-service -n $NAMESPACE --url)
    else
        FRONTEND_URL="http://localhost:80"
        GRAFANA_URL="http://localhost:3000"
        PROMETHEUS_URL="http://localhost:9090"
    fi
    
    print_success "Application URLs:"
    echo "Frontend: $FRONTEND_URL"
    echo "Grafana: $GRAFANA_URL (admin/admin123)"
    echo "Prometheus: $PROMETHEUS_URL"
}

# Show deployment status
show_status() {
    print_status "Deployment status:"
    
    echo ""
    echo "Pods:"
    kubectl get pods -n $NAMESPACE
    
    echo ""
    echo "Services:"
    kubectl get services -n $NAMESPACE
    
    echo ""
    echo "Deployments:"
    kubectl get deployments -n $NAMESPACE
    
    echo ""
    echo "Ingress:"
    kubectl get ingress -n $NAMESPACE
}

# Cleanup function
cleanup() {
    print_status "Cleaning up deployment..."
    
    kubectl delete namespace $NAMESPACE --ignore-not-found=true
    
    if command_exists minikube; then
        minikube stop
    elif command_exists kind; then
        kind delete cluster --name medchain-cluster
    fi
    
    print_success "Cleanup completed!"
}

# Main deployment function
deploy() {
    print_status "Starting MedChain deployment..."
    
    check_prerequisites
    start_cluster
    build_images
    deploy_namespace
    deploy_monitoring
    deploy_application
    
    # Optional: Setup Istio and Helm
    if [ "$1" = "--with-istio" ]; then
        setup_istio
    fi
    
    if [ "$1" = "--with-helm" ]; then
        setup_helm
        deploy_with_helm
    fi
    
    get_urls
    show_status
    
    print_success "MedChain deployment completed successfully!"
    print_status "You can now access the application at the URLs shown above."
    print_status "The blockchain simulation is active - all transactions will show realistic transaction IDs and confirmations."
}

# Help function
show_help() {
    echo "MedChain Deployment Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  deploy              Deploy the complete MedChain application"
    echo "  deploy --with-istio Deploy with Istio service mesh"
    echo "  deploy --with-helm  Deploy using Helm charts"
    echo "  status              Show deployment status"
    echo "  cleanup             Clean up all resources"
    echo "  help                Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 deploy"
    echo "  $0 deploy --with-istio"
    echo "  $0 status"
    echo "  $0 cleanup"
}

# Main script logic
case "${1:-deploy}" in
    "deploy")
        deploy "$2"
        ;;
    "status")
        show_status
        ;;
    "cleanup")
        cleanup
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac 