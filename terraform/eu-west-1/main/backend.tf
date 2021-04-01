provider "aws" {
  region = "eu-west-1"
}

terraform {
  required_version = ">= 0.11.10"

  backend "s3" {
    bucket         = "mvasilenko-tfstate"
    key            = "terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "mvasilenko-terraform-statelock"
  }
}
