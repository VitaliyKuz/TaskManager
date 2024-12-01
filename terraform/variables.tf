# AWS Variables
variable "aws_region" {
  default = "eu-central-1"
}

variable "aws_access_key" {
  description = "AWS Access Key"
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
}

variable "aws_ami_id" {
  default = "ami-0030e6787a44f5fdc" # Ubuntu 20.04
}


variable "aws_instance_type" {
  default     = "t2.micro"
  description = "AWS Instance Type"
}

# DigitalOcean Variables
variable "do_token" {
  description = "DigitalOcean Personal Access Token"
}

variable "ssh_private_key_path" {
  default     = "~/.ssh/id_rsa"
  description = "Path to SSH private key"
}
