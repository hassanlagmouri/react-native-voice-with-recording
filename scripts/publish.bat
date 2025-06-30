@echo off
setlocal enabledelayedexpansion

echo 🚀 Starting publishing process for react-native-voice-with-recording

REM Check if we're logged in to npm
echo 📋 Checking npm login status...
npm whoami >nul 2>&1
if errorlevel 1 (
    echo ❌ Not logged in to npm. Please run 'npm login' first.
    exit /b 1
)

for /f "tokens=*" %%i in ('npm whoami') do set NPM_USER=%%i
echo ✅ Logged in to npm as %NPM_USER%

REM Install dependencies
echo 📦 Installing dependencies...
npm install
if errorlevel 1 (
    echo ❌ Failed to install dependencies.
    exit /b 1
)

REM Build the package
echo 🔨 Building package...
npm run build
if errorlevel 1 (
    echo ❌ Build failed.
    exit /b 1
)

REM Check if build was successful
if not exist "dist\index.js" (
    echo ❌ Build failed. dist\index.js not found.
    exit /b 1
)

echo ✅ Build successful

REM Show what will be published
echo 📋 Files that will be published:
npm pack --dry-run

REM Ask for confirmation
echo.
set /p CONFIRM="🤔 Do you want to publish this package? (y/N): "
if /i not "%CONFIRM%"=="y" (
    echo ❌ Publishing cancelled.
    exit /b 0
)

REM Publish the package
echo 📤 Publishing to npm...
npm publish
if errorlevel 1 (
    echo ❌ Publishing failed.
    exit /b 1
)

echo ✅ Package published successfully!
echo 🌐 View your package at: https://www.npmjs.com/package/react-native-voice-with-recording

echo 🎉 Publishing process completed successfully! 