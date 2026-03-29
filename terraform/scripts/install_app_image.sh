#!/bin/bash
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "[INFO] Fixing interrupted dpkg state if needed..."
sudo dpkg --configure -a || true

echo "[INFO] Updating package index..."
sudo apt-get update -y

echo "[INFO] Installing Java 17, Maven and Git..."
sudo apt-get install -y openjdk-17-jdk maven git

echo "[INFO] Checking project directory..."
if [ ! -d "/home/ubuntu/project" ]; then
  echo "[ERROR] Project directory /home/ubuntu/project not found"
  exit 1
fi

cd /home/ubuntu/project

echo "[INFO] Building multi-module Maven project..."
mvn -B -ntp clean package -DskipTests

echo "[INFO] Locating executable application jar..."
JAR_FILE=$(find /home/ubuntu/project/citizen-registry-service/target \
  -maxdepth 1 \
  -type f \
  -name "*.jar" \
  ! -name "*.original" | head -n 1)

if [ -z "${JAR_FILE}" ]; then
  echo "[ERROR] No application jar found under citizen-registry-service/target"
  ls -la /home/ubuntu/project/citizen-registry-service/target || true
  exit 1
fi

echo "[INFO] Found jar: ${JAR_FILE}"

echo "[INFO] Preparing /opt directory..."
sudo mkdir -p /opt

echo "[INFO] Copying application jar to /opt/app.jar..."
sudo cp "${JAR_FILE}" /opt/app.jar
sudo chown ubuntu:ubuntu /opt/app.jar
sudo chmod 644 /opt/app.jar

echo "[INFO] Verifying installed jar..."
ls -l /opt/app.jar
java -version

echo "[INFO] Creating systemd service..."

sudo tee /etc/systemd/system/citizen-registry.service > /dev/null <<EOF
[Unit]
Description=Citizen Registry Spring Boot Application
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/opt
ExecStart=/usr/bin/java -jar /opt/app.jar
SuccessExitStatus=143
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "[INFO] Enabling citizen-registry service..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable citizen-registry

echo "[INFO] Application image preparation completed successfully."