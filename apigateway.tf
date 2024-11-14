resource "aws_api_gateway_rest_api" "RestAPI" {
  name        = "RestAPI"
  description = "Customer usage plan" # Example description
}

resource "aws_api_gateway_deployment" "RestAPI" {
  rest_api_id = aws_api_gateway_rest_api.RestAPI.id

  triggers = {
    redeployment = sha1(jsonencode([
        aws_api_gateway_resource.StartVideoAnalysisResource,
        aws_api_gateway_method.StartVideoAnalysisMethod,
        aws_api_gateway_integration.StartVideoAnalysisIntegration,

        aws_api_gateway_resource.SearchVideoAnalysisResource,
        aws_api_gateway_method.SearchVideoAnalysisMethod,
        aws_api_gateway_integration.SearchVideoAnalysisIntegration
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_api_gateway_stage" "RestAPIStage" {
  stage_name = var.stage_name
  rest_api_id = aws_api_gateway_rest_api.RestAPI.id
  deployment_id = aws_api_gateway_deployment.RestAPI.id
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.RestAPIAccessLogGroup.arn
    format          = "$context.requestId $context.authorize.status $context.integration.integrationStatus $context.integrationErrorMessage"
  }

}

resource "aws_api_gateway_method_settings" "settings" {
  rest_api_id = aws_api_gateway_rest_api.RestAPI.id
  stage_name  = aws_api_gateway_stage.RestAPIStage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"

  }
}

resource "aws_cloudwatch_log_group" "RestAPIAccessLogGroup" {
  name = "/aws/apigateway/RestAPIAccessLogGroup"
}

resource "aws_api_gateway_resource" "analysis" {
  rest_api_id = aws_api_gateway_rest_api.RestAPI.id
  parent_id   = aws_api_gateway_rest_api.RestAPI.root_resource_id
  path_part   = "analysis"
}

###############################
# start video analysis endpoint
###############################
resource "aws_api_gateway_resource" "StartVideoAnalysisResource" {
  rest_api_id = aws_api_gateway_rest_api.RestAPI.id
  parent_id   = aws_api_gateway_resource.analysis.id
  path_part   = "start"
}
resource "aws_api_gateway_method" "StartVideoAnalysisMethod" {
  rest_api_id   = aws_api_gateway_rest_api.RestAPI.id
  resource_id   = aws_api_gateway_resource.StartVideoAnalysisResource.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = true
}
resource "aws_api_gateway_integration" "StartVideoAnalysisIntegration" {
  rest_api_id             = aws_api_gateway_rest_api.RestAPI.id
  resource_id             = aws_api_gateway_resource.StartVideoAnalysisResource.id
  http_method             = aws_api_gateway_method.StartVideoAnalysisMethod.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.StartAnalysisFunction.invoke_arn
}

###############################
# search video analysis endpoint
###############################

resource "aws_api_gateway_resource" "SearchVideoAnalysisResource" {
  rest_api_id = aws_api_gateway_rest_api.RestAPI.id
  parent_id   = aws_api_gateway_resource.analysis.id
  path_part   = "search"
}
resource "aws_api_gateway_method" "SearchVideoAnalysisMethod" {
  rest_api_id   = aws_api_gateway_rest_api.RestAPI.id
  resource_id   = aws_api_gateway_resource.SearchVideoAnalysisResource.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = true
}
resource "aws_api_gateway_integration" "SearchVideoAnalysisIntegration" {
  rest_api_id             = aws_api_gateway_rest_api.RestAPI.id
  resource_id             = aws_api_gateway_resource.SearchVideoAnalysisResource.id
  http_method             = aws_api_gateway_method.SearchVideoAnalysisMethod.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.SearchAnalysisFunction.invoke_arn
}
