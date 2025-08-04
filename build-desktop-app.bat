@echo off
echo 🏥 Building MedChain Desktop App...
echo.

REM Check if Node.js is installed
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js is not installed. Please install Node.js first.
    echo Download from: https://nodejs.org/
    pause
    exit /b 1
)

REM Check if npm is available
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ npm is not available. Please install Node.js with npm.
    pause
    exit /b 1
)

echo ✅ Node.js and npm are available

REM Navigate to desktop app directory
cd desktop-app

REM Install dependencies
echo 📦 Installing desktop app dependencies...
npm install

REM Build the frontend first
echo 🏗️ Building frontend...
cd ../frontend
npm install
npm run build
cd ../desktop-app

REM Build the desktop app
echo 🖥️ Building desktop application...
npm run build-win

echo.
echo ✅ MedChain Desktop App built successfully!
echo 📁 Check the 'dist' folder for the installer
echo 🎯 You can now install and run MedChain as a desktop app!
echo.

REM Open the dist folder
explorer dist

pause 