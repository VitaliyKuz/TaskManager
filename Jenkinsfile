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

        stage('Install Dependencies') {
            steps {
                echo 'Installing dependencies...'
                sh '''
                if ! command -v ntpdate &> /dev/null; then
                    apt-get update && apt-get install -y ntpdate curl unzip
                else
                    echo "Dependencies already installed."
                fi
                '''
            }
        }

        stage('Check and Sync System Time') {
            steps {
                echo 'Checking and synchronizing system time...'
                sh '''
                echo "Current system time:"
                date
                ntpdate -u pool.ntp.org || echo "Time synchronization failed."
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

        stag
