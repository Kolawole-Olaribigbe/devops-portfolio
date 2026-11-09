# Kubernetes Todo Application — Container Orchestration and Autoscaling

## Overview

This project demonstrates how to deploy and manage a containerized Node.js Todo API using Kubernetes.

The application is packaged as a Docker image, published to Docker Hub, and deployed to a local Kubernetes cluster using Minikube.

Kubernetes resources are used to manage application replicas, configuration, secrets, networking, persistent storage, ingress routing, and automatic scaling based on CPU utilization.

The project demonstrates practical container orchestration and cloud-native application deployment concepts.

## Architecture

```text
                         Client
                           |
                           |
                     todo.local
                           |
                           v
                  +------------------+
                  | Kubernetes       |
                  | NGINX Ingress    |
                  | Controller       |
                  +--------+---------+
                           |
                           v
                  +------------------+
                  | Kubernetes      |
                  | Service         |
                  | ClusterIP       |
                  +--------+---------+
                           |
                 +---------+---------+
                 |                   |
                 v                   v
          +-------------+     +-------------+
          | Todo API    |     | Todo API    |
          | Pod 1       |     | Pod 2       |
          +------+------+     +------+------+
                 |                   |
                 +---------+---------+
                           |
                           v
                  +------------------+
                  | Persistent       |
                  | Volume Claim     |
                  | 1 GiB            |
                  +------------------+

                  Horizontal Pod Autoscaler
                     Minimum: 2 replicas
                     Maximum: 5 replicas
                     CPU target: 50%
```

The application is exposed through an NGINX Ingress Controller. A Kubernetes ClusterIP Service distributes requests to the available application Pods.

The Horizontal Pod Autoscaler adjusts the number of application replicas based on CPU utilization.

## Technologies Used

| Technology | Purpose |
|---|---|
| Node.js | Application runtime |
| Express.js | REST API framework |
| Docker | Application containerization |
| Docker Hub | Container image registry |
| Kubernetes | Container orchestration |
| Minikube | Local Kubernetes cluster |
| kubectl | Kubernetes resource management |
| NGINX Ingress Controller | External HTTP routing |
| ConfigMap | Application configuration |
| Kubernetes Secret | Sensitive configuration |
| PersistentVolumeClaim | Persistent application storage |
| Metrics Server | Resource metrics collection |
| Horizontal Pod Autoscaler | Automatic replica scaling |

## Application Features

The Todo API supports:

- Retrieving application information.
- Checking application health.
- Retrieving all Todo items.
- Creating Todo items.
- Persisting Todo records in JSON storage.

### API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/` | Application information |
| GET | `/health` | Health check |
| GET | `/todos` | Retrieve Todo items |
| POST | `/todos` | Create a Todo item |

### Example API Request

Create a Todo:

```bash
curl -X POST http://todo.local/todos \
  -H "Content-Type: application/json" \
  -d '{"title":"Learn Kubernetes"}'
```

Retrieve Todo items:

```bash
curl http://todo.local/todos
```

Example response:

```json
[
  {
    "id": 1794249095898,
    "title": "Learn Kubernetes",
    "completed": false
  }
]
```

## Docker Image

The application is containerized using a Dockerfile based on Node.js Alpine.

The image is published to Docker Hub:

**Repository:** `kolaolaribigbe/kubernetes-todo-app`

**Image tag:** `v1`

```bash
docker pull kolaolaribigbe/kubernetes-todo-app:v1
```

Docker Hub:

https://hub.docker.com/r/kolaolaribigbe/kubernetes-todo-app

## Kubernetes Resources

All Kubernetes manifests are maintained in the `k8s/` directory.

| Manifest | Resource | Purpose |
|---|---|---|
| `deployment.yaml` | Deployment | Manages application Pods and replicas |
| `service.yaml` | ClusterIP Service | Provides internal application networking |
| `configmap.yaml` | ConfigMap | Supplies application environment configuration |
| `secret.example.yaml` | Secret template | Demonstrates sensitive configuration management |
| `pvc.yaml` | PersistentVolumeClaim | Requests persistent storage |
| `ingress.yaml` | Ingress | Exposes the application through HTTP routing |
| `hpa.yaml` | HorizontalPodAutoscaler | Automatically scales application replicas |

### Deployment and Replicas

The Deployment manages the application Pods.

The initial configuration uses two replicas and defines CPU and memory requests and limits.

```yaml
replicas: 2
```

The container uses the published Docker Hub image:

```yaml
image: kolaolaribigbe/kubernetes-todo-app:v1
imagePullPolicy: Always
```

### ConfigMap and Secret

