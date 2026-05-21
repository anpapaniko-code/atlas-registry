Citizen Registry Backend - Kubernetes / Minikube Deployment

This folder contains Kubernetes manifests for the backend of the Citizen Registry application.

Architecture:
- RESTful Spring Boot service: Deployment + NodePort Service
- MySQL database: StatefulSet + ClusterIP Service
- Database persistence: PersistentVolumeClaim
- Database credentials: Kubernetes Secret
- Application non-sensitive configuration: ConfigMap

Objects:
- namespace.yaml
- mysql-secret.yaml
- app-configmap.yaml
- mysql-pvc.yaml
- mysql-service.yaml
- mysql-statefulset.yaml
- app-deployment.yaml
- app-service.yaml
- kustomization.yaml

Security choices:
- The database is exposed only inside the Kubernetes cluster through a ClusterIP service.
- Only the REST API is exposed through a NodePort service.
- Database credentials are stored in a Kubernetes Secret.
- The REST service runs as a non-root user.
- Privilege escalation is disabled for the REST service container.
- Linux capabilities are dropped for the REST service container.
- The REST service root filesystem is read-only and only /tmp is writable.

Minikube execution steps:

1. Start minikube:
   minikube start

2. Build the Docker image inside minikube:
   eval $(minikube docker-env)
   docker build -t citizen-registry-service:1.0.1 .

3. Apply the Kubernetes manifests:
   kubectl apply -f yaml/

4. Check status:
   kubectl get pods -n citizen-registry
   kubectl get svc -n citizen-registry
   kubectl get pvc -n citizen-registry

5. Access the REST API:
   minikube service citizen-registry-app -n citizen-registry

Alternative validation with port-forward:
   kubectl port-forward -n citizen-registry service/citizen-registry-app 8081:8080
   curl http://localhost:8081/health
   curl http://localhost:8081/api/citizens

Expected result:
- The MySQL pod should become Running and Ready.
- The REST API pods should become Running and Ready.
- The /health endpoint should return OK.
- The /api/citizens endpoint should return a JSON response.

Cleanup:
   kubectl delete -f yaml/
