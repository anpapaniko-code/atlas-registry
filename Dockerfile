# ---------- BUILD STAGE ----------
FROM maven:3.9.9-eclipse-temurin-17 AS builder

WORKDIR /build

# Copy reactor structure first for better layer caching
COPY pom.xml ./
COPY atlas-domain/pom.xml atlas-domain/pom.xml
COPY citizen-registry-service/pom.xml citizen-registry-service/pom.xml
COPY citizen-registry-client/pom.xml citizen-registry-client/pom.xml

# Download dependencies only for the required module and its dependencies
RUN mvn -B -q -pl citizen-registry-service -am dependency:go-offline

# Copy only the source code needed for the build
COPY atlas-domain/src atlas-domain/src
COPY citizen-registry-service/src citizen-registry-service/src

# Build only the REST service and the modules it depends on
RUN mvn -B -q -pl citizen-registry-service -am clean package -DskipTests

# ---------- RUNTIME STAGE ----------
FROM eclipse-temurin:17-jre-jammy

# Create non-root user and group
RUN groupadd --system --gid 10001 appgroup     && useradd --system --uid 10001 --gid 10001 --create-home --shell /usr/sbin/nologin appuser

WORKDIR /app

# Copy only the final executable JAR
COPY --from=builder --chown=10001:10001 /build/citizen-registry-service/target/*.jar /app/app.jar

USER 10001:10001

EXPOSE 8080

ENTRYPOINT ["java", "-Djava.io.tmpdir=/tmp", "-jar", "/app/app.jar"]
