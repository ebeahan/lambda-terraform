variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "us-west-1"
}

variable "aws_account" {}

variable "tf_s3_bucket" {}

variable "master_state_file" {}

variable "access_key" {}

variable "secret_key" {}
