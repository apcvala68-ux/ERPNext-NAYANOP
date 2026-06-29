#!/bin/bash
set -e

echo "=== Starting All-in-One Automotive CRM ==="

# Initialize MariaDB data dir if empty (fresh container)
echo "[1/4] Starting MariaDB..."
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "  Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null 2>&1
fi

mysqld_safe --datadir=/var/lib/mysql &
sleep 3

# Wait for MariaDB
for i in $(seq 1 30); do
    if mysqladmin ping -h localhost --silent 2>/dev/null; then
        echo "  MariaDB ready!"
        break
    fi
    if [ "$i" -eq 30 ]; then
        echo "  ERROR: MariaDB failed to start within 30 seconds"
        exit 1
    fi
    sleep 1
done

# Setup MariaDB
echo "[2/4] Configuring MariaDB..."
mysql -u root -e "CREATE DATABASE IF NOT EXISTS automotive_crm;" 2>/dev/null || true
mysql -u root -e "CREATE USER IF NOT EXISTS 'frappe'@'localhost' IDENTIFIED BY '${DB_PASSWORD:-admin}';" 2>/dev/null || true
mysql -u root -e "GRANT ALL PRIVILEGES ON automotive_crm.* TO 'frappe'@'localhost';" 2>/dev/null || true
mysql -u root -e "FLUSH PRIVILEGES;" 2>/dev/null || true

# Start Redis
echo "[3/4] Starting Redis..."
redis-server --daemonize yes --port 11000 --loglevel warning
redis-server --daemonize yes --port 13000 --loglevel warning
sleep 1

# Create site if not exists
SITE_NAME="${SITE_NAME:-localhost}"
cd /home/frappe/frappe-bench
if [ ! -f "sites/${SITE_NAME}/site_config.json" ]; then
    echo "[4/4] Creating site: ${SITE_NAME}..."
    su - frappe -c "cd /home/frappe/frappe-bench && yes '' | bench new-site '${SITE_NAME}' --mariadb-root-password root --admin-password '${ADMIN_PASSWORD:-admin}' --no-mariadb-socket --force"

    echo "Installing apps..."
    su - frappe -c "cd /home/frappe/frappe-bench && bench --site '${SITE_NAME}' install-app erpnext"
    su - frappe -c "cd /home/frappe/frappe-bench && bench --site '${SITE_NAME}' install-app hrms"
    su - frappe -c "cd /home/frappe/frappe-bench && bench --site '${SITE_NAME}' install-app automotive_crm"

    su - frappe -c "cd /home/frappe/frappe-bench && bench config -g set default_site '${SITE_NAME}'"
    su - frappe -c "cd /home/frappe/frappe-bench && bench build --app automotive_crm" || true
    su - frappe -c "cd /home/frappe/frappe-bench && bench --site '${SITE_NAME}' clear-cache" || true
else
    echo "[4/4] Site ${SITE_NAME} exists. Running migrations..."
    su - frappe -c "cd /home/frappe/frappe-bench && bench --site '${SITE_NAME}' migrate" || true
    su - frappe -c "cd /home/frappe/frappe-bench && bench --site '${SITE_NAME}' clear-cache" || true
fi

echo "=== All services started ==="
echo "App: http://localhost:8000"
echo "Login: Administrator / ${ADMIN_PASSWORD:-admin}"
echo ""

# Start Frappe
exec su - frappe -c "cd /home/frappe/frappe-bench && bench start"
