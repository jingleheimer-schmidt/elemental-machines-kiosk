# Elemental Machines Kiosk

Electron-based kiosk application for the Elemental Machines dashboard.
This app is not affiliated with or endorsed by Elemental Machines. The code and packaged builds are provided as-is without any warranties or guarantees.

## Overview

This application launches a single locked-down browser window intended for dedicated kiosk use.

- Opens directly to `https://dashboard.elementalmachines.io/users/sign_in`
- Runs in kiosk/fullscreen mode
- Removes standard browser chrome (tabs, address bar, menu bar)
- Routes non-allowlisted links to the system browser
- Persists session state across restarts
- Applies restrictive Electron security defaults

## Simple Chrome Launchers

For a lighter-weight option, this repo also includes native Chrome launchers for macOS and Windows:

- `launch-dashboard-kiosk.command` for macOS
- `launch-dashboard-kiosk.bat` for Windows

Each launcher opens `https://dashboard.elementalmachines.io/users/sign_in` in a Chrome kiosk-style app window and uses a dedicated Chrome profile so the kiosk session persists separately from the user's normal browser profile.

Run the macOS launcher from Finder or Terminal. Run the Windows launcher from File Explorer or `cmd.exe`.

These launchers are intentionally simpler than the Electron app and do not include the same navigation allowlisting or Electron security hardening.

## Get the App

Download the latest packaged build from GitHub Releases:

https://github.com/jingleheimer-schmidt/elemental-machines-kiosk/releases

Choose the installer for your operating system and run it directly.
