#!/bin/bash
set -e

echo "Starting AtonixCorp Platform..."

# Wait for database to be ready
echo "Waiting for database..."
while ! nc -z ${DATABASE_HOST:-db} ${DATABASE_PORT:-5432}; do
  sleep 1
done
echo "Database is ready!"

# Wait for Redis to be ready
echo "Waiting for Redis..."
while ! nc -z ${REDIS_HOST:-redis} ${REDIS_PORT:-6379}; do
  sleep 1
done
echo "Redis is ready!"

# Wait for Zookeeper to be ready (optional)
if [ ! -z "$ZOOKEEPER_HOSTS" ]; then
  echo "Waiting for Zookeeper..."
  ZOOKEEPER_HOST=$(echo $ZOOKEEPER_HOSTS | cut -d':' -f1)
  ZOOKEEPER_PORT=$(echo $ZOOKEEPER_HOSTS | cut -d':' -f2)
  while ! nc -z ${ZOOKEEPER_HOST} ${ZOOKEEPER_PORT:-2181}; do
    sleep 1
  done
  echo "Zookeeper is ready!"
fi

# Wait for Kafka to be ready (optional)
if [ ! -z "$KAFKA_BOOTSTRAP_SERVERS" ]; then
  echo "Waiting for Kafka..."
  KAFKA_HOST=$(echo $KAFKA_BOOTSTRAP_SERVERS | cut -d':' -f1)
  KAFKA_PORT=$(echo $KAFKA_BOOTSTRAP_SERVERS | cut -d':' -f2)
  while ! nc -z ${KAFKA_HOST} ${KAFKA_PORT:-9092}; do
    sleep 1
  done
  echo "Kafka is ready!"
fi

# Create required directories
mkdir -p /app/logs /app/static /app/media

# Copy nginx configuration
cp /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Set proper permissions
chown -R app:app /app/logs /app/static /app/media

echo "Starting supervisor..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf