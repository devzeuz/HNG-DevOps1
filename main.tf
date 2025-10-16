resource "aws_security_group" "SG" {
  name        = "HNG-SG"
  description = "Allow SSH inbound traffic"
  vpc_id      = "vpc-007a82912ee1fbd89"
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.SG.id
  cidr_ipv4         = "0.0.0.0/0"  
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.SG.id
  cidr_ipv4         = "0.0.0.0/0"  
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key" {
  key_name   = "key"
  public_key = tls_private_key.key.public_key_openssh
}

resource "aws_s3_bucket" "key_bucket" {
  bucket = "my-key-storage-bucket"
}

resource "aws_s3_object" "key" {
  bucket       = aws_s3_bucket.key_bucket.bucket
  key          = "key.pem"
  content      = tls_private_key.key.private_key_pem
  acl          = "private"
}

resource "aws_instance" "hng_ec2_instance" {
  ami                         = "ami-0341d95f75f311023"
  instance_type               = "t2.micro"
  subnet_id                   = "subnet-0b0b5224c6bb51e97"
  key_name                    = aws_key_pair.key.key_name
  vpc_security_group_ids      = [aws_security_group.SG.id]
  associate_public_ip_address = true

  tags = {
    Name = "hng_ec2_instance_"
  }

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail
    apt-get update -y
    apt-get install -y nginx git
    systemctl enable nginx
    systemctl start nginx
    mkdir -p /var/www/html
    rm -f /var/www/html/index.html
    git clone https://github.com/devzeuz/hng13-stage0-devops.git /tmp/webrepo
    cp /tmp/webrepo/index.html /var/www/html/index.html
    chmod 644 /var/www/html/index.html
    systemctl restart nginx
  EOF
}
output "private_key" {
  value     = tls_private_key.key.private_key_pem
  sensitive = true
}

output "instace_public_ip" {
    value = aws_instance.hng_ec2_instance.public_ip
}



