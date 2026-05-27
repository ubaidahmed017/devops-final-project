output "server_public_static_ip" {
  value       = aws_eip.devops_eip.public_ip
  description = "The Static Elastic IP of the deployed m7i.flex-large EC2 instance"
}

output "ssh_connection_string" {
  value       = "ssh -i aws-key.pem ubuntu@${aws_eip.devops_eip.public_ip}"
  description = "The absolute SSH command to connect to your instance"
}
