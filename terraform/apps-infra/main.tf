resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  # Generates a dynamic name like "poc-api-a1b2c3d4"
  # Used to avoid naming conflicts
  name = "${var.main_app_name}-${random_id.suffix.hex}"
}