A ConfigMap supplies non-sensitive application settings:

```text
PORT=3000
DATA_DIR=/data
```

A Kubernetes Secret provides a demonstration API key through an environment variable.

The actual Secret manifest is excluded from Git. A safe example template is included in the repository.

**Security note:** Kubernetes Secrets are not automatically encrypted simply because their values are Base64-encoded. Production environments should use appropriate encryption at rest, access controls, and secret-management practices.

### Persistent Storage

A PersistentVolumeClaim requests 1 GiB of storage using the Minikube `standard` StorageClass.

The volume is mounted inside the application container at:

```text
/data
```

Todo records are stored in:

```text
/data/todos.json
```

Persistence was tested by deleting an application Pod and allowing the Deployment to create a replacement. Previously created Todo records remained available.

### Ingress

The NGINX Ingress Controller provides HTTP access through:

```text
http://todo.local
```

The local hostname was configured to resolve to the Minikube Ingress IP address.

The Ingress routes incoming requests to the Kubernetes Todo Service.

### Horizontal Pod Autoscaler

The Horizontal Pod Autoscaler monitors CPU utilization and adjusts the number of application replicas.

Configuration:

| Setting | Value |
|---|---:|
| Minimum replicas | 2 |
| Maximum replicas | 5 |
| Target CPU utilization | 50% |

Metrics Server provides the resource metrics required by the autoscaler.

## Deployment Environment

| Configuration | Value |
|---|---|
| Kubernetes distribution | Minikube |
| Cluster driver | Docker |
| Kubernetes version | v1.37.0 |
| Runtime | containerd |
| Application port | 3000 |
| Service type | ClusterIP |
| Ingress controller | NGINX |
| Storage request | 1 GiB |

## Running the Project

### Prerequisites

Install and configure:

- Docker Desktop
- WSL 2 with Ubuntu
- Minikube
- kubectl
- Node.js and npm (for local application development)

Ensure Docker Desktop is running before starting Minikube.

### 1. Clone the Repository

```bash
git clone git@github.com:Kolawole-Olaribigbe/devops-portfolio.git
```

Navigate into the application directory:

```bash
cd devops-portfolio/kubernetes-todo-app
```

### 2. Start Minikube

```bash
minikube start --driver=docker
```

Verify the cluster:

```bash
minikube status
minikube kubectl -- get nodes
```

### 3. Enable Required Add-ons

Enable the Ingress Controller:

```bash
minikube addons enable ingress
```

Enable Metrics Server:

```bash
minikube addons enable metrics-server
```

### 4. Create the Namespace

```bash
minikube kubectl -- create namespace kubernetes-todo
```

### 5. Create the Kubernetes Secret

Create your own local Secret manifest using the example:

```bash
cp k8s/secret.example.yaml k8s/secrets.yaml
```

Edit the new file and replace the placeholder with your own demonstration value.

Apply it:

```bash
minikube kubectl -- apply -f k8s/secrets.yaml
```

The actual `secrets.yaml` file is excluded from Git.

### 6. Apply the Kubernetes Manifests

Apply the ConfigMap:

```bash
minikube kubectl -- apply -f k8s/configmap.yaml
```

Apply persistent storage:

```bash
minikube kubectl -- apply -f k8s/pvc.yaml
```

Apply the Deployment:

```bash
minikube kubectl -- apply -f k8s/deployment.yaml
```

Apply the Service:

```bash
minikube kubectl -- apply -f k8s/service.yaml
```

Apply Ingress:

```bash
minikube kubectl -- apply -f k8s/ingress.yaml
```

Apply the Horizontal Pod Autoscaler:

```bash
minikube kubectl -- apply -f k8s/hpa.yaml
```

### 7. Configure Local Hostname Resolution

Retrieve the Minikube IP:

```bash
minikube ip
```

Add the returned IP address and hostname to the WSL hosts file:

```text
MINIKUBE_IP todo.local
```

The hostname can then be used to access the application from WSL.

### 8. Verify the Deployment

Check application Pods:

```bash
minikube kubectl -- get pods -n kubernetes-todo
```

Check all application resources:

```bash
minikube kubectl -- get all -n kubernetes-todo
```

Check the Ingress:

```bash
minikube kubectl -- get ingress -n kubernetes-todo
```

Check persistent storage:

```bash
minikube kubectl -- get pvc -n kubernetes-todo
```

Check the autoscaler:

```bash
minikube kubectl -- get hpa -n kubernetes-todo
```

## Testing and Verification

The following tests were completed successfully.

