pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'votre-registry'
        AWS_REGION = 'eu-west-3'
        EKS_CLUSTER = 'votre-cluster'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo "Code récupéré avec succès"
            }
        }
        
        stage('Vérification des outils') {
            steps {
                sh '''
                    echo "=== Vérification des outils ==="
                    docker --version
                    kubectl version --client
                    git --version
                    aws --version
                    terraform version
                    helm version
                    trivy --version
                '''
            }
        }
        
        stage('Build Docker Image') {
            steps {
                sh '''
                    # Créer un Dockerfile de test si pas existant
                    if [ ! -f Dockerfile ]; then
                        cat > Dockerfile << 'DOCKEREOF'
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/
EXPOSE 80
DOCKEREOF
                        echo "<h1>Build ${BUILD_NUMBER}</h1>" > index.html
                    fi
                    
                    docker build -t mon-app:${BUILD_NUMBER} .
                '''
            }
        }
        
        stage('Test') {
            steps {
                sh '''
                    docker run --rm -d -p 8081:80 --name test-app mon-app:${BUILD_NUMBER}
                    sleep 2
                    curl -s http://localhost:8081 | head -5
                    docker stop test-app
                '''
            }
        }
        
        stage('Security Scan') {
            steps {
                sh '''
                    trivy image --severity HIGH,CRITICAL --no-progress mon-app:${BUILD_NUMBER} || true
                '''
            }
        }
        
        stage('Push to Registry') {
            steps {
                sh '''
                    echo "Pushing to registry..."
                    # Décommenter quand vous avez un registry
                    # docker tag mon-app:${BUILD_NUMBER} ${DOCKER_REGISTRY}/mon-app:${BUILD_NUMBER}
                    # docker push ${DOCKER_REGISTRY}/mon-app:${BUILD_NUMBER}
                '''
            }
        }
        
        stage('Deploy to K8s') {
            steps {
                sh '''
                    echo "Deploying to Kubernetes..."
                    kubectl get nodes
                    # kubectl set image deployment/mon-app mon-app=${DOCKER_REGISTRY}/mon-app:${BUILD_NUMBER} -n production
                '''
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo "✅ Pipeline réussi ! Build ${BUILD_NUMBER}"
        }
        failure {
            echo "❌ Pipeline échoué ! Build ${BUILD_NUMBER}"
        }
    }
}