#!/bin/bash
set -e

echo "=== Starting All-in-One Automotive CRM ==="

# Start a temporary port listener so Render detects the port immediately
echo "Starting temporary health check listener on port 8000..."
python3 -c "
import http.server, socketserver
class H(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'OK - Setting up...')
    def log_message(self, *args): pass
with socketserver.TCPServer(('0.0.0.0', 8000), H) as httpd:
    httpd.serve_forever()
" &
TEMP_PID=$!
sleep 1

# Initialize MariaDB data dir if empty (fresh container)
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
        kill $TEMP_PID 2>/dev/null || true
        exit 1
    fi
    sleep 1
done

# Set root password for TCP connections (bench new-site uses TCP)
echo "[2/4] Configuring MariaDB..."
mariadb -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_PASSWORD:-admin}'; FLUSH PRIVILEGES;" 2>/dev/null || \
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_PASSWORD:-admin}'; FLUSH PRIVILEGES;" 2>/dev/null || true

mariadb -u root -p"${DB_PASSWORD:-admin}" -e "CREATE DATABASE IF NOT EXISTS automotive_crm;" 2>/dev/null || \
mysql -u root -p"${DB_PASSWORD:-admin}" -e "CREATE DATABASE IF NOT EXISTS automotive_crm;" 2>/dev/null || true

mariadb -u root -p"${DB_PASSWORD:-admin}" -e "CREATE USER IF NOT EXISTS 'frappe'@'localhost' IDENTIFIED BY '${DB_PASSWORD:-admin}';" 2>/dev/null || \
mysql -u root -p"${DB_PASSWORD:-admin}" -e "CREATE USER IF NOT EXISTS 'frappe'@'localhost' IDENTIFIED BY '${DB_PASSWORD:-admin}';" 2>/dev/null || true

mariadb -u root -p"${DB_PASSWORD:-admin}" -e "GRANT ALL PRIVILEGES ON automotive_crm.* TO 'frappe'@'localhost'; FLUSH PRIVILEGES;" 2>/dev/null || \
mysql -u root -p"${DB_PASSWORD:-admin}" -e "GRANT ALL PRIVILEGES ON automotive_crm.* TO 'frappe'@'localhost'; FLUSH PRIVILEGES;" 2>/dev/null || true

# Start Redis
echo "[3/4] Starting Redis..."
redis-server --daemonize yes --port 11000 --loglevel warning
redis-server --daemonize yes --port 13000 --loglevel warning
sleep 1

# Create site if not exists
SITE_NAME="${SITE_NAME:-localhost}"
# Strip protocol prefix if present (Render sets full URL)
SITE_NAME=$(echo "$SITE_NAME" | sed 's|https\?://||' | sed 's|/.*||')
cd /home/frappe/frappe-bench
if [ ! -f "sites/${SITE_NAME}/site_config.json" ]; then
    echo "[4/4] Creating site: ${SITE_NAME}..."
    su - frappe -c "cd /home/frappe/frappe-bench && yes '' | bench new-site '${SITE_NAME}' --mariadb-root-password '${DB_PASSWORD:-admin}' --admin-password '${ADMIN_PASSWORD:-admin}' --force"

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

# Kill the temp listener
kill $TEMP_PID 2>/dev/null || true

echo "=== All services started ==="
echo "App: http://localhost:8000"
echo "Login: Administrator / ${ADMIN_PASSWORD:-admin}"
echo ""

# Start Frappe
exec su - frappe -c "cd /home/frappe/frappe-bench && bench start"
