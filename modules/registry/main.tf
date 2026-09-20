resource "aws_ecr_repository" "app" {
  name                 = var.repository_name
  image_tag_mutability = var.image_mutability
  image_scanning_configuration { scan_on_push = var.scan_on_push }
  encryption_configuration     { encryption_type = var.encryption_type }
  tags                         = var.tags
}

resource "aws_ecr_lifecycle_policy" "cleanup" {
  repository = aws_ecr_repository.app.name
  policy     = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire untagged images",
      "action": {
        "type": "expire"
      },
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": ${var.untagged_lifecycle_days}
      }
    }
  ]
}
EOF
}