resource "aws_sns_topic" "VideoAnalysisTopic" {
  name = "VidAnalysisTopic"
}

resource "aws_sns_topic_subscription" "oscSub" {
  topic_arn = aws_sns_topic.VideoAnalysisTopic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.SceneClassification.arn

  filter_policy = jsonencode({
    analysis = ["all", "osc"]
  })
}

resource "aws_sns_topic_subscription" "bftSub" {
  topic_arn = aws_sns_topic.VideoAnalysisTopic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.BrandFromTextAnalysis.arn

  filter_policy = jsonencode({
    analysis = ["all", "bft"]
  })
}



resource "aws_sns_topic" "EmailTopic" {
  display_name = "NotificationTopic"
}

resource "aws_sns_topic_subscription" "EmailSubscription" {
  topic_arn = aws_sns_topic.EmailTopic.arn
  protocol  = "email"
  endpoint  = var.email
}



resource "aws_sns_topic" "MediaConvertTopic" {
  name = "MCJobStatus"
}

resource "aws_sns_topic_subscription" "MediaConvertTopicSubscription" {
  topic_arn = aws_sns_topic.MediaConvertTopic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.MediaConvertJobChecker.arn
}
resource "aws_sns_topic_policy" "EventTopicPolicy" {
  arn = aws_sns_topic.MediaConvertTopic.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        },
        Action = "sns:Publish",
        Resource = "*"
      }
    ]
  })
}

