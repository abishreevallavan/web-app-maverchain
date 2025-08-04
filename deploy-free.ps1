# MedChain FREE Deployment Script for Windows PowerShell
# Uses only free CNCF technologies and local development tools
# Total cost: $0

param(
    [string]$Command = "deploy",
    [string]$Option = ""
)

# Configuration
$NAMESPACE = "medchain"
$FRONTEND_IMAGE = "medchain/frontend:latest"
$REGISTRY = "localhost:5000"

# Colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Reset = "`e[0m"

# Function to print colored output
function Write-Status {
    param([string]$Message)
    Write-Host "$Blue[INFO]$Reset $Message"
}

function Write-Success {
    param([string]$Message)
    Write-Host "$Green[SUCCESS]$Reset $Message"
}

function Write-Warning {
    param([string]$Message)
    Write-Host "$Yellow[WARNING]$Reset $Message"
}

function Write-Error {
    param([string]$Message)
    Write-Host "$Red[ERROR]$Reset $Message"
}

# Function to check if command exists
function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Check FREE prerequisites
function Check-Prerequisites {
    Write-Status "Checking FREE prerequisites..."
    
    # Check kubectl
    if (-not (Test-Command "kubectl")) {
        Write-Error "kubectl is not installed. Please install kubectl first."
        Write-Status "Install kubectl: https://kubernetes.io/docs/tasks/tools/"
        exit 1
    }
    
    # Check Docker
    if (-not (Test-Command "docker")) {
        Write-Error "Docker is not installed. Please install Docker first."
        Write-Status "Install Docker: https://docs.docker.com/get-docker/"
        exit 1
    }
    
    # Check minikube or kind
    if (-not (Test-Command "minikube")) {
        if (-not (Test-Command "kind")) {
            Write-Warning "Neither minikube nor kind is installed. Installing minikube (FREE)..."
            Write-Status "Installing minikube..."
            
            # Download and install minikube for Windows
            Invoke-WebRequest -OutFile "minikube.exe" -Uri "https://github.com/kubernetes/minikube/releases/latest/download/minikube-windows-amd64.exe"
            Move-Item "minikube.exe" "C:\Windows\System32\minikube.exe" -Force
        }
    }
    
    Write-Success "All FREE prerequisites are ready!"
}

# Start FREE local Kubernetes cluster
function Start-FreeCluster {
    Write-Status "Starting FREE local Kubernetes cluster..."
    
    if (Test-Command "minikube") {
        $status = minikube status 2>&1
        if ($status -notmatch "Running") {
            # Start with minimal resources (FREE)
            minikube start --cpus 2 --memory 4096 --disk-size 10g --driver=docker
            minikube addons enable ingress
            minikube addons enable metrics-server
        } else {
            Write-Status "Minikube is already running"
        }
        & minikube docker-env
    } elseif (Test-Command "kind") {
        $clusters = kind get clusters 2>&1
        if ($clusters -notmatch "medchain-cluster") {
            # Create kind cluster configuration
            @"
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
"@ | Out-File -FilePath "kind-config.yaml" -Encoding UTF8
            
            kind create cluster --name medchain-cluster --config kind-config.yaml
        } else {
            Write-Status "Kind cluster is already running"
        }
    }
    
    Write-Success "FREE Kubernetes cluster is ready!"
}

# Build FREE Docker images
function Build-FreeImages {
    Write-Status "Building FREE Docker images..."
    
    # Build frontend image
    Write-Status "Building frontend image..."
    Set-Location frontend
    docker build -t $FRONTEND_IMAGE .
    Set-Location ..
    
    Write-Success "FREE Docker images built successfully!"
}

# Deploy FREE namespace
function Deploy-FreeNamespace {
    Write-Status "Creating namespace..."
    kubectl apply -f k8s/namespace.yaml
    Write-Success "Namespace created!"
}

# Deploy FREE monitoring stack
function Deploy-FreeMonitoring {
    Write-Status "Deploying FREE monitoring stack..."
    kubectl apply -f k8s/monitoring.yaml
    
    # Wait for monitoring to be ready
    Write-Status "Waiting for FREE monitoring stack to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n $NAMESPACE
    kubectl wait --for=condition=available --timeout=300s deployment/grafana -n $NAMESPACE
    
    Write-Success "FREE monitoring stack deployed!"
}

# Deploy FREE application
function Deploy-FreeApplication {
    Write-Status "Deploying FREE MedChain application..."
    
    # Apply deployment
    kubectl apply -f k8s/frontend-deployment.yaml
    
    # Wait for deployment to be ready
    Write-Status "Waiting for FREE application to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/medchain-frontend -n $NAMESPACE
    
    Write-Success "FREE application deployed!"
}

# Setup FREE Istio (optional)
function Setup-FreeIstio {
    Write-Status "Setting up FREE Istio service mesh..."
    
    # Install Istio (FREE)
    if (-not (Test-Command "istioctl")) {
        Write-Warning "Istioctl not found. Installing FREE Istio..."
        Invoke-WebRequest -OutFile "istio.zip" -Uri "https://github.com/istio/istio/releases/latest/download/istio-latest-win.zip"
        Expand-Archive -Path "istio.zip" -DestinationPath "." -Force
        $env:PATH += ";$PWD\istio-1.19.0\bin"
    }
    
    # Install Istio with demo profile (FREE)
    istioctl install --set profile=demo -y
    
    # Enable Istio injection for namespace
    kubectl label namespace $NAMESPACE istio-injection=enabled --overwrite
    
    Write-Success "FREE Istio setup completed!"
}

