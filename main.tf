
# Créer une passerelle Internet
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Créer un VPC
resource "aws_vpc" "main" {
  cidr_block = "172.16.0.0/16"
}

# Créer une subnet publique
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "172.16.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

# Créer une subnet privée
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "172.16.2.0/24"
  availability_zone = "us-east-1a"
}

# Créer un groupe de sécurité pour le bastion
resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
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
  key_name           = "labuser2"
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
# resource "aws_route_table" "private" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.gw.id
#   }

#   tags = {
#     Name = "public"
#   }
# }
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
  ami           = "ami-0c94855ba95c71c99"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = data.aws_key_pair.terraform1.key_name
}

# Créer une instance EC2 privée
resource "aws_instance" "private" {
  ami           = "ami-0c94855ba95c71c99"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name               = data.aws_key_pair.terraform1.key_name
}

# # Création d'un VPC
# resource "aws_vpc" "terraform1" {
#   cidr_block = var.vpc_cidr_block
# }

# # Création d'une sous-réseau dans le VPC
# resource "aws_subnet" "terraform1" {
#   vpc_id     = aws_vpc.terraform1.id
#   cidr_block = var.subnet_cidr_block
#   availability_zone = var.availability_zone
# }

# # Création d'une passerelle Internet pour le VPC
# resource "aws_internet_gateway" "terraform1" {
#   vpc_id = aws_vpc.terraform1.id
# }

# # Création d'une passerelle de sortie pour le VPC
# resource "aws_egress_only_internet_gateway" "terraform1" {
#   vpc_id = aws_vpc.terraform1.id
# }

# # Création d'une interface réseau dans la sous-réseau
# resource "aws_network_interface" "terraform1" {
#   subnet_id   = aws_subnet.terraform1.id
#   private_ips = ["172.20.0.100"] # Adresse IP dans le bloc d'adresses de la sous-réseau

#   tags = {
#     Name = "primary_network_interface"
#   }
# }

# # Création d'une table de routage pour le VPC
# resource "aws_route_table" "terraform1" {
#   vpc_id = aws_vpc.terraform1.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.terraform1.id
#   }

#   route {
#     ipv6_cidr_block        = "::/0"
#     egress_only_gateway_id = aws_egress_only_internet_gateway.terraform1.id
#   }

#   tags = {
#     Name = "terraform1"
#   }
# }

# # Association de la table de routage avec la sous-réseau
# resource "aws_route_table_association" "terraform1" {
#   subnet_id      = aws_subnet.terraform1.id
#   route_table_id = aws_route_table.terraform1.id
# }

# data "aws_key_pair" "terraform1" {
#   key_name           = var.key_name
#   include_public_key = false
# }

# # Création d'une instance EC2
# resource "aws_instance" "terraform1" {
#   ami           = var.ami_id
#   instance_type = var.instance_type
#   vpc_security_group_ids = [aws_security_group.terraform1.id]
#   subnet_id = aws_subnet.terraform1.id
#   key_name               = data.aws_key_pair.terraform1.key_name
#   associate_public_ip_address = true

#   tags = {
#     Name = "terraform1"
#   }
# }

# # Création d'un groupe de sécurité pour l'instance EC2
# resource "aws_security_group" "terraform1" {
#   name        = var.security_group_name
#   description = "security_group_terraform1"
#   vpc_id      = aws_vpc.terraform1.id

#   # Autorisation du trafic SSH entrant
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # Autorisation du trafic sortant
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = var.security_group_name
#   }
# }

# ## ________________________________________________________________________________________________________________________
# # # Création d'un VPC
# # resource "aws_vpc" "terraform1" {
# #   cidr_block = "172.20.0.0/16"
# # }

# # # Création d'une sous-réseau dans le VPC
# # resource "aws_subnet" "terraform1" {
# #   vpc_id     = aws_vpc.terraform1.id
# #   cidr_block = "172.20.0.0/24"
# #   availability_zone = "us-east-1a"
# # }

# # # Création d'une passerelle Internet pour le VPC
# # resource "aws_internet_gateway" "terraform1" {
# #   vpc_id = aws_vpc.terraform1.id
# # }

# # # Création d'une passerelle de sortie pour le VPC
# # resource "aws_egress_only_internet_gateway" "terraform1" {
# #   vpc_id = aws_vpc.terraform1.id
# # }

# # # Création d'une interface réseau dans la sous-réseau
# # resource "aws_network_interface" "terraform1" {
# #   subnet_id   = aws_subnet.terraform1.id
# #   private_ips = ["172.20.0.100"] # Adresse IP dans le bloc d'adresses de la sous-réseau

# #   tags = {
# #     Name = "primary_network_interface"
# #   }
# # }

# # # Création d'une table de routage pour le VPC
# # resource "aws_route_table" "terraform1" {
# #   vpc_id = aws_vpc.terraform1.id

# #   route {
# #     cidr_block = "0.0.0.0/0"
# #     gateway_id = aws_internet_gateway.terraform1.id
# #   }

# #   route {
# #     ipv6_cidr_block        = "::/0"
# #     egress_only_gateway_id = aws_egress_only_internet_gateway.terraform1.id
# #   }

# #   tags = {
# #     Name = "terraform1"
# #   }
# # }

# # # Association de la table de routage avec la sous-réseau
# # resource "aws_route_table_association" "terraform1" {
# #   subnet_id      = aws_subnet.terraform1.id
# #   route_table_id = aws_route_table.terraform1.id
# # }
# # data "aws_key_pair" "terraform1" {
# #   key_name           = "labuser2"
# #   include_public_key = false
# # }

# # # Création d'une instance EC2 t2 micro avec Debian 12
# # resource "aws_instance" "terraform1" {
# #   ami           = "ami-0c94855ba95c71c99" # ID de l'AMI Debian 12 pour la région us-east-1
# #   instance_type = "t2.micro"
# #   vpc_security_group_ids = [aws_security_group.terraform1.id]
# #   subnet_id = aws_subnet.terraform1.id
# #    key_name               = data.aws_key_pair.terraform1.key_name
# #    associate_public_ip_address = true

# #   tags = {
# #     Name = "terraform1"
# #   }
# # }

# # # Création d'un groupe de sécurité pour l'instance EC2
# # resource "aws_security_group" "terraform1" {
# #   name        = "terraform1"
# #   description = "security_group_terraform1"
# #   vpc_id      = aws_vpc.terraform1.id

# #   # Autorisation du trafic SSH entrant
# #   ingress {
# #     from_port   = 22
# #     to_port     = 22
# #     protocol    = "tcp"
# #     cidr_blocks = ["0.0.0.0/0"]
# #   }

# #   # Autorisation du trafic sortant
# #   egress {
# #     from_port   = 0
# #     to_port     = 0
# #     protocol    = "-1"
# #     cidr_blocks = ["0.0.0.0/0"]
# #   }

# #   tags = {
# #     Name = "terraform1"
# #   }
# # }