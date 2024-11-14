resource "aws_elasticsearch_domain" "lambdaeskibana_elasticsearch_domain" {
  domain_name = "media-intelligence"

  elasticsearch_version = "7.10"

  cluster_config {
    dedicated_master_count     = 3
    dedicated_master_enabled   = true
    instance_count             = 3
    zone_awareness_enabled     = true
    instance_type          = "t3.small.elasticsearch"
    zone_awareness_config {
      availability_zone_count = 3
    }
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }

  cognito_options {
    enabled          = true
    identity_pool_id = aws_cognito_identity_pool.lambdaeskibana_cognito_identity_pool.id
    role_arn         = aws_iam_role.lambdaeskibana_cognito_kibana_configure_role.arn
    user_pool_id     = aws_cognito_user_pool.lambdaeskibana_cognito_user_pool.id
  }

  access_policies = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            aws_iam_role.lambdaeskibanaLambdaFunctionServiceRole3CAA4E89.arn,
            aws_iam_role.lambdaeskibana_cognito_kibana_configure_role.arn
          ]
        }
        Action = "es:ESHttp*"
        Resource = "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/my-domain/*"
      }
    ]
  })

#   encryption_at_rest {
#     enabled = true
#   }

  node_to_node_encryption {
    enabled = true
  }

  snapshot_options {
    automated_snapshot_start_hour = 1
  }

  depends_on = [
    aws_iam_policy.lambdaeskibana_cognito_kibana_configure_policy
  ]
}

