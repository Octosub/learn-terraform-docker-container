/*
 * A role definition attached to a RDS cluster monitoring.
 */
resource "aws_iam_role" "rds_monitoring" {
  name               = "RDSMonitoringRole"
  description        = "Allows RDS clusters to call AWS services on your behalf"
  assume_role_policy = data.aws_iam_policy_document.rds_monitoring_assume_role.json
}

data "aws_iam_policy_document" "rds_monitoring_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "monitoring.rds.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_monitoring_access" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
