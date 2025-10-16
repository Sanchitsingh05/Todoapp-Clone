pipeline {
    agent { label 'built-in' }  // Ensure this agent has Docker + Node + sonar-scanner installed

    environment {
        DOCKERHUB_USER = 'sanchit0305'
        IMAGE_NAME = 'kanbanboard'
        VERSION = "0.01-${BUILD_NUMBER}"
       // SONAR_PROJECT_KEY = 'kanbanboard'
        //SONARQUBE_TOKEN = credentials('SonarQube')
        //SONAR_HOST_URL = 'http://3.94.159.61:9000'
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
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
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
                build job: 'kanban-deploy-pipeline', parameters: [
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
