data "aws_iam_policy_document" "profile-lambda-execution-role" {
  statement {
    sid = "CreateLogGroup"
    actions = [
      "logs:CreateLogGroup",
    ]
    resources = [
      "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }

  statement {
    sid = "WriteLogs"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.service}_*:*"
    ]
  }

  statement {
    sid = "DynamodbPermissions"
    actions = [
      "dynamodb:UpdateItem"
    ]
    resources = [
      "arn:aws:dynamodb:${local.region}:${data.aws_caller_identity.current.account_id}:table/${local.table}"
    ]
  }
}

resource "aws_iam_role" "lambda-execution-role" {
  name               = "${local.service}-lambda-execution-role"
  path               = "/service-role/"
  assume_role_policy = file("templates/lambda-assume-role.json")
}

resource "aws_iam_role_policy" "lambda-execution-role" {
  name   = "${local.service}-AWSLambdaBasicExecutionRole"
  policy = data.aws_iam_policy_document.profile-lambda-execution-role.json
  role   = aws_iam_role.lambda-execution-role.id
}
