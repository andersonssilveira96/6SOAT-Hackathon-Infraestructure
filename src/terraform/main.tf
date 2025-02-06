provider "aws" {
 region = "us-east-1"
}

resource "aws_cognito_user_pool" "fiapx-userspool" {
  name = "fiapx-userspool"

  # Configuração da política de senha
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  alias_attributes         = ["email", "preferred_username"]
  
  # Configuração dos tipos de autenticação permitidos
  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  auto_verified_attributes = ["email"]

  # Adicionando o atributo username
  schema {
    attribute_data_type      = "String"
    name                     = "username"
    required                 = false
    mutable                  = false
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }
}

resource "aws_cognito_user_pool_client" "fiapx-usersclient" {
  name         = "fiapx-usersclient"
  user_pool_id = aws_cognito_user_pool.fiapx-userspool.id

  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}

module "lambda" {
  source = "./modules/lambda"
  arn    = data.aws_iam_role.name.arn
}

module "apiGateway" {
  source               = "./modules/apiGateway"
  arn_lambda_auth      = module.lambda.lambda_arn_auth
  arn_lambda_signup    = module.lambda.lambda_arn_signup
  environment          = var.environment
  nome_lambda_auth     = module.lambda.nome_lambda_auth
  nome_lambda_signup   = module.lambda.nome_lambda_signup
}
