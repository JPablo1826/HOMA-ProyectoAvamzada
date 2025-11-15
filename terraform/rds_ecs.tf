# ==============================================================
# Terraform - RDS Database
# ==============================================================

resource "aws_db_subnet_group" "main" {
  name       = "${var.app_name}-db-subnet-group-${var.environment}"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.app_name}-db-subnet-group-${var.environment}"
  }
}

resource "aws_rds_cluster" "main" {
  cluster_identifier      = "${var.app_name}-db-cluster-${var.environment}"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.02.0"
  database_name           = homa_avanzada_db
  master_username         = root
  master_password         = emili123
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  skip_final_snapshot     = var.environment != "prod"
  backup_retention_period = var.environment == "prod" ? 30 : 7
  storage_encrypted       = true
  kms_key_id              = aws_kms_key.rds.arn

  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

  tags = {
    Name = "${var.app_name}-db-cluster-${var.environment}"
  }
}

resource "aws_rds_cluster_instance" "main" {
  count              = var.environment == "prod" ? 2 : 1
  identifier         = "${var.app_name}-db-instance-${count.index + 1}-${var.environment}"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = var.db_instance_class
  engine             = aws_rds_cluster.main.engine
  engine_version     = aws_rds_cluster.main.engine_version

  performance_insights_enabled = var.environment == "prod"

  tags = {
    Name = "${var.app_name}-db-instance-${count.index + 1}-${var.environment}"
  }
}

# KMS Key for RDS encryption
resource "aws_kms_key" "rds" {
  description             = "KMS key for ${var.app_name} RDS encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name = "${var.app_name}-rds-key-${var.environment}"
  }
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.app_name}-rds-${var.environment}"
  target_key_id = aws_kms_key.rds.key_id
}

# ==============================================================
# Terraform - ECS Task Definitions
# ==============================================================

resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.app_name}-backend-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.backend_container_cpu
  memory                   = var.backend_container_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "${var.app_name}-backend"
      image     = "ghcr.io/${var.app_name}/homa-backend:latest"
      essential = true
      portMappings = [
        {
          containerPort = var.backend_container_port
          hostPort      = var.backend_container_port
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "SPRING_PROFILES_ACTIVE"
          value = var.environment
        },
        {
          name  = "SPRING_DATASOURCE_URL"
          value = "jdbc:mysql://${aws_rds_cluster.main.endpoint}:3306/${var.db_name}"
        },
        {
          name  = "SPRING_DATASOURCE_USERNAME"
          value = var.db_username
        }
      ]
      secrets = [
        {
          name      = "SPRING_DATASOURCE_PASSWORD"
          valueFrom = "${aws_secretsmanager_secret.db_password.arn}:password::"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.backend.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "${var.app_name}-backend-task-${var.environment}"
  }
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.app_name}-frontend-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.frontend_container_cpu
  memory                   = var.frontend_container_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "${var.app_name}-frontend"
      image     = "ghcr.io/${var.app_name}/homa-frontend:latest"
      essential = true
      portMappings = [
        {
          containerPort = var.frontend_container_port
          hostPort      = var.frontend_container_port
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "API_BASE_URL"
          value = "https://${var.domain_name}/api"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.frontend.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "${var.app_name}-frontend-task-${var.environment}"
  }
}

# ==============================================================
# Terraform - ECS Services
# ==============================================================

resource "aws_ecs_service" "backend" {
  name            = "${var.app_name}-backend-service-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = var.ecs_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "${var.app_name}-backend"
    container_port   = var.backend_container_port
  }

  depends_on = [
    aws_lb_listener.https,
    aws_iam_role_policy.ecs_task_execution_role_policy
  ]

  tags = {
    Name = "${var.app_name}-backend-service-${var.environment}"
  }
}

resource "aws_ecs_service" "frontend" {
  name            = "${var.app_name}-frontend-service-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = var.ecs_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "${var.app_name}-frontend"
    container_port   = var.frontend_container_port
  }

  depends_on = [
    aws_lb_listener.https,
    aws_iam_role_policy.ecs_task_execution_role_policy
  ]

  tags = {
    Name = "${var.app_name}-frontend-service-${var.environment}"
  }
}

# ==============================================================
# Auto Scaling (opcional)
# ==============================================================

resource "aws_appautoscaling_target" "backend_target" {
  count              = var.environment == "prod" ? 1 : 0
  max_capacity       = 4
  min_capacity       = var.ecs_desired_count
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.backend.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "backend_policy" {
  count              = var.environment == "prod" ? 1 : 0
  policy_name        = "${var.app_name}-backend-scaling-${var.environment}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.backend_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.backend_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.backend_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

# ==============================================================
# Secrets Manager para contraseña DB
# ==============================================================

resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${var.app_name}-db-password-${var.environment}"
  recovery_window_in_days = 7

  tags = {
    Name = "${var.app_name}-db-password-${var.environment}"
  }
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({ password = var.db_password })
}
