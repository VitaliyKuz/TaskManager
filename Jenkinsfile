pipeline {
    agent any
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

        stage('Install Dependencies Locally') {
            steps {
                echo 'Installing dependencies locally...'
                sh '''
                mkdir -p $CUSTOM_BIN
                if [ ! -f "$CUSTOM_BIN/unzip" ]; then
                    echo "Downloading unzip..."
                    curl -L -o $CUSTOM_BIN/unzip https://github.com/nih-at/libzip/releases/download/v1.9.2/unzip
                    chmod +x $CUSTOM_BIN/unzip
                fi
                echo "Dependencies installed locally."
                '''
            }
        }

        stage('Check and Sync System Time') {
            steps {
                echo 'Checking system time...'
                sh '''
                echo "Current system time:"
                date
                echo "Checking network connectivity..."
                curl -I https://www.google.com || echo "Network unreachable."
                '''
            }
        }

        stage('Install Terraform') {
            steps {
                echo 'Installing Terraform locally...'
                sh '''
                mkdir -p $CUSTOM_BIN
                if [ ! -f "$CUSTOM_BIN/terraform" ]; then
                    echo "Downloading Terraform..."
                    curl -o $CUSTOM_BIN/terraform.zip https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip
                    $CUSTOM_BIN/unzip $CUSTOM_BIN/terraform.zip -d $CUSTOM_BIN/
                    rm -f $CUSTOM_BIN/terraform.zip
                    chmod +x $CUSTOM_BIN/terraform
                fi
                $CUSTOM_BIN/terraform --version
                '''
            }
        }

        stage('Initialize Terraform') {
            steps {
                echo 'Initializing Terraform...'
                dir("${TERRAFORM_DIR}") {
                    sh '''
                    $CUSTOM_BIN/terraform init -upgrade || exit 1
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
                        $CUSTOM_BIN/terraform apply \
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
                    $CUSTOM_BIN/terraform output || exit 1
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
