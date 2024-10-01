variable "aws_region" {
  description = "La región de AWS a utilizar"
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "El bloque CIDR para la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "El bloque CIDR para la subred"
  type        = string
  default     = "10.0.1.0/24"
}
variable "subnet_cidr_2" {
  description = "El bloque CIDR para la subred"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  description = "La zona de disponibilidad para la subred"
  type        = string
  default     = "us-west-1b"
}
variable "availability_zone2" {
  description = "La zona de disponibilidad para la subred"
  type        = string
  default     = "us-west-1c"
}

variable "ami_id" {
  description = "ID de la AMI para la instancia EC2"
  type        = string
  default     = "ami-0d53d72369335a9d6"  # Ubuntu 20.04LTS AMI ID X86_64
}

variable "controlplane_instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t2.micro"
}
#
variable "nodes_instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t2.micro"
}


variable "key_name" {
  description = "Nombre del par de claves en AWS"
  type        = string
  default     = "masternode"
}