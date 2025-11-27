# ==============================================================================
# APIGATEWAY.TF
# API Gateway HTTP - Puerta de entrada simplificada
# ==============================================================================

# Resource: aws_apigatewayv2_api
# Crea una API HTTP (más rápida y barata que REST API).
resource "aws_apigatewayv2_api" "main" {
  name          = "${var.app_name}-gateway"
  protocol_type = "HTTP"
}

# Resource: aws_apigatewayv2_stage
# Define el stage de despliegue (ej: default, dev, prod).
# auto_deploy = true aplica cambios automáticamente.
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn
    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    })
  }
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name              = "/aws/api-gateway/${var.app_name}"
  retention_in_days = 7
}

# Resource: aws_apigatewayv2_integration
# Configura cómo API Gateway pasa las peticiones al backend (ALB).
resource "aws_apigatewayv2_integration" "alb" {
  api_id             = aws_apigatewayv2_api.main.id
  integration_type   = "HTTP_PROXY" # Pasa la petición tal cual
  integration_uri    = "http://${aws_lb.main.dns_name}"
  integration_method = "ANY"
  connection_type    = "INTERNET" 
  # Usamos INTERNET porque nuestro ALB es público.
  # Si el ALB fuera privado, usaríamos VPC_LINK.
}

# Resource: aws_apigatewayv2_route
# Define la ruta por defecto. Captura todo el tráfico y lo manda a la integración.
resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "$default" # Ruta especial que captura todo el tráfico sin modificar el path
  target    = "integrations/${aws_apigatewayv2_integration.alb.id}"
}
