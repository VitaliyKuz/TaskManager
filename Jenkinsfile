pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "taskmanager_image"
        DOCKER_CONTAINER = "taskmanager_container"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/VitaliyKuz/TaskManager.git'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t ${DOCKER_IMAGE} .'
                }
            }
        }
        
        stage('Run Docker Container') {
            steps {
                script {
                    sh 'docker stop ${DOCKER_CONTAINER} || true'
                    sh 'docker rm ${DOCKER_CONTAINER} || true'
                    sh 'docker run -d --name ${DOCKER_CONTAINER} -p 5000:5000 ${DOCKER_IMAGE}'
                }
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    sh 'docker exec ${DOCKER_CONTAINER} pytest tests/'
                }
            }
        }
        
        stage('Deploy') {
            steps {
                echo 'Deployment is complete!'
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution complete.'
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
