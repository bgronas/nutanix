@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"
title Article Creator (Nutanix Dump)

echo ===========================================
echo          CREATE NEW ARTICLE
echo ===========================================
echo.

:: 1. Verifiser Hugo
where hugo >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Hugo not found in PATH.
  pause
  exit /b 1
)

:: 2. Hent tittel
set /p POST_TITLE=Enter title: 
if "%POST_TITLE%"=="" (
  echo [ERROR] Title is required.
  goto :EOF
)

:: 3. Generer Slug (Fjerner tegn som ikke passer i URL)
set "POST_SLUG=%POST_TITLE: =-%"
set "POST_SLUG=%POST_SLUG:.=%"
set "POST_SLUG=%POST_SLUG:,=%"
set "POST_SLUG=%POST_SLUG:?=%"
set "POST_SLUG=%POST_SLUG:!=%"

:: 4. Hent dato via PowerShell (Mer robust)
for /f %%a in ('powershell -Command "Get-Date -Format 'yyyy-MM-dd'"') do set HUGO_DATE=%%a

:: 5. Definer sti (Page Bundle struktur)
set "POST_PATH=post/%HUGO_DATE%-%POST_SLUG%"
set "FULL_PATH=content\%POST_PATH%"
set "POST_FILE=%FULL_PATH%\index.md"

:: 6. Sjekk kollisjon
if exist "%POST_FILE%" (
  echo [WARN] Post already exists: %POST_FILE%
  pause
  exit /b 1
)

:: 7. Opprett post
echo Creating: %POST_PATH%...
hugo new "%POST_PATH%/index.md"
if errorlevel 1 (
  echo [ERROR] Hugo failed.
  pause
  exit /b 1
)

:: 8. Oppdater tittel i Front Matter (Fix for Archetypes)
powershell -Command "(Get-Content '%POST_FILE%') -replace 'title:.*', 'title: \"%POST_TITLE%\"' | Set-Content '%POST_FILE%'"

:: 9. Start Typora
echo Launching Typora...
if exist "C:\Program Files\Typora\Typora.exe" (
    start "" "C:\Program Files\Typora\Typora.exe" "%POST_FILE%"
) else (
    echo [WARN] Typora not found at default path. Opening default editor.
    start "" "%POST_FILE%"
)

echo ✅ Done.