# Setup FREE Helm (optional)
function Setup-FreeHelm {
    Write-Status "Setting up FREE Helm..."
    
    if (-not (Test-Command "helm")) {
        Write-Warning "Helm not found. Installing FREE Helm..."
        Invoke-WebRequest -OutFile "helm.zip" -Uri "https://get.helm.sh/helm-v3.12.0-windows-amd64.zip"
        Expand-Archive -Path "helm.zip" -DestinationPath "." -Force
        Move-Item "windows-amd64\helm.exe" "C:\Windows\System32\helm.exe" -Force
    }
    
    # Add FREE Helm repositories
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update
    
    Write-Success "FREE Helm setup completed!"
}

# Get FREE application URLs
function Get-FreeUrls {
    Write-Status "Getting FREE application URLs..."
    
    if (Test-Command "minikube") {
        $FRONTEND_URL = minikube service medchain-frontend-service -n $NAMESPACE --url
        $GRAFANA_URL = minikube service grafana-service -n $NAMESPACE --url
        $PROMETHEUS_URL = minikube service prometheus-service -n $NAMESPACE --url
    } else {
        $FRONTEND_URL = "http://localhost:30080"
        $GRAFANA_URL = "http://localhost:30300"
        $PROMETHEUS_URL = "http://localhost:30090"
    }
    
    Write-Success "FREE Application URLs:"
    Write-Host "Frontend: $FRONTEND_URL"
    Write-Host "Grafana: $GRAFANA_URL (admin/admin123)"
    Write-Host "Prometheus: $PROMETHEUS_URL"
    Write-Host ""
    Write-Host "💰 Total Cost: `$0 (FREE!)"
}

# Show FREE deployment status
function Show-FreeStatus {
    Write-Status "FREE Deployment status:"
    
    Write-Host ""
    Write-Host "Pods:"
    kubectl get pods -n $NAMESPACE
    
    Write-Host ""
    Write-Host "Services:"
    kubectl get services -n $NAMESPACE
    
    Write-Host ""
    Write-Host "Deployments:"
    kubectl get deployments -n $NAMESPACE
    
    Write-Host ""
    Write-Host "💰 Cost Analysis:"
    Write-Host "- Kubernetes: FREE (local)"
    Write-Host "- Monitoring: FREE (self-hosted)"
    Write-Host "- Service Mesh: FREE (Istio)"
    Write-Host "- Total: `$0"
}

# FREE cleanup function
function Cleanup-Free {
    Write-Status "Cleaning up FREE deployment..."
    
    kubectl delete namespace $NAMESPACE --ignore-not-found=true
    
    if (Test-Command "minikube") {
        minikube stop
    } elseif (Test-Command "kind") {
        kind delete cluster --name medchain-cluster
    }
    
    Write-Success "FREE cleanup completed!"
}

# FREE deployment function
function Deploy-Free {
    param([string]$Option = "")
    
    Write-Status "Starting FREE MedChain deployment..."
    
    Check-Prerequisites
    Start-FreeCluster
    Build-FreeImages
    Deploy-FreeNamespace
    Deploy-FreeMonitoring
    Deploy-FreeApplication
    
    # Optional: Setup FREE Istio and Helm
    if ($Option -eq "--with-istio") {
        Setup-FreeIstio
    }
    if ($Option -eq "--with-helm") {
        Setup-FreeHelm
    }
    
    Get-FreeUrls
    Show-FreeStatus
    
    Write-Success "FREE MedChain deployment completed successfully!"
    Write-Status "💰 Total cost: `$0 (FREE!)"
    Write-Status "You can now access the application at the URLs shown above."
    Write-Status "The blockchain simulation is active - all transactions will show realistic transaction IDs and confirmations."
}

# FREE help function
function Show-FreeHelp {
    Write-Host "MedChain FREE Deployment Script for Windows PowerShell"
    Write-Host ""
    Write-Host "💰 Total Cost: `$0 (FREE!)"
    Write-Host ""
    Write-Host "Usage: .\deploy-free.ps1 [COMMAND] [OPTION]"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  deploy              Deploy the complete FREE MedChain application"
    Write-Host "  deploy --with-istio Deploy with FREE Istio service mesh"
    Write-Host "  deploy --with-helm  Deploy using FREE Helm charts"
    Write-Host "  status              Show FREE deployment status"
    Write-Host "  cleanup             Clean up all FREE resources"
    Write-Host "  help                Show this help message"
    Write-Host ""
    Write-Host "💰 Cost Breakdown:"
    Write-Host "- Kubernetes: FREE (minikube/kind)"
    Write-Host "- Monitoring: FREE (Prometheus/Grafana)"
    Write-Host "- Service Mesh: FREE (Istio)"
    Write-Host "- Total: `$0"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\deploy-free.ps1 deploy"
    Write-Host "  .\deploy-free.ps1 deploy --with-istio"
    Write-Host "  .\deploy-free.ps1 status"
    Write-Host "  .\deploy-free.ps1 cleanup"
}

# Main script logic
switch ($Command.ToLower()) {
    "deploy" {
        Deploy-Free -Option $Option
    }
    "status" {
        Show-FreeStatus
    }
    "cleanup" {
        Cleanup-Free
    }
    "help" {
        Show-FreeHelp
    }
    default {
        Write-Error "Unknown command: $Command"
        Show-FreeHelp
        exit 1
    }
} 