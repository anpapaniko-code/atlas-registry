#!/bin/bash
set -e

echo "[INFO] Updating package index..."
sudo apt-get update -y

echo "[INFO] Installing MySQL Server..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server

echo "[INFO] Enabling MySQL service..."
sudo systemctl enable mysql
sudo systemctl start mysql

echo "[INFO] Verifying MySQL service status..."
sudo systemctl status mysql --no-pager || true

echo "[INFO] Database image preparation completed successfully."