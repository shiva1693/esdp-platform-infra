resource "aws_cloudwatch_log_group" "flow_logs" {
  name               = "/aws/vpc/${var.name_prefix}-flow-logs"
  retention_in_days  = var.log_retention_in_days

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-flow-logs"
  })
}

resource "aws_iam_role" "flow_logs_role" {
  name = "${var.name_prefix}-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      },
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "flow_logs_policy" {
  name = "${var.name_prefix}-flow-logs-policy"
  role = aws_iam_role.flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_flow_log" "vpc_flow_logs" {
  log_destination_type = "cloud-watch-logs"
  iam_role_arn         = aws_iam_role.flow_logs_role.arn
  log_destination      = aws_cloudwatch_log_group.flow_logs.arn
  traffic_type         = "ALL"
  vpc_id               = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc-flow-logs"
  })
}