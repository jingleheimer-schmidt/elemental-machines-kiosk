# Elemental Machines Kiosk

Minimal Electron MVP for a dedicated desktop kiosk app that opens the Elemental Machines dashboard sign-in flow.

## What it does

- Launches a single Electron BrowserWindow pointed at `https://dashboard.elementalmachines.io/users/sign_in`
- Starts in kiosk/fullscreen mode by default for a dedicated-app feel
- Hides the menu bar and exposes no browser tabs, address bar, or standard browser chrome
- Blocks arbitrary popup windows and routes external links to the default system browser
- Persists the browser session across launches so auth state can survive app restarts
- Uses secure Electron defaults with comments in the main process around navigation and permission handling

## Project files

- `package.json`: scripts, dependencies, and cross-platform packaging config
- `main.js`: Electron main process, BrowserWindow creation, navigation restrictions, and security defaults
- `.gitignore`: ignores dependencies, logs, and packaged output

## Setup

1. Install Node.js 20 or newer.
2. Install dependencies:

```bash
npm install
```

## Run

Normal kiosk/fullscreen launch:

```bash
npm start
```

Development escape hatch with a visible top menu and Quit action:

```bash
npm run dev
```

The development script runs windowed instead of kiosked and enables the standard Electron developer tools menu actions.

## Build

Build for the current platform:

```bash
npm run build
```

Build platform-specific packages:

```bash
npm run build:mac
npm run build:win
npm run build:linux
```

Packaged artifacts are written to `release/`.

## Auth redirect allowlisting

The app only allows in-app navigation to the origin of the configured target URL by default. Today that means `https://dashboard.elementalmachines.io` only.

If the login flow later needs a second trusted auth origin, set it with a comma-separated environment variable before launch:

```bash
ALLOWED_AUTH_ORIGINS=https://example-idp.com,https://another-auth.example npm start
```

The navigation guard in `main.js` is intentionally fail-closed:

- allowlisted origins stay inside the Electron window
- other HTTP or HTTPS links open in the system browser
- non-HTTP targets are blocked

Do not broaden the allowlist casually. Add only the exact origins required for the auth flow.

## Change the target URL later

There are two supported ways to change the URL the kiosk opens:

1. Edit `DEFAULT_TARGET_URL` in `main.js` if you want a permanent repository default.
2. Set `KIOSK_TARGET_URL` at runtime if you want an environment-specific override.

Example:

```bash
KIOSK_TARGET_URL=https://dashboard.elementalmachines.io/some/other/path npm start
```

If the new target uses a different origin, update the allowlist at the same time.

## Packaging notes

- Packaging is configured with `electron-builder` for macOS, Windows, and Linux.
- This MVP does not include code signing, notarization, or auto-update.
- Cross-platform installers are usually built on the matching operating system or in CI; the scripts are included even if local cross-compilation is limited.

## Automated GitHub Releases

Pushes to `main` now trigger GitHub Actions to:

- bump and tag a new version
- build macOS, Windows, and Linux installers
- create a GitHub Release and attach all generated artifacts

The workflow lives at `.github/workflows/release.yml`.

### Version bump rules

Versioning is automatic and based on commit messages since the previous tag:

- `major`: commit message contains `BREAKING CHANGE` or `!:`
- `minor`: commit subject starts with `feat:` or `feat(...):`
- `patch`: all other commits

If no special markers are found, the workflow defaults to a patch release.