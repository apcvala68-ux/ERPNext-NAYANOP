#!/bin/bash

echo "=== Starting All-in-One Automotive CRM ==="

# Kill any existing process on port 8000 (handles container restarts)
fuser -k 8000/tcp 2>/dev/null || true
sleep 1

# Start temporary health check listener so Render detects the port immediately
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
        kill $TEMP_PID 2>/dev/null || true
        exit 1
    fi
    sleep 1
done

# Update root password if DB_PASSWORD env var is set
# Build sets root to mysql_native_password with 'admin'. Use -padmin to connect.
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

# Set admin password from ADMIN_PASSWORD env var (default 'admin' from build)
echo "[4/4] Setting admin password..."
su - frappe -c "cd /home/frappe/frappe-bench && bench set-admin-password '${ADMIN_PASSWORD:-admin}'" 2>/dev/null || true

# Kill the temp listener
kill $TEMP_PID 2>/dev/null || true

echo "=== All services started ==="
echo "App: http://localhost:8000"
echo "Login: Administrator / ${ADMIN_PASSWORD:-admin}"
echo ""

# Start Frappe (site is already built into the Docker image)
exec su - frappe -c "cd /home/frappe/frappe-bench && bench start"
