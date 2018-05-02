terraform {
  backend "s3" {
    bucket  = "ebeahan-jenkins-terraform"
    key     = "jenkins/terraform.tfstate"
    region  = "us-west-1"
  }
}
