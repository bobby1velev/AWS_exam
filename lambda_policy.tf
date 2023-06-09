#{
#    "Version": "2012-10-17",
#    "Statement": [
#        {
#            "Sid": "DenyAllExceptDescribeTerminate",
#            "Effect": "Allow",
#            "Resource": "*",
#            "Action": [
#                "ec2:DescribeInstances",
#                "ec2:StopInstances",
#                "autoscaling:UpdateAutoScalingGroup",
#                "autoscaling:DescribeAutoScalingInstances",
#                "autoscaling:SuspendProcesses"
#            ]
#        }
#    ]
#}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "cloudwatch_logs_policy" {
  name = "cloudwatch-logs-policy"
  role = aws_iam_role.lambda_role.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:StopInstances"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}