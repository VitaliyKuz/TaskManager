pipeline {
    agent any
    environment {
        AWS_REGION = 'us-east-1'  // Замініть на ваш AWS регіон
        AWS_CREDENTIALS = 'AWS_Credentials'  // Ідентифікатор AWS Credentials у Jenkins
    }
    stages {
        stage('Setup Terraform') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: AWS_CREDENTIALS]]) {
                    sh '''
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                    terraform init
                    '''
                }
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
