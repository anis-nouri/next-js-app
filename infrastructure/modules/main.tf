locals {
  region                    = var.config["default"]["region"]
  next_bucket_name          = var.config["default"]["next_bucket_name"]
  api_gateway_name          = var.config["default"]["api_gateway_name"]
  lambda_function_image_uri = var.config["default"]["lambda_function_image_uri"]
}

module "my_lambda_module" {
  source           = "./aws-lambda-web-adapter"
  region = local.region
  next_bucket_name = local.next_bucket_name
  api_gateway_name = local.api_gateway_name
  lambda_function_image_uri = local.lambda_function_image_uri
}
