pipeline {
    agent {
        docker {
            image 'python:3.12-slim' // Використовується Python з усіма основними утилітами
            args '-u root' // Виконання команд як root
        }
    }
    environment {
        AWS_REGION = 'eu-central-1'
        AWS_CREDENTIALS = 'AWS_Credentials'
        DO_TOKEN = 'DO_Token'
        TERRAFORM_DIR = 'terraform'
        CUSTOM_BIN = '/var/jenkins_home/bin'
        PATH = '/var/jenkins_home/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
    }
    stages {
        stage('Clone Repository') {
            steps {
                echo 'Cloning Repository...'
                git branch: 'main', url: 'https://github.com/VitaliyKuz/TaskManager.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Installing dependencies...'
                sh '''
                apt-get update && apt-get install -y curl unzip
                '''
            }
        }

        stage('Check System Time') {
            steps {
                echo 'Checking system time...'
                sh '''
                echo "Current system time:"
                date
                '''
            }
        }

        stage('Install Terraform') {
            steps {
                echo 'Installing Terraform...'
                sh '''
                mkdir -p $CUSTOM_BIN
                curl -o $CUSTOM_BIN/terraform.zip https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip
                unzip -o $CUSTOM_BIN/terraform.zip -d $CUSTOM_BIN/
                rm -f $CUSTOM_BIN/terraform.zip
                chmod +x $CUSTOM_BIN/terraform
                $CUSTOM_BIN/terraform --version
                '''
            }
        }

        stage('Initialize Terraform') {
            steps {
                echo 'Initializing Terraform...'
                dir("${TERRAFORM_DIR}") {
                    sh '''
                    terraform init || exit 1
                    '''
                }
            }
        }

        stage('Apply Terraform') {
            steps {
                echo 'Applying Terraform configuration for AWS and DigitalOcean...'
                dir("${TERRAFORM_DIR}") {
                    withCredentials([
                        [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: AWS_CREDENTIALS],
                        string(credentialsId: 'DO_Token', variable: 'DO_TOKEN')
                    ]) {
                        sh '''
                        terraform apply \
                            -var="aws_access_key=$AWS_ACCESS_KEY_ID" \
                            -var="aws_secret_key=$AWS_SECRET_ACCESS_KEY" \
                            -var="do_token=$DO_TOKEN" \
                            -auto-approve || exit 1
                        '''
                    }
                }
            }
        }

        stage('Validate Terraform Outputs') {
            steps {
                echo 'Validating Terraform Outputs...'
                dir("${TERRAFORM_DIR}") {
                    sh '''
                    terraform output || exit 1
                    '''
                }
            }
        }
    }
    post {
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed. Please check the logs for details.'
        }
    }
}
