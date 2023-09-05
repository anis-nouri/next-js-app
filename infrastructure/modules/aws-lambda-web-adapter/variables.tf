variable "region" {
  description = "The AWS region where your resources will be provisioned."
  type        = string
  default     = "eu-west-1"
}

variable "next_bucket_name" {
  description = "The name of the S3 bucket to create."
  type        = string
  default     = "nextbucket"
}