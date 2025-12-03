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
  default     = "gini-apps"
}

variable "main_app_name" {
  description = "Nombre de la aplicación, usado como prefijo para nombrar recursos"
  default     = "gini-apps"
}

variable "image_tag" {
  description = "Tag de la imagen Docker a desplegar"
  type        = string
  default     = "latest"
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

variable "jwt_secret" {
  description = "Secret for JWT signing"
  type        = string
  default     = "secretKey123" 
}

variable "jwt_refresh_secret" {
  description = "Secret for JWT Refresh signing"
  type        = string
  default     = "refreshSecretKey123"
}

variable "ses_from_email" {
  description = "Email remitente para SES"
  type        = string
  default     = "noreply@example.com"
}

variable "ses_from_name" {
  description = "Nombre remitente para SES"
  type        = string
  default     = "UMS App"
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

variable "user_pool_arn" {
  description = "ARN del User Pool de Cognito"
  type        = string
  default     = ""
}

variable "admins_client_id" {
  description = "ID del Cliente de Cognito para Admins"
  type        = string
  default     = ""
}

variable "general_cognito_issuer_url" {
  description = "URL del emisor de Cognito (opcional)"
  type        = string
  default     = ""
}
