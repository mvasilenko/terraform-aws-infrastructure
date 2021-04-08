data "terraform_remote_state" "iam" {
  backend = "s3"

  config = {
    bucket = "mvasilenko-tfstate"
    key    = "global/iam/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "ecs" {
  backend = "s3"

  config = {
    bucket = "mvasilenko-tfstate"
    key    = "eu-west-1/ecs/app/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "lb" {
  backend = "s3"

  config = {
    bucket = "mvasilenko-tfstate"
    key    = "eu-west-1/lb/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "mvasilenko-tfstate"
    key    = "eu-west-1/network/terraform.tfstate"
    region = "eu-west-1"
  }
}
