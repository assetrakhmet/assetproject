resource "aws_ecs_cluster" "my_cluster" {
    name = "my-ecs-cluster"
}

resource "aws_ecs_task_definition" "my_api" {
    family                   = "my-task-family"
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = "256"
    memory                   = "512"

    execution_role_arn = aws_iam_role.my_api_task_execution_role.arn

    container_definitions = jsonencode([
      {
        "name": "my-api",
        "image": "assetproject/project:latest",
        "portMappings": [
          {
            "containerPort": 3000
          }
        ]
      }
    ])
}

resource "aws_ecs_service" "my_api" {
    name            = "my-api"
    cluster         = aws_ecs_cluster.my_cluster.id
    task_definition = aws_ecs_task_definition.my_api.arn
    launch_type     = "FARGATE"

    desired_count  = 2 

    network_configuration {
       assign_public_ip = false 

       security_groups = [
        aws_security_group.egress_all.id,
        aws_security_group.ingress_api.id
       ]

       subnets = [
         aws_subnet.private_d.id,
         aws_subnet.private_e.id,
       ]
    }

    load_balancer {
       target_group_arn = aws_lb_target_group.my_api.arn
       container_name   = "my-api"
       container_port   = 3000
    }
}

resource "aws_iam_role" "my_api_task_execution_role" {
    name                = "my-api-task-execution-role"
    assume_role_policy  = data.aws_iam_policy_document.ecs_task_assume_role.json
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
    statement {
      actions = ["sts:AssumeRole"]
      
      principals {
         type        = "Service"
         identifiers = ["ecs-tasks.amazonaws.com"]
      }
    }
}

data "aws_iam_policy" "ecs_task_execution_role" {
   arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
   role       = aws_iam_role.my_api_task_execution_role.name 
   policy_arn = data.aws_iam_policy.ecs_task_execution_role.arn
}

resource "aws_lb_target_group" "my_api" {
   name        = "my-api"
   port        = 3000
   protocol    = "HTTP"
   target_type = "ip"
   vpc_id      = aws_vpc.app_vpc.id

   health_check {
     enabled = true
     path    = "/health"
   }

   depends_on = [aws_alb.my_api]
}

resource "aws_alb" "my_api" {
   name                 = "my-api-lb"
   internal             = false
   load_balancer_type   = "application"

   subnets = [ 
     aws_subnet.public_d.id,
     aws_subnet.public_e.id
   ]

   security_groups = [
     aws_security_group.http.id
   ]
}
