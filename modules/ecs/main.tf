

##############################################################
# ECS
##############################################################

resource "aws_ecs_cluster" "test_cluster" {
  name = "Test-ECS-Cluster"
  depends_on = [aws_cloudwatch_log_group.test_lg]
}

#########################################################
# ECS Security Group and Policy
#########################################################
resource "aws_security_group" "allow_http" {
  name                   = "allow_http_ecs"
  description            = "Allow HTTP access to ECS Services"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "Test_Task_Execution"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ecs_task_execution" {
  description = "ECS task execution policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "fargate_task" {
  name   = "fargate_task_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [  
    {
        "Effect": "Allow",
        "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.ecs_task_execution.arn
}

resource "aws_iam_role_policy_attachment" "fargate-task" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.fargate_task.arn
}



#########################################################
# ECS Service
#########################################################

resource "aws_ecs_service" "ecs_service" {
  name             = "Test_Service"
  cluster          = aws_ecs_cluster.test_cluster.id
  task_definition  = aws_ecs_task_definition.test_task.arn
  launch_type      = "FARGATE"
  platform_version = "LATEST"
  desired_count    = 1

  network_configuration {
    security_groups  = [aws_security_group.allow_http.id]
    subnets          = [var.subnet_id]
    assign_public_ip = var.assign_public_ip
  }

  #load_balancer {
  #  target_group_arn = var.target_group_arn
  #  container_name   = "Test_TaskDef"
  #  container_port   = 9030
  #}
}

resource "aws_ecs_task_definition" "test_task" {
  family                   = "test-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = <<DEFINITION
    [
      {
        "name": "Test_TaskDef",
        "image": "016776319009.dkr.ecr.eu-west-2.amazonaws.com/scale/fat-buyer-ui:b2fb88a-snapshot",
        "requires_compatibilities": "FARGATE",
        "cpu": 256,
        "memory": 512,
        "essential": true,
        "networkMode": "awsvpc",
        "portMappings": [
            {
            "containerPort": 9030,
            "hostPort": 9030
            }
        ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
              "awslogs-group": "${aws_cloudwatch_log_group.test_lg.name}",
              "awslogs-region": "eu-west-2",
              "awslogs-stream-prefix": "fargate-fat-buyer-ui"
          }
        }
      }
    ]
DEFINITION
}

resource "aws_cloudwatch_log_group" "test_lg" {
  name_prefix       = "/fargate/service/scale/test-task"
  retention_in_days = 7
}
