resource "aws_iam_role" "ecs_task_app" {
  name = "sample-ecs-task-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "ecs_task_app" {
  name = "sample-ecs-task-role-app-policy"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "AllowSSMAccessToUseEcsExec"
          "Effect" : "Allow",
          "Action" : [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel"
          ],
          "Resource" : "*"
        },
        {
          "Sid" : "AllowKMSAccessToUseEcsExec"
          "Effect" : "Allow",
          "Action" : [
            "kms:Decrypt",
          ],
          "Resource" : aws_kms_key.ecs_exec.arn
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "ecs_task_app" {
  role       = aws_iam_role.ecs_task_app.name
  policy_arn = aws_iam_policy.ecs_task_app.arn
}
