@echo off
echo 🖥️ Building MedChain Desktop App...
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

REM Build the frontend first
echo 📦 Building frontend...
cd frontend
npm install --silent
npm run build
cd ..

REM Create a simple desktop app using Electron
echo 🖥️ Creating desktop app...
cd desktop-app

REM Install Electron
echo 📦 Installing Electron...
npm install electron --save-dev --silent

REM Create a simple package.json for the desktop app
echo 📝 Creating desktop app configuration...
echo { > package.json
echo   "name": "medchain-desktop", >> package.json
echo   "version": "1.0.0", >> package.json
echo   "main": "main.js", >> package.json
echo   "scripts": { >> package.json
echo     "start": "electron .", >> package.json
echo     "build": "electron-builder" >> package.json
echo   }, >> package.json
echo   "build": { >> package.json
echo     "appId": "com.medchain.desktop", >> package.json
echo     "productName": "MedChain", >> package.json
echo     "directories": { >> package.json
echo       "output": "dist" >> package.json
echo     }, >> package.json
echo     "files": [ >> package.json
echo       "main.js", >> package.json
echo       "../frontend/build/**/*" >> package.json
echo     ], >> package.json
echo     "win": { >> package.json
echo       "target": "nsis", >> package.json
echo       "icon": "assets/icon.png" >> package.json
echo     } >> package.json
echo   } >> package.json
echo } >> package.json

REM Install electron-builder
echo 📦 Installing electron-builder...
npm install electron-builder --save-dev --silent

REM Build the desktop app
echo 🚀 Building desktop application...
npm run build

echo.
echo ✅ MedChain Desktop App built successfully!
echo 📁 Check the 'dist' folder for the installer
echo 🎯 You can now install and run MedChain as a desktop app!
echo.

REM Open the dist folder
explorer dist

pause 