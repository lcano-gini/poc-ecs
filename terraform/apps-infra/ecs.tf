# ==============================================================================
# ECS.TF
# Elastic Container Service - Orquestación de Contenedores
# ==============================================================================

# Resource: aws_ecs_cluster
# El clúster lógico que agrupa los servicios y tareas.
resource "aws_ecs_cluster" "main" {
  name = "${local.name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Resource: aws_ecs_task_definition
# La "receta" para correr el contenedor. Define CPU, RAM, Imagen, Puertos, etc.
resource "aws_ecs_task_definition" "app" {
  family                   = "${local.name}-task"
  network_mode             = "awsvpc" # Requerido para Fargate
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256 # .25 vCPU
  memory                   = 512 # 512 MB RAM
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn # Rol para que ECS pueda jalar imagenes y escribir logs

  # Definición del contenedor en formato JSON
  container_definitions = jsonencode([
    {
      name      = local.name
      image     = "${aws_ecr_repository.app.repository_url}:${var.image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = 4000
          hostPort      = 4000
        }
      ]
      environment = [
        {
          name  = "ENVIRONMENT"
          value = var.environment
        },
        {
          name  = "REGION"
          value = var.aws_region
        },
        {
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          name  = "DB_HOST"
          value = aws_db_instance.postgres.address
        },
        {
          name  = "DB_PORT"
          value = tostring(aws_db_instance.postgres.port)
        },
        {
          name  = "DB_USER"
          value = var.db_username
        },
        {
          name  = "DB_PASS"
          value = var.db_password
        },
        {
          name  = "DB_NAME"
          value = var.db_name
        },
        {
          name  = "DB_SSL"
          value = "true"
        },
        {
          name  = "JWT_SECRET"
          value = var.jwt_secret
        },
        {
          name  = "JWT_EXPIRES_IN"
          value = "15m"
        },
        {
          name  = "JWT_REFRESH_SECRET"
          value = var.jwt_refresh_secret
        },
        {
          name  = "JWT_REFRESH_EXPIRES_IN"
          value = "7d"
        },
        {
          name  = "USER_POOL_ID"
          value = var.general_cognito_user_pool_id
        },
        {
          name  = "USER_POOL_ARN"
          value = var.user_pool_arn
        },
        {
          name  = "APP_CLIENT_ID"
          value = var.general_cognito_client_id
        },
        {
          name  = "ADMINS_CLIENT_ID"
          value = var.admins_client_id
        },
        {
          name  = "RUN_MIGRATIONS"
          value = "true"
        },
        {
          name  = "SES_FROM_EMAIL"
          value = var.ses_from_email
        },
        {
          name  = "SES_FROM_NAME"
          value = var.ses_from_name
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${local.name}"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
          awslogs-create-group  = "true"
        }
      }
      command = ["sh", "-c", "if [ \"$RUN_MIGRATIONS\" = \"true\" ]; then npm run migration:run; fi && npm run start:prod"]
    }
  ])
}

# Resource: aws_ecs_service
# Mantiene la aplicación corriendo. Asegura que siempre haya X copias (desired_count) de la tarea.
resource "aws_ecs_service" "main" {
  name            = "${local.name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1         # Número inicial de réplicas. 
  launch_type     = "FARGATE" # Serverless compute engine
  force_new_deployment = true # Forzar el despliegue de la nueva tarea con la última task disponible

  # Configuración de red para las tareas
  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true # Necesario en subredes públicas para bajar imagen de ECR
  }

  # Conexión con el Load Balancer
  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = local.name
    container_port   = 4000
  }

  # Ignorar desired_count para evitar conflictos con AutoScaling
  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [aws_lb_listener.front_end] # Espera a que el ALB esté listo
}

# Resource: aws_appautoscaling_target
# Define el objetivo de escalado (el servicio ECS) y sus límites (min/max).
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Resource: aws_appautoscaling_policy (CPU)
# Política de escalado basada en uso de CPU. Mantiene el CPU promedio al 70%.
resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "${local.name}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

# Resource: aws_appautoscaling_policy (Memory)
# Política de escalado basada en uso de Memoria. Mantiene la RAM promedio al 70%.
resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "${local.name}-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = 70.0
  }
}

# Resource: aws_iam_role
# Rol de IAM que permite al agente de ECS ejecutar acciones en tu nombre (pull image, logs).
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${local.name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Resource: aws_iam_role_policy_attachment
# Adjunta la política predefinida de AWS para ejecución de tareas ECS al rol.
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Resource: aws_cloudwatch_log_group
# Grupo de logs en CloudWatch para centralizar la salida estándar (stdout/stderr) de los contenedores.
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${local.name}"
  retention_in_days = 7
}
