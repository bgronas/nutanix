@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo =====================================================
echo        BUILD AND PUBLISH TO GITHUB (Nutanix)
echo =====================================================
echo.

:: 1. Clean old builds
echo 🧹 Cleaning /docs and /public...
if exist docs rmdir /s /q docs
if exist public rmdir /s /q public

:: 2. Build with Hugo (Minify for speed)
echo 🏗️  Building site to /docs...
hugo --minify --cleanDestinationDir
if errorlevel 1 (
    echo ❌ Hugo Build Failed!
    pause
    exit /b 1
)

:: 3. Git Operations
echo 📦 Staging changes...
git add .

:: Generer tidsstempel
for /f "tokens=1-3 delims=. " %%a in ('date /t') do set CDATE=%%c-%%b-%%a
set CTIME=%time: =0%
set MSG=Site Update: %CDATE% %CTIME%

echo 💾 Committing: "%MSG%"...
git commit -m "%MSG%"

echo 🚀 Pushing to GitHub (origin main)...
git push origin main

echo.
echo =====================================================
echo ✅ PUBLISHED! 
echo 🌍 Live at: https://bgronas.github.io/nutanix/
echo =====================================================
pause