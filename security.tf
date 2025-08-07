# security.tf

provider "aws" {
  region = "ap-northeast-2"
}

# IAM 정책: S3 특정 버킷에 대한 읽기 전용 권한
resource "aws_iam_policy" "s3_read_only" {
  name   = "S3AppBucketReadOnly"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["s3:GetObject", "s3:ListBucket"],
      Resource = ["arn:aws:s3:::my-secure-data-2025", "arn:aws:s3:::my-secure-data-2025/*"]
    }]
  })
}

# 보안 그룹: 웹서버용 (SSH, HTTP, HTTPS 인바운드 허용)
resource "aws_security_group" "web_server" {
  name        = "web-server-sg"
  description = "Allow SSH, HTTP, HTTPS inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_HOME_IP/32"] # 경고: 실제 환경에서는 개인 IP로 제한하세요.
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
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

# S3 버킷: 퍼블릭 접근 전면 차단
resource "aws_s3_bucket" "secure_data" {
  bucket = "my-secure-data-2025" # 전역적으로 고유한 이름 필요
}

resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.secure_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
