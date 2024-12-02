# AWS Outputs
output "aws_instance_id" {
  value = aws_instance.app.id
}

output "aws_public_ip" {
  value = aws_instance.app.public_ip
}

# DigitalOcean Outputs
output "do_droplet_ip" {
  value = digitalocean_droplet.app.ipv4_address
}
