resource "aws_rekognition_project" "example" {
  name        = "media-intelligence"
  auto_update = "ENABLED"
  feature     = "CUSTOM_LABELS"
}