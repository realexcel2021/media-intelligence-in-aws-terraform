resource "aws_cognito_user_pool" "lambdaeskibana_cognito_user_pool" {
  name = "lambdaeskibanaCognitoUserPoolF53C1400"
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 1
    }
    recovery_mechanism {
      name     = "verified_email"
      priority = 2
    }
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

#   email_verification_message = "The verification code to your new account is {####}"
#   email_verification_subject = "Verify your new account"
#   sms_verification_message = "The verification code to your new account is {####}"

  user_pool_add_ons {
    advanced_security_mode = "ENFORCED"
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_message        = "The verification code to your new account is {####}"
    email_subject        = "Verify your new account"
    sms_message          = "The verification code to your new account is {####}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cognito_user_pool_client" "lambdaeskibana_cognito_user_pool_client" {
  name         = "lambdaeskibanaCognitoUserPoolClient3896C0B6"
  user_pool_id = aws_cognito_user_pool.lambdaeskibana_cognito_user_pool.id

  allowed_oauth_flows = [
    "implicit",
    "code"
  ]

  allowed_oauth_flows_user_pool_client = true

  allowed_oauth_scopes = [
    "profile",
    "phone",
    "email",
    "openid",
    "aws.cognito.signin.user.admin"
  ]

  callback_urls = [
    "https://examples.com"
  ]

  supported_identity_providers = [
    "COGNITO"
  ]
}

resource "aws_cognito_identity_pool" "lambdaeskibana_cognito_identity_pool" {
  identity_pool_name               = "lambdaeskibanaCognitoIdentityPool83C5566D"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id                = aws_cognito_user_pool_client.lambdaeskibana_cognito_user_pool_client.id
    provider_name            = aws_cognito_user_pool.lambdaeskibana_cognito_user_pool.endpoint
    server_side_token_check  = true
  }
}

resource "aws_cognito_user_pool_domain" "lambdaeskibana_user_pool_domain" {
  domain       = var.cognito_domain_name
  user_pool_id = aws_cognito_user_pool.lambdaeskibana_cognito_user_pool.id

  depends_on = [
    aws_cognito_user_pool.lambdaeskibana_cognito_user_pool
  ]
}


resource "aws_cognito_identity_pool_roles_attachment" "lambdaeskibana_identity_pool_role_mapping" {
  identity_pool_id = aws_cognito_identity_pool.lambdaeskibana_cognito_identity_pool.id

  roles = {
    authenticated = aws_iam_role.lambdaeskibana_cognito_authorized_role.arn
  }
}


