# Kubernetes Local Learning Environment

## Learning Objectives
- Understand Kubernetes architecture and concepts
- Practice deploying applications with manifests
- Learn about pods, services, deployments, and ingress
- Experience Kubernetes cluster management

## Prerequisites

Install required tools based on your choice:

### Option 1: Kind (Recommended for Learning)
```bash
# Install Kind
# macOS
brew install kind

# Linux
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

### Option 2: Minikube
```bash
# Install Minikube
# macOS
brew install minikube

# Linux
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

## Setup Instructions

### Using Kind

1. **Create the cluster**:
   ```bash
   kind create cluster --config=kind-cluster.yaml
   ```

2. **Install NGINX Ingress Controller**:
   ```bash
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
   
   # Wait for ingress controller to be ready
   kubectl wait --namespace ingress-nginx \
     --for=condition=ready pod \
     --selector=app.kubernetes.io/component=controller \
     --timeout=300s
   ```

3. **Deploy applications**:
   ```bash
   kubectl apply -f web-app-deployment.yaml
   kubectl apply -f api-deployment.yaml
   kubectl apply -f ingress.yaml
   ```

4. **Add hosts (for host-based routing)**:
   ```bash
   echo "127.0.0.1 web.local api.local" | sudo tee -a /etc/hosts
   ```

### Using Minikube

1. **Start minikube**:
   ```bash
   minikube start --nodes 3
   ```

2. **Enable ingress**:
   ```bash
   minikube addons enable ingress
   ```

3. **Deploy applications** (same as Kind steps 3-4)

## Access Applications

- **Web App**: http://localhost
- **API**: http://localhost/api
- **Host-based**: http://web.local, http://api.local

## Key Kubernetes Concepts

### Pods
- Smallest deployable unit
- Contains one or more containers
- Shared network and storage

### Deployments
- Manages ReplicaSets
- Declarative updates
- Rolling updates and rollbacks

### Services
- Stable network endpoint
- Load balancing across pods
- Service discovery

### Ingress
- HTTP/HTTPS routing
- SSL termination
- Host and path-based routing

## Essential Commands

### Cluster Management
```bash
# View cluster info
kubectl cluster-info

# View nodes
kubectl get nodes

# View all resources
kubectl get all
```

### Pod Management
```bash
# List pods
kubectl get pods

# Describe pod
kubectl describe pod <pod-name>

# View pod logs
kubectl logs <pod-name>

# Execute command in pod
kubectl exec -it <pod-name> -- /bin/sh
```

### Deployment Management
```bash
# List deployments
kubectl get deployments

# Scale deployment
kubectl scale deployment web-app --replicas=5

# Update deployment image
kubectl set image deployment/web-app web-app=nginx:1.21

# View rollout status
kubectl rollout status deployment/web-app

# Rollback deployment
kubectl rollout undo deployment/web-app
```

### Service and Ingress
```bash
# List services
kubectl get services

# List ingress
kubectl get ingress

# Port forward to service
kubectl port-forward service/web-app-service 8080:80
```

## Practice Exercises

### 1. Scaling Applications
```bash
# Scale web app to 5 replicas
kubectl scale deployment web-app --replicas=5

# Watch pods being created
kubectl get pods -w

# Scale back down
kubectl scale deployment web-app --replicas=2
```

### 2. Rolling Updates
```bash
# Update nginx image
kubectl set image deployment/web-app web-app=nginx:1.21-alpine

# Watch the rollout
kubectl rollout status deployment/web-app

# Check rollout history
kubectl rollout history deployment/web-app
```

### 3. Configuration Management
```bash
# View ConfigMap
kubectl get configmap web-content -o yaml

# Edit ConfigMap
kubectl edit configmap web-content

# Restart deployment to pick up changes
kubectl rollout restart deployment/web-app
```

### 4. Secrets Management
```bash
# View secret (base64 encoded)
kubectl get secret api-secret -o yaml

# Decode secret
kubectl get secret api-secret -o jsonpath="{.data.token}" | base64 --decode
```

## Debugging and Troubleshooting

### Common Issues
```bash
# Check pod events
kubectl describe pod <pod-name>

# View recent events
kubectl get events --sort-by=.metadata.creationTimestamp

# Check node resources
kubectl top nodes

# Check pod resources
kubectl top pods
```

### Networking Issues
```bash
# Test service connectivity
kubectl run test-pod --image=busybox --rm -it --restart=Never -- wget -O- web-app-service

# Check ingress controller logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
```

## Advanced Topics

### Resource Quotas
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
```

### Network Policies
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

### Persistent Volumes
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: web-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

## Monitoring and Observability

### Built-in Dashboard (Minikube)
```bash
minikube dashboard
```

### Metrics Server
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

## Cleanup

### Kind
```bash
kind delete cluster --name learning-cluster
```

### Minikube
```bash
minikube delete
```

### Remove hosts entries
```bash
sudo sed -i '/web.local api.local/d' /etc/hosts
```

## Next Steps
- Learn Helm for package management
- Explore operators and CRDs
- Study production deployment patterns
- Practice with different storage solutions
- Implement monitoring with Prometheus
- Learn about service mesh (Istio, Linkerd)