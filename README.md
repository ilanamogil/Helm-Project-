# Flask AWS Monitor — Code Repository

This repository holds the application code, container definition, CI/CD
pipeline and Helm chart for the End-to-End DevOps exam.

## What this repo contains

| Path           | Purpose                                                       |
|----------------|---------------------------------------------------------------|
| `app.py`       | Flask application that lists AWS EC2 instances, VPCs, Load Balancers and AMIs in `us-east-1`. |
| `requirements.txt` | Python dependencies (`flask`, `boto3`).                   |
| `Dockerfile`   | Multi-stage build that packages the Flask app and exposes port `5001`. |
| `helmchart/`   | Helm chart that deploys the app to Kubernetes (see `helmchart/README.md`). |

## What has been implemented

- **Section 3 — Dockerizing the application**: the AWS monitoring Flask app
  is packaged with a multi-stage `Dockerfile` (bonus) and reads the AWS
  credentials from the `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`
  environment variables. The app is exposed on port `5001`.
- **Section 7 / Helm** — a configurable Helm chart under `helmchart/`.

## Known issues / blockers

- **Section 4 bug (intentional at this stage)**: `app.py` references the
  variables `vpcs`, `lbs` and `amis` without ever calling the matching
  `describe_*` APIs, so the page raises a `NameError`. As required by the
  exam, the bug is left in place in the dockerize stage and fixed in
  Section 4 on a dedicated feature branch.

## How to build and run

```bash
# Build the image
docker build -t flask-aws-monitor:latest .

# Run the container (credentials injected at runtime)
docker run -d -p 5001:5001 \
  -e AWS_ACCESS_KEY_ID="<your-access-key>" \
  -e AWS_SECRET_ACCESS_KEY="<your-secret-key>" \
  flask-aws-monitor:latest

# Open the app
# http://<host>:5001/
```

> Credentials are **never** committed or baked into the image. Provide them
> at runtime via environment variables (or, on Kubernetes, via the Helm
> `aws-values.yaml` file which is git-ignored).

## Git workflow

This project follows Git Flow:

- `main` — stable, production-ready code (protected; merges via PR only).
- `dev` — integration branch.
- `feature/*` — one branch per exam section, merged into `dev`.
