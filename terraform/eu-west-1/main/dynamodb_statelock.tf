resource "aws_dynamodb_table" "mvasilenko_terraform_statelock" {
  name           = "mvasilenko-terraform-statelock"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Terraform = "true"
  }
}
