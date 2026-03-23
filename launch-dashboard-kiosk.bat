@echo off
setlocal EnableExtensions

set "TARGET_URL=https://dashboard.elementalmachines.io/users/sign_in"
set "PROFILE_DIR=%LOCALAPPDATA%\ElementalMachinesKioskChrome"
set "CHROME_BIN="

if exist "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe" (
  set "CHROME_BIN=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"
)

if not defined CHROME_BIN if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" (
  set "CHROME_BIN=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
)

if not defined CHROME_BIN if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" (
  set "CHROME_BIN=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
)

if not defined CHROME_BIN (
  echo Google Chrome was not found in any of these locations:
  echo   %LOCALAPPDATA%\Google\Chrome\Application\chrome.exe
  echo   %ProgramFiles%\Google\Chrome\Application\chrome.exe
  echo   %ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe
  echo.
  echo Press any key to close...
  pause >nul
  exit /b 1
)

if not exist "%PROFILE_DIR%" (
  mkdir "%PROFILE_DIR%"
  if errorlevel 1 (
    echo Failed to create the kiosk Chrome profile directory:
    echo   %PROFILE_DIR%
    echo.
    echo Press any key to close...
    pause >nul
    exit /b 1
  )
)

start "" "%CHROME_BIN%" ^
  --app="%TARGET_URL%" ^
  --kiosk ^
  --user-data-dir="%PROFILE_DIR%" ^
  --no-first-run ^
  --no-default-browser-check

endlocal
exit /b 0
