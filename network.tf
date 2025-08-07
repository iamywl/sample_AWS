# network.tf

resource "aws_security_group" "web_server" {
  name        = "web-server-sg"
  description = "Allow SSH, HTTP, HTTPS inbound traffic"
  # vpc_id = aws_vpc.main.id # 실제로는 VPC ID를 지정해야 합니다.

  ingress {
    description = "SSH access from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_HOME_IP/32"]
  }

  ingress {
    description = "HTTP access from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
