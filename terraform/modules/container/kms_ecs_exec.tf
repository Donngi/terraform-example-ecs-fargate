resource "aws_kms_key" "ecs_exec" {
  description = "KMS key for ECS exec"
}

resource "aws_kms_alias" "ecs_exec" {
  name          = "alias/ecs-exec"
  target_key_id = aws_kms_key.ecs_exec.key_id
}

resource "aws_kms_key_policy" "ecs_exec" {
  key_id = aws_kms_key.ecs_exec.key_id

  policy = jsonencode({
    "Version" : "2012-10-17"
    "Statement" : [
      {
        "Sid" : "Enable IAM User Permissions"
        "Effect" : "Allow"
        "Principal" : {
          "AWS" : "*"
        }
        "Action" : "kms:*"
        "Resource" : "*"
      },
    ]
  })
}
