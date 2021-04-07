resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    data.terraform_remote_state.network.outputs.sg_http_https,
    data.terraform_remote_state.network.outputs.sg_local,
  ]

  subnets = data.terraform_remote_state.network.outputs.public_subnets

  tags = {
    Environment = "app"
    Name        = "alb"
    Terraform   = "true"
  }
}

resource "aws_lb_listener" "alb_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Empty page"
      status_code  = "200"
    }
  }
}
