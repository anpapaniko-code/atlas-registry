#!/bin/bash
set -e

DB_NAME="${1}"
DB_USER="${2}"
DB_PASSWORD="${3}"

if [ -z "$DB_NAME" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ]; then
  echo "[ERROR] Usage: $0 <db_name> <db_user> <db_password>"
  exit 1
fi

echo "[INFO] Starting MySQL service..."
sudo systemctl enable mysql
sudo systemctl start mysql

echo "[INFO] Creating database and application user..."

sudo mysql <<EOF
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

echo "[INFO] Configuring MySQL to listen on all interfaces..."
MYSQL_CONFIG_FILE="/etc/mysql/mysql.conf.d/mysqld.cnf"

if sudo test -f "$MYSQL_CONFIG_FILE"; then
  sudo sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' "$MYSQL_CONFIG_FILE"
fi

echo "[INFO] Restarting MySQL..."
sudo systemctl restart mysql

echo "[INFO] Database runtime configuration completed successfully."