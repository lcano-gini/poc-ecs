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

variable "app_name" {
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
