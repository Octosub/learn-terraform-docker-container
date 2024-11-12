/*
 * The role to deploy service
 */
resource "aws_iam_role" "sfn_execution" {
  name               = "StepFunctionExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.sfn_assume_role.json
}

resource "aws_iam_role_policy_attachment" "sfn_execution" {
  role       = aws_iam_role.sfn_execution.name
  policy_arn = aws_iam_policy.sfn_execution.arn
}

data "aws_iam_policy_document" "sfn_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "states.ap-northeast-1.amazonaws.com"
      ]
    }
  }
}

/*
 * The policy to deploy service
 */
resource "aws_iam_policy" "sfn_execution" {
  name        = "StepFunctionExecutionRolePolicy"
  description = "The policy to deploy service"
  policy      = data.aws_iam_policy_document.sfn_execution.json
}

data "aws_iam_policy_document" "sfn_execution" {
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [
      "arn:aws:lambda:ap-northeast-1:*:function:*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "states:StartExecution"
    ]
    resources = [
      "arn:aws:states:ap-northeast-1:*:stateMachine:*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "states:StopExecution"
    ]
    resources = [
      "arn:aws:states:ap-northeast-1:*:stateMachine:*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "states:DescribeExecution",
      "states:StopExecution"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "events:PutTargets",
      "events:PutRule",
      "events:DescribeRule"
    ]
    resources = [
      format("arn:aws:events:ap-northeast-1:%s:rule/StepFunctionsGetEventsForStepFunctionsExecutionRule", data.aws_caller_identity.self.account_id)
    ]
  }
}
