output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "alb_http_listener" {
  value = aws_lb_listener.alb_http.arn
}