| Test | Result |
|---|---|
| Local Node.js API testing | Passed |
| Docker image build | Passed |
| Docker container testing | Passed |
| Docker Hub image publication | Passed |
| Kubernetes Deployment | Passed |
| Two application replicas | Passed |
| ConfigMap environment injection | Passed |
| Secret environment injection | Passed |
| ClusterIP Service connectivity | Passed |
| NGINX Ingress routing | Passed |
| Persistent storage provisioning | Passed |
| Todo persistence after Pod replacement | Passed |
| Metrics Server functionality | Passed |
| HPA scale-up under CPU load | Passed |
| HPA scale-down after CPU load stopped | Passed |

### Autoscaling Test

The application was subjected to CPU load to test the Horizontal Pod Autoscaler.

The number of replicas increased from two to five under load.

After the CPU load was stopped, the autoscaler returned the Deployment to its minimum of two replicas.

This demonstrated that Kubernetes could dynamically adjust application capacity based on observed CPU utilization.

### Persistence Test

A Todo record was created through the public Ingress endpoint.

An application Pod was deleted, and the Deployment automatically created a replacement.

The previously created Todo record remained available, confirming that the application was using persistent storage rather than relying solely on the container filesystem.

## Monitoring and Troubleshooting

Useful Kubernetes commands used during the project include:

### View Pod Status

```bash
minikube kubectl -- get pods -n kubernetes-todo
```

### Inspect Deployment

```bash
minikube kubectl -- describe deployment kubernetes-todo -n kubernetes-todo
```

### View Application Logs

```bash
minikube kubectl -- logs deployment/kubernetes-todo -n kubernetes-todo
```

### Monitor Node Resource Usage

```bash
minikube kubectl -- top nodes
```

### Monitor Pod Resource Usage

```bash
minikube kubectl -- top pods -n kubernetes-todo
```

### Inspect Horizontal Pod Autoscaler

```bash
minikube kubectl -- describe hpa kubernetes-todo-hpa -n kubernetes-todo
```

### Inspect Kubernetes Events

```bash
minikube kubectl -- get events -n kubernetes-todo --sort-by=.metadata.creationTimestamp
```

## Project Limitations and Production Considerations

This project was developed and tested using a local Minikube cluster. It demonstrates Kubernetes concepts but is not intended to represent a production-ready application.

Important considerations:

1. **Shared JSON storage:** Both application replicas mount the same ReadWriteOnce PersistentVolumeClaim. Although this worked in the single-node Minikube environment, concurrent writes to a shared JSON file are not safe for production. A database such as PostgreSQL would be a more appropriate shared data store.

2. **Local storage:** The Minikube storage provisioner uses local cluster storage. Production deployments require an appropriate persistent storage solution.

3. **Ingress and HTTPS:** The project uses local HTTP routing. HTTPS, TLS certificates, and a production domain have not been configured.

4. **Secrets management:** The included Secret is for demonstration. Production deployments should use secure secret-management solutions and encryption at rest.

5. **High availability:** A single-node Minikube cluster does not provide production-grade infrastructure availability.

These limitations identify opportunities for future improvements.

## Skills Demonstrated

- Docker image creation and containerization
- Publishing container images to Docker Hub
- Kubernetes cluster management with Minikube
- Kubernetes Deployments and replica management
- Service discovery and internal networking
- ConfigMaps and Secrets
- PersistentVolumes and PersistentVolumeClaims
- NGINX Ingress configuration
- Horizontal Pod Autoscaling
- Metrics Server installation and monitoring
- Kubernetes logs, events, and resource inspection
- Application persistence testing
- Container orchestration and troubleshooting

## Future Improvements

Potential enhancements include:

- Replace JSON-file storage with PostgreSQL.
- Add readiness and liveness probes.
- Configure HTTPS with TLS certificates.
- Add CI/CD automation for image builds and Kubernetes deployments.
- Deploy to a managed Kubernetes platform.
- Introduce monitoring dashboards and centralized logging.
- Implement stronger security controls and production secret management.

## Project Outcome

Successfully deployed a containerized Node.js Todo API to a Minikube Kubernetes cluster, with multiple replicas, internal Service networking, NGINX Ingress routing, ConfigMap and Secret configuration, persistent storage, and CPU-based horizontal autoscaling.

The project demonstrates practical understanding of Kubernetes container orchestration, application deployment, scaling, networking, storage, monitoring, and troubleshooting.

**Technologies:** Node.js · Express.js · Docker · Docker Hub · Kubernetes · Minikube · kubectl · NGINX Ingress · ConfigMaps · Secrets · PersistentVolumes · Metrics Server · Horizontal Pod Autoscaler
