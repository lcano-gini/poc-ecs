# ==============================================================================
# ALB.TF
# Application Load Balancer - Distribución de tráfico
# ==============================================================================

# Resource: aws_lb
# Crea el balanceador de carga de aplicación (Capa 7).
# Recibe el tráfico externo y lo distribuye.
resource "aws_lb" "main" {
  name               = "${local.name}-alb"
  internal           = false                   # false = accesible desde internet
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public[*].id # Se despliega en las subredes públicas
}

# Resource: aws_lb_target_group
# Grupo de destino donde el ALB enviará las peticiones.
# Los contenedores ECS se registrarán automáticamente aquí.
resource "aws_lb_target_group" "app" {
  name        = "${local.name}-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip" # Requerido para Fargate (modo awsvpc)

  # Health Check: El ALB verifica constantemente que la app responda.
  health_check {
    path                = "/"
    healthy_threshold   = 2   # Número de checks exitosos para considerar "sano"
    unhealthy_threshold = 10  # Número de fallos para considerar "no sano"
    timeout             = 60
    interval            = 300
    matcher             = "200,404" # Códigos HTTP aceptados como éxito
  }
}

# Resource: aws_lb_listener
# Escucha peticiones en el puerto 80 (HTTP) del ALB y define qué hacer con ellas.
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn # Redirige todo al Target Group de la app
  }
}
