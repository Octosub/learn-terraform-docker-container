/**
 * EC2 Instance profile
 */
resource "aws_iam_instance_profile" "ec2_common" {
  name = "Ec2CommonRole"
  role = aws_iam_role.ec2_common.name
}

/*
 * The role for EC2 common
 */
resource "aws_iam_role" "ec2_common" {
  name               = "Ec2CommonRole"
  assume_role_policy = data.aws_iam_policy_document.ec2_common_assume.json
}

data "aws_iam_policy_document" "ec2_common_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}

/*
 * Attache role policy
 */
resource "aws_iam_role_policy_attachment" "ec2_common" {
  role       = aws_iam_role.ec2_common.name
  policy_arn = data.aws_iam_policy.systems_manager.arn
}

/*
 * The policy to manage instance
 */
data "aws_iam_policy" "systems_manager" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}