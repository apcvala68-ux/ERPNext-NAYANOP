#!/bin/bash
set -e

SITE_NAME="${1:-localhost}"
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
    sleep 1
done

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

echo "=== Stopping MariaDB ==="
kill ${MYSQL_PID} 2>/dev/null || true
sleep 2

echo "=== Cleaning up ==="
rm -rf /tmp/* /var/tmp/*

echo "=== Site setup complete! ==="
