# flask-app role
data "aws_iam_policy_document" "flask_app" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "ecr:Get*",
      "ecr:Describe*",
      "ecr:List*",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
    ]

    resources = [
      "arn:aws:ecr:eu-west-1:${data.aws_caller_identity.current.account_id}:repository/flask-app",
    ]
  }
}

module "flask_app" {
  source    = "../../modules/iam-role"
  role_name = "flask_app"
  policy    = data.aws_iam_policy_document.flask_app.json
}
