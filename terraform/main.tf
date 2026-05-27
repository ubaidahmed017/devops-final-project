# 1. Dynamically fetch the latest official Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

# 2. Dynamically generate an RSA Private Key for SSH
resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 3. Save the private key locally as aws-key.pem
resource "local_file" "private_key" {
  content         = tls_private_key.rsa_key.private_key_pem
  filename        = "${path.module}/aws-key.pem"
  file_permission = "0400"
}

# 4. Register the generated key pair with AWS
resource "aws_key_pair" "deployer_key" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.rsa_key.public_key_openssh
}

# 5. Create a comprehensive Security Group for all DevOps layers
resource "aws_security_group" "devops_sg" {
  name        = "${var.project_name}-sg"
  description = "Security Group for DevSecOps 3-Tier Application Platform"

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # React Frontend
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Node.js Backend API
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jenkins Server
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SonarQube Code Scanning
  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Grafana Dashboards
  ingress {
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Prometheus Metrics Collector
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Full Outbound Traffic Allow Rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 6. Provision the m7i.flex-large EC2 Server
resource "aws_instance" "devops_node" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.deployer_key.key_name
  vpc_security_group_ids = [aws_security_group.devops_sg.id]

  root_block_device {
    volume_size = 30 # 30 GB to support K8s, Jenkins, and Monitoring tools comfortably
    volume_type = "gp3"
  }

  tags = {
    Name = var.project_name
  }
}

# 7. Create and bind an Elastic IP to keep the server IP static
resource "aws_eip" "devops_eip" {
  instance = aws_instance.devops_node.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-eip"
  }
}
