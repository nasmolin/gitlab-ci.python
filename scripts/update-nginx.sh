#!/bin/bash

set -e

NGINX_CONF_DIR="/etc/nginx/sites-available"
CUSTOM_CONF_DIR="./nginx"
NGINX_CONF_FILE="$1"
BACKUP_CONF_FILE="${NGINX_CONF_DIR}/${NGINX_CONF_FILE}.bak"
CUSTOM_CONF_FILE="${CUSTOM_CONF_DIR}/${NGINX_CONF_FILE}"
TARGET_CONF_FILE="${NGINX_CONF_DIR}/${NGINX_CONF_FILE}"

rollback() {
    echo "[ERROR] Nginx configuration error! Rolling back changes..." >&2
    cp "$BACKUP_CONF_FILE" "$TARGET_CONF_FILE" || { echo "[ERROR] Failed to restore the previous config!" >&2; exit 1; }
    systemctl restart nginx || { echo "[ERROR] Failed to restart Nginx after rollback!" >&2; exit 1; }
    echo "[ERROR] Rollback completed, Nginx started with the previous config." >&2
    exit 1
}

trap 'rollback' ERR

if [[ ! -f "$CUSTOM_CONF_FILE" ]]; then
    echo "[ERROR] Custom config $CUSTOM_CONF_FILE not found." >&2
    exit 1
fi

if [[ -f "$TARGET_CONF_FILE" ]]; then
    cp "$TARGET_CONF_FILE" "$BACKUP_CONF_FILE"
    echo "[INFO] Backup of the current config created: $BACKUP_CONF_FILE"
else
    echo "[DEBUG] TARGET_CONF_FILE = $TARGET_CONF_FILE"
    echo "[WARNING] No existing config found, skipping backup."
fi

install -m 644 -o root -g root "$CUSTOM_CONF_FILE" "$TARGET_CONF_FILE"
echo "[INFO] New config copied."

nginx -t 2>&1 || rollback

echo "[INFO] Nginx configuration is valid. Restarting..."
systemctl restart nginx || { echo "[ERROR] Failed to restart Nginx!" >&2; exit 1; }
echo "[SUCCESS] Nginx successfully restarted."
