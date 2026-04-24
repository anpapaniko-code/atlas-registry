@echo off
setlocal

echo [1/3] Pulling pinned MySQL base image...
docker pull mysql:8.0
if errorlevel 1 goto :error

echo [2/3] Building REST service image...
docker build -t citizen-registry-service:1.0.1 -f Dockerfile .
if errorlevel 1 goto :error

echo [3/3] Ensuring persistent database volume exists...
docker volume inspect citizen-registry-db-data >nul 2>&1
if errorlevel 1 (
    docker volume create citizen-registry-db-data >nul
    if errorlevel 1 goto :error
)

echo Build completed successfully.
exit /b 0

:error
echo Build failed.
exit /b 1
