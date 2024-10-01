terraform {
  backend "s3" {
    bucket         = "cmcio-terraform"       # Nombre del bucket de S3
    key            = "terraform/state/terraform.tfstate"        # Ruta y nombre del archivo de estado dentro del bucket
    region         = "us-west-1"             # Región de AWS donde se encuentra el bucket
    dynamodb_table = "cmcio-state"           # Tabla de DynamoDB para el bloqueo del estado
    encrypt        = true                    # Habilitar cifrado del archivo de estado
  }
}

# Inicia sesión en AWS con la CLI de AWS
provider "aws" {
  region = "us-west-1"
}
#Creacion de la vpc
resource "aws_vpc" "vpc-cmcio" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-cmcio"
  }
  
}
#Creacion de la subred en la zona 1 
resource "aws_subnet" "sbn-cmcio-1" {
  vpc_id            = aws_vpc.vpc-cmcio.id
  cidr_block        = var.subnet_cidr
  availability_zone = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "sbn-cmcio-1"
  }
  
}

#Creacion de la subred en la zona 2 
resource "aws_subnet" "sbn-cmcio-2" {
  vpc_id            = aws_vpc.vpc-cmcio.id
  cidr_block        = var.subnet_cidr_2
  availability_zone = var.availability_zone2
  map_public_ip_on_launch = true

  tags = {
    Name = "sbn-cmcio-2"
  }
  
}

#creacion de la internet gateway
resource "aws_internet_gateway" "igw-cmcio" {
  vpc_id = aws_vpc.vpc-cmcio.id

  tags = {
    Name = "igw-cmcio"
  }
  
}
# Creacion de la tabla de rutas
resource "aws_route_table" "rt-cmcio" {
  vpc_id = aws_vpc.vpc-cmcio.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-cmcio.id
  }

  tags = {
    Name = "rt-cmcio"
  }
  
}

