/**
 * The role to execute ecs task
 */
resource "aws_iam_role" "ecs_task_execution" {
  name               = "EcsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume.json
}

data "aws_iam_policy_document" "ecs_task_execution_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

/**
 * Provides access to other AWS service resources
 * that are required to run Amazon ECS tasks
 */
resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

/**
 * ECS Task Execution Role Policy
 */
resource "aws_iam_policy" "ecs_task_execution_main" {
  name = "EcsTaskExecutionRolePolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # 1) ECS Cluster resouces
      {
        Effect = "Allow"
        Action = [
          "ecs:ListClusters",
          "ecs:ListContainerInstances",
          "ecs:DescribeContainerInstances"
        ],
        Resource = [
          format("arn:aws:ecs:ap-northeast-1:%s:cluster/*", data.aws_caller_identity.self.account_id),
          format("arn:aws:ecs:ap-northeast-1:%s:container-instance/*", data.aws_caller_identity.self.account_id)
        ]
      },
      # 2) KMS values used for secret value decode
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "secretsmanager:GetSecretValue",
        ],
        Resource = [
          format("arn:aws:kms:ap-northeast-1:%s:alias/sops", data.aws_caller_identity.self.account_id),
          format("arn:aws:secretsmanager:ap-northeast-1:%s:secret:*", data.aws_caller_identity.self.account_id),
        ]
      },
      # 3) Cloudwatch group of server log output destination
      {
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        Resource = ["*"]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_main" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.ecs_task_execution_main.arn
}

/**
 * Set permissions to execute specified StepFunction from ECS
 */
resource "aws_iam_policy" "ecs_task_execution_stf" {
  name = "EcsTaskExecutionRolePolicyForStepFunction"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "states:StartExecution",
          "states:StopExecution"
        ],
        Resource = [
          format("arn:aws:states:ap-northeast-1:%s:stateMachine:*", data.aws_caller_identity.self.account_id)
        ]
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ecs_task_execution_stf" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.ecs_task_execution_stf.arn
}