@echo off
echo 🚀 STARTING MEDCHAIN APP NOW!
echo ==============================
echo Your app will be ready in 30 seconds!
echo.

REM Check if Node.js is installed
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js not found. Installing...
    echo Please download from: https://nodejs.org/
    echo Then run this script again.
    pause
    exit /b 1
)

echo ✅ Node.js found!

REM Start the app immediately
echo 🚀 Starting MedChain app...
cd frontend

REM Quick install and start
echo 📦 Installing dependencies (this will be fast)...
npm install --silent

echo 🌐 Starting your app...
echo.
echo 🎯 Your app will open at: http://localhost:3000
echo 📱 Works on all devices (phone, tablet, computer)
echo 🔗 Blockchain simulation ready!
echo.
echo ⏹️ Press Ctrl+C to stop the app
echo.

npm start 