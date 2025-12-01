# ==============================================================================
# CLOUDFRONT.TF
# Content Delivery Network - Distribución de contenido
# ==============================================================================

# Resource: aws_cloudfront_distribution
# Crea una distribución de CloudFront para cachear y servir la aplicación globalmente.
resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${local.name} CloudFront Distribution"
  default_root_object = "" # ALB maneja las rutas, no es un bucket S3

  # Origin: Define de dónde saca el contenido CloudFront (en este caso, el ALB)
  origin {
    domain_name = aws_lb.main.dns_name
    origin_id   = aws_lb.main.name

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only" # El ALB escucha en HTTP (puerto 80)
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # Default Cache Behavior: Cómo manejar las peticiones por defecto
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_lb.main.name

    forwarded_values {
      query_string = true
      headers      = ["*"] # Reenvía todos los headers al ALB (importante para APIs)

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0 # Para API dinámica, por defecto no cachear agresivamente
    max_ttl                = 86400
    compress               = true
  }

  # Restrictions: Restricciones geográficas
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Viewer Certificate: Certificado SSL para el dominio de CloudFront
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name        = "${local.name}-cloudfront"
    Environment = var.environment
    Project     = var.project_name
  }
}

