output "LambdaRole" {
  value = aws_iam_role.lambdaeskibanaLambdaFunctionServiceRole3CAA4E89.arn
}

output "ESDomainEndpoint" {
  value = aws_elasticsearch_domain.lambdaeskibana_elasticsearch_domain.endpoint
}