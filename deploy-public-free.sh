#!/bin/bash
# MedChain PUBLIC FREE Deployment Script
# Deploys your app to the internet for free - no localhost!
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Configuration
APP_NAME="medchain"
FRONTEND_DIR="frontend"

echo "🏥 MedChain PUBLIC FREE Deployment"
echo "=================================="
echo "This will deploy your app to the internet for FREE!"
echo "No more localhost - your app will be publicly accessible!"
echo

# Check prerequisites
print_status "Checking prerequisites..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed. Please install Node.js first."
    echo "Download from: https://nodejs.org/"
    exit 1
fi

# Check if npm is available
if ! command -v npm &> /dev/null; then
    print_error "npm is not available. Please install Node.js with npm."
    exit 1
fi

print_success "Node.js and npm are available"

# Build the frontend
print_status "Building frontend for production..."
cd $FRONTEND_DIR

# Install dependencies
print_status "Installing frontend dependencies..."
npm install

# Build for production
print_status "Building production version..."
npm run build

print_success "Frontend built successfully!"

# Create deployment options
echo
echo "🌐 Choose your FREE hosting platform:"
echo "1. Vercel (Recommended) - Automatic deployment, custom domain"
echo "2. Netlify - Great for static sites, custom domain"
echo "3. GitHub Pages - Free hosting from GitHub"
echo "4. Surge.sh - Simple static hosting"
echo "5. Firebase Hosting - Google's hosting platform"
echo "6. Render - Modern cloud platform"
echo

read -p "Enter your choice (1-6): " choice

case $choice in
    1)
        deploy_vercel
        ;;
    2)
        deploy_netlify
        ;;
    3)
        deploy_github_pages
        ;;
    4)
        deploy_surge
        ;;
    5)
        deploy_firebase
        ;;
    6)
        deploy_render
        ;;
    *)
        print_error "Invalid choice. Please select 1-6."
        exit 1
        ;;
esac

# Function to deploy to Vercel
deploy_vercel() {
    print_status "Deploying to Vercel..."
    
    # Check if Vercel CLI is installed
    if ! command -v vercel &> /dev/null; then
        print_status "Installing Vercel CLI..."
        npm install -g vercel
    fi
    
    # Create vercel.json configuration
    cat > vercel.json << EOF
{
  "version": 2,
  "builds": [
    {
      "src": "build/**",
      "use": "@vercel/static"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/build/index.html"
    }
  ],
  "env": {
    "REACT_APP_ENVIRONMENT": "production",
    "REACT_APP_VERSION": "v1.0.0"
  }
}
EOF
    
    # Deploy to Vercel
    print_status "Deploying to Vercel (this may take a few minutes)..."
    vercel --prod --yes
    
    print_success "Deployed to Vercel successfully!"
    print_status "Your app is now live on the internet!"
    print_status "Check the URL provided by Vercel above."
}

# Function to deploy to Netlify
deploy_netlify() {
    print_status "Deploying to Netlify..."
    
    # Check if Netlify CLI is installed
    if ! command -v netlify &> /dev/null; then
        print_status "Installing Netlify CLI..."
        npm install -g netlify-cli
    fi
    
    # Create netlify.toml configuration
    cat > netlify.toml << EOF
[build]
  publish = "build"
  command = "npm run build"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[build.environment]
  REACT_APP_ENVIRONMENT = "production"
  REACT_APP_VERSION = "v1.0.0"
EOF
    
    # Deploy to Netlify
    print_status "Deploying to Netlify (this may take a few minutes)..."
    netlify deploy --prod --dir=build
    
    print_success "Deployed to Netlify successfully!"
    print_status "Your app is now live on the internet!"
    print_status "Check the URL provided by Netlify above."
}

# Function to deploy to GitHub Pages
deploy_github_pages() {
    print_status "Deploying to GitHub Pages..."
    
    # Check if git is available
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed. Please install Git first."
        exit 1
    fi
    
    # Create GitHub Pages configuration
    cat > .github/workflows/deploy.yml << EOF
name: Deploy to GitHub Pages

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    
    - name: Setup Node.js
      uses: actions/setup-node@v2
      with:
        node-version: '16'
        
    - name: Install dependencies
      run: npm install
      
    - name: Build
      run: npm run build
      
    - name: Deploy to GitHub Pages
      uses: peaceiris/actions-gh-pages@v3
      with:
        github_token: \${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./build
EOF
    
    print_status "GitHub Pages deployment configured!"
    print_status "Push your code to GitHub and it will auto-deploy."
    print_status "Your app will be available at: https://yourusername.github.io/yourrepo"
}

# Function to deploy to Surge
deploy_surge() {
    print_status "Deploying to Surge.sh..."
    
    # Check if Surge is installed
    if ! command -v surge &> /dev/null; then
        print_status "Installing Surge..."
        npm install -g surge
    fi
    
    # Deploy to Surge
    print_status "Deploying to Surge.sh..."
    surge build --domain medchain.surge.sh
    
    print_success "Deployed to Surge.sh successfully!"
    print_status "Your app is now live at: https://medchain.surge.sh"
}

# Function to deploy to Firebase
deploy_firebase() {
    print_status "Deploying to Firebase..."
    
    # Check if Firebase CLI is installed
    if ! command -v firebase &> /dev/null; then
        print_status "Installing Firebase CLI..."
        npm install -g firebase-tools
    fi
    
    # Initialize Firebase (if not already done)
    if [ ! -f firebase.json ]; then
        print_status "Initializing Firebase project..."
        firebase init hosting --public build --single-page-app true --project medchain-app
    fi
    
    # Deploy to Firebase
    print_status "Deploying to Firebase..."
    firebase deploy --only hosting
    
    print_success "Deployed to Firebase successfully!"
    print_status "Your app is now live on Firebase!"
}

# Function to deploy to Render
deploy_render() {
    print_status "Deploying to Render..."
    
    # Create render.yaml configuration
    cat > render.yaml << EOF
services:
  - type: web
    name: medchain
    env: static
    buildCommand: cd frontend && npm install && npm run build
    staticPublishPath: ./frontend/build
    routes:
      - type: rewrite
        source: /*
        destination: /index.html
EOF
    
    print_status "Render configuration created!"
    print_status "Push your code to GitHub and connect to Render for auto-deployment."
    print_status "Your app will be available at: https://your-app-name.onrender.com"
}

# Show deployment summary
echo
print_success "🎉 Deployment completed!"
echo
echo "🌐 Your MedChain app is now LIVE on the internet!"
echo "💰 Total cost: $0 (FREE!)"
echo
echo "📱 What you can do now:"
echo "   - Share the URL with anyone"
echo "   - Access from any device"
echo "   - No more localhost!"
echo "   - Real blockchain simulation for everyone"
echo
echo "🔗 Your app URL will be shown above"
echo "📊 Monitor your app's performance"
echo "🔄 Automatic deployments on code changes"
echo
print_success "MedChain is now a public, production-ready application!" 