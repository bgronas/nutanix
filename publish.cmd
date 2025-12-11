@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo =====================================================
echo    NUCLEAR PUBLISH: Local Version -> GitHub (Force)
echo =====================================================
echo.

:: --- SIKKERHETSSJEKK ---
:: Vi sjekker om "remote origin" faktisk inneholder ordet "nutanix".
:: Dette hindrer at du ved uhell kjører scriptet i feil mappe.
echo 🔒 Checking safety locks (Repo name)...
git remote get-url origin | findstr /I "nutanix" >nul
if errorlevel 1 (
    echo.
    echo 🛑 CRITICAL ERROR: This does not look like the 'nutanix' repo!
    echo    Remote URL does not contain 'nutanix'.
    echo    Aborting to protect your other sites.
    pause
    exit /b 1
)
echo ✅ Safety check passed. Correct repo detected.
echo.

:: --- RENSING ---
echo 🧹 Cleaning old build files...
if exist docs rmdir /s /q docs
if exist public rmdir /s /q public

:: --- BYGGING (HUGO) ---
echo 🏗️  Building site (Hugo Extended)...
hugo --minify --cleanDestinationDir
if errorlevel 1 (
    echo ❌ Hugo Build Failed! Fix errors and try again.
    pause
    exit /b 1
)

:: --- GIT OPERASJONER ---
echo 📦 Staging all files...
git add .

:: Lager en tidsstempel for commit-meldingen
for /f "tokens=1-3 delims=. " %%a in ('date /t') do set CDATE=%%c-%%b-%%a
set CTIME=%time: =0%
set MSG=Force Update: %CDATE% %CTIME%

echo 💾 Committing: "%MSG%"...
:: Vi bruker "allow-empty" i tilfelle du bare re-publiserer uten endringer
git commit --allow-empty -m "%MSG%"

:: --- THE NUCLEAR OPTION ---
:: Her bruker vi --force. Det betyr: "Jeg driter i hva GitHub har.
:: Min PC har rett. Overskriv alt der ute."
echo 🚀 OVERWRITING GitHub (origin main --force)...
git push origin main --force

echo.
echo =====================================================
echo ✅ SUCCESS! Local version is now enforced on GitHub.
echo 🌍 Check it out: https://bgronas.github.io/nutanix/
echo =====================================================
pause