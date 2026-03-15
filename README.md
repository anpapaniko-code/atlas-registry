# Citizen Registry REST API

This project implements a RESTful service for managing a citizen registry.

The application was developed as part of the course:
Continuous Integration / Continuous Delivery (CI/CD).

## Technologies

- Java 17
- Spring Boot
- Maven
- Git
- GitHub Actions

## Project Structure

atlas-domain  
Contains domain model and entity classes.

citizen-registry-service  
Implements the REST API and business logic.

citizen-registry-client  
Client module for accessing the REST service.

## CI/CD Pipeline

The project includes a Continuous Integration pipeline implemented using GitHub Actions.

Pipeline steps:

1. Checkout repository
2. Setup Java 17
3. Compile the project using Maven
4. Execute unit tests
5. Execute integration tests
6. Upload test reports as artifacts

The pipeline is automatically triggered on commits to the **develop** branch.

## Repository

https://github.com/anpapaniko-code/atlas-registry
