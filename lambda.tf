# scene classification lambda
resource "aws_lambda_function" "SceneClassification" {
  filename         = "src/SceneClassification.zip"
  function_name    = "SceneClassification"
  handler          = "osc.lambda_handler"
  runtime          = "python3.9"
  timeout          = 900
  role             = aws_iam_role.SceneClassificationLambdaRole.arn

  environment {
    variables = {
      IN_S3_BUCKET    = var.s3_bucket
      DDB_TABLE       = "${aws_dynamodb_table.ResultsTable.name}"
      DEST_S3_BUCKET  = var.destination_bucket
      ES_LAMBDA_ARN   = "${aws_lambda_function.ESLambda.arn}"
      OSC_DICT        = var.osc_dictionary
      SNS_EMAIL_TOPIC = aws_sns_topic.EmailTopic.arn
    }
  }
}

resource "aws_iam_role" "SceneClassificationLambdaRole" {
  name = "SceneClassificationLambdaRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]

  inline_policy {
    name = "SceneClassificationPolicy"
    policy = jsonencode({
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "rekognition:DetectLabels"
          ]
          Resource = "*"
        },
        {
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:PutObject"
          ]
          Resource = [
            "arn:aws:s3:::${var.s3_bucket}/*",
            "arn:aws:s3:::${var.destination_bucket}/*"
          ]
        },
        {
          Effect = "Allow"
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = "arn:aws:logs::${data.aws_caller_identity.current.account_id}:*:*:*"
        },
        {
          Effect = "Allow"
          Action = [
            "dynamodb:Query",
            "dynamodb:PutItem",
            "dynamodb:BatchWriteItem"
          ]
          Resource = [
            "arn:aws:dynamodb:*:*:table/${aws_dynamodb_table.ResultsTable.name}",
            "arn:aws:dynamodb:*:*:table/${aws_dynamodb_table.ResultsTable.name}/*"
          ]
        },
        {
          Effect = "Allow"
          Action = [
            "lambda:InvokeFunction"
          ]
          Resource = "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:*"
        },
        {
          Effect = "Allow"
          Action = [
            "sns:Publish"
          ]
          Resource = aws_sns_topic.EmailTopic.arn
        }
      ]
    })
  }
}
resource "aws_lambda_permission" "AllowSNSInvokeLambda" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.SceneClassification.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.VideoAnalysisTopic.arn
}

# ESLambda
resource "aws_lambda_function" "ESLambda" {
  filename         = "src/ESLambda.zip"
  function_name    = "ESLambda"
  handler          = "esindex.lambda_handler"
  runtime          = "python3.8" 
  role             = aws_iam_role.lambdaeskibanaLambdaFunctionServiceRole3CAA4E89.arn

  environment {
    variables = {
      AWS_NODEJS_CONNECTION_REUSE_ENABLED = "1"
      DOMAIN_ENDPOINT                     = "${aws_elasticsearch_domain.lambdaeskibana_elasticsearch_domain.endpoint}"
    }
  }
}

