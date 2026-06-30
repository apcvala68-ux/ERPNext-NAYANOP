#!/bin/bash

echo "=== Starting All-in-One Automotive CRM ==="

# Start MariaDB (loads pre-built site data from Docker image)
echo "[1/4] Starting MariaDB..."
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "  Initializing MariaDB data directory..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null 2>&1 || \
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null 2>&1 || true
fi

mysqld_safe --datadir=/var/lib/mysql &
sleep 3

# Wait for MariaDB
for i in $(seq 1 30); do
    if mariadb-admin ping -h localhost --silent 2>/dev/null || mysqladmin ping -h localhost --silent 2>/dev/null; then
        echo "  MariaDB ready!"
        break
    fi
    if [ "$i" -eq 30 ]; then
        echo "  ERROR: MariaDB failed to start within 30 seconds"
        exit 1
    fi
    sleep 1
done

# Update root password if DB_PASSWORD env var is set
echo "[2/4] Configuring MariaDB..."
if [ -n "${DB_PASSWORD}" ] && [ "${DB_PASSWORD}" != "admin" ]; then
    mariadb -u root -padmin -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_PASSWORD}'; FLUSH PRIVILEGES;" 2>/dev/null || \
    mysql -u root -padmin -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_PASSWORD}'; FLUSH PRIVILEGES;" 2>/dev/null || true
fi

# Start Redis
echo "[3/4] Starting Redis..."
redis-server --daemonize yes --port 11000 --loglevel warning
redis-server --daemonize yes --port 13000 --loglevel warning
sleep 1

# Set admin password
echo "[4/4] Setting admin password..."
su - frappe -c "cd /home/frappe/frappe-bench && bench set-admin-password '${ADMIN_PASSWORD:-admin}'" 2>/dev/null || true

# Detect hostname from RENDER_EXTERNAL_URL or use default
SITE_HOST=$(echo "${RENDER_EXTERNAL_URL:-erpnext-nayanop.onrender.com}" | sed -E 's|https?://||;s|/.*||')
echo "Detected hostname: ${SITE_HOST}"

# Update default_site in common_site_config.json dynamically
su - frappe -c "cd /home/frappe/frappe-bench && python3 -c \"
import json
f='sites/common_site_config.json'
d=json.load(open(f))
d['default_site']='${SITE_HOST}'
json.dump(d,open(f,'w'),indent=1)
print('default_site set to: ${SITE_HOST}')
\""

# Update site_name in site config if site exists
SITE_DIR="/home/frappe/frappe-bench/sites/${SITE_HOST}"
if [ -d "$SITE_DIR" ]; then
    su - frappe -c "cd /home/frappe/frappe-bench && python3 -c \"
import json, os
f='${SITE_DIR}/site_config.json'
if os.path.exists(f):
    d=json.load(open(f))
    d['site_name']='${SITE_HOST}'
    d['host_name']='${SITE_HOST}'
    json.dump(d,open(f,'w'),indent=1)
    print('site_config updated for ${SITE_HOST}')
\""
fi

echo "=== All services started ==="
echo "App: https://${SITE_HOST}"
echo "Login: Administrator / ${ADMIN_PASSWORD:-admin}"
echo ""

# Start Frappe — bench serve binds to 0.0.0.0:8000
exec su - frappe -c "export PATH='/usr/local/nodejs/bin:/usr/local/bin:$PATH' && cd /home/frappe/frappe-bench && bench start"
