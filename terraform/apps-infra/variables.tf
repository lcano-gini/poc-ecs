# ==============================================================================
# VARIABLES.TF
# Definición de variables de entrada
# ==============================================================================

variable "aws_region" {
  description = "Región de AWS donde se desplegarán los recursos"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Perfil de AWS CLI a utilizar para la autenticación"
  type        = string
  default     = "gini-admin" 
}

variable "environment" {
  description = "Nombre del entorno (ej: dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Nombre del proyecto para etiquetado de recursos"
  type        = string
  default     = "poc-api"
}

variable "main_app_name" {
  description = "Nombre de la aplicación, usado como prefijo para nombrar recursos"
  default     = "poc-api"
}

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
}

variable "db_username" {
  description = "Usuario maestro de la base de datos"
  type        = string
}

variable "db_password" {
  description = "Contraseña maestra de la base de datos"
  type        = string
  sensitive   = true
}

# Variables opcionales para conexión con infraestructura general

variable "general_s3_bucket_name" {
  description = "Nombre del bucket S3 de la infraestructura general (opcional)"
  type        = string
  default     = ""
}

variable "general_dynamodb_table_name" {
  description = "Nombre de la tabla DynamoDB de la infraestructura general (opcional)"
  type        = string
  default     = ""
}

variable "general_cognito_user_pool_id" {
  description = "ID del User Pool de Cognito (opcional)"
  type        = string
  default     = ""
}

variable "general_cognito_client_id" {
  description = "ID del Cliente de Cognito (opcional)"
  type        = string
  default     = ""
}

variable "general_cognito_issuer_url" {
  description = "URL del emisor de Cognito (opcional)"
  type        = string
  default     = ""
}
