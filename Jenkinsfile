// Jenkins Pipeline for CI/CD Integration (Exam Section 5)
//
// Stages:
//   1. Clone the Git repository
//   2. Run Linting and Security Scanning IN PARALLEL
//   3. Build the Docker image
//   4. Push the image to Docker Hub
//
// Credentials:
//   Create a Jenkins credential of type "Username with password"
//   with the ID "dockerhub" (Docker Hub user + access token/password).
//   `credentials('dockerhub')` exposes DOCKERHUB_USR and DOCKERHUB_PSW.
//
// Linting / scanning use real tools when available and fall back to a
// clearly-marked mock message otherwise (mocks are allowed; real tools
// are the bonus).

pipeline {
    agent any

    environment {
        DOCKERHUB  = credentials('dockerhub')
        IMAGE_NAME = "${DOCKERHUB_USR}/flask-aws-monitor"
        IMAGE_TAG  = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/ilanamogil/Helm-Project-.git'
            }
        }

        stage('Checks') {
            parallel {
                stage('Linting') {
                    steps {
                        sh '''
                            echo "===== Linting ====="

                            # Python lint (Flake8)
                            if command -v flake8 >/dev/null 2>&1; then
                                flake8 app.py || true
                            else
                                echo "[mock] flake8 not installed - skipping Python lint"
                            fi

                            # Dockerfile lint (Hadolint)
                            if command -v hadolint >/dev/null 2>&1; then
                                hadolint Dockerfile || true
                            else
                                echo "[mock] hadolint not installed - skipping Dockerfile lint"
                            fi

                            # Shell lint (ShellCheck)
                            if command -v shellcheck >/dev/null 2>&1; then
                                shellcheck *.sh 2>/dev/null || true
                            else
                                echo "[mock] shellcheck not installed - skipping shell lint"
                            fi
                        '''
                    }
                }

                stage('Security Scan') {
                    steps {
                        sh '''
                            echo "===== Security Scan ====="

                            # Python security (Bandit)
                            if command -v bandit >/dev/null 2>&1; then
                                bandit -r app.py || true
                            else
                                echo "[mock] bandit not installed - skipping Python security scan"
                            fi

                            # Filesystem / dependency scan (Trivy)
                            if command -v trivy >/dev/null 2>&1; then
                                trivy fs --exit-code 0 --no-progress . || true
                            else
                                echo "[mock] trivy not installed - skipping Trivy scan"
                            fi
                        '''
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG -t $IMAGE_NAME:latest .'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                sh '''
                    echo "$DOCKERHUB_PSW" | docker login -u "$DOCKERHUB_USR" --password-stdin
                    docker push $IMAGE_NAME:$IMAGE_TAG
                    docker push $IMAGE_NAME:latest
                    docker logout
                '''
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed! Check logs for details.'
        }
        always {
            sh 'docker logout || true'
        }
    }
}
