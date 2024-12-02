resource "aws_instance" "app" {
  ami           = var.aws_ami_id
  instance_type = var.aws_instance_type
  vpc_security_group_ids = [aws_security_group.allow_http.id]

  tags = {
    Name = "TaskManager-AWS"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.ssh_private_key_path)
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y docker.io docker-compose",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "git clone https://github.com/VitaliyKuz/TaskManager.git /home/ubuntu/TaskManager",
      "cd /home/ubuntu/TaskManager && sudo docker-compose up -d"
    ]
  }
}

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
    host        = self.ipv4_address
  }

  provisioner "remote-exec" {
    inline = [
      "apt-get update",
      "apt-get install -y docker.io docker-compose",
      "systemctl start docker",
      "systemctl enable docker",
      "git clone https://github.com/VitaliyKuz/TaskManager.git /root/TaskManager",
      "cd /root/TaskManager && docker-compose up -d"
    ]
  }
}
