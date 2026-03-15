# Citizen Registry REST API

![CI](https://github.com/anpapaniko-code/atlas-registry/actions/workflows/ci.yml/badge.svg)

This repository contains a RESTful service for managing a citizen registry.

The project was developed as part of the course:

**Continuous Integration / Continuous Delivery (CI/CD)**

---

# Project Structure

The project follows a **multi-module Maven architecture**.

### atlas-domain
Contains the domain model and entity classes.

### citizen-registry-service
Implements the REST API and the business logic.

### citizen-registry-client
Client module used to access the REST service.

---

# Technologies

- Java 17
- Spring Boot
- Maven
- Git
- GitHub
- GitHub Actions

---

# Continuous Integration Pipeline

The project includes a **CI pipeline implemented with GitHub Actions**.

The pipeline is automatically triggered whenever a commit is pushed to the **develop** branch.

Pipeline steps:

1. Checkout repository
2. Setup Java 17
3. Compile source code
4. Execute unit tests
5. Execute API / integration tests
6. Upload test reports as artifacts

This ensures that every change committed to the develop branch is automatically built and tested.

---

# Repository

GitHub repository:

https://github.com/anpapaniko-code/atlas-registry
