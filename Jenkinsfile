pipeline {
    agent any
    environment {
        DOCKER_COMPOSE = 'docker compose'
    }
    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/VitaliyKuz/TaskManager.git'
            }
        }
        stage('Build') {
            steps {
                script {
                    sh "${DOCKER_COMPOSE} --env-file .env build"
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    sh "${DOCKER_COMPOSE} --env-file .env up -d"
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    sh 'pytest'
                }
            }
        }
    }
    post {
        success {
            echo 'Deployment and Tests Completed Successfully!'
        }
        failure {
            echo 'Deployment or Tests Failed!'
        }
    }
}
