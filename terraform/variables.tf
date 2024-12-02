# AWS Variables
variable "aws_region" {
  default = "eu-central-1"
}

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_ami_id" {
  default = "ami-0c02fb55956c7d316" # Змініть на доступну AMI у вашому регіоні
}

variable "aws_instance_type" {
  default = "t2.micro"
}

# DigitalOcean Variables
variable "do_token" {}
variable "ssh_private_key_path" {
  default = "~/.ssh/id_rsa"
}
