#!/bin/bash

# MedChain FREE Deployment Script
# Uses only free CNCF technologies and local development tools
# Total cost: $0

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

# Check prerequisites (all free tools)
check_prerequisites() {
    print_status "Checking FREE prerequisites..."
    
    if ! command_exists kubectl; then
        print_error "kubectl is not installed. Please install kubectl first."
        print_status "Install kubectl: https://kubernetes.io/docs/tasks/tools/"
        exit 1
    fi
    
    if ! command_exists docker; then
        print_error "Docker is not installed. Please install Docker first."
        print_status "Install Docker: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    if ! command_exists minikube && ! command_exists kind; then
        print_warning "Neither minikube nor kind is installed. Installing minikube (FREE)..."
        print_status "Installing minikube..."
        
        # Install minikube based on OS
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
            sudo install minikube-linux-amd64 /usr/local/bin/minikube
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install minikube
        else
            print_error "Unsupported OS. Please install minikube manually."
            exit 1
        fi
    fi
    
    print_success "All FREE prerequisites are ready!"
}

# Start FREE local Kubernetes cluster
start_free_cluster() {
    print_status "Starting FREE local Kubernetes cluster..."
    
    if command_exists minikube; then
        if ! minikube status | grep -q "Running"; then
            # Start with minimal resources (FREE)
            minikube start --cpus 2 --memory 4096 --disk-size 10g --driver=docker
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
EOF
        else
            print_status "Kind cluster is already running"
        fi
    fi
    
    print_success "FREE Kubernetes cluster is ready!"
}

# Build Docker images (FREE)
build_free_images() {
    print_status "Building FREE Docker images..."
    
    # Build frontend image
    print_status "Building frontend image..."
    cd frontend
    docker build -t $FRONTEND_IMAGE .
    cd ..
    
    print_success "FREE Docker images built successfully!"
}

# Deploy namespace (FREE)
deploy_free_namespace() {
    print_status "Creating namespace..."
    kubectl apply -f k8s/namespace.yaml
    print_success "Namespace created!"
}

# Deploy FREE monitoring stack
deploy_free_monitoring() {
    print_status "Deploying FREE monitoring stack..."
    kubectl apply -f k8s/monitoring.yaml
    
    # Wait for monitoring to be ready
    print_status "Waiting for FREE monitoring stack to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n $NAMESPACE
    kubectl wait --for=condition=available --timeout=300s deployment/grafana -n $NAMESPACE
    
    print_success "FREE monitoring stack deployed!"
}

# Deploy FREE application
deploy_free_application() {
    print_status "Deploying FREE MedChain application..."
    
    # Apply deployment
    kubectl apply -f k8s/frontend-deployment.yaml
    
    # Wait for deployment to be ready
    print_status "Waiting for FREE application to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/medchain-frontend -n $NAMESPACE
    
    print_success "FREE application deployed!"
}

# Setup FREE Istio (optional)
setup_free_istio() {
    print_status "Setting up FREE Istio service mesh..."
    
    # Install Istio (FREE)
    if ! command_exists istioctl; then
        print_warning "Istioctl not found. Installing FREE Istio..."
        curl -L https://istio.io/downloadIstio | sh -
        export PATH=$PWD/istio-*/bin:$PATH
    fi
    
    # Install Istio with demo profile (FREE)
    istioctl install --set profile=demo -y
    
    # Enable Istio injection for namespace
    kubectl label namespace $NAMESPACE istio-injection=enabled --overwrite
    
    print_success "FREE Istio setup completed!"
}

# Setup FREE Helm (optional)
setup_free_helm() {
    print_status "Setting up FREE Helm..."
    
    if ! command_exists helm; then
        print_warning "Helm not found. Installing FREE Helm..."
        curl https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz | tar xz
        sudo mv linux-amd64/helm /usr/local/bin/helm
    fi
    
    # Add FREE Helm repositories
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update
    
    print_success "FREE Helm setup completed!"
}

# Get FREE application URLs
get_free_urls() {
    print_status "Getting FREE application URLs..."
    
    if command_exists minikube; then
        FRONTEND_URL=$(minikube service medchain-frontend-service -n $NAMESPACE --url)
        GRAFANA_URL=$(minikube service grafana-service -n $NAMESPACE --url)
        PROMETHEUS_URL=$(minikube service prometheus-service -n $NAMESPACE --url)
    else
        FRONTEND_URL="http://localhost:80"
        GRAFANA_URL="http://localhost:3000"
        PROMETHEUS_URL="http://localhost:9090"
    fi
    
    print_success "FREE Application URLs:"
    echo "Frontend: $FRONTEND_URL"
    echo "Grafana: $GRAFANA_URL (admin/admin123)"
    echo "Prometheus: $PROMETHEUS_URL"
    echo ""
    echo "💰 Total Cost: $0 (FREE!)"
}

# Show FREE deployment status
show_free_status() {
    print_status "FREE Deployment status:"
    
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
    echo "💰 Cost Analysis:"
    echo "- Kubernetes: FREE (local)"
    echo "- Monitoring: FREE (self-hosted)"
    echo "- Service Mesh: FREE (Istio)"
    echo "- Total: $0"
}

# FREE cleanup function
cleanup_free() {
    print_status "Cleaning up FREE deployment..."
    
    kubectl delete namespace $NAMESPACE --ignore-not-found=true
    
    if command_exists minikube; then
        minikube stop
    elif command_exists kind; then
        kind delete cluster --name medchain-cluster
    fi
    
    print_success "FREE cleanup completed!"
}

# FREE deployment function
deploy_free() {
    print_status "Starting FREE MedChain deployment..."
    
    check_prerequisites
    start_free_cluster
    build_free_images
    deploy_free_namespace
    deploy_free_monitoring
    deploy_free_application
    
    # Optional: Setup FREE Istio and Helm
    if [ "$1" = "--with-istio" ]; then
        setup_free_istio
    fi
    
    if [ "$1" = "--with-helm" ]; then
        setup_free_helm
    fi
    
    get_free_urls
    show_free_status
    
    print_success "FREE MedChain deployment completed successfully!"
    print_status "💰 Total cost: $0 (FREE!)"
    print_status "You can now access the application at the URLs shown above."
    print_status "The blockchain simulation is active - all transactions will show realistic transaction IDs and confirmations."
}

# FREE help function
show_free_help() {
    echo "MedChain FREE Deployment Script"
    echo ""
    echo "💰 Total Cost: $0 (FREE!)"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  deploy              Deploy the complete FREE MedChain application"
    echo "  deploy --with-istio Deploy with FREE Istio service mesh"
    echo "  deploy --with-helm  Deploy using FREE Helm charts"
    echo "  status              Show FREE deployment status"
    echo "  cleanup             Clean up all FREE resources"
    echo "  help                Show this help message"
    echo ""
    echo "💰 Cost Breakdown:"
    echo "- Kubernetes: FREE (minikube/kind)"
    echo "- Monitoring: FREE (Prometheus/Grafana)"
    echo "- Service Mesh: FREE (Istio)"
    echo "- Total: $0"
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
        deploy_free "$2"
        ;;
    "status")
        show_free_status
        ;;
    "cleanup")
        cleanup_free
        ;;
    "help"|"-h"|"--help")
        show_free_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_free_help
        exit 1
        ;;
esac 