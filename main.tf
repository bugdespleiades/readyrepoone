module "terraformaws" {
  source  = "./module"

#  vpc_cidr_block      = "172.20.0.0/16"
#  subnet_cidr_block   = "172.20.0.0/24"
#  availability_zone  = "us-east-1a"
  aws_vpc             = "vpc_piero"
  bastion_sg_name     = "bastion_sg"
  aws_key_pair        = "keyjenkins"
#  ami                 = "ami-0c94855ba95c71c99"
#  instance_type       = "t2.micro"
}
# # Créer une passerelle Internet
# module "aws_internet_gateway" "gw" {
#   source = "module"
#   vpc_id = aws_vpc.main.id
# }

# # Créer un VPC
# module "aws_vpc" "main" {
#   source = "module"
# #  cidr_block = "172.16.0.0/16"
# }

# # Créer une subnet publique
# module "aws_subnet" "public" {
#   source = "module"
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "172.16.1.0/24"
#   availability_zone = "us-east-1a"
#   map_public_ip_on_launch = true
# }

# # Créer une subnet privée
# module "aws_subnet" "private" {
#   source = "module"
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "172.16.2.0/24"
#   availability_zone = "us-east-1a"
# }

# # Créer un groupe de sécurité pour le bastion
# module "aws_security_group" "bastion_sg" {
#   source = "module"
#   name        = "bastion_sg"
#   description = "sg_bastion"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     from_port   =22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# # Créer un groupe de sécurité pour l'instance privée
# module "aws_security_group" "private_sg" {
#   source = "module"
#   name        = "private_sg"
#   description = "sg_private_instance"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = [aws_subnet.public.cidr_block]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
#  data "aws_key_pair" "terraform1" {
#   key_name           = "keyjenkins"
#   include_public_key = false
# }
# # Créer une table de routage pour le sous-réseau publique
# module "aws_route_table" "public" {
#   source = "module"
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.gw.id
#   }

#   tags = {
#     Name = "public"
#   }
# }
# # Créer une table de routage pour le sous-réseau privé
# module "aws_route_table" "private" {
#   source = "module"
#   vpc_id = aws_vpc.main.id

#   # Ne pas ajouter de route ici, on la créera séparément
#   tags = {
#     Name = "private"
#   }
# }
# # Associer la table de routage à la sous-réseau publique
# module "aws_route_table_association" "public" {
#   source = "module"
#   subnet_id      = aws_subnet.public.id
#   route_table_id = aws_route_table.public.id
# }
# # Associer la table de routage à la sous-réseau privé
# module "aws_route_table_association" "private" {
#   source = "module"
#   subnet_id      = aws_subnet.private.id
#   route_table_id = aws_route_table.private.id
# }
# # Création d'une EIP
# module "aws_eip" "private" {
#   source = "module"
#   vpc = true
# }
# # Créer une passerelle nat
# module "aws_nat_gateway" "private" {
#   source = "module"
#   allocation_id = aws_eip.private.id
#   subnet_id     = aws_subnet.public.id

#   tags = {
#     Name = "gw NAT"
#   }
# }
# module "aws_route" "private_nat" {
#   source = "module"
#   route_table_id         = aws_route_table.private.id
#   nat_gateway_id         = aws_nat_gateway.private.id
#   destination_cidr_block = "0.0.0.0/0"
# }
# # Créer une instance EC2 pour le bastion
# module "aws_instance" "bastion" {
#   source = "module"
#   ami           = "ami-0c94855ba95c71c99"
#   instance_type = "t2.micro"
#   subnet_id     = aws_subnet.public.id
#   vpc_security_group_ids = [aws_security_group.bastion_sg.id]
#   key_name               = data.aws_key_pair.terraform1.key_name
# }

# # Créer une instance EC2 privée
# module "aws_instance" "private" {
#   source = "module"
#   ami           = "ami-0c94855ba95c71c99"
#   instance_type = "t2.micro"
#   subnet_id     = aws_subnet.private.id
#   vpc_security_group_ids = [aws_security_group.private_sg.id]
#   key_name               = data.aws_key_pair.terraform1.key_name
# }
