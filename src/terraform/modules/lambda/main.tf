resource "aws_lambda_function" "fiapx" {
  function_name = "fiapx-lambda-auth"
  filename      = "../FIAPX.Auth/auth_lambda.zip"
  handler       = "FIAPX.Auth::FIAPX.Auth.Function_LambdaAuth_Generated::LambdaAuth"
  runtime       = "dotnet8"
  role          = var.arn
  tags = {
    Name = "fiapx-lambda"
  }
  timeout     = 30
  memory_size = 512
}

resource "aws_lambda_function" "fiapx_lambda_signup" {
  function_name = "fiapx-lambda-signup"
  filename      = "../FIAPX.Auth/auth_lambda.zip"
  handler       = "FIAPX.Auth::FIAPX.Auth.Function_LambdaSignUP_Generated::LambdaSignUP"
  runtime       = "dotnet8"
  role          = var.arn
  tags = {
    Name = "fiapx-lambda"
  }
  timeout     = 30
  memory_size = 512
}