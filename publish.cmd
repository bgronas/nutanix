@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo -----------------------------------------------------
echo    NUCLEAR PUBLISH: Local Version -^> GitHub (Force)
echo -----------------------------------------------------
echo.

:: --- SIKKERHETSSJEKK ---
echo [INFO] Checking safety locks (Repo name)...
git remote get-url origin | findstr /I "nutanix" >nul
if errorlevel 1 (
    echo.
    echo [!!] CRITICAL ERROR: This does not look like the 'nutanix' repo!
    echo      Remote URL does not contain 'nutanix'.
    echo      Aborting to protect your other sites.
    pause
    exit /b 1
)
echo [OK]   Safety check passed. Correct repo detected.
echo.

:: --- RENSING ---
echo [INFO] Cleaning old build files...
:: Vi sender feilmeldinger til nul i tilfelle en fil er i bruk. Hugo rydder uansett opp.
if exist docs rmdir /s /q docs >nul 2>&1
if exist public rmdir /s /q public >nul 2>&1

:: --- BYGGING (HUGO) ---
echo [INFO] Building site (Hugo Extended)...
:: --quiet gjør at Hugo holder kjeft med mindre noe går galt
hugo --minify --cleanDestinationDir --quiet
if errorlevel 1 (
    echo [!!] Hugo Build Failed! Fix errors and try again.
    pause
    exit /b 1
)
echo [OK]   Build complete.

:: --- GIT OPERASJONER ---
echo [INFO] Staging all files...
:: Sender output til nul for å slippe LF/CRLF spam
git add . >nul 2>&1

:: Penere tidsstempel uten millisekunder
for /f "tokens=1-3 delims=. " %%a in ('date /t') do set CDATE=%%c-%%b-%%a
set CTIME=%time:~0,5%
set MSG=Force Update: %CDATE% %CTIME%

echo [INFO] Committing: "%MSG%"...
git commit --allow-empty -m "%MSG%" >nul

:: --- THE NUCLEAR OPTION ---
echo [INFO] OVERWRITING GitHub (origin main --force)...
git push origin main --force

echo.
echo -----------------------------------------------------
echo [OK]   SUCCESS! Local version is now enforced on GitHub.
echo        Live at: https://bgronas.github.io/nutanix/
echo -----------------------------------------------------
pause