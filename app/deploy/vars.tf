variable "cluster" {
  type    = string
  default = "app-dev"
}

variable "scale" {
  default = 1
}

variable "cpu" {
  default = 256
}

variable "memory" {
  default = 512
}

variable "image_tag" {
  type    = string
  default = "latest"
}
