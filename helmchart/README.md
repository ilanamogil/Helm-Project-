# Helm Chart — flask-aws-monitor (Exam Section 7)

Helm chart that deploys the Flask AWS monitor to Kubernetes. It is the
templated, configurable equivalent of the plain manifests in `../k8s/`.

## What this chart deploys

| Template                  | What it creates                                           |
|---------------------------|-----------------------------------------------------------|
| `templates/deployment.yaml` | Deployment — configurable replicas, image, resources    |
| `templates/service.yaml`    | Service — ClusterIP or LoadBalancer on port 5001        |
| `templates/ingress.yaml`    | Ingress — optional, nginx class, configurable host      |
| `templates/secret.yaml`     | Secret — AWS credentials (populated from `aws-values.yaml`) |

## Configurable values

| Key               | Default                        | Purpose                        |
|-------------------|--------------------------------|--------------------------------|
| `replicaCount`    | `2`                            | Number of pod replicas         |
| `image.repository`| `ilanamogil/flask-aws-monitor` | Docker Hub image               |
| `image.tag`       | `v1`                           | Image tag                      |
| `service.type`    | `ClusterIP`                    | `ClusterIP` or `LoadBalancer`  |
| `service.port`    | `5001`                         | Exposed port                   |
| `ingress.enabled` | `true`                         | Toggle the Ingress resource     |
| `ingress.host`    | `flask-monitor.local`          | Hostname for the Ingress rule  |
| `resources`       | see `values.yaml`              | CPU/memory requests and limits |
| `aws.region`      | `""`                           | AWS region (injected at deploy)|
| `aws.accessKeyId` | `""`                           | AWS key (injected at deploy)   |
| `aws.secretAccessKey` | `""`                       | AWS secret (injected at deploy)|

## Prerequisites

- Helm 3
- A reachable Kubernetes cluster (`kubectl get nodes`)
- (For Ingress) an nginx ingress controller

## Install

AWS credentials are never committed. Put them in a gitignored file and merge
at install time:

```bash
# Create aws-values.yaml locally (already in .gitignore):
cat > aws-values.yaml <<'EOF'
aws:
  region: us-east-1
  accessKeyId: "AKIAIOSFODNN7EXAMPLE"
  secretAccessKey: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
EOF

# Install (merges chart defaults with your AWS overrides)
helm install flask-monitor ./helmchart -f aws-values.yaml

# Verify
kubectl get pods,svc,ingress -l app=flask-monitor-flask-aws-monitor
```

## Upgrade

```bash
helm upgrade flask-monitor ./helmchart -f aws-values.yaml --set image.tag=<new-tag>
```

## Uninstall

```bash
helm uninstall flask-monitor
```

## Notes

- AWS credentials are stored in a Kubernetes `Secret` (`<release>-aws-credentials`)
  created by `templates/secret.yaml` from the values you pass at deploy time.
  They are never baked into the image or committed to git.
- To use a LoadBalancer instead of ClusterIP: `--set service.type=LoadBalancer`
- To disable the Ingress: `--set ingress.enabled=false`
