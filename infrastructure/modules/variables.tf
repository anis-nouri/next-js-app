variable "config" {
  description = "Configuration settings"
  type = map(object({
    region                  = string
    next_bucket_name        = string
    api_gateway_name        = string
    lambda_function_image_uri = string
  }))
}