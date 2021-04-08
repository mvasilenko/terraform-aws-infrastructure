resource "aws_cloudwatch_log_group" "fargate-flask-app" {
  name              = "flask-app"
  retention_in_days = "3"
}

resource "aws_ecs_task_definition" "flask-app" {
  family                   = "flask-app"
  container_definitions    = module.flask-app.json_map_encoded_list
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = data.terraform_remote_state.iam.outputs.flask_app_role
  task_role_arn            = data.terraform_remote_state.iam.outputs.flask_app_role
}


module "flask-app" {
  source          = "git::https://github.com/cloudposse/terraform-aws-ecs-container-definition.git?ref=0.45.2"
  container_name  = "flask-app"
  container_image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.eu-west-1.amazonaws.com/flask-app:${var.image_tag}"
  environment     = []

  secrets = []

  port_mappings = [
    {
      "containerPort" = 5000
      "hostPort"      = 5000
      "protocol"      = "tcp"
    },
  ]

  log_configuration = {
    logDriver = "awslogs"
    options = {
      "awslogs-region" : "eu-west-1",
      "awslogs-group" : aws_cloudwatch_log_group.fargate-flask-app.name,
      "awslogs-stream-prefix" : "fargate",
    }
  }
}
