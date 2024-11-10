/*
 * Copyright edutech Inc. All Rights Reserved.
 *
 * For the full copyright and license information,
 * please view the LICENSE file that was distributed with this source code.
 */

resource "aws_iam_role" "ext_github_deploy" {
  name               = "ExternalGithubForDeploy"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ext_github_deploy.json
}
/**
 * Assume role policy
 */
data "aws_iam_policy_document" "ext_github_deploy" {
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
        "repo:Octosub/learn-terraform-docker-container:*",
      ]
      variable = "token.actions.githubusercontent.com:sub"
    }
  }
}
/**
 * Access to the KMS KEY used for encoding/decoding the private key.
 */
resource "aws_iam_policy" "ext_github_deploy_kms" {
  name = "ExternalGithubActionsPolicyKMSAccess"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:DescribeKey"
        ],
        Resource = [
          format("arn:aws:kms:ap-northeast-1:%s:alias/sops", data.aws_caller_identity.self.account_id),
          format("arn:aws:kms:ap-northeast-1:%s:key/*", data.aws_caller_identity.self.account_id),
        ]
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ext_github_deploy_kms" {
  role       = aws_iam_role.ext_github_deploy.name
  policy_arn = aws_iam_policy.ext_github_deploy_kms.arn
}
