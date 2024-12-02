pipeline {
    agent any
    environment {
        AWS_REGION = 'us-east-1'  // Замініть на ваш регіон AWS
        AWS_CREDENTIALS = 'AWS_Credentials'  // Ідентифікатор із Jenkins
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
    }
}
