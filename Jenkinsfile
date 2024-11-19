pipeline {
    agent any
    environment {
        DOCKER_IMAGE = 'task_manager_web'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Cloning repository...'
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo 'Building Docker images...'
                sh 'docker compose build'
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
                sh 'docker compose run web pytest'
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying application...'
                sh 'docker compose down && docker compose up -d'
            }
        }
    }
}
