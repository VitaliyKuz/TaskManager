provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "digitalocean" {
  token = var.do_token
}

# AWS Resources
resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app" {
  ami           = var.aws_ami_id
  instance_type = var.aws_instance_type
  vpc_security_group_ids = [aws_security_group.allow_http.id]

  tags = {
    Name = "TaskManager-AWS"
  }
}

# DigitalOcean Resources
resource "digitalocean_droplet" "app" {
  image  = "ubuntu-20-04-x64"
  name   = "TaskManager-DO"
  region = "fra1"
  size   = "s-1vcpu-1gb"

  tags = ["TaskManager"]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.ssh_private_key_path)
  }
}
