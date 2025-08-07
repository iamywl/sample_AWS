# 고객 관리형 대칭 키 생성 (자동 회전 활성화)
resource "aws_kms_key" "s3_key" {
  description             = "KMS key for S3 bucket encryption"
  enable_key_rotation     = true # 1년마다 키 자동 회전
  deletion_window_in_days = 7
}

# 키에 대한 별칭(Alias) 설정
resource "aws_kms_alias" "s3_key_alias" {
  name          = "alias/s3_encryption_key"
  target_key_id = aws_kms_key.s3_key.key_id
}

# 암호화가 적용된 S3 버킷 생성
resource "aws_s3_bucket" "encrypted_bucket" {
  bucket = "my-top-secret-files-2025"
}

# S3 버킷에 서버 측 암호화(SSE-KMS) 설정
resource "aws_s3_bucket_server_side_encryption_configuration" "sse_config" {
  bucket = aws_s3_bucket.encrypted_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_key.arn
    }
  }
}
