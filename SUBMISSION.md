# End-to-End DevOps Exam — Submission

**Student:** Ilana Mogil
**GitHub:** https://github.com/ilanamogil

This document maps every section of the exam to what was implemented and where.

## Repositories

| Repo            | URL                                                | Contents                                  |
|-----------------|----------------------------------------------------|-------------------------------------------|
| Code            | https://github.com/ilanamogil/Helm-Project-        | App, Dockerfile, Jenkinsfile, Azure pipeline, Helm chart, k8s manifests |
| Terraform       | https://github.com/ilanamogil/terraform-exam-      | EC2 "builder" provisioning + Docker bootstrap |
| GitOps          | https://github.com/ilanamogil/gitops-repo          | ArgoCD ApplicationSet + dev/qa/prd values |
| Shared Library  | (optional / bonus — not submitted)                 | —                                         |

## Git workflow

Git Flow is used in the code and terraform repos:

- `main` — stable, merged via Pull Request only (no direct pushes)
- `dev` — integration branch
- `feature/*` — one branch per section, merged into `dev`

## Section-by-section status

| Exam section                    | Status | Where                                   |
|---------------------------------|--------|-----------------------------------------|
| Git Repository Setup            | done   | branches + merges in all repos          |
| Terraform Task                  | done   | `terraform-exam-` repo                   |
| Dockerizing the Application     | done   | `Dockerfile` (multi-stage, bonus)        |
| Python code                     | done   | `app.py` (boto3 AWS resource listing)    |
| Debugging and Fixing a Bug      | done   | Section 4 — added `describe_vpcs` / `describe_load_balancers` / `describe_images` |
| CI/CD Integration with Jenkins  | done   | `Jenkinsfile` (parallel lint/scan, build, push) |
| Azure DevOps pipeline (5.1)     | done   | `azure-pipelines.yml`                    |
| Kubernetes Deployment           | done   | `k8s/deployment.yaml`, `k8s/service.yaml`|
| Helm                            | done   | `helmchart/`                             |
| ArgoCD (GitOps)                 | done   | `gitops-repo` ApplicationSet             |

## How to run each part

### Terraform (provision the builder EC2)

```bash
cd terraform-exam-
terraform init
terraform apply -var 'allowed_ssh_cidr=YOUR.IP/32'
terraform output ssh_command
```

### Docker (build & run the app)

```bash
docker build -t flask-aws-monitor .
docker run -d -p 5001:5001 \
  -e AWS_ACCESS_KEY_ID=... -e AWS_SECRET_ACCESS_KEY=... \
  flask-aws-monitor
# open http://<host>:5001/
```

### Jenkins / Azure CI

- Jenkins credential `dockerhub` (Username + password) → builds and pushes the image.
- Azure: secret variables `DOCKERHUB_USERNAME` / `DOCKERHUB_PASSWORD`.

### Kubernetes (plain manifests)

```bash
kubectl create secret generic aws-credentials \
  --from-literal=AWS_ACCESS_KEY_ID=... --from-literal=AWS_SECRET_ACCESS_KEY=...
kubectl apply -f k8s/
```

### Helm

```bash
helm install flask-monitor ./helmchart -f aws-values.yaml
```

### ArgoCD (GitOps)

```bash
kubectl apply -f applicationsets/flask-applicationset.yaml
kubectl get applications -n argocd
```

## Notes & blockers

- AWS credentials are never committed; they are injected at runtime via
  environment variables, Kubernetes Secrets, or a git-ignored `aws-values.yaml`.
- Linting/security scanning in CI run real tools when present and fall back to
  clearly-marked mock messages otherwise (mocks are allowed; real tools = bonus).
- The Docker Hub image name must match the account used; confirm it is consistent
  across `helmchart/values.yaml`, `k8s/deployment.yaml` and the GitOps env values.
