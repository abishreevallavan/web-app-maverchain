@echo off
echo 🚀 STARTING MEDCHAIN APP NOW!
echo ==============================

REM Navigate to frontend and start
cd frontend
echo 📦 Installing dependencies...
npm install --silent

echo 🌐 Starting your app...
echo.
echo 🎯 Your app will open at: http://localhost:3000
echo 📱 Works on all devices!
echo 🔗 Blockchain simulation ready!
echo.

npm start 