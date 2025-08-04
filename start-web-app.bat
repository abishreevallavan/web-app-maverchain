@echo off
echo 🏥 Starting MedChain Web Application...
echo.

REM Check if we're in the right directory
if not exist "frontend" (
    echo ❌ Please run this script from the maverchain-main directory
    echo Current directory: %CD%
    pause
    exit /b 1
)

echo ✅ Found MedChain project directory
echo.

REM Check if Node.js is installed
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js is not installed. Please install Node.js first.
    echo Download from: https://nodejs.org/
    pause
    exit /b 1
)

echo ✅ Node.js is available

REM Navigate to frontend and install dependencies
echo 📦 Installing frontend dependencies...
cd frontend
npm install

REM Start the development server
echo 🚀 Starting MedChain web application...
echo.
echo 🌐 The application will open in your browser at:
echo    http://localhost:3000
echo.
echo 💡 You can also manually open your browser and go to:
echo    http://localhost:3000
echo.
echo 🎯 Features available:
echo    - Blockchain simulation with realistic transaction IDs
echo    - Role-based dashboards (Manufacturer, Distributor, Hospital, Patient)
echo    - QR code verification system
echo    - Real-time transaction notifications
echo    - Supply chain tracking
echo.
echo ⏹️  Press Ctrl+C to stop the application
echo.

npm start 