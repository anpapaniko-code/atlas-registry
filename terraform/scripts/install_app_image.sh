#!/bin/bash
set -e

echo "[INFO] Updating package index..."
sudo apt-get update -y

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

JAR_FILE="/home/ubuntu/project/citizen-registry-service/target/citizen-registry-service-1.0.0.jar"

if [ ! -f "$JAR_FILE" ]; then
  echo "[ERROR] Expected jar not found at $JAR_FILE"
  exit 1
fi

echo "[INFO] Copying application jar to /opt/app.jar..."
sudo cp "$JAR_FILE" /opt/app.jar

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