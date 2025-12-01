# ==============================================================================
# PROVIDERS.TF
# Configuración de proveedores y fuentes de datos globales
# ==============================================================================

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Provider: AWS
# Configura la autenticación y región para interactuar con AWS.
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# Data Source: aws_availability_zones
# Obtiene dinámicamente las zonas de disponibilidad (AZs) disponibles en la región actual.
# Esto permite desplegar subredes en múltiples AZs sin hardcodear nombres (ej: us-east-1a).
data "aws_availability_zones" "available" {}