# Asociacion de la tabla de rutas con la subred
resource "aws_route_table_association" "ta-cmcio" {
  subnet_id      = aws_subnet.sbn-cmcio-1.id
  route_table_id = aws_route_table.rt-cmcio.id
  
}
#creacion de el grupo de seguridad
#commun
resource "aws_security_group" "common-sg-cmcio" {
  name = "common-sg-cmcio"
  vpc_id = aws_vpc.vpc-cmcio.id
  
  # Allow HTTPS
  ingress {
    description = "Allow HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
  # Allow HTTP
  ingress {
    description = "Allow HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.lb_sg-cmcio.id]
    
    }
  # Allow SSH
  ingress{
    description = "SSH access"
    from_port   = 22
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
    

  tags = {
    Name = "master-node-sg"
  }
}
# master-sg
resource "aws_security_group" "controlplane-sg-cmcio" {
  name = "controlplane-sg-cmcio"
  vpc_id = aws_vpc.vpc-cmcio.id
  tags = {
    "Name" = "controlplane-sg-cmcio"
  }
  
  # etcd peers
  ingress{
    description = "etcd peers"
    from_port   = 2380 
    to_port     = 2380 
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
  # kube-apiserver
  ingress{
    description = "kube-apiserver"
    from_port   = 6443 
    to_port     = 6443 
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
  # k0s-api
  ingress{
    description = "k0s-api"
    from_port   = 10250 
    to_port     = 10250 
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
  # konnectivity 
  ingress{
    description = "konnectivity"
    from_port   = 8132  
    to_port     = 8132  
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
  
  
}


# Security group for the Load Balancer
resource "aws_security_group" "lb_sg-cmcio" {
  name = "lb_sg-cmcio"
  vpc_id = aws_vpc.vpc-cmcio.id
  tags = {
    "Name" = "lb_sg-cmcio"
  }

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
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


# worker-sg
resource "aws_security_group" "nodes-sg-cmcio" {
  name = "nodes-sg-cmcio"
  vpc_id = aws_vpc.vpc-cmcio.id
  tags = {
    "Name" = "nodes-sg-cmcio"
  }
  
  # kube-apiserver
  ingress{
    description = "kube-apiserver"
    from_port   = 6443 
    to_port     = 6443 
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
  # kube-router
  ingress{
    description = "kube-router"
    from_port   = 179  
    to_port     = 179  
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
  # Calico
  ingress{
    description = "Calico"
    from_port   = 4789  
    to_port     = 4789  
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
  # kubelet
  ingress{
    description = "kubelet"
    from_port   = 10250  
    to_port     = 10250  
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
  # konnectivity
  ingress{
    description = "konnectivity"
    from_port   = 8132   
    to_port     = 8132   
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
  # NodePort Services
  ingress{
    description = "NodePort Services"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
  
  # Allow traffic from the Load Balancer
  ingress {
    description = "Allow traffic from the Load Balancer"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.lb_sg-cmcio.id]
  }
  
}
# Load Balancer
resource "aws_lb" "lb-cmcio" {
  name               = "lb-cmcio"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg-cmcio.id]
  subnets            = [aws_subnet.sbn-cmcio-1.id, aws_subnet.sbn-cmcio-2.id]

  enable_deletion_protection = false
}

# Target Group
resource "aws_lb_target_group" "lb-tg-cmcio" {
  name     = "lb-tg-cmcio"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc-cmcio.id

  health_check {
    interval            = 30
    path                = "/"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# Listener
resource "aws_lb_listener" "lb-l-cmcio" {
  load_balancer_arn = aws_lb.lb-cmcio.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
     target_group_arn = aws_lb_target_group.lb-tg-cmcio.arn
  }
}
# Crear una configuracion de destino para el grupo de objetivos
resource "aws_lb_target_group_attachment" "example" {
  target_group_arn = aws_lb_target_group.lb-tg-cmcio.arn
  target_id        = aws_instance.nodes.id
  port             = 80
}

#Obtener el dns del load balancer
output "load_balancer_dns_name" {
  value = aws_lb.lb-cmcio.dns_name
}

#Seccion de instancias de recursos de AWS
resource "aws_instance" "ControlPlane" {
  ami           = var.ami_id  # Ubuntu 20.04LTS AMI ID X86_64
  instance_type = var.controlplane_instance_type # Tipo de instancia
  subnet_id     = aws_subnet.sbn-cmcio-1.id# Subnet ID
  security_groups = [
    aws_security_group.common-sg-cmcio.id,
    aws_security_group.controlplane-sg-cmcio.id    
    ] # Grupo de seguridad
  associate_public_ip_address = true # Asigna una IP publica
  key_name =  var.key_name # Nombre del par de claves en AWS
  tags = {
    Name = "ControlPlane"
  }
  provisioner "local-exec" {
    command = <<EOT
    echo "[controlplane]" > inventory.ini
    echo "${self.public_ip} ansible_ssh_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa.pem" >> inventory.ini
    echo "[nodes]" >> inventory.ini
    EOT
  }
}
# ! Salida de la IP publica de las instancias
  output "master_public_ip" {
    value = "${aws_instance.ControlPlane.public_ip}"
  }
#Creacion de la instancias de   workers

resource "aws_instance" "nodes" {
  ami           = var.ami_id  # Ubuntu 20.04LTS AMI ID X86_64
  instance_type = var.nodes_instance_type # Tipo de instancia
  subnet_id     = aws_subnet.sbn-cmcio-1.id # Subnet ID
  security_groups = [
    aws_security_group.common-sg-cmcio.id,
    aws_security_group.nodes-sg-cmcio.id,
    ] # Grupo de seguridad
  associate_public_ip_address = true # Asigna una IP publica
  key_name =  var.key_name # Nombre del par de claves en AWS

  tags = {
    Name = "nodes"
  }
  depends_on = [aws_instance.ControlPlane]

  provisioner "local-exec" {
    command = <<EOT
    echo "${self.public_ip} ansible_ssh_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa.pem" >> inventory.ini
    EOT
  }
}
# ! Salida de la IP privada de la instancia
  output "worker_public_ip" {
    value = "${aws_instance.nodes.public_ip}"
  }