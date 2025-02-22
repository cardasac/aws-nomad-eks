resource "aws_ecr_repository" "any-api" {
  name                 = "any-api"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
}
