
# Créer une passerelle Internet
resource "aws_internet_gateway" "gw" {
  vpc_id = var.aws_vpc.main.id
}

# Créer un VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
}

# Créer une subnet publique
resource "aws_subnet" "public" {
  vpc_id            = var.aws_vpc.main.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.availability_zone
  map_public_ip_on_launch = true
}

# Créer une subnet privée
resource "aws_subnet" "private" {
  vpc_id            = var.aws_vpc.main.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.availability_zone
}

# Créer un groupe de sécurité pour le bastion
resource "aws_security_group" "bastion_sg" {
  name        = var.bastion_sg_name
  description = "sg_bastion"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   =22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Créer un groupe de sécurité pour l'instance privée
resource "aws_security_group" "private_sg" {
  name        = "private_sg"
  description = "sg_private_instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
 data "aws_key_pair" "terraform1" {
  key_name           = var.aws_key_pair
  include_public_key = false
}
# Créer une table de routage pour le sous-réseau publique
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public"
  }
}
# Créer une table de routage pour le sous-réseau privé
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  # Ne pas ajouter de route ici, on la créera séparément
  tags = {
    Name = "private"
  }
}
# Associer la table de routage à la sous-réseau publique
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
# Associer la table de routage à la sous-réseau privé
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
# Création d'une EIP
resource "aws_eip" "private" {
  vpc = true
}
# Créer une passerelle nat
resource "aws_nat_gateway" "private" {
  allocation_id = aws_eip.private.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "gw NAT"
  }
}
resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  nat_gateway_id         = aws_nat_gateway.private.id
  destination_cidr_block = "0.0.0.0/0"
}
# Créer une instance EC2 pour le bastion
resource "aws_instance" "bastion" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = data.aws_key_pair.terraform1.key_name
}

# Créer une instance EC2 privée
resource "aws_instance" "private" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name               = data.aws_key_pair.terraform1.key_name
}
