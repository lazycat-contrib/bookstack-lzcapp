#!/bin/bash
# Create the first BookStack admin, once.
#
# Dropped into /custom-cont-init.d/ so LinuxServer's s6 overlay runs it after
# the app config init (which performs `artisan migrate --force`).
set -eu

: "${BOOKSTACK_ADMIN_EMAIL:?BOOKSTACK_ADMIN_EMAIL is required}"
: "${BOOKSTACK_ADMIN_PASSWORD:?BOOKSTACK_ADMIN_PASSWORD is required}"

[ "${#BOOKSTACK_ADMIN_PASSWORD}" -ge 12 ] || {
  echo "[bookstack] ERROR: admin password must be at least 12 characters" >&2
  exit 1
}

ARTISAN=/app/www/artisan

# Wait for the schema to exist before touching the users table.
for _ in $(seq 1 60); do
  if php "$ARTISAN" migrate:status >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

# Count existing users; only seed when the table is empty.
COUNT=$(php "$ARTISAN" tinker --execute='echo \BookStack\Users\Models\User::count();' 2>/dev/null | tr -dc '0-9' || true)

if [ -z "$COUNT" ]; then
  echo "[bookstack] could not read user count, skipping admin creation"
  exit 0
fi

if [ "$COUNT" -gt 0 ]; then
  echo "[bookstack] $COUNT user(s) already exist, skipping admin creation"
  exit 0
fi

echo "[bookstack] creating initial admin"
php "$ARTISAN" bookstack:create-admin \
  --email="$BOOKSTACK_ADMIN_EMAIL" \
  --name="admin" \
  --password="$BOOKSTACK_ADMIN_PASSWORD" \
  --initial

# Hand ownership back to the app user used by the image.
lsiown -R abc:abc /config 2>/dev/null || true

echo "[bookstack] admin created"
