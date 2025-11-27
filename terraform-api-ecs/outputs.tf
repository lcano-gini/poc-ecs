# ==============================================================================
# OUTPUTS.TF
# Valores de salida útiles después del despliegue
# ==============================================================================

output "alb_dns_name" {
  description = "DNS público del Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "ecr_repository_url" {
  description = "URL del repositorio ECR para subir la imagen Docker"
  value       = aws_ecr_repository.app.repository_url
}

output "api_gateway_endpoint" {
  description = "URL pública del API Gateway"
  value       = aws_apigatewayv2_api.main.api_endpoint
}

output "rds_endpoint" {
  description = "Endpoint de conexión a la base de datos RDS (host:port)"
  value       = aws_db_instance.postgres.endpoint
}

output "rds_db_name" {
  description = "Nombre de la base de datos creada"
  value       = aws_db_instance.postgres.db_name
}
