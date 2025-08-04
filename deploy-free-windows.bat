@echo off
REM MedChain FREE Deployment Script for Windows
REM Uses only free CNCF technologies and local development tools
REM Total cost: $0

setlocal enabledelayedexpansion

REM Configuration
set NAMESPACE=medchain
set FRONTEND_IMAGE=medchain/frontend:latest
set REGISTRY=localhost:5000

REM Colors for output (Windows compatible)
set RED=[91m
set GREEN=[92m
set YELLOW=[93m
set BLUE=[94m
set NC=[0m

REM Function to print colored output
:print_status
echo %BLUE%[INFO]%NC% %~1
goto :eof

:print_success
echo %GREEN%[SUCCESS]%NC% %~1
goto :eof

:print_warning
echo %YELLOW%[WARNING]%NC% %~1
goto :eof

:print_error
echo %RED%[ERROR]%NC% %~1
goto :eof

REM Function to check if command exists
:command_exists
where %1 >nul 2>&1
if %errorlevel% equ 0 (
    exit /b 0
) else (
    exit /b 1
)

REM Check FREE prerequisites
:check_prerequisites
call :print_status "Checking FREE prerequisites..."

REM Check kubectl
call :command_exists kubectl
if %errorlevel% neq 0 (
    call :print_error "kubectl is not installed. Please install kubectl first."
    call :print_status "Install kubectl: https://kubernetes.io/docs/tasks/tools/"
    exit /b 1
)

REM Check Docker
call :command_exists docker
if %errorlevel% neq 0 (
    call :print_error "Docker is not installed. Please install Docker first."
    call :print_status "Install Docker: https://docs.docker.com/get-docker/"
    exit /b 1
)

REM Check minikube or kind
call :command_exists minikube
if %errorlevel% neq 0 (
    call :command_exists kind
    if %errorlevel% neq 0 (
        call :print_warning "Neither minikube nor kind is installed. Installing minikube (FREE)..."
        call :print_status "Installing minikube..."
        
        REM Download and install minikube for Windows
        powershell -Command "Invoke-WebRequest -OutFile minikube.exe -Uri 'https://github.com/kubernetes/minikube/releases/latest/download/minikube-windows-amd64.exe'"
        move minikube.exe C:\Windows\System32\minikube.exe
    )
)

call :print_success "All FREE prerequisites are ready!"
goto :eof

REM Start FREE local Kubernetes cluster
:start_free_cluster
call :print_status "Starting FREE local Kubernetes cluster..."

call :command_exists minikube
if %errorlevel% equ 0 (
    minikube status | findstr "Running" >nul
    if %errorlevel% neq 0 (
        REM Start with minimal resources (FREE)
        minikube start --cpus 2 --memory 4096 --disk-size 10g --driver=docker
        minikube addons enable ingress
        minikube addons enable metrics-server
    ) else (
        call :print_status "Minikube is already running"
    )
    call minikube docker-env
) else (
    call :command_exists kind
    if %errorlevel% equ 0 (
        kind get clusters | findstr "medchain-cluster" >nul
        if %errorlevel% neq 0 (
            REM Create kind cluster configuration
            echo kind: Cluster > kind-config.yaml
            echo apiVersion: kind.x-k8s.io/v1alpha4 >> kind-config.yaml
            echo nodes: >> kind-config.yaml
            echo - role: control-plane >> kind-config.yaml
            echo   kubeadmConfigPatches: >> kind-config.yaml
            echo   - ^| >> kind-config.yaml
            echo     kind: InitConfiguration >> kind-config.yaml
            echo     nodeRegistration: >> kind-config.yaml
            echo       kubeletExtraArgs: >> kind-config.yaml
            echo         node-labels: "ingress-ready=true" >> kind-config.yaml
            echo   extraPortMappings: >> kind-config.yaml
            echo   - containerPort: 80 >> kind-config.yaml
            echo     hostPort: 80 >> kind-config.yaml
            echo     protocol: TCP >> kind-config.yaml
            echo   - containerPort: 443 >> kind-config.yaml
            echo     hostPort: 443 >> kind-config.yaml
            echo     protocol: TCP >> kind-config.yaml
            
            kind create cluster --name medchain-cluster --config kind-config.yaml
        ) else (
            call :print_status "Kind cluster is already running"
        )
    )
)

call :print_success "FREE Kubernetes cluster is ready!"
goto :eof

REM Build FREE Docker images
:build_free_images
call :print_status "Building FREE Docker images..."

REM Build frontend image
call :print_status "Building frontend image..."
cd frontend
docker build -t %FRONTEND_IMAGE% .
cd ..

call :print_success "FREE Docker images built successfully!"
goto :eof

REM Deploy FREE namespace
:deploy_free_namespace
call :print_status "Creating namespace..."
kubectl apply -f k8s/namespace.yaml
call :print_success "Namespace created!"
goto :eof

REM Deploy FREE monitoring stack
:deploy_free_monitoring
call :print_status "Deploying FREE monitoring stack..."
kubectl apply -f k8s/monitoring.yaml

REM Wait for monitoring to be ready
call :print_status "Waiting for FREE monitoring stack to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n %NAMESPACE%
kubectl wait --for=condition=available --timeout=300s deployment/grafana -n %NAMESPACE%

call :print_success "FREE monitoring stack deployed!"
goto :eof

REM Deploy FREE application
:deploy_free_application
call :print_status "Deploying FREE MedChain application..."

REM Apply deployment
kubectl apply -f k8s/frontend-deployment.yaml

REM Wait for deployment to be ready
call :print_status "Waiting for FREE application to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/medchain-frontend -n %NAMESPACE%

call :print_success "FREE application deployed!"
goto :eof

REM Setup FREE Istio (optional)
:setup_free_istio
call :print_status "Setting up FREE Istio service mesh..."

REM Install Istio (FREE)
call :command_exists istioctl
if %errorlevel% neq 0 (
    call :print_warning "Istioctl not found. Installing FREE Istio..."
    powershell -Command "Invoke-WebRequest -OutFile istio.zip -Uri 'https://github.com/istio/istio/releases/latest/download/istio-latest-win.zip'"
    powershell -Command "Expand-Archive -Path istio.zip -DestinationPath . -Force"
    set PATH=%PATH%;%CD%\istio-1.19.0\bin
)

REM Install Istio with demo profile (FREE)
istioctl install --set profile=demo -y

REM Enable Istio injection for namespace
kubectl label namespace %NAMESPACE% istio-injection=enabled --overwrite

call :print_success "FREE Istio setup completed!"
goto :eof

REM Setup FREE Helm (optional)
:setup_free_helm
call :print_status "Setting up FREE Helm..."

call :command_exists helm
if %errorlevel% neq 0 (
    call :print_warning "Helm not found. Installing FREE Helm..."
    powershell -Command "Invoke-WebRequest -OutFile helm.zip -Uri 'https://get.helm.sh/helm-v3.12.0-windows-amd64.zip'"
    powershell -Command "Expand-Archive -Path helm.zip -DestinationPath . -Force"
    move windows-amd64\helm.exe C:\Windows\System32\helm.exe
)

REM Add FREE Helm repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

call :print_success "FREE Helm setup completed!"
goto :eof

REM Get FREE application URLs
:get_free_urls
call :print_status "Getting FREE application URLs..."

call :command_exists minikube
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('minikube service medchain-frontend-service -n %NAMESPACE% --url') do set FRONTEND_URL=%%i
    for /f "tokens=*" %%i in ('minikube service grafana-service -n %NAMESPACE% --url') do set GRAFANA_URL=%%i
    for /f "tokens=*" %%i in ('minikube service prometheus-service -n %NAMESPACE% --url') do set PROMETHEUS_URL=%%i
) else (
    set FRONTEND_URL=http://localhost:30080
    set GRAFANA_URL=http://localhost:30300
    set PROMETHEUS_URL=http://localhost:30090
)

call :print_success "FREE Application URLs:"
echo Frontend: %FRONTEND_URL%
echo Grafana: %GRAFANA_URL% (admin/admin123)
echo Prometheus: %PROMETHEUS_URL%
echo.
echo 💰 Total Cost: $0 (FREE!)
goto :eof

REM Show FREE deployment status
:show_free_status
call :print_status "FREE Deployment status:"

echo.
echo Pods:
kubectl get pods -n %NAMESPACE%

echo.
echo Services:
kubectl get services -n %NAMESPACE%

echo.
echo Deployments:
kubectl get deployments -n %NAMESPACE%

echo.
echo 💰 Cost Analysis:
echo - Kubernetes: FREE (local)
echo - Monitoring: FREE (self-hosted)
echo - Service Mesh: FREE (Istio)
echo - Total: $0
goto :eof

REM FREE cleanup function
:cleanup_free
call :print_status "Cleaning up FREE deployment..."

kubectl delete namespace %NAMESPACE% --ignore-not-found=true

call :command_exists minikube
if %errorlevel% equ 0 (
    minikube stop
) else (
    call :command_exists kind
    if %errorlevel% equ 0 (
        kind delete cluster --name medchain-cluster
    )
)

call :print_success "FREE cleanup completed!"
goto :eof

REM FREE deployment function
:deploy_free
call :print_status "Starting FREE MedChain deployment..."

call :check_prerequisites
call :start_free_cluster
call :build_free_images
call :deploy_free_namespace
call :deploy_free_monitoring
call :deploy_free_application

REM Optional: Setup FREE Istio and Helm
if "%1"=="--with-istio" call :setup_free_istio
if "%1"=="--with-helm" call :setup_free_helm

call :get_free_urls
call :show_free_status

call :print_success "FREE MedChain deployment completed successfully!"
call :print_status "💰 Total cost: $0 (FREE!)"
call :print_status "You can now access the application at the URLs shown above."
call :print_status "The blockchain simulation is active - all transactions will show realistic transaction IDs and confirmations."
goto :eof

REM FREE help function
:show_free_help
echo MedChain FREE Deployment Script for Windows
echo.
echo 💰 Total Cost: $0 (FREE!)
echo.
echo Usage: %0 [COMMAND]
echo.
echo Commands:
echo   deploy              Deploy the complete FREE MedChain application
echo   deploy --with-istio Deploy with FREE Istio service mesh
echo   deploy --with-helm  Deploy using FREE Helm charts
echo   status              Show FREE deployment status
echo   cleanup             Clean up all FREE resources
echo   help                Show this help message
echo.
echo 💰 Cost Breakdown:
echo - Kubernetes: FREE (minikube/kind)
echo - Monitoring: FREE (Prometheus/Grafana)
echo - Service Mesh: FREE (Istio)
echo - Total: $0
echo.
echo Examples:
echo   %0 deploy
echo   %0 deploy --with-istio
echo   %0 status
echo   %0 cleanup
goto :eof

REM Main script logic
if "%1"=="deploy" (
    call :deploy_free "%2"
) else if "%1"=="status" (
    call :show_free_status
) else if "%1"=="cleanup" (
    call :cleanup_free
) else if "%1"=="help" (
    call :show_free_help
) else if "%1"=="-h" (
    call :show_free_help
) else if "%1"=="--help" (
    call :show_free_help
) else if "%1"=="" (
    call :deploy_free
) else (
    call :print_error "Unknown command: %1"
    call :show_free_help
    exit /b 1
) 