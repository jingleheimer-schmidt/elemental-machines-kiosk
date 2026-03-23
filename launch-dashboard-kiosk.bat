@echo off
setlocal EnableExtensions

set "TARGET_URL=https://dashboard.elementalmachines.io/users/sign_in"
set "PROFILE_DIR=%LOCALAPPDATA%\ElementalMachinesKioskChrome"
set "CHROME_BIN="

if exist "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe" set "CHROME_BIN=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"
if not defined CHROME_BIN if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" set "CHROME_BIN=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
if not defined CHROME_BIN if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" set "CHROME_BIN=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"

echo CHROME_BIN=%CHROME_BIN%
echo PROFILE_DIR=%PROFILE_DIR%
echo TARGET_URL=%TARGET_URL%
echo.

if not defined CHROME_BIN (
  echo Google Chrome was not found.
  pause
  exit /b 1
)

if not exist "%PROFILE_DIR%" (
  mkdir "%PROFILE_DIR%"
  if errorlevel 1 (
    echo Failed to create profile directory.
    pause
    exit /b 1
  )
)

"%CHROME_BIN%" ^
  --app="%TARGET_URL%" ^
  --kiosk ^
  --user-data-dir="%PROFILE_DIR%" ^
  --no-first-run ^
  --no-default-browser-check

echo.
echo Chrome exited with code %errorlevel%
pause
