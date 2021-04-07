data "aws_iam_policy_document" "aws_assume" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = var.aws_assume_identifiers
    }
  }
}

resource "aws_iam_role" "role" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.aws_assume.json
}

resource "aws_iam_policy" "policy" {
  name   = var.role_name
  policy = var.policy
}

resource "aws_iam_role_policy_attachment" "attachment" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = var.role_name
  role = aws_iam_role.role.name
}

resource "aws_iam_user" "user" {
  count = var.with_user
  name  = var.role_name
}

resource "aws_iam_user_policy_attachment" "user-attachment" {
  count      = var.with_user
  user       = aws_iam_user.user[0].name
  policy_arn = aws_iam_policy.policy.arn
}

