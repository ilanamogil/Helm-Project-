# syntax=docker/dockerfile:1

# ---- Stage 1: build dependencies (bonus: multi-stage build) ----
FROM python:3.12-slim AS builder

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ---- Stage 2: runtime image ----
FROM python:3.12-slim

WORKDIR /app

# Copy only the installed packages from the builder stage
COPY --from=builder /install /usr/local

# Copy the application source
COPY app.py .

# AWS credentials are provided at runtime via environment variables:
#   AWS_ACCESS_KEY_ID
#   AWS_SECRET_ACCESS_KEY
# (never bake secrets into the image)

EXPOSE 5001

CMD ["python", "app.py"]
