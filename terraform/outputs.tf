output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.devops_server.id
}

output "elastic_ip" {
  description = "Elastic IP attached to the server"
  value       = aws_eip.devops_eip.public_ip
}

output "private_ip" {
  description = "Private IP of the server"
  value       = aws_instance.devops_server.private_ip
}

output "ami_used" {
  description = "AMI ID that was dynamically selected"
  value       = data.aws_ami.ubuntu.id
}

output "ami_name" {
  description = "AMI name that was dynamically selected"
  value       = data.aws_ami.ubuntu.name
}

output "availability_zone" {
  description = "AZ where instance was deployed"
  value       = data.aws_availability_zones.available.names[0]
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.devops_sg.id
}

output "app_url" {
  description = "Application URL"
  value       = "http://${aws_eip.devops_eip.public_ip}"
}

output "ssh_command" {
  description = "SSH command to connect to the server"
  value       = "ssh -i ubaidahmed.pem ubuntu@${aws_eip.devops_eip.public_ip}"
}
