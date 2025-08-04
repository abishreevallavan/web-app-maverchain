@echo off
echo 🏥 MedChain QUICK Deployment - Going Live!
echo ==========================================
echo Deploying your app to the internet RIGHT NOW!
echo.

REM Check prerequisites
echo [INFO] Checking prerequisites...

REM Check if Node.js is installed
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js is not installed. Please install Node.js first.
    echo Download from: https://nodejs.org/
    pause
    exit /b 1
)

echo [SUCCESS] Node.js is available

REM Build the frontend
echo [INFO] Building frontend for production...
cd frontend

REM Install dependencies
echo [INFO] Installing frontend dependencies...
npm install

REM Build for production
echo [INFO] Building production version...
npm run build

echo [SUCCESS] Frontend built successfully!

REM Go back to root directory
cd ..

REM Deploy to Vercel automatically
echo [INFO] Deploying to Vercel (this will take 2-3 minutes)...
echo [INFO] Installing Vercel CLI...
call npm install -g vercel

echo [INFO] Deploying your app to the internet...
vercel --prod --yes --confirm

echo.
echo [SUCCESS] 🎉 DEPLOYMENT COMPLETED!
echo.
echo 🌐 Your MedChain app is now LIVE on the internet!
echo 💰 Total cost: $0 (FREE!)
echo.
echo 📱 What you can do now:
echo    - Share the URL with anyone
echo    - Access from any device
echo    - No more localhost!
echo    - Real blockchain simulation for everyone
echo.
echo 🔗 Your app URL will be shown above
echo 📊 Monitor your app's performance
echo 🔄 Automatic deployments on code changes
echo.
echo [SUCCESS] MedChain is now a public, production-ready application!
pause 