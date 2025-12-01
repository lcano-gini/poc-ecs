# ==============================================================================
# ECR.TF
# Elastic Container Registry - Almacenamiento de imágenes Docker
# ==============================================================================

# Resource: aws_ecr_repository
# Crea el repositorio privado donde se subirán las imágenes de la aplicación.
resource "aws_ecr_repository" "app" {
  name                 = local.name
  image_tag_mutability = "MUTABLE" # Permite sobrescribir tags (ej: 'latest')
  force_delete         = true      # ¡Cuidado! Borra el repo aunque tenga imágenes al hacer destroy

  # Configuración de escaneo de seguridad
  image_scanning_configuration {
    scan_on_push = true # Escanea vulnerabilidades automáticamente al subir una imagen
  }
}
