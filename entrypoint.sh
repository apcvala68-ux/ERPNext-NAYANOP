#!/bin/bash

echo "=== Starting All-in-One Automotive CRM ==="

# Render sets PORT env var (default 10000). Use it.
echo "PORT env var: '${PORT}'"
PORT="${PORT:-10000}"
echo "Using port: ${PORT}"

# Start health check on port 8080 (separate from app port) to keep Render alive
python3 -c "
import http.server, socketserver

class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-Type', 'text/plain')
        self.end_headers()
        self.wfile.write(b'OK')
    def log_message(self, format, *args):
        pass

class ReuseTCPServer(socketserver.TCPServer):
    allow_reuse_address = True

server = ReuseTCPServer(('0.0.0.0', 8080), Handler)
print('Health check on port 8080', flush=True)
server.serve_forever()
" &
HEALTH_PID=$!
echo "Health check PID: ${HEALTH_PID}"

# Start MariaDB
echo "[1/4] Starting MariaDB..."
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "  Initializing MariaDB data directory..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null 2>&1 || \
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null 2>&1 || true
fi

mysqld_safe --datadir=/var/lib/mysql &
sleep 3

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

echo "[2/4] Configuring MariaDB..."
if [ -n "${DB_PASSWORD}" ] && [ "${DB_PASSWORD}" != "admin" ]; then
    mariadb -u root -padmin -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_PASSWORD}'; FLUSH PRIVILEGES;" 2>/dev/null || \
    mysql -u root -padmin -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_PASSWORD}'; FLUSH PRIVILEGES;" 2>/dev/null || true
fi

echo "[3/4] Starting Redis..."
redis-server --daemonize yes --port 11000 --loglevel warning
redis-server --daemonize yes --port 13000 --loglevel warning
sleep 1

echo "[4/4] Setting admin password..."
su - frappe -c "cd /home/frappe/frappe-bench && bench set-admin-password '${ADMIN_PASSWORD:-admin}'" 2>/dev/null || true

SITE_HOST=$(echo "${RENDER_EXTERNAL_URL:-erpnext-nayanop.onrender.com}" | sed -E 's|https?://||;s|/.*||')
echo "Detected hostname: ${SITE_HOST}"

# Update site configs with correct port
su - frappe -c "cd /home/frappe/frappe-bench && python3 -c \"
import json
f='sites/common_site_config.json'
d=json.load(open(f))
d['default_site']='${SITE_HOST}'
d['webserver_port']=${PORT}
json.dump(d,open(f,'w'),indent=1)
print('common_site_config updated')
\""

SITE_DIR="/home/frappe/frappe-bench/sites/${SITE_HOST}"
if [ -d "$SITE_DIR" ]; then
    su - frappe -c "cd /home/frappe/frappe-bench && python3 -c \"
import json, os
f='${SITE_DIR}/site_config.json'
if os.path.exists(f):
    d=json.load(open(f))
    d['site_name']='${SITE_HOST}'
    d['host_name']='${SITE_HOST}'
    d['port']=${PORT}
    json.dump(d,open(f,'w'),indent=1)
    print('site_config updated')
\""
fi

echo "=== Setup complete ==="
echo "Starting bench on port ${PORT}"

# Kill health check
kill ${HEALTH_PID} 2>/dev/null || true
sleep 2

# Start Frappe on Render's assigned port
exec su - frappe -c "export PATH='/usr/local/nodejs/bin:/usr/local/bin:$PATH' && cd /home/frappe/frappe-bench && bench serve --port ${PORT}"
