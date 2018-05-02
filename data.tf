data "terraform_remote_state" "master_state" {
  backend = "s3"

  config {
    bucket  = "${var.tf_s3_bucket}"
    region  = "${var.aws_region}"
    profile = "${var.aws_account}"
    key     = "${var.master_state_file}"
  }
}

