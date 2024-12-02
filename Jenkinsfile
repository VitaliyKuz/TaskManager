pipeline {
    agent any
    environment {
        AWS_REGION = 'eu-central-1' // Регіон AWS
        AWS_CREDENTIALS = 'AWS_Credentials' // Назва AWS credentials у Jenkins
        DO_TOKEN = 'DO_Token' // Назва DigitalOcean токена у Jenkins
        TERRAFORM_DIR = 'terraform' // Директорія з Terraform конфігураціями
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

        stage('Verify AWS Access') {
            steps {
                echo 'Verifying AWS Access...'
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: AWS_CREDENTIALS]]) {
                    sh '''
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                    aws sts get-caller-identity --region $AWS_REGION
                    '''
                }
            }
        }

        stage('Verify DigitalOcean Access') {
            steps {
                echo 'Verifying DigitalOcean Access...'
                withCredentials([string(credentialsId: 'DO_Token', variable: 'DO_TOKEN')]) {
                    sh '''
                    if ! command -v curl &> /dev/null
                    then
                        echo "Installing curl..."
                        apt-get update && apt-get install -y curl
                    fi
                    echo "Verifying DigitalOcean Token..."
                    curl -X GET "https://api.digitalocean.com/v2/account" \
                         -H "Authorization: Bearer $DO_TOKEN"
                    '''
                }
            }
        }

        stage('Initialize Terraform') {
            steps {
                echo 'Initializing Terraform...'
                dir("${TERRAFORM_DIR}") {
                    sh '''
                    terraform init
                    '''
                }
            }
        }

        stage('Apply Terraform (AWS)') {
            steps {
                echo 'Applying Terraform configuration for AWS...'
                dir("${TERRAFORM_DIR}/aws") {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: AWS_CREDENTIALS]]) {
                        sh '''
                        terraform apply -var="aws_access_key=$AWS_ACCESS_KEY_ID" \
                                        -var="aws_secret_key=$AWS_SECRET_ACCESS_KEY" \
                                        -auto-approve
                        '''
                    }
                }
            }
        }

        stage('Apply Terraform (DigitalOcean)') {
            steps {
                echo 'Applying Terraform configuration for DigitalOcean...'
                dir("${TERRAFORM_DIR}/digitalocean") {
                    withCredentials([string(credentialsId: 'DO_Token', variable: 'DO_TOKEN')]) {
                        sh '''
                        terraform apply -var="do_token=$DO_TOKEN" -auto-approve
                        '''
                    }
                }
            }
        }

        stage('Collect Metrics') {
            steps {
                echo 'Collecting metrics from Prometheus...'
                sh '''
                curl -s "http://localhost:9090/api/v1/query?query=node_cpu_seconds_total" > metrics_cpu.json
                curl -s "http://localhost:9090/api/v1/query?query=node_memory_MemAvailable_bytes" > metrics_memory.json
                curl -s "http://localhost:9090/api/v1/query?query=node_network_receive_bytes_total" > metrics_network_in.json
                curl -s "http://localhost:9090/api/v1/query?query=node_network_transmit_bytes_total" > metrics_network_out.json
                curl -s "http://localhost:9090/api/v1/query?query=up" > metrics_up.json
                '''
            }
        }
    }
    post {
        success {
            echo 'Terraform applied and metrics collected successfully.'
        }
        failure {
            echo 'Pipeline failed. Please check the logs for more details.'
        }
    }
}
