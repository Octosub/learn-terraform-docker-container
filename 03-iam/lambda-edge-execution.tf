/**
 * Lambda execution role
 */
resource "aws_iam_role" "lambda_edge_execution" {
  name = "LambdaEdgeExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = [
            "lambda.amazonaws.com",
            "edgelambda.amazonaws.com"
          ]
        }
      },
    ]
  })
}

/**
 * Attache AWS Policy: Full Access SNS
 */
resource "aws_iam_role_policy_attachment" "lambda_edge_execution" {
  role       = aws_iam_role.lambda_edge_execution.name
  policy_arn = aws_iam_policy.lambda_edge_execution.arn
}

/**
 * Role policy: EC2 Network Interface
 */
resource "aws_iam_policy" "lambda_edge_execution" {
  name   = "LambdaEdgeExecutionRolePolicy"
  policy = data.aws_iam_policy_document.lambda_edge_execution.json
}

data "aws_iam_policy_document" "lambda_edge_execution" {
  statement {
    sid    = "LambdaEdge"
    effect = "Allow"
    actions = [
      "iam:CreateServiceLinkedRole",
      "lambda:GetFunction",
      "lambda:EnableReplication",
      "cloudfront:UpdateDistribution"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "LambdaNetworkInterfacesAccess"
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "LambdaPushLogs"
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogGroup",
      "logs:CreateLogStream"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "S3Access"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
    resources = ["*"]
  }
}
