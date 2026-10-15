#!/usr/bin/env bash
# InfraLab | Controlled Failure Drill 01
# Scope: ONLY /var/www/infralab/index.html permissions.
# Does NOT alter SSH, UFW, certificates, router settings, or Nginx configuration.
# Read and review this script before running it on your lab server.
set -Eeuo pipefail

TARGET='/var/www/infralab/index.html'
STATE_DIR='/var/lib/infralab-drill-01'
STATE_FILE="$STATE_DIR/original_mode"

usage() {
  printf 'Usage: sudo bash %s {break|restore|status}\n' "$0" >&2
  exit 2
}

[[ $# -eq 1 ]] || usage
case "$1" in break|restore|status) ;; *) usage ;; esac

if [[ $EUID -ne 0 ]]; then
  printf 'Run with sudo.\n' >&2
  exit 1
fi

# Fail safely if the site does not have the expected structure.
if [[ ! -f "$TARGET" || -L "$TARGET" ]]; then
  printf 'Expected ordinary site file missing or symbolic link: %s\nNo changes made.\n' "$TARGET" >&2
  exit 1
fi

case "$1" in
  break)
    if [[ -e "$STATE_FILE" ]]; then
      printf 'A drill is already active. No changes made.\n' >&2
      exit 1
    fi
    if ! systemctl is-active --quiet nginx; then
      printf 'Nginx is not currently active. No changes made.\n' >&2
      exit 1
    fi
    original_mode=$(stat -c '%a' -- "$TARGET")
    umask 077
    install -d -m 700 -- "$STATE_DIR"
    printf '%s\n' "$original_mode" > "$STATE_FILE"
    if ! chmod 000 -- "$TARGET"; then
      rm -f -- "$STATE_FILE"
      printf 'Could not inject failure; saved state removed.\n' >&2
      exit 1
    fi
    printf 'Controlled failure activated. Investigate from Windows.\n'
    printf 'Scope: web content only. SSH/UFW/TLS configurations were not modified.\n'
    ;;
  restore)
    if [[ ! -f "$STATE_FILE" ]]; then
      printf 'No saved drill state found. Nothing restored.\n' >&2
      exit 1
    fi
    original_mode=$(cat -- "$STATE_FILE")
    if [[ ! "$original_mode" =~ ^[0-7]{3,4}$ ]]; then
      printf 'Saved permission value is invalid. Manual review required.\n' >&2
      exit 1
    fi
    chmod "$original_mode" -- "$TARGET"
    rm -f -- "$STATE_FILE"
    rmdir -- "$STATE_DIR" 2>/dev/null || true
    printf 'Original file permissions restored.\n'
    ;;
  status)
    if [[ -f "$STATE_FILE" ]]; then
      printf 'Drill state: active (backup permission value stored).\n'
    else
      printf 'Drill state: inactive.\n'
    fi
    ;;
esac
