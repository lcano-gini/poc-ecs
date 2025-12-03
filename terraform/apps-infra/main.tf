resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  # Generates a dynamic name like "gini-apps-a1b2c3d4"
  name = "${var.main_app_name}-${random_id.suffix.hex}"
}

