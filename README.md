# Flask AWS Monitor — Helm Chart

A Helm chart that packages and deploys the Flask AWS monitoring application
to a Kubernetes cluster.

## Repository layout

```
.
├── app.py                  # Flask + Prometheus metrics application
├── Dockerfile              # Container image definition
├── requirements.txt        # Python dependencies
├── helmchart/
│   ├── Chart.yaml
│   ├── values.yaml         # Default configuration
│   ├── aws-values.yaml.example   # Template for local AWS credentials
│   └── templates/
│       ├── deployment.yaml
│       ├── service.yaml
│       └── ingress.yaml    # Optional ingress (bonus)
└── .gitignore              # Keeps aws-values.yaml out of git
```

## Prerequisites

- Docker Desktop with Kubernetes enabled (or any Kubernetes cluster)
- `kubectl` (bundled with Docker Desktop)
- `helm` 3.x
- A Docker Hub account

Verify the toolchain:

```
docker --version
kubectl version --client
kubectl get nodes
helm version
```

## 1. Build and push the Docker image

From the project root:

```
docker build -t alonamog/flask-aws-monitor:latest .
docker login
docker push alonamog/flask-aws-monitor:latest
```

## 2. Configure AWS credentials (only if the app actually needs them)

Copy the template, then fill in real values locally:

```
cp helmchart/aws-values.yaml.example helmchart/aws-values.yaml
```

Edit `helmchart/aws-values.yaml`. This file is gitignored and must never be
committed.

## 3. Install the chart

Without AWS credentials:

```
helm install flask-monitor ./helmchart
```

With AWS credentials merged in at install time:

```
helm install flask-monitor ./helmchart -f helmchart/aws-values.yaml
```

## 4. Verify the deployment

```
kubectl get pods,svc
```

Expected: pods in `Running` state and a service exposing port `5001`.

## 5. Access the application

Forward the service to your local machine:

```
kubectl port-forward svc/flask-monitor-flask-aws-monitor 5001:5001
```

Then open:

- `http://localhost:5001/` — sample counters page
- `http://localhost:5001/metrics` — Prometheus metrics endpoint

If the service type is `LoadBalancer`, get the external IP with
`kubectl get svc` and visit `http://<external-ip>:5001/` instead.

## 6. Upgrade and rollback

After editing `values.yaml`:

```
helm upgrade flask-monitor ./helmchart
helm history flask-monitor
helm rollback flask-monitor <revision>
```

## 7. Uninstall

```
helm uninstall flask-monitor
```
