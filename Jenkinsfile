pipeline {
    agent { label 'built-in' }  // Ensure this agent has Docker + Node + sonar-scanner installed

    environment {
        DOCKERHUB_USER = 'sanchit0305'
        IMAGE_NAME = 'kanbanboard'
        VERSION = "0.01-${BUILD_NUMBER}"
        SONAR_PROJECT_KEY = 'kanbanboard'
        SONARQUBE_TOKEN = credentials('SonarQube')
        SONAR_HOST_URL = 'http://3.94.159.61:9000'
        
// ==== ADDED: AWS credentials & region (available to all stages) ====
        AWS_ACCESS_KEY_ID     = credentials('AKIA3FLDYXH3XCXCH7QE')       // Secret Text in Jenkins
        AWS_SECRET_ACCESS_KEY = credentials('7GKeGBD33EAYnWCsj9tWUHN9ESNDQjBWFdZRgPBH')   // Secret Text in Jenkins
        AWS_DEFAULT_REGION     = 'ap-south-1'                           // set your AWS region
        AWS_REGION             = 'ap-south-1'                           // some tools read this name
        // ================================================================
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('SonarQube Scan') {
            steps {
                script {
                    // Must match the *Name* under "Manage Jenkins" -> "Configure System" -> "SonarQube Servers"
                    withSonarQubeEnv('SonarQube') {
                        sh """
                            sonar-scanner \
                                -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                                -Dsonar.sources=. \
                                -Dsonar.projectVersion=${VERSION} \
                                -Dsonar.host.url=${SONAR_HOST_URL} \
                                -Dsonar.login=$SONARQUBE_TOKEN \
                        """
                    }
                }
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
