pipeline {
    agent any
    
    tools {
        maven 'Maven-3.8'  // Si vous utilisez Maven
        nodejs 'NodeJS-16' // Si vous utilisez NodeJS
    }
    
    environment {
        DOCKER_REGISTRY = 'votre-registry'
        AWS_REGION = 'eu-west-3'
        EKS_CLUSTER = 'votre-cluster'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', 
                    url: 'https://github.com/votre-repo/app.git',
                    credentialsId: 'github-credentials'
            }
        }
        
        stage('Build') {
            steps {
                sh 'docker build -t mon-app:${BUILD_NUMBER} .'
            }
        }
        
        stage('Test') {
            steps {
                sh 'docker run mon-app:${BUILD_NUMBER} npm test'
            }
        }
        
        stage('Scan Security') {
            steps {
                sh 'trivy image mon-app:${BUILD_NUMBER}'
            }
        }
        
        stage('Push to Registry') {
            steps {
                withAWS(region: 'eu-west-3', credentials: 'aws-credentials') {
                    sh '''
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${DOCKER_REGISTRY}
                        docker tag mon-app:${BUILD_NUMBER} ${DOCKER_REGISTRY}/mon-app:${BUILD_NUMBER}
                        docker push ${DOCKER_REGISTRY}/mon-app:${BUILD_NUMBER}
                    '''
                }
            }
        }
        
        stage('Deploy to K8s') {
            steps {
                withKubeConfig([credentialsId: 'kubeconfig', clusterName: 'eks-cluster']) {
                    sh '''
                        kubectl set image deployment/mon-app mon-app=${DOCKER_REGISTRY}/mon-app:${BUILD_NUMBER} -n production
                        kubectl rollout status deployment/mon-app -n production
                    '''
                }
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline réussi !'
            slackSend(color: 'good', message: "Build ${BUILD_NUMBER} réussi")
        }
        failure {
            echo 'Pipeline échoué !'
            slackSend(color: 'danger', message: "Build ${BUILD_NUMBER} échoué")
        }
    }
}
