# Elemental Machines Kiosk

Electron-based kiosk application for the Elemental Machines dashboard.
This app is a personal project for convenience and is not affiliated with or endorsed by Elemental Machines.

## Overview

This application launches a single locked-down browser window intended for dedicated kiosk use.

- Opens directly to `https://dashboard.elementalmachines.io/users/sign_in`
- Runs in kiosk/fullscreen mode
- Removes standard browser chrome (tabs, address bar, menu bar)
- Routes non-allowlisted links to the system browser
- Persists session state across restarts
- Applies restrictive Electron security defaults

## Get the App

Download the latest packaged build from GitHub Releases:

https://github.com/jingleheimer-schmidt/elemental-machines-kiosk/releases

Choose the installer for your operating system and run it directly.
