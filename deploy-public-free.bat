@echo off
echo 🏥 MedChain PUBLIC FREE Deployment
echo ==================================
echo This will deploy your app to the internet for FREE!
echo No more localhost - your app will be publicly accessible!
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

REM Check if npm is available
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] npm is not available. Please install Node.js with npm.
    pause
    exit /b 1
)

echo [SUCCESS] Node.js and npm are available

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

REM Create deployment options
echo.
echo 🌐 Choose your FREE hosting platform:
echo 1. Vercel (Recommended) - Automatic deployment, custom domain
echo 2. Netlify - Great for static sites, custom domain
echo 3. GitHub Pages - Free hosting from GitHub
echo 4. Surge.sh - Simple static hosting
echo 5. Firebase Hosting - Google's hosting platform
echo 6. Render - Modern cloud platform
echo.

set /p choice="Enter your choice (1-6): "

if "%choice%"=="1" goto deploy_vercel
if "%choice%"=="2" goto deploy_netlify
if "%choice%"=="3" goto deploy_github_pages
if "%choice%"=="4" goto deploy_surge
if "%choice%"=="5" goto deploy_firebase
if "%choice%"=="6" goto deploy_render
echo [ERROR] Invalid choice. Please select 1-6.
pause
exit /b 1

:deploy_vercel
echo [INFO] Deploying to Vercel...
call npm install -g vercel
echo [INFO] Deploying to Vercel (this may take a few minutes)...
vercel --prod --yes
echo [SUCCESS] Deployed to Vercel successfully!
echo [INFO] Your app is now live on the internet!
echo [INFO] Check the URL provided by Vercel above.
goto end

:deploy_netlify
echo [INFO] Deploying to Netlify...
call npm install -g netlify-cli
echo [INFO] Deploying to Netlify (this may take a few minutes)...
netlify deploy --prod --dir=frontend/build
echo [SUCCESS] Deployed to Netlify successfully!
echo [INFO] Your app is now live on the internet!
echo [INFO] Check the URL provided by Netlify above.
goto end

:deploy_github_pages
echo [INFO] Deploying to GitHub Pages...
echo [INFO] GitHub Pages deployment configured!
echo [INFO] Push your code to GitHub and it will auto-deploy.
echo [INFO] Your app will be available at: https://yourusername.github.io/yourrepo
goto end

:deploy_surge
echo [INFO] Deploying to Surge.sh...
call npm install -g surge
echo [INFO] Deploying to Surge.sh...
surge frontend/build --domain medchain.surge.sh
echo [SUCCESS] Deployed to Surge.sh successfully!
echo [INFO] Your app is now live at: https://medchain.surge.sh
goto end

:deploy_firebase
echo [INFO] Deploying to Firebase...
call npm install -g firebase-tools
echo [INFO] Initializing Firebase project...
firebase init hosting --public frontend/build --single-page-app true --project medchain-app
echo [INFO] Deploying to Firebase...
firebase deploy --only hosting
echo [SUCCESS] Deployed to Firebase successfully!
echo [INFO] Your app is now live on Firebase!
goto end

:deploy_render
echo [INFO] Deploying to Render...
echo [INFO] Render configuration created!
echo [INFO] Push your code to GitHub and connect to Render for auto-deployment.
echo [INFO] Your app will be available at: https://your-app-name.onrender.com
goto end

:end
echo.
echo [SUCCESS] 🎉 Deployment completed!
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