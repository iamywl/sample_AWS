# 알림을 받을 SNS 주제 생성
resource "aws_sns_topic" "security_alerts" {
  name = "SecurityAlertsTopic"
}

# 로그를 저장할 S3 버킷 생성
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "my-cloudtrail-log-bucket-2025" # 전역적으로 고유한 이름 필요
}

# CloudTrail 로그를 수집할 CloudWatch Log Group 생성
resource "aws_cloudwatch_log_group" "trail_log_group" {
  name = "CloudTrail/DefaultLogGroup"
}

# CloudTrail 활성화
resource "aws_cloudtrail" "main_trail" {
  name                          = "MainTrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.trail_log_group.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_to_cloudwatch.arn
}

# 로그인 실패 감지를 위한 Metric Filter 생성
resource "aws_cloudwatch_log_metric_filter" "console_signin_failures" {
  name           = "ConsoleSigninFailures"
  pattern        = "{ ($.eventName = \"ConsoleLogin\") && ($.errorMessage = \"Failed authentication\") }"
  log_group_name = aws_cloudwatch_log_group.trail_log_group.name

  metric_transformation {
    name      = "ConsoleSigninFailureCount"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

# 1분 동안 3회 이상 로그인 실패 시 알람 발생
resource "aws_cloudwatch_metric_alarm" "signin_failure_alarm" {
  alarm_name          = "ConsoleSignInFailureAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ConsoleSigninFailureCount"
  namespace           = "CloudTrailMetrics"
  period              = "60" # 60초
  statistic           = "Sum"
  threshold           = "3"
  alarm_description   = "3번 이상 로그인 실패 시 알람"
  alarm_actions       = [aws_sns_topic.security_alerts.arn]
}

# (참고) CloudTrail이 CloudWatch에 로그를 쓸 수 있도록 하는 IAM 역할
resource "aws_iam_role" "cloudtrail_to_cloudwatch" {
 # ... IAM 역할 및 정책 정의 필요 ...
}
