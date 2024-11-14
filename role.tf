##############################################
# Lambda function role
##############################################


resource "aws_iam_role" "lambdaeskibanaLambdaFunctionServiceRole3CAA4E89" {
  name = "lambdaeskibanaLambdaFunctionServiceRole3CAA4E89"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_function_service_role_policy" {
  name = "LambdaFunctionServiceRolePolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambdaeskibana_policy_attachment" {
  role       = aws_iam_role.lambdaeskibanaLambdaFunctionServiceRole3CAA4E89.name
  policy_arn = aws_iam_policy.lambda_function_service_role_policy.arn
}


resource "aws_iam_role_policy" "lambdaeskibana_lambda_function_service_role_default_policy" {
  name = "lambdaeskibanaLambdaFunctionServiceRoleDefaultPolicyD0744538"
  role = aws_iam_role.lambdaeskibanaLambdaFunctionServiceRole3CAA4E89.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}


##############################################
# cognito identity pool role
##############################################

resource "aws_iam_role" "lambdaeskibana_cognito_authorized_role" {
  name = "lambdaeskibanaCognitoAuthorizedRoleC08D0363"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = "${aws_cognito_identity_pool.lambdaeskibana_cognito_identity_pool.id}"
          }
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "authenticated"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambdaeskibana_cognito_access_policy" {
  name = "CognitoAccessPolicy"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "es:ESHttp*"
        ]
        Effect = "Allow"
        Resource = "arn:${data.aws_partition.current.partition}:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/aprendiendoaws-ml-mi-kibana-users/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambdaeskibana_cognito_role_policy_attachment" {
  role       = aws_iam_role.lambdaeskibana_cognito_authorized_role.name
  policy_arn = aws_iam_policy.lambdaeskibana_cognito_access_policy.arn
}


##############################################
# elastisearch role
##############################################

resource "aws_iam_role" "lambdaeskibana_cognito_kibana_configure_role" {
  name = "lambdaeskibanaCognitoKibanaConfigureRoleDC6E0E46"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "es.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_policy" "lambdaeskibana_cognito_kibana_configure_policy" {
  name   = "lambdaeskibanaCognitoKibanaConfigureRolePolicy2CCD4655"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cognito-idp:DescribeUserPool",
          "cognito-idp:CreateUserPoolClient",
          "cognito-idp:DeleteUserPoolClient",
          "cognito-idp:DescribeUserPoolClient",
          "cognito-idp:AdminInitiateAuth",
          "cognito-idp:AdminUserGlobalSignOut",
          "cognito-idp:ListUserPoolClients",
          "cognito-identity:DescribeIdentityPool",
          "cognito-identity:UpdateIdentityPool",
          "cognito-identity:SetIdentityPoolRoles",
          "cognito-identity:GetIdentityPoolRoles",
          "es:UpdateElasticsearchDomainConfig"
        ]
        Effect = "Allow"
        Resource = [
          aws_cognito_user_pool.lambdaeskibana_cognito_user_pool.arn,
          "arn:aws:cognito-identity:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:identitypool/${aws_cognito_identity_pool.lambdaeskibana_cognito_identity_pool.id}",
          "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/my-domain"
        ]
      },
      {
        Action = "iam:PassRole"
        Effect = "Allow"
        Condition = {
          StringLike = {
            "iam:PassedToService" = "cognito-identity.amazonaws.com"
          }
        }
        Resource = aws_iam_role.lambdaeskibana_cognito_kibana_configure_role.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambdaeskibana_cognito_kibana_policy_attachment" {
  role       = aws_iam_role.lambdaeskibana_cognito_kibana_configure_role.name
  policy_arn = aws_iam_policy.lambdaeskibana_cognito_kibana_configure_policy.arn
}



##############################################
# media convert role
##############################################

resource "aws_iam_role" "MediaConvertS3Role" {
  name = "MediaConvertS3Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "mediaconvert.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "MediaConvertS3RolePolicy" {
  name   = "MediaConvertS3RolePolicy"
  policy = jsonencode({
    Statement = [
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
      }
    ]
  })
}

resource "aws_iam_policy" "MediaConvertCloudWatchEventsPolicy" {
  name   = "MediaConvertCloudWatchEventsPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "cloudwatch:PutMetricStream",
          "logs:*"
        ]
        Resource = [
          "arn:aws:logs::${data.aws_caller_identity.current.account_id}:*:*:*",
          "arn:aws:cloudwatch::${data.aws_caller_identity.current.account_id}:*/*",
          "arn:aws:cloudwatch::${data.aws_caller_identity.current.account_id}:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "MediaConvertS3RolePolicyAttachment" {
  role       = aws_iam_role.MediaConvertS3Role.name
  policy_arn = aws_iam_policy.MediaConvertS3RolePolicy.arn
}

resource "aws_iam_role_policy_attachment" "MediaConvertCloudWatchEventsPolicyAttachment" {
  role       = aws_iam_role.MediaConvertS3Role.name
  policy_arn = aws_iam_policy.MediaConvertCloudWatchEventsPolicy.arn
}

##############################################
# api lambda role
##############################################

resource "aws_iam_role" "APILambdaRole" {
  name = "APILambdaRole"

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
}

resource "aws_iam_role_policy" "LambdaWorkflowRolePolicy" {
  name   = "LambdaWorkflowRolePolicy"
  role   = aws_iam_role.APILambdaRole.name
  policy = jsonencode({
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
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
        Action = "lambda:InvokeFunction"
        Resource = "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:Get*",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          "arn:aws:dynamodb:*:*:table/${var.dynamodb_table_name}",
          "arn:aws:dynamodb:*:*:table/${var.dynamodb_table_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "APILambdaRoleBasicExecution" {
  role       = aws_iam_role.APILambdaRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "APILambdaRoleS3ReadOnlyAccess" {
  role       = aws_iam_role.APILambdaRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}




