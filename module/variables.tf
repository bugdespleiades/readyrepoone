

variable "vpc_cidr_block" {
  type        = string
  default     = "172.20.0.0/16"
  description = "Bloc d'adresses du VPC"
}

variable "subnet_cidr_block" {
  type        = string
  default     = "172.20.0.0/24"
  description = "Bloc d'adresses de la sous-réseau"
}

variable "availability_zone" {
  type        = string
  default     = "us-east-1a"
  description = "Zone de disponibilité"
}

variable "bastion_sg_name" {
  type        = string
  default     = "bastion_sg"
}
variable "aws_key_pair" {
  type        = string
  description = "nome de la paire de clef ssh"
}
variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Type d'instance EC2"
}

variable "ami_id" {
  type        = string
  default     = "ami-0c94855ba95c71c99"
  description = "ID de l'AMI Debian 12"
}

variable "key_name" {
  type        = string
  default     = "labuser2"
  description = "Nom de la paire de clés"
}

variable "security_group_name" {
  type        = string
  default     = "terraform1"
  description = "Nom du groupe de sécurité"
}
variable "ami" {
  type        = string
  default     = "ami-0c94855ba95c71c99"
  description = "ID de l'AMI Debian 12"
}
variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "type d'insrtance ec2"
}