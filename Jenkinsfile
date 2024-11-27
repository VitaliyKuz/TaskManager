pipeline {
    agent any
    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/VitaliyKuz/TaskManager.git'
            }
        }
        stage('Build') {
            steps {
                script {
                    sh 'docker build -t task_manager_web .'
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    sh '''
                    docker-compose up -d
                    '''
                }
            }
        }
    }
    post {
        success {
            echo 'Pipeline executed successfully!'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
