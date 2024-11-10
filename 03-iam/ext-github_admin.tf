resource "aws_iam_role" "ext_github" {
  name               = "ExternalGithubForAdmin"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ext_github_assume_role.json
}
/**
 * Assume role policy
 */
data "aws_iam_policy_document" "ext_github_assume_role" {
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]
    principals {
      type = "Federated"
      identifiers = [
        format("arn:aws:iam::%s:oidc-provider/token.actions.githubusercontent.com", data.aws_caller_identity.self.account_id)
      ]
    }
    condition {
      test = "ForAnyValue:StringLike"
      values = [
        "repo:Octosub/learn-terraform-docker-container:*"
      ]
      variable = "token.actions.githubusercontent.com:sub"
    }
  }
}
/**
 * The policy to execute Terraform
 */
resource "aws_iam_policy" "ext_github_actions" {
  name = "ExternalGithubActionsPolicyEerAccess"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny",
        Action = [
          "account:*",
          "aws-marketplace:*",
          "aws-marketplace-management:*",
          "billing:*",
          "budgets:*",
          "cloudtrail:*",
          "config:*",
          "consolidatedbilling:*",
          "directconnect:*",
          "ec2:*ReservedInstances*",
          "freetier:*",
          "iam:*Group*",
          "iam:*Login*",
          "invoicing:*",
          "payments:*",
          "tax:*"
        ],
        Resource = [
          "*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "acm:*",
          "apigateway:*",
          "cloudfront:*",
          "dynamodb:*",
          "cognito:*",
          "cognito-idp:*",
          "ec2:*",
          "ecr:*",
          "ecs:*",
          "elasticache:*",
          "elasticloadbalancing:*",
          "es:*",
          "events:*",
          "iam:*",
          "kms:*",
          "lambda:*",
          "logs:*",
          "rds:*",
          "route53:*",
          "s3:*",
          "secretsmanager:*",
          "servicediscovery:*",
          "ses:*",
          "ssm:*",
          "states:*",
          "wafv2:*",
          "iam:AttachUserPolicy",
          "iam:DetachUserPolicy"
        ],
        Resource = [
          "*"
        ]
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ext_github_actions" {
  role       = aws_iam_role.ext_github.name
  policy_arn = aws_iam_policy.ext_github_actions.arn
}