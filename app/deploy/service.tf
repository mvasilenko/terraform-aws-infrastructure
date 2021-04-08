resource "aws_ecs_service" "flask-app" {
  name            = "flask-app"
  cluster         = var.cluster
  task_definition = aws_ecs_task_definition.flask-app.arn
  desired_count   = var.scale
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = true
    security_groups = [
      data.terraform_remote_state.network.outputs.sg_http_https,
      data.terraform_remote_state.network.outputs.sg_local,
    ]

    # TODO replace with for_each
    subnets = [
      data.terraform_remote_state.network.outputs.public_subnets[0],
      data.terraform_remote_state.network.outputs.public_subnets[1],
      data.terraform_remote_state.network.outputs.public_subnets[2],
    ]
  }

  load_balancer {
    target_group_arn = data.terraform_remote_state.ecs.outputs.tg_flask_app
    container_name   = "flask-app"
    container_port   = "5000"
  }
}
