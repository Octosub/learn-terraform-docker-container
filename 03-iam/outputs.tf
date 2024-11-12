output "ec2_common" {
  value = aws_iam_role.ec2_common.arn
}

output "ec2_common_profile" {
  value = aws_iam_instance_profile.ec2_common.name
}

output "ecs_task_execution" {
  value = aws_iam_role.ecs_task_execution.arn
}

output "lambda_execution" {
  value = aws_iam_role.lambda_execution.arn
}

output "rds_monitoring" {
  value = aws_iam_role.rds_monitoring.arn
}

output "sfn_execution" {
  value = aws_iam_role.sfn_execution.arn
}
