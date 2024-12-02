pipeline {
    agent any
    environment {
        AWS_REGION = 'eu-central-1' // Змініть на ваш регіон
        AWS_CREDENTIALS = 'AWS_Credentials' // Назва AWS credentials у Jenkins
    }
    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/VitaliyKuz/TaskManager.git'
            }
        }
        stage('Verify AWS Access') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: AWS_CREDENTIALS]]) {
                    sh '''
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                    aws sts get-caller-identity --region $AWS_REGION
                    '''
                }
            }
        }
    }
}
