@echo off
echo 🖥️ Starting MedChain Desktop App...
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

REM Start the web app in background
echo 🌐 Starting web app...
cd frontend
start /B npm start

REM Wait for web app to start
echo ⏳ Waiting for web app to start...
timeout /t 30 /nobreak >nul

REM Start the desktop app
echo 🖥️ Starting desktop app...
cd ../desktop-app

REM Install dependencies if needed
if not exist "node_modules" (
    echo 📦 Installing desktop app dependencies...
    npm install --silent
)

REM Start the desktop app
echo 🚀 Launching MedChain Desktop App...
npm start

echo.
echo ✅ MedChain Desktop App is running!
echo 🎯 You now have a desktop app with an icon!
echo.
pause 