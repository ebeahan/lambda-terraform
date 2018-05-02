terraform {
  backend "s3" {
    bucket  = "ebeahan-jenkins-terraform"
    key     = "terraform.tfstate"
    region  = "us-west-1"
    profile = "ebeahan"
  }
}
