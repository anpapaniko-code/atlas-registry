#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

echo "[INFO] Updating package index..."
sudo apt-get update -y

echo "[INFO] Fixing any interrupted dpkg state..."
sudo dpkg --configure -a || true

echo "[INFO] Installing Java 17 and Maven..."
sudo apt-get install -y openjdk-17-jdk maven

echo "[INFO] Checking project directory..."
if [ ! -d "/home/ubuntu/project" ]; then
  echo "[ERROR] Project directory /home/ubuntu/project not found"
  exit 1
fi

cd /home/ubuntu/project

echo "[INFO] Building multi-module Maven project..."
sudo mvn clean package -DskipTests

echo "[INFO] Locating built application jar..."
JAR_FILE=$(find /home/ubuntu/project/citizen-registry-service/target -maxdepth 1 -type f -name "*.jar" ! -name "*sources.jar" ! -name "*javadoc.jar" | head -n 1)

if [ -z "$JAR_FILE" ]; then
  echo "[ERROR] No application jar found in /home/ubuntu/project/citizen-registry-service/target"
  ls -la /home/ubuntu/project/citizen-registry-service/target || true
  exit 1
fi

echo "[INFO] Found jar: $JAR_FILE"

echo "[INFO] Preparing /opt/app.jar..."
sudo mkdir -p /opt
sudo cp "$JAR_FILE" /opt/app.jar
sudo chmod 644 /opt/app.jar

echo "[INFO] Creating systemd service..."
sudo tee /etc/systemd/system/citizen-registry.service > /dev/null <<'EOF'
[Unit]
Description=Citizen Registry Spring Boot Application
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/opt
EnvironmentFile=-/etc/default/citizen-registry
ExecStart=/usr/bin/java -jar /opt/app.jar
SuccessExitStatus=143
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "[INFO] Creating default environment file..."
sudo tee /etc/default/citizen-registry > /dev/null <<'EOF'
SPRING_DATASOURCE_URL=
SPRING_DATASOURCE_USERNAME=
SPRING_DATASOURCE_PASSWORD=
SPRING_DATASOURCE_DRIVER_CLASS_NAME=com.mysql.cj.jdbc.Driver
SPRING_JPA_DATABASE_PLATFORM=org.hibernate.dialect.MySQLDialect
SPRING_JPA_HIBERNATE_DDL_AUTO=update
SPRING_H2_CONSOLE_ENABLED=false
EOF

echo "[INFO] Reloading systemd..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable citizen-registry

echo "[INFO] Verifying installed files..."
sudo ls -l /opt/app.jar
sudo ls -l /etc/systemd/system/citizen-registry.service
sudo ls -l /etc/default/citizen-registry

echo "[INFO] Application image preparation completed successfully."