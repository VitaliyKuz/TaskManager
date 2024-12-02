pipeline {
    agent any
    environment {
        AWS_REGION = 'eu-central-1'
        AWS_CREDENTIALS = 'AWS_Credentials'
        DO_TOKEN = 'DO_Token'
        TERRAFORM_DIR = 'terraform'
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
                    ntpdate -u pool.ntp.org || echo "Time synchronization skipped."
                else
                    echo "Installing ntpdate not possible, skipping..."
                fi
                '''
            }
        }

        stage('Install Terraform') {
            steps {
                echo 'Installing Terraform...'
                sh '''
                mkdir -p ~/bin
                curl -o ~/terraform.zip https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
                unzip -o ~/terraform.zip -d ~/bin/
                rm -f ~/terraform.zip
                export PATH=~/bin:$PATH
                terraform --version || echo "Terraform is not installed!"
                '''
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
                            -auto-approve
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
