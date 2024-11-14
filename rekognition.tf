resource "aws_rekognition_project" "example" {
  name        = "media-intelligence"
  feature     = "CUSTOM_LABELS"
}