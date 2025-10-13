pipeline {
    agent { label 'kube-node' }  // Ensure this agent has Docker + Node + sonar-scanner installed

    environment {
        DOCKERHUB_USER = 'sanchit0305'
        IMAGE_NAME = 'kanbanboard'
        VERSION = "0.01-${BUILD_NUMBER}"
        SONAR_PROJECT_KEY = 'kanbanboard'
        SONAR_SCANNER_HOME = tool 'SonarScanner'  // Define this in Jenkins Global Tool Config
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
                    withSonarQubeEnv('SonarQube') {   // SonarQube server name from Jenkins config
                        sh """
                        ${SONAR_SCANNER_HOME}/bin/sonar-scanner \
                          -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                          -Dsonar.sources=. \
                          -Dsonar.host.url=$SONAR_HOST_URL \
                          -Dsonar.login=$SONAR_AUTH_TOKEN
                        """
                    }
                }
            }
        }

        stage('Wait for Quality Gate') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true  // Fail pipeline if quality gate fails
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🔧 Building Docker image..."
                sh '''
                    docker build -t $DOCKERHUB_USER/$IMAGE_NAME:$VERSION .
                '''
            }
        }

        stage('Login to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-pat', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh '''
                        echo "$PASS" | docker login -u "$USER" --password-stdin
                    '''
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                sh '''
                    docker push $DOCKERHUB_USER/$IMAGE_NAME:$VERSION
                '''
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
