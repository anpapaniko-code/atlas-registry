#!/bin/bash
set -e

DB_HOST="${1}"
DB_PORT="${2}"
DB_NAME="${3}"
DB_USER="${4}"
DB_PASSWORD="${5}"

if [ -z "$DB_HOST" ] || [ -z "$DB_PORT" ] || [ -z "$DB_NAME" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ]; then
  echo "[ERROR] Usage: $0 <db_host> <db_port> <db_name> <db_user> <db_password>"
  exit 1
fi

echo "[INFO] Installing curl for local checks..."
sudo apt-get update -y || true
sudo apt-get install -y curl || true

echo "[INFO] Configuring application runtime..."

sudo tee /etc/systemd/system/citizen-registry.service > /dev/null <<EOF
[Unit]
Description=Citizen Registry Spring Boot Application
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/opt

Environment=SPRING_DATASOURCE_URL=jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_NAME}
Environment=SPRING_DATASOURCE_USERNAME=${DB_USER}
Environment=SPRING_DATASOURCE_PASSWORD=${DB_PASSWORD}
Environment=SPRING_DATASOURCE_DRIVER_CLASS_NAME=com.mysql.cj.jdbc.Driver
Environment=SPRING_JPA_DATABASE_PLATFORM=org.hibernate.dialect.MySQLDialect
Environment=SPRING_JPA_HIBERNATE_DDL_AUTO=update
Environment=SPRING_H2_CONSOLE_ENABLED=false

ExecStart=/usr/bin/java -jar /opt/app.jar
SuccessExitStatus=143
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "[INFO] Reloading systemd..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

echo "[INFO] Enabling and starting application..."
sudo systemctl enable citizen-registry
sudo systemctl restart citizen-registry

echo "[INFO] Waiting 20 seconds before diagnostics..."
sleep 20

echo "[INFO] ===== SYSTEMCTL STATUS ====="
sudo systemctl status citizen-registry --no-pager || true

echo "[INFO] ===== JOURNAL ====="
sudo journalctl -u citizen-registry -n 200 --no-pager || true

echo "[INFO] ===== PORT CHECK ====="
sudo ss -tulpen | grep 8080 || true

echo "[INFO] ===== LOCAL HEALTH CHECK ====="
curl -i http://localhost:8080/health || true

echo "[INFO] ===== LOCAL API CHECK ====="
curl -i http://localhost:8080/api/citizens || true

echo "[INFO] Application runtime configuration completed successfully."