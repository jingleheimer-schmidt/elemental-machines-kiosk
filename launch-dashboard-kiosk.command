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

mkdir -p "$PROFILE_DIR"

nohup "$CHROME_BIN" \
  --app="$TARGET_URL" \
  --kiosk \
  --user-data-dir="$PROFILE_DIR" \
  --no-first-run \
  --no-default-browser-check \
  >/dev/null 2>&1 &

trap - EXIT
exit 0
