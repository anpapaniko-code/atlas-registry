#!/bin/bash
set -e

DB_HOST="${1}"
DB_PORT="${2}"
DB_NAME="${3}"
DB_USER="${4}"
DB_PASSWORD="${5}"

export DEBIAN_FRONTEND=noninteractive

echo "[INFO] Fixing any interrupted dpkg state..."
sudo dpkg --configure -a || true

echo "[INFO] Ensuring git exists..."
if ! command -v git >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y git
fi

echo "[INFO] Ensuring curl exists..."
if ! command -v curl >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y curl
fi

echo "[INFO] Checking app artifacts..."
if [ ! -f "/opt/app.jar" ]; then
  echo "[ERROR] /opt/app.jar not found"
  ls -la /opt || true
  exit 1
fi

if [ ! -f "/etc/systemd/system/citizen-registry.service" ]; then
  echo "[ERROR] /etc/systemd/system/citizen-registry.service not found"
  exit 1
fi

echo "[INFO] Writing runtime environment file..."
sudo tee /etc/default/citizen-registry > /dev/null <<EOF
SPRING_DATASOURCE_URL=jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_NAME}
SPRING_DATASOURCE_USERNAME=${DB_USER}
SPRING_DATASOURCE_PASSWORD=${DB_PASSWORD}
SPRING_DATASOURCE_DRIVER_CLASS_NAME=com.mysql.cj.jdbc.Driver
SPRING_JPA_DATABASE_PLATFORM=org.hibernate.dialect.MySQLDialect
SPRING_JPA_HIBERNATE_DDL_AUTO=update
SPRING_H2_CONSOLE_ENABLED=false
EOF

echo "[INFO] Reloading systemd..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

echo "[INFO] Enabling and restarting application..."
sudo systemctl enable citizen-registry
sudo systemctl restart citizen-registry

echo "[INFO] Waiting 20 seconds before diagnostics..."
sleep 20

echo "[INFO] ===== SYSTEMCTL STATUS ====="
sudo systemctl status citizen-registry --no-pager || true

echo "[INFO] ===== JOURNAL ====="
sudo journalctl -u citizen-registry -n 200 --no-pager || true

echo "[INFO] ===== PORT CHECK ====="
sudo ss -ltnp | grep 8080 || true

echo "[INFO] ===== LOCAL HEALTH CHECK ====="
curl -v http://localhost:8080/health || true

echo "[INFO] ===== LOCAL API CHECK ====="
curl -v http://localhost:8080/api/citizens || true

echo "[INFO] Application runtime configuration completed successfully."