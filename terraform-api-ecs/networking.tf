# ==============================================================================
# NETWORKING.TF
# Definición de la capa de red (VPC, Subnets, Ruteo)
# ==============================================================================

# Resource: aws_vpc
# Crea la Virtual Private Cloud (VPC) que actuará como red aislada para nuestros recursos.
# CIDR 10.0.0.0/16 permite hasta 65,536 direcciones IP.
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true # Permite que las instancias tengan nombres DNS
  enable_dns_support   = true # Habilita resolución DNS en la VPC

  tags = {
    Name = "${var.app_name}-vpc"
  }
}

# Resource: aws_internet_gateway
# Puerta de enlace que permite la comunicación entre la VPC e Internet.
# Es necesario para que las subredes públicas tengan salida a la red mundial.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.app_name}-igw"
  }
}

# Resource: aws_subnet
# Crea subredes públicas en diferentes zonas de disponibilidad (AZ) para alta disponibilidad.
# count = 2 crea dos subredes.
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24" # 10.0.1.0/24 y 10.0.2.0/24
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true # Asigna IP pública automáticamente a recursos lanzados aquí

  tags = {
    Name = "${var.app_name}-public-${count.index + 1}"
  }
}

# Resource: aws_route_table
# Define las reglas de ruteo para las subredes públicas.
# La regla "0.0.0.0/0" -> Internet Gateway permite tráfico hacia cualquier lugar de internet.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.app_name}-rt-public"
  }
}

# Resource: aws_route_table_association
# Asocia las subredes creadas anteriormente con la tabla de ruteo pública.
# Esto efectivamente convierte a las subredes en "públicas".
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
