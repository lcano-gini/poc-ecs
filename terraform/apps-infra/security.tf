# ==============================================================================
# SECURITY.TF
# Definición de Grupos de Seguridad (Firewalls virtuales)
# ==============================================================================

# Resource: aws_security_group (ALB)
# Controla el tráfico permitido hacia y desde el Application Load Balancer.
resource "aws_security_group" "alb_sg" {
  name        = "${local.name}-alb-sg"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.main.id

  # Ingress: Permite tráfico HTTP (puerto 80) desde cualquier IP (0.0.0.0/0)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress: Permite todo el tráfico de salida (necesario para conectar con los targets)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 significa todos los protocolos
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Resource: aws_security_group (ECS)
# Controla el tráfico hacia los contenedores (tareas) de ECS.
# Implementa el principio de "mínimo privilegio" permitiendo solo tráfico desde el ALB.
resource "aws_security_group" "ecs_sg" {
  name        = "${local.name}-ecs-sg"
  description = "Allow traffic from ALB"
  vpc_id      = aws_vpc.main.id

  # Ingress: Permite tráfico en el puerto de la app (3000) SOLO si viene del ALB SG.
  # Esto evita que alguien acceda directo a los contenedores saltándose el balanceador.
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Egress: Permite salida a internet (necesario para descargar imagen Docker, logs, etc.)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Resource: aws_security_group (RDS)
# Controla el tráfico hacia la base de datos.
# Permite tráfico únicamente desde el grupo de seguridad de ECS.
resource "aws_security_group" "rds_sg" {
  name        = "${local.name}-rds-sg"
  description = "Allow PostgreSQL traffic from ECS"
  vpc_id      = aws_vpc.main.id

  # Ingress: Permite tráfico PostgreSQL (5432) SOLO si viene del ECS SG.
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  # Egress: Permite salida (normalmente no necesario para RDS, pero buena práctica)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
