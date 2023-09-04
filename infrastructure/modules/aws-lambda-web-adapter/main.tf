data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


resource "aws_lambda_function" "nextjs_function" {
  function_name = "next-js-website"
  role = aws_iam_role.iam_for_lambda.arn
  package_type = "Image"
  image_uri    = "055531036085.dkr.ecr.eu-west-1.amazonaws.com/next-js-app:latest"
  runtime = "nodejs16.x"
  architectures = [ "x86_64" ]
  memory_size = 512
  timeout = 10
  tags = {
    CreatedBy = "anis.nouri"
  }
 
}
resource "aws_lambda_function_url" "nextjs_function" {
    function_name = aws_lambda_function.nextjs_function.function_name
    authorization_type = "NONE"
}