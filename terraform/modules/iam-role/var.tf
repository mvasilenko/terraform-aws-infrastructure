variable "role_name" {
  type = string
}

variable "policy" {
  type = string
}

variable "with_user" {
  type    = string
  default = "0"
}

variable "aws_assume_identifiers" {
  type    = list(string)
  default = ["ec2.amazonaws.com", "ecs-tasks.amazonaws.com"]
}

