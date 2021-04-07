
resource "aws_lb_target_group" "flask-app" {
  name                 = "flask-app"
  port                 = 5000
  protocol             = "HTTP"
  vpc_id               = data.terraform_remote_state.network.outputs.vpc_id
  deregistration_delay = 60
  target_type          = "ip"


  health_check {
    path                = "/"
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
}

resource "aws_lb_listener_rule" "flask-app" {
  listener_arn = data.terraform_remote_state.lb.outputs.alb_http_listener
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.flask-app.arn
  }

  condition {
    host_header {
      values = ["flask.mvasilenko.me"]
    }
  }
}
