#!/bin/bash
set -e

RAW_SITE_NAME="${1:-erpnext-nayanop.onrender.com}"
SITE_NAME=$(echo "$RAW_SITE_NAME" | sed -E 's|https?://||;s|/.*||')
BENCH_DIR="/home/frappe/frappe-bench"

echo "=== Starting MariaDB ==="
mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld
mysqld --user=mysql --datadir=/var/lib/mysql &
MYSQL_PID=$!

echo "=== Waiting for MariaDB ==="
for i in $(seq 1 30); do
    if mariadb-admin ping -h localhost --silent 2>/dev/null; then
        echo "MariaDB ready!"
        break
    fi
    if [ "$i" -eq 30 ]; then
        echo "ERROR: MariaDB failed to start within 30 seconds"
        exit 1
    fi
    sleep 1
done

echo "=== Setting MariaDB root password ==="
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD('admin'); FLUSH PRIVILEGES;"

echo "=== Starting Redis ==="
redis-server --daemonize yes --port 11000 --loglevel warning
redis-server --daemonize yes --port 13000 --loglevel warning
sleep 1
echo "Redis started!"

echo "=== Creating site: ${SITE_NAME} ==="
su - frappe -c "cd ${BENCH_DIR} && yes '' | bench new-site '${SITE_NAME}' --mariadb-root-password admin --admin-password admin --force"

echo "=== Installing erpnext ==="
su - frappe -c "cd ${BENCH_DIR} && bench --site '${SITE_NAME}' install-app erpnext"

echo "=== Installing hrms ==="
su - frappe -c "cd ${BENCH_DIR} && bench --site '${SITE_NAME}' install-app hrms"

echo "=== Installing automotive_crm ==="
su - frappe -c "cd ${BENCH_DIR} && bench --site '${SITE_NAME}' install-app automotive_crm"

echo "=== Building automotive_crm assets ==="
su - frappe -c "cd ${BENCH_DIR} && bench build --app automotive_crm" || true

echo "=== Clearing cache ==="
su - frappe -c "cd ${BENCH_DIR} && bench --site '${SITE_NAME}' clear-cache" || true

echo "=== Stopping Redis ==="
redis-cli -p 11000 shutdown 2>/dev/null || true
redis-cli -p 13000 shutdown 2>/dev/null || true

echo "=== Stopping MariaDB ==="
kill ${MYSQL_PID} 2>/dev/null || true
sleep 2

echo "=== Cleaning up ==="
rm -rf /tmp/* /var/tmp/*

echo "=== Site setup complete! ==="
