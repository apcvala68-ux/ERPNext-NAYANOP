#!/bin/bash
set -e

echo "=== Automotive CRM Entrypoint ==="

# Wait for MariaDB
echo "Waiting for MariaDB..."
until mysqladmin ping -h "$DB_HOST" -P "$DB_PORT" -u root -p"$DB_PASSWORD" --silent; do
    echo "MariaDB is not ready yet. Waiting..."
    sleep 5
done
echo "MariaDB is ready!"

# Wait for Redis
echo "Waiting for Redis..."
until redis-cli -h redis-cache ping | grep -q PONG; do
    echo "Redis is not ready yet. Waiting..."
    sleep 5
done
echo "Redis is ready!"

# Run migrations
echo "Running migrations..."
bench --site "$SITE_NAME" migrate

# Clear cache
echo "Clearing cache..."
bench --site "$SITE_NAME" clear-cache

# Generate assets
echo "Generating assets..."
bench --site "$SITE_NAME" build

echo "=== Entrypoint completed ==="

exec "$@"
