# ==============================================================================
# ECS.TF
# Elastic Container Service - Orquestación de Contenedores
# ==============================================================================

# Resource: aws_ecs_cluster
# El clúster lógico que agrupa los servicios y tareas.
resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Resource: aws_ecs_task_definition
# La "receta" para correr el contenedor. Define CPU, RAM, Imagen, Puertos, etc.
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.app_name}-task"
  network_mode             = "awsvpc" # Requerido para Fargate
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256 # .25 vCPU
  memory                   = 512 # 512 MB RAM
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn # Rol para que ECS pueda jalar imagenes y escribir logs

  # Definición del contenedor en formato JSON
  container_definitions = jsonencode([
    {
      name      = var.app_name
      image     = "${aws_ecr_repository.app.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      environment = [
        {
          name  = "DB_HOST"
          value = aws_db_instance.postgres.address
        },
        {
          name  = "DB_PORT"
          value = tostring(aws_db_instance.postgres.port)
        },
        {
          name  = "DB_USERNAME"
          value = var.db_username
        },
        {
          name  = "DB_PASSWORD"
          value = var.db_password
        },
        {
          name  = "DB_NAME"
          value = var.db_name
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.app_name}"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
          awslogs-create-group  = "true"
        }
      }
    }
  ])
}

# Resource: aws_ecs_service
# Mantiene la aplicación corriendo. Asegura que siempre haya X copias (desired_count) de la tarea.
resource "aws_ecs_service" "main" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1         # Número de réplicas
  launch_type     = "FARGATE" # Serverless compute engine

  # Configuración de red para las tareas
  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true # Necesario en subredes públicas para bajar imagen de ECR
  }

  # Conexión con el Load Balancer
  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = var.app_name
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.front_end] # Espera a que el ALB esté listo
}

# Resource: aws_iam_role
# Rol de IAM que permite al agente de ECS ejecutar acciones en tu nombre (pull image, logs).
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.app_name}-ecs-task-execution-role"

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
  name              = "/ecs/${var.app_name}"
  retention_in_days = 7
}
