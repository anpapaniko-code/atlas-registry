@echo off
setlocal

echo [1/4] Stopping and removing containers...
docker rm -f citizen-registry-app citizen-registry-db >nul 2>&1

echo [2/4] Removing user-defined network...
docker network rm citizen-registry-backend-net >nul 2>&1

echo [3/4] Removing dangling images...
docker image prune -f >nul 2>&1

echo [4/4] Removing dangling build cache...
docker builder prune -f >nul 2>&1

echo Shutdown and cleanup completed.
exit /b 0
