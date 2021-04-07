data "terraform_remote_state" "iam" {
  backend = "s3"

  config = {
    bucket = "mvasilenko-tfstate"
    key    = "global/iam/terraform.tfstate"
    region = "eu-west-1"
  }
}
