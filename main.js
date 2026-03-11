const { app, BrowserWindow, Menu, powerSaveBlocker, session, shell } = require('electron');

const DEFAULT_TARGET_URL = 'https://dashboard.elementalmachines.io/users/sign_in';
const TARGET_URL = process.env.KIOSK_TARGET_URL || DEFAULT_TARGET_URL;
const PERSISTENT_PARTITION = 'persist:elemental-machines-kiosk';
const isDevelopment = !app.isPackaged || process.env.NODE_ENV === 'development';
const isWindowedMode = isDevelopment && process.env.WINDOWED === 'true';

let mainWindow;
let displaySleepBlockerId = null;

const singleInstanceLock = app.requestSingleInstanceLock();

if (!singleInstanceLock) {
  app.quit();
}

function normalizeOrigin(value) {
  try {
    return new URL(value).origin;
  } catch {
    return null;
  }
}

function getAllowedOrigins() {
  const configuredOrigins = (process.env.ALLOWED_AUTH_ORIGINS || '')
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean)
    .map(normalizeOrigin)
    .filter(Boolean);

  return new Set([normalizeOrigin(TARGET_URL), ...configuredOrigins].filter(Boolean));
}

function isHttpUrl(target) {
  try {
    const parsed = new URL(target);
    return parsed.protocol === 'http:' || parsed.protocol === 'https:';
  } catch {
    return false;
  }
}

function isAllowedInAppNavigation(target, allowedOrigins) {
  const origin = normalizeOrigin(target);
  return Boolean(origin && allowedOrigins.has(origin));
}

async function openInDefaultBrowser(target) {
  if (!isHttpUrl(target)) {
    return;
  }

  try {
    await shell.openExternal(target);
  } catch (error) {
    console.error('Failed to open external URL:', target, error);
  }
}

function buildApplicationMenu() {
  if (!isWindowedMode) {
    return null;
  }

  return Menu.buildFromTemplate([
    {
      label: app.name,
      submenu: [
        { role: 'quit', label: 'Quit Elemental Machines Kiosk', accelerator: 'CmdOrCtrl+Q' }
      ]
    },
    {
      label: 'View',
      submenu: [
        { role: 'reload' },
        { role: 'forceReload' },
        { role: 'toggleDevTools' }
      ]
    }
  ]);
}

function attachSecurityHandlers(window, allowedOrigins) {
  const { webContents } = window;

  // Keep the Electron container on explicitly allowlisted origins only.
  webContents.on('will-navigate', (event, target) => {
    if (isAllowedInAppNavigation(target, allowedOrigins)) {
      return;
    }

    event.preventDefault();

    if (isHttpUrl(target)) {
      void openInDefaultBrowser(target);
      return;
    }

    console.warn('Blocked navigation to non-HTTP target:', target);
  });

  // Deny all popup and window.open flows; trusted external links are handed off to the OS.
  webContents.setWindowOpenHandler(({ url: target }) => {
    if (isAllowedInAppNavigation(target, allowedOrigins)) {
      window.loadURL(target);
      return { action: 'deny' };
    }

    if (isHttpUrl(target)) {
      void openInDefaultBrowser(target);
    }

    return { action: 'deny' };
  });

  webContents.on('will-attach-webview', (event) => {
    event.preventDefault();
  });
}

function configureSessionPermissions(partition) {
  const kioskSession = session.fromPartition(partition);

  // Fail closed on permission prompts unless the app is intentionally expanded later.
  kioskSession.setPermissionRequestHandler((_webContents, _permission, callback) => {
    callback(false);
  });

  kioskSession.setPermissionCheckHandler(() => false);
}

function startDisplaySleepBlocker() {
  if (displaySleepBlockerId !== null && powerSaveBlocker.isStarted(displaySleepBlockerId)) {
    return;
  }

  displaySleepBlockerId = powerSaveBlocker.start('prevent-display-sleep');
}

function stopDisplaySleepBlocker() {
  if (displaySleepBlockerId === null) {
    return;
  }

  if (powerSaveBlocker.isStarted(displaySleepBlockerId)) {
    powerSaveBlocker.stop(displaySleepBlockerId);
  }

  displaySleepBlockerId = null;
}

function createMainWindow() {
  const allowedOrigins = getAllowedOrigins();

  mainWindow = new BrowserWindow({
    title: 'Elemental Machines Kiosk',
    width: 1440,
    height: 960,
    show: false,
    kiosk: !isWindowedMode,
    fullscreen: !isWindowedMode,
    autoHideMenuBar: !isWindowedMode,
    backgroundColor: '#ffffff',
    webPreferences: {
      partition: PERSISTENT_PARTITION,
      contextIsolation: true,
      sandbox: true,
      nodeIntegration: false,
      webSecurity: true,
      allowRunningInsecureContent: false,
      devTools: isDevelopment,
      spellcheck: false
    }
  });

  attachSecurityHandlers(mainWindow, allowedOrigins);
  mainWindow.setMenuBarVisibility(isWindowedMode);

  mainWindow.once('ready-to-show', () => {
    mainWindow.show();

    if (isWindowedMode) {
      mainWindow.focus();
      return;
    }

    mainWindow.setKiosk(true);
  });

  mainWindow.on('closed', () => {
    mainWindow = null;
  });

  void mainWindow.loadURL(TARGET_URL);
}

app.on('second-instance', () => {
  if (!mainWindow) {
    return;
  }

  if (mainWindow.isMinimized()) {
    mainWindow.restore();
  }

  mainWindow.focus();
});

app.whenReady().then(() => {
  app.setAppUserModelId('io.elementalmachines.kiosk');
  startDisplaySleepBlocker();
  configureSessionPermissions(PERSISTENT_PARTITION);
  Menu.setApplicationMenu(buildApplicationMenu());
  createMainWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createMainWindow();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('before-quit', () => {
  stopDisplaySleepBlocker();
  const kioskSession = session.fromPartition(PERSISTENT_PARTITION);
  kioskSession.flushStorageData();
});
