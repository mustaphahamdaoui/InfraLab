#!/usr/bin/env bash
# InfraLab - Controlled Failure Drill 02 (Nginx HTTP/HTTPS behavior)
# READ BEFORE RUNNING: modifies only /etc/nginx/sites-available/infralab.
# Keeps a root-only backup and tests Nginx syntax before reloading.
# Never edits SSH, UFW, DHCP, private keys, or other Nginx site files.
# To keep the exercise blind, you may review the code AFTER the diagnosis.
set -Eeuo pipefail

CONF=/etc/nginx/sites-available/infralab
ENABLED=/etc/nginx/sites-enabled/infralab
STATE=/var/lib/infralab-drill-02
ORIGINAL="$STATE/original.conf"
INJECTED="$STATE/injected.conf"

usage() {
  printf 'Usage: sudo bash %s {break|status|restore|finish}\n' "$0" >&2
  exit 2
}

[[ $# -eq 1 ]] || usage
case "$1" in break|status|restore|finish) ;; *) usage ;; esac
[[ $EUID -eq 0 ]] || { echo 'Run this script with sudo.' >&2; exit 1; }
[[ -f "$CONF" && ! -L "$CONF" ]] || { echo 'Unexpected Nginx site file; no changes made.' >&2; exit 1; }
[[ -L "$ENABLED" && "$(readlink -f "$ENABLED")" == "$CONF" ]] || {
  echo 'Expected enabled site link is missing; no changes made.' >&2; exit 1;
}
command -v python3 >/dev/null || { echo 'python3 is required; no changes made.' >&2; exit 1; }

probe() {
  local http https
  http=$(curl --silent --show-error --max-time 5 --output /dev/null --write-out '%{http_code}' \
    --resolve infra.test:80:127.0.0.1 http://infra.test/) || return 1
  https=$(curl --insecure --silent --show-error --max-time 5 --output /dev/null --write-out '%{http_code}' \
    --resolve infra.test:443:127.0.0.1 https://infra.test/) || return 1
  [[ "$http" == 301 && "$https" == 200 ]]
}

temporary_file() {
  mktemp /etc/nginx/sites-available/.infralab-drill-02.XXXXXXXX
}

case "$1" in
  status)
    if [[ -f "$ORIGINAL" ]]; then
      echo 'Drill 02 state: active (original site config backed up).'
    else
      echo 'Drill 02 state: inactive.'
    fi
    ;;
  break)
    [[ ! -e "$STATE" ]] || { echo 'Drill already active or state exists. No changes made.' >&2; exit 1; }
    systemctl is-active --quiet nginx || { echo 'Nginx is not running. No changes made.' >&2; exit 1; }
    nginx -t >/dev/null 2>&1 || { echo 'Existing Nginx config fails nginx -t. No changes made.' >&2; exit 1; }
    probe || { echo 'Baseline website check failed. Restore your site before starting this drill. No changes made.' >&2; exit 1; }
    umask 077
    install -d -m 700 "$STATE"
    cp -p -- "$CONF" "$ORIGINAL"
    tmp=$(temporary_file)
    if ! python3 - "$CONF" "$tmp" <<'PY'
import pathlib, re, sys
src, dest = map(pathlib.Path, sys.argv[1:])
text = src.read_text()
# Strictly target the already-existing TLS server block, not the HTTP one.
if 'return 301 https://$host$request_uri;' not in text:
    sys.exit('Expected HTTP-to-HTTPS redirect not found.')
pattern = re.compile(r'(?m)^(?P<indent>[ \t]*)listen[ \t]+443[ \t]+ssl[ \t]*;[ \t]*\n(?:[ \t]*\n)*(?P=indent)server_name[ \t]+infra\.test[ \t]*;')
found = list(pattern.finditer(text))
if len(found) != 1 or 'return 302 http://$host$request_uri;' in text:
    sys.exit('Unexpected HTTPS block structure; refusing to edit.')
m = found[0]
output = text[:m.end()] + '\n' + m.group('indent') + 'return 302 http://$host$request_uri;' + text[m.end():]
dest.write_text(output)
PY
    then
      rm -f -- "$tmp"
      rm -f -- "$ORIGINAL"
      rmdir "$STATE"
      echo 'Site layout differs from expected. Nothing modified.' >&2
      exit 1
    fi
    chmod --reference="$CONF" "$tmp"
    chown --reference="$CONF" "$tmp"
    cp -p -- "$tmp" "$INJECTED"
    mv -f -- "$tmp" "$CONF"
    if ! nginx -t >/dev/null 2>&1 || ! systemctl reload nginx; then
      echo 'Activation failed. Reverting automatically.' >&2
      recovery=$(temporary_file)
      cp -p -- "$ORIGINAL" "$recovery"
      mv -f -- "$recovery" "$CONF"
      nginx -t && systemctl reload nginx || true
      rm -rf -- "$STATE"
      exit 1
    fi
    echo 'Drill 02 activated. Ticket: the site is no longer usable as expected.'
    echo 'Investigate from the Windows client using the usual infra.test address.'
    echo 'Nginx config is backed up. SSH, UFW and certificates are untouched.'
    ;;
  restore)
    [[ -f "$ORIGINAL" && -f "$INJECTED" ]] || { echo 'No backup found. Nothing to restore.' >&2; exit 1; }
    if ! cmp -s -- "$CONF" "$INJECTED"; then
      echo 'The site config was modified after injection. Refusing to overwrite your changes.' >&2
      echo "Review the backup in $ORIGINAL before making further edits." >&2
      exit 1
    fi
    recovery=$(temporary_file)
    cp -p -- "$ORIGINAL" "$recovery"
    mv -f -- "$recovery" "$CONF"
    nginx -t && systemctl reload nginx || {
      echo 'Restore file placed, but reload failed. Check Nginx manually.' >&2
      exit 1
    }
    rm -rf -- "$STATE"
    echo 'Original configuration restored and Nginx reloaded.'
    ;;
  finish)
    [[ -f "$ORIGINAL" ]] || { echo 'No active drill found.' >&2; exit 1; }
    nginx -t >/dev/null 2>&1 || { echo 'Nginx configuration test failed.' >&2; exit 1; }
    systemctl reload nginx || { echo 'Nginx reload failed.' >&2; exit 1; }
    probe || { echo 'Baseline behavior not restored yet. Keep investigating.' >&2; exit 1; }
    rm -rf -- "$STATE"
    echo 'Website recovered. Drill 02 completed; backup state cleaned.'
    ;;
esac
