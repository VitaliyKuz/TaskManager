pipeline {
    agent any
    environment {
        AWS_REGION = 'eu-central-1' // Вкажіть ваш AWS регіон
        AWS_CREDENTIALS = 'AWS_Credentials' // Назва AWS credentials у Jenkins
    }
    stages {
        stage('Clone Repository') {
            steps {
                echo 'Cloning Repository...'
                git branch: 'main', url: 'https://github.com/VitaliyKuz/TaskManager.git'
            }
        }

        stage('Synchronize System Time') {
            steps {
                echo 'Synchronizing system time...'
                sh '''
                if command -v ntpdate &> /dev/null
                then
                    echo "Synchronizing time with NTP server..."
                    ntpdate -u pool.ntp.org || echo "Time synchronization not required or already done."
                else
                    echo "Installing NTP tools..."
                    apt-get update && apt-get install -y ntpdate
                    ntpdate -u pool.ntp.org || echo "Time synchronization not required or already done."
                fi
                '''
            }
        }

        stage('Install AWS CLI') {
            steps {
                echo 'Installing AWS CLI...'
                sh '''
                if ! command -v aws &> /dev/null
                then
                    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                    unzip -o awscliv2.zip
                    ./aws/install -i /tmp/.aws-cli -b /tmp/.local/bin
                    rm -rf awscliv2.zip aws/
                    export PATH=/tmp/.local/bin:$PATH
                    echo "AWS CLI installed successfully."
                else
                    echo "AWS CLI is already installed."
                fi
                '''
            }
        }

        stage('Verify AWS Access') {
            steps {
                echo 'Verifying AWS Access...'
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: AWS_CREDENTIALS]]) {
                    sh '''
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                    export PATH=/tmp/.local/bin:$PATH
                    aws sts get-caller-identity --region $AWS_REGION
                    '''
                }
            }
        }
    }
    post {
        success {
            echo 'AWS CLI and credentials verified successfully.'
        }
        failure {
            echo 'Pipeline failed. Please check the logs for more details.'
        }
    }
}
