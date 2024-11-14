resource "aws_cloudwatch_event_rule" "MediaConvertJobEventRule" {
  name        = "MediaConvertJobEventRule"
  description = "Rule to capture MediaConvert job state changes"
  role_arn    =  aws_iam_role.AllowPublishAlarmsRole.arn
  
  event_pattern = jsonencode({
    source = ["aws.mediaconvert"],
    "detail-type" = ["MediaConvert Job State Change"],
    detail = {
      status = ["COMPLETE", "ERROR"]
    }
  })
}

resource "aws_cloudwatch_event_target" "MediaConvertJobEventTarget" {
  rule = aws_cloudwatch_event_rule.MediaConvertJobEventRule.name
  arn  = aws_sns_topic.MediaConvertTopic.arn
  target_id = "MCJobsTopic"

  input_transformer {
    input_paths = {
      "job_id" = "$.detail.jobId"
    }
    input_template = "{\"job_id\": <job_id>}"
  }
}


resource "aws_iam_role" "AllowPublishAlarmsRole" {
  name = "AllowPublishAlarmsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "AllowPublishAlarmsPolicy"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = "sns:Publish",
          Resource = "*"
        }
      ]
    })
  }
}
