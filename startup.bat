@echo off
setlocal enabledelayedexpansion

echo [1/6] Ensuring Docker network exists...
docker network inspect citizen-registry-backend-net >nul 2>&1
if errorlevel 1 (
    docker network create citizen-registry-backend-net >nul
    if errorlevel 1 goto :error
)

echo [2/6] Removing old containers if they exist...
docker rm -f citizen-registry-app citizen-registry-db >nul 2>&1

echo [3/6] Starting MySQL container...
docker run -d ^
  --name citizen-registry-db ^
  --network citizen-registry-backend-net ^
  --env-file docker\mysql.env ^
  --volume citizen-registry-db-data:/var/lib/mysql ^
  --health-cmd="mysqladmin ping -h 127.0.0.1 -uappuser -papppass --silent" ^
  --health-interval=10s ^
  --health-timeout=5s ^
  --health-retries=10 ^
  --health-start-period=30s ^
  mysql:8.0
if errorlevel 1 goto :error

echo [4/6] Waiting for MySQL to become healthy...
for /L %%i in (1,1,30) do (
    for /f %%s in ('docker inspect -f "{{.State.Health.Status}}" citizen-registry-db 2^>nul') do set DB_STATUS=%%s
    if "!DB_STATUS!"=="healthy" goto :db_ready
    timeout /t 2 /nobreak >nul
)

echo MySQL did not become healthy in time.
goto :error

:db_ready
echo [5/6] Starting REST service container...
docker run -d ^
  --name citizen-registry-app ^
  --network citizen-registry-backend-net ^
  --publish 8081:8080 ^
  --env-file docker\app.env ^
  citizen-registry-service:1.0.1
if errorlevel 1 goto :error

echo [6/6] Backend is available.
echo Health endpoint: http://localhost:8081/health
echo REST base path:   http://localhost:8081/api/citizens
exit /b 0

:error
echo Startup failed.
exit /b 1
