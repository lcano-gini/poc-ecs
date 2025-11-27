# ==============================================================================
# RDS.TF
# Base de datos Relacional (PostgreSQL)
# ==============================================================================

# Resource: aws_db_subnet_group
# Agrupa las subredes donde puede vivir la base de datos.
# RDS requiere al menos dos zonas de disponibilidad (que ya tenemos en aws_subnet.public).
resource "aws_db_subnet_group" "main" {
  name       = "${var.app_name}-db-subnet-group"
  subnet_ids = aws_subnet.public[*].id

  tags = {
    Name = "${var.app_name}-db-subnet-group"
  }
}

# Resource: aws_db_instance
# Instancia de base de datos PostgreSQL.
resource "aws_db_instance" "postgres" {
  identifier           = "${var.app_name}-postgres"
  allocated_storage    = 20            # 20 GB de almacenamiento (minimo para free tier)
  storage_type         = "gp2"         # General Purpose SSD
  engine               = "postgres"
  engine_version       = "16.3"        # Versión de PostgreSQL
  instance_class       = "db.t3.micro" # Instancia pequeña y económica
  
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  
  parameter_group_name = "default.postgres16"
  skip_final_snapshot  = true          # No crear snapshot al destruir (para PoCs)
  publicly_accessible  = false         # No accesible desde internet directamente
  
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  tags = {
    Name = "${var.app_name}-postgres"
  }
}

