variable "cognito_domain_name" {
  description = "The domain name for the Cognito user pool"
  type        = string
  default     = "media-intelligence-domain-test"
}


variable "email" {
  description = "Email to notify when fail occurs"
  type        = string
  default     = "email@domain.com"
}

variable "s3_bucket" {
  description = "Your Amazon S3 bucket name"
  type        = string
  default     = "aprendiendoaws-ml-mi"
}

variable "destination_bucket" {
  description = "Amazon S3 bucket to bulk frames and audio outputs"
  type        = string
  default     = "results"
}

variable "es_domain_name" {
  description = "Amazon ElasticSearch Domain name"
  type        = string
  default     = "aprendiendoaws-ml-mi-domain"
}

variable "dynamodb_table_name" {
  type    = string
  default = "aprendiendoaws-ml-mi-jobs"
}

variable "stage_name" {
  type    = string
  default = "Prod"
}

variable "osc_dictionary" {
  type    = string
  default = "osc_files/dictionary.json"
}

variable "lambda_role" {
  type = string
}

variable "es_domain_endpoint" {
  type = string
}
