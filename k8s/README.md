# Kubernetes Manifests (Exam Section 7)

Plain Kubernetes manifests that deploy the Flask AWS monitor using the image
pushed to Docker Hub. This is the non-Helm path; the Helm chart under
`../helmchart/` does the same thing in a templated, configurable way.

## Files

| File             | Purpose                                             |
|------------------|-----------------------------------------------------|
| `deployment.yaml`| Deployment (2 replicas) running the app on port 5001.|
| `service.yaml`   | `LoadBalancer` Service exposing port 5001.          |

## Prerequisites

1. A reachable cluster:
   ```bash
   kubectl get nodes
   ```
2. The AWS credentials Secret (NEVER committed — created directly):
   ```bash
   kubectl create secret generic aws-credentials \
     --from-literal=AWS_ACCESS_KEY_ID="<your-access-key>" \
     --from-literal=AWS_SECRET_ACCESS_KEY="<your-secret-key>"
   ```

## Deploy

```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Watch the rollout
kubectl get pods,svc -l app=flask-aws-monitor
```

## Access

```bash
# Get the external IP / hostname of the LoadBalancer service
kubectl get svc flask-aws-monitor

# Then open in a browser:
# http://<EXTERNAL-IP>:5001/
```

> If the image username differs from `ilanamogil`, update the `image:` field
> in `deployment.yaml` to match your Docker Hub account.
