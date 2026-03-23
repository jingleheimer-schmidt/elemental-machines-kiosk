#!/bin/bash

set -euo pipefail

TARGET_URL='https://dashboard.elementalmachines.io/users/sign_in'
CHROME_BIN='/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
PROFILE_DIR="${HOME}/Library/Application Support/ElementalMachinesKioskChrome"

pause_on_error() {
  local exit_code="$1"

  if [[ "$exit_code" -ne 0 && -t 1 ]]; then
    printf '\nPress Enter to close...\n'
    read -r _
  fi

  exit "$exit_code"
}

trap 'pause_on_error $?' EXIT

if [[ ! -x "$CHROME_BIN" ]]; then
  printf 'Google Chrome was not found at:\n%s\n' "$CHROME_BIN" >&2
  exit 1
fi

if ! mkdir -p "$PROFILE_DIR"; then
  printf 'Failed to create the kiosk Chrome profile directory:\n%s\n' "$PROFILE_DIR" >&2
  exit 1
fi

LAUNCH_LOG="$(mktemp -t elemental-machines-kiosk-launch.XXXXXX.log)"

nohup "$CHROME_BIN" \
  --app="$TARGET_URL" \
  --kiosk \
  --user-data-dir="$PROFILE_DIR" \
  --no-first-run \
  --no-default-browser-check \
  >"$LAUNCH_LOG" 2>&1 &

CHROME_PID=$!
sleep 1

if ! kill -0 "$CHROME_PID" 2>/dev/null; then
  printf 'Failed to launch Google Chrome.\n' >&2
  if [[ -s "$LAUNCH_LOG" ]]; then
    printf 'Chrome startup output:\n' >&2
    cat "$LAUNCH_LOG" >&2
  fi
  rm -f "$LAUNCH_LOG"
  exit 1
fi

rm -f "$LAUNCH_LOG"

trap - EXIT
exit 0