# BrandFrom Text Anaylsis Lambda
resource "aws_lambda_function" "BrandFromTextAnalysis" {
  filename         = "src/BrandFromTextAnalysis.zip"
  function_name    = "BrandFromTextAnalysis"
  handler          = "bft.lambda_handler"
  runtime          = "python3.9"
  role             = aws_iam_role.BrandFromTextAnalysisLambdaRole.arn

  environment {
    variables = {
      DDB_TABLE        = aws_dynamodb_table.ResultsTable.name
      IN_S3_BUCKET     = var.s3_bucket
      DEST_S3_BUCKET   = var.destination_bucket
      SIM_THRESHOLD    = "0.7"
      ES_LAMBDA_ARN    = aws_lambda_function.ESLambda.arn
      SNS_EMAIL_TOPIC  = aws_sns_topic.EmailTopic.arn
    }
  }
}
resource "aws_iam_role" "BrandFromTextAnalysisLambdaRole" {
  name = "BrandFromTextAnalysisLambdaRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]

  inline_policy {
    name = "BrandFromTextAnalysisPolicy"
    policy = jsonencode({
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "rekognition:StartTextDetection",
            "rekognition:GetTextDetection",
            "rekognition:DetectText"
          ]
          Resource = "*"
        },
        {
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:PutObject"
          ]
          Resource = [
            "arn:aws:s3:::${var.s3_bucket}/*",
            "arn:aws:s3:::${var.destination_bucket}/*"
          ]
        },
        {
          Effect = "Allow"
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = "arn:aws:logs::${data.aws_caller_identity.current.account_id}:*:*:*"
        },
        {
          Effect = "Allow"
          Action = [
            "dynamodb:PutItem",
            "dynamodb:BatchWriteItem"
          ]
          Resource = [
            "arn:aws:dynamodb:*:*:table/${aws_dynamodb_table.ResultsTable.name}",
            "arn:aws:dynamodb:*:*:table/${aws_dynamodb_table.ResultsTable.name}/*"
          ]
        },
        {
          Effect = "Allow"
          Action = [
            "lambda:InvokeFunction"
          ]
          Resource = "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:*"
        },
        {
          Effect = "Allow"
          Action = [
            "sns:Publish"
          ]
          Resource = aws_sns_topic.EmailTopic.arn
        }
      ]
    })
  }
}
resource "aws_lambda_permission" "AllowSNSInvokeLambdaBrandFromTextAnalysis" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.BrandFromTextAnalysis.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.VideoAnalysisTopic.arn
}

# StartAnalysis Function 
resource "aws_lambda_function" "StartAnalysisFunction" {
  filename         = "src/StartAnalysisFunction.zip"
  function_name    = "StartAnalysisFunction"
  handler          = "main.lambda_handler"
  runtime          = "python3.8"
  role             = aws_iam_role.StartAnalysisFunctionLambdaRole.arn

  environment {
    variables = {
      DDB_TABLE        = aws_dynamodb_table.ResultsTable.name
      MEDIA_CONVERT_ARN = aws_iam_role.MediaConvertS3Role.arn
      DEST_S3_BUCKET   = var.destination_bucket
      IN_S3_BUCKET     = var.s3_bucket
      SNS_TOPIC        = aws_sns_topic.VideoAnalysisTopic.arn
    }
  }
}

resource "aws_iam_role" "StartAnalysisFunctionLambdaRole" {
  name = "StartAnalysisFunctionLambdaRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]

  inline_policy {
    name = "StartAnalysisFunctionPolicy"
    policy = jsonencode({
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "mediaconvert:GetJob",
            "mediaconvert:ListJobs",
            "mediaconvert:DescribeEndpoints",
            "mediaconvert:CreateJob"
          ]
          Resource = "*"
        },
        {
          Effect = "Allow"
          Action = "iam:PassRole"
          Resource = aws_iam_role.MediaConvertS3Role.arn
        },
        {
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:PutObject"
          ]
          Resource = "arn:aws:s3:::${var.s3_bucket}/*"
        },
        {
          Effect = "Allow"
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = "arn:aws:logs::${data.aws_caller_identity.current.account_id}:*:*:*"
        },
        {
          Effect = "Allow"
          Action = [
            "dynamodb:Query",
            "dynamodb:PutItem"
          ]
          Resource = [
            "arn:aws:dynamodb:*:*:table/${aws_dynamodb_table.ResultsTable.name}",
            "arn:aws:dynamodb:*:*:table/${aws_dynamodb_table.ResultsTable.name}/*"
          ]
        },
        {
          Effect = "Allow"
          Action = "sns:Publish"
          Resource = aws_sns_topic.VideoAnalysisTopic.arn
        }
      ]
    })
  }
}

resource "aws_lambda_permission" "AllowAPIGatewayInvokeLambdaStartAnalysisFunction" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.StartAnalysisFunction.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.RestAPI.execution_arn}/*/*/*"
}


