/**
 * Lambda execution role
 */
resource "aws_iam_role" "lambda_execution" {
  name = "LambdaExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

/**
 * Provides minimum permissions for a Lambda function
 * to execute while accessing a resource within a VPC
 * Ref: https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/configuration-vpc.html
 */
resource "aws_iam_role_policy_attachment" "lambda_execution" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

/**
 * For ECR image and launch a Lambda function
 */
resource "aws_iam_policy" "lambda_execution_get_ecr_images" {
  name = "LambdaExecutionRoleGetEcrImages"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:BatchGetImage",
          "ecr:DescribeRepositories"
        ],
        Resource = [
          format("arn:aws:ecr:ap-northeast-1:%s:repository/*", data.aws_caller_identity.self.account_id),
        ]
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "lambda_execution_get_ecr_images" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = aws_iam_policy.lambda_execution_get_ecr_images.arn
}

/**
 * KMS values used for secret value decode
 */
resource "aws_iam_policy" "lambda_execution_secrets_access" {
  name = "LambdaExecutionRoleSecretsAccess"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "secretsmanager:GetSecretValue",
        ],
        Resource = [
          format("arn:aws:kms:ap-northeast-1:%s:alias/sops", data.aws_caller_identity.self.account_id),
          format("arn:aws:secretsmanager:ap-northeast-1:%s:secret:*", data.aws_caller_identity.self.account_id),
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_execution_secrets_access" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = aws_iam_policy.lambda_execution_secrets_access.arn
}

/**
 * Set permissions to start specified StepFunction from Lambda
 */
resource "aws_iam_policy" "lambda_task_execution_start_stf" {
  name = "LambdaExecutionRolePolicyStartSTF"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "states:StartExecution"
        ],
        Resource = [
          format("arn:aws:states:ap-northeast-1:%s:stateMachine:*", data.aws_caller_identity.self.account_id)
        ]
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "lambda_task_execution_start_stf" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = aws_iam_policy.lambda_task_execution_start_stf.arn
}
