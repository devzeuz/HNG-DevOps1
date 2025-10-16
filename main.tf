resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "generated-key"
  public_key = tls_private_key.key.public_key_openssh
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = "vpc-007a82912ee1fbd89"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "hng_ec2_instance" {
  ami                         = "ami-0341d95f75f311023"
  instance_type               = "t2.micro"
  subnet_id                   = "subnet-0b0b5224c6bb51e97"
  key_name                    = aws_key_pair.generated_key.key_name
  vpc_security_group_ids      = [aws_security_group.allow_ssh.name]
  associate_public_ip_address = true
  tags = {
    Name = "hng_ec2_instance"
  }

  user_data = <<-EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum install -y nginx
  sudo systemctl start nginx
  sudo systemctl enable nginx

  rm -rf /usr/share/nginx/html/*
  git clone https://github.com/devzeuz/hng13-stage0-devops.git /tmp/site
  cp -r /tmp/site/* /usr/share/nginx/html/
  chown -R nginx:nginx /usr/share/nginx/html/
EOF
}

output "private_key" {
  value     = tls_private_key.key.private_key_pem
  sensitive = true
}

output "instace_public_ip" {
    value = aws_instance.hng_ec2_instance.public_ip
}