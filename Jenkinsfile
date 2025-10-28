pipeline {
    agent { label 'deploy-node' }  // Ensure this agent has Docker + Node + sonar-scanner installed

    environment {
        DOCKERHUB_USER = 'sanchit0305'
        IMAGE_NAME = 'todoapp'
        VERSION = "openshift"
       // SONAR_PROJECT_KEY = 'kanbanboard'
       // SONARQUBE_TOKEN = credentials('SonarQube')
       // SONAR_HOST_URL = 'http://3.81.151.108:9000/'
        
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🔧 Building Docker image..."
                sh """
                    docker build -t $DOCKERHUB_USER/$IMAGE_NAME:$VERSION .
                """
            }
        }

        stage('Login to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-pat', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh """
                        echo "$PASS" | docker login -u "$USER" --password-stdin
                    """
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                sh """
                    docker push $DOCKERHUB_USER/$IMAGE_NAME:$VERSION
                """
            }
        }

        stage('Trigger Deployment Pipeline') {
            steps {
                echo "✅ Image pushed successfully! Triggering deployment..."
                build job: 'kanban-deploy-openshift-cd', parameters: [
                    string(name: 'IMAGE_TAG', value: "${VERSION}")
                ]
            }
        }
    }

    post {
        failure {
            echo "❌ Build failed. Deployment not triggered."
        }
    }
}
