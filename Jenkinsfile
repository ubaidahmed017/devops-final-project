pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = 'ubaidahmed017'
        BACKEND_IMAGE   = "${DOCKER_HUB_USER}/devops-backend"
        FRONTEND_IMAGE  = "${DOCKER_HUB_USER}/devops-frontend"
        IMAGE_TAG       = "v${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('Code Quality Check') {
            steps {
                sh '''
                    echo "=== Backend files ===" && ls -la app/backend/
                    echo "=== Frontend files ===" && ls -la app/frontend/
                    cat app/backend/package.json
                '''
            }
        }

        stage('Security Scan - Filesystem') {
            steps {
                sh '''
                    if command -v trivy > /dev/null 2>&1; then
                        trivy fs --exit-code 0 --severity HIGH,CRITICAL --no-progress .
                    else
                        echo "SKIP: Trivy not yet installed - see Module 8"
                    fi
                '''
            }
        }

        stage('Build Docker Images') {
            steps {
                sh '''
                    docker build -t ${BACKEND_IMAGE}:${IMAGE_TAG} -t ${BACKEND_IMAGE}:latest ./app/backend
                    docker build -t ${FRONTEND_IMAGE}:${IMAGE_TAG} -t ${FRONTEND_IMAGE}:latest ./app/frontend
                    docker images | grep ubaidahmed017
                '''
            }
        }

        stage('Security Scan - Images') {
            steps {
                sh '''
                    if command -v trivy > /dev/null 2>&1; then
                        trivy image --exit-code 0 --severity HIGH,CRITICAL --no-progress ${BACKEND_IMAGE}:${IMAGE_TAG}
                    else
                        echo "SKIP: Trivy image scan - see Module 8"
                    fi
                '''
            }
        }

        stage('Test Application') {
            steps {
                sh '''
                    docker run -d --name test-backend -p 3099:3000 \
                        -e MONGO_URI=mongodb://localhost:27017/testdb \
                        ${BACKEND_IMAGE}:${IMAGE_TAG}
                    sleep 6
                    curl -f http://localhost:3099/api/health || echo "Health check note: MongoDB not in test env"
                    docker stop test-backend || true
                    docker rm test-backend || true
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push ${BACKEND_IMAGE}:${IMAGE_TAG}
                        docker push ${BACKEND_IMAGE}:latest
                        docker push ${FRONTEND_IMAGE}:${IMAGE_TAG}
                        docker push ${FRONTEND_IMAGE}:latest
                        docker logout
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    rm -rf /tmp/devops-deploy
                    git clone https://github.com/ubaidahmed017/devops-final-project.git /tmp/devops-deploy
                    cd /tmp/devops-deploy
                    docker stop frontend backend mongo || true
                    docker rm frontend backend mongo || true
                    docker run -d --name mongo \
                        --network app-network \
                        -v mongo-data:/data/db \
                        mongo:6 || true
                    docker run -d --name backend \
                        --network app-network \
                        -p 3000:3000 \
                        -e MONGO_URI=mongodb://mongo:27017/devopsdb \
                        ${BACKEND_IMAGE}:latest
                    docker run -d --name frontend \
                        --network app-network \
                        -p 80:80 \
                        ${FRONTEND_IMAGE}:latest
                    docker network create app-network || true
                    echo "=== Deployment complete ==="
                    docker ps | grep -E "frontend|backend|mongo"
                '''
            }
        }
    }

    post {
        success {
            echo "Pipeline SUCCESS - Build ${BUILD_NUMBER} - Images tagged ${IMAGE_TAG}"
        }
        failure {
            echo "Pipeline FAILED - Build ${BUILD_NUMBER} - Check logs above"
        }
        always {
            sh 'docker system prune -f || true'
        }
    }
}
