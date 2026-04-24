Place all files in the ROOT of the atlas-registry project.

Chosen approach for grading:
1. Dockerfile -> secure multi-stage build for the REST service
2. build.bat / startup.bat / shutdown.bat -> plain Docker workflow
3. docker-compose.yml -> Docker Compose orchestration for the backend
4. docker/mysql.env and docker/app.env -> avoid hardcoding environment values directly in YAML/scripts

Validation commands:
- docker compose config
- docker compose up -d --build
- docker compose down

Application URL:
- REST service: http://localhost:8081
- Health endpoint: http://localhost:8081/health