# SearchAnalysis Function
resource "aws_lambda_function" "SearchAnalysisFunction" {
  filename         = "src/SearchAnalysisFunction.zip"
  function_name    = "SearchAnalysisFunction"
  handler          = "main.lambda_handler"
  runtime          = "python3.8"
  role             = aws_iam_role.lambdaeskibanaLambdaFunctionServiceRole3CAA4E89.arn

  environment {
    variables = {
      DOMAIN_ENDPOINT = aws_elasticsearch_domain.lambdaeskibana_elasticsearch_domain.endpoint
    }
  }
}

resource "aws_lambda_permission" "AllowAPIGatewayInvokeLambdaSearchAnalysisFunction" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.SearchAnalysisFunction.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.RestAPI.execution_arn}/*/*/*"
}


resource "aws_lambda_function" "MediaConvertJobChecker" {
  filename         = "src/MediaConvertJobChecker.zip"
  function_name    = "MediaConvertJobChecker"
  handler          = "media-convert-job-checker.lambda_handler"
  runtime          = "python3.8"
  role             = aws_iam_role.MediaConvertJobCheckerLambdaRole.arn

  environment {
    variables = {
      SNS_TOPIC       = aws_sns_topic.VideoAnalysisTopic.arn
      SNS_EMAIL_TOPIC = aws_sns_topic.EmailTopic.arn
      IN_S3_BUCKET    = var.s3_bucket
      DDB_TABLE       = aws_dynamodb_table.ResultsTable.name
    }
  }
}

resource "aws_lambda_permission" "MCLambdaInvokePermissions" {
  statement_id  = "AllowSnsInvocationOfMediaConvertJobChecker"
  action        = "lambda:InvokeFunction"
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.MediaConvertTopic.arn
  function_name = aws_lambda_function.MediaConvertJobChecker.arn
}


resource "aws_iam_role" "MediaConvertJobCheckerLambdaRole" {
  name = "MediaConvertJobCheckerLambdaRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]

  inline_policy {
    name = "MediaConvertJobCheckerPolicy"
    policy = jsonencode({
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "mediaconvert:GetJob",
            "mediaconvert:DescribeEndpoints"
          ]
          Resource = "*"
        },
        {
          Effect = "Allow"
          Action = "iam:PassRole"
          Resource = aws_iam_role.MediaConvertS3Role.arn
        },
        {
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:PutObject"
          ]
          Resource = "arn:aws:s3:::${var.s3_bucket}/*"
        },
        {
          Effect = "Allow"
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = "arn:aws:logs::${data.aws_caller_identity.current.account_id}:*:*:*"
        },
        {
          Effect = "Allow"
          Action = [
            "dynamodb:Query",
            "dynamodb:PutItem"
          ]
          Resource = [
            "arn:aws:dynamodb:*:*:table/${aws_dynamodb_table.ResultsTable.name}",
            "arn:aws:dynamodb:*:*:table/${aws_dynamodb_table.ResultsTable.name}/*"
          ]
        },
        {
          Effect = "Allow"
          Action = "sns:Publish"
          Resource = [
            aws_sns_topic.VideoAnalysisTopic.arn,
            aws_sns_topic.EmailTopic.arn
          ]
        }
      ]
    })
  }
}


resource "aws_lambda_function" "GetAnalysisFunction" {
  filename         = "src/GetAnalysisFunction.zip"
  function_name    = "GetAnalysisFunction"
  handler          = "main.lambda_handler"
  runtime          = "python3.8"
  role             = aws_iam_role.APILambdaRole.arn

  environment {
    variables = {
      DDB_TABLE      = aws_dynamodb_table.ResultsTable.name
      ANALYSIS_LIST  = "['osc','bft','bfl','cff']"
    }
  }
}

resource "aws_lambda_permission" "AllowAPIGatewayInvokeLambdaGetAnalysisFunction" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.GetAnalysisFunction.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.RestAPI.execution_arn}/*/*/*"
}