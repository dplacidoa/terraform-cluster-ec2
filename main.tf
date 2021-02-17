provider "aws" {
  access_key = "AKIAQH7HGAUY6CVGWI6U"
  secret_key = "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"
  region     = var.name_region
}
#CREACION DE VPC
resource "aws_vpc" "vpc_jboss" {
  cidr_block = "172.70.0.0/16"
  tags = {
    Name = "vpc_jboss_domain"
  }
}
#CREACION DE SUBNET EN AZ-A
resource "aws_subnet" "subnet_jboss_AZA" {
  vpc_id            = aws_vpc.vpc_jboss.id
  cidr_block        = "172.70.0.0/20"
  map_public_ip_on_launch = true
  availability_zone = var.availability_zone_A
  #Auto-assign public IPv4
  tags = {
    Name = "subnet_jboss_domain_AZA"
  }
}
#CREACION DE SUBNET EN AZ-B
resource "aws_subnet" "subnet_jboss_AZB" {
  vpc_id            = aws_vpc.vpc_jboss.id
  cidr_block        = "172.70.16.0/20"
  map_public_ip_on_launch = true
  availability_zone = var.availability_zone_B
  #Auto-assign public IPv4
  tags = {
    Name = "subnet_jboss_domain_AZB"
  }
}
#CREATE INTERNET GATEWAY
resource "aws_internet_gateway" "gw_jboss_domain" {
  vpc_id = aws_vpc.vpc_jboss.id

  tags = {
    Name = "gw_jboss_domain"
  }
}
#ROUTE TABLES: Create route using internet gateway destination 0.0.0.0/0
resource "aws_route_table" "route_jboss" {
  vpc_id = aws_vpc.vpc_jboss.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw_jboss_domain.id
  }
  tags = {
    Name = "route_jboss_domain"
  }
}
#ROUTE TABLE ASSOCIATION SUBNET AZA
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet_jboss_AZA.id
  route_table_id = aws_route_table.route_jboss.id
}
#ROUTE TABLE ASSOCIATION SUBNET AZB
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet_jboss_AZB.id
  route_table_id = aws_route_table.route_jboss.id
}
#CREACION DE SECURITY GROUP
resource "aws_security_group" "sg_jboss_domain" {
  vpc_id = aws_vpc.vpc_jboss.id

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "sg_jboss_domain"
  }
}
#CREACION DE INSTANCE EC2 - JBOSS-HC1
resource "aws_instance" "jboss_HC1" {
  ami           = var.ami_type
  instance_type = var.instance_type
  subnet_id     = aws_subnet.subnet_jboss_AZA.id
  associate_public_ip_address = true
  security_groups = [aws_security_group.sg_jboss_domain.id]
  #Crear key_pair para poder conectarnos a la instancia, de lo contrario no es posible
  key_name = var.key_pair
  tags = {
    "Name"        = "Jboss-HostController1"
    "Environment" = "QA"
  }
}
#CREACION DE VOLUMEN PARA INSTANCIA EC2 - JBOSS-HC1
resource "aws_ebs_volume" "ebs-jboss1" {
  availability_zone = var.availability_zone_A
  size              = 40
}
#ATACHAR EL VOLUMEN EN LA INSTANCIA EC2 - JBOSS-HC1
resource "aws_volume_attachment" "ebs_attach1" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.ebs-jboss1.id
  instance_id = aws_instance.jboss_HC1.id
}
#CREACION DE INTERFACE - IP PRIVADA EN SUBNET A
#resource "aws_network_interface" "jboss_HC1" {
#  subnet_id       = aws_subnet.subnet_jboss_AZA.id
#  private_ips     = ["172.70.7.107"] #172.70.21.44
#  security_groups = [aws_security_group.sg_jboss_domain.id]
#  attachment {
#    instance     = aws_instance.jboss_HC1.id
#    device_index = 1
#  }
#  tags = {
#    Name = "interface_jboss_HC1"
#  }
#}
#CREACION DE INSTANCE EC2 - JBOSS-HC2
resource "aws_instance" "jboss_HC2" {
  ami           = var.ami_type
  instance_type = var.instance_type
  subnet_id     = aws_subnet.subnet_jboss_AZB.id
  associate_public_ip_address = true
  security_groups = [aws_security_group.sg_jboss_domain.id]
  #Crear key_pair para poder conectarnos a la instancia, de lo contrario no es posible
  key_name = var.key_pair
  tags = {
    "Name"        = "Jboss-HostController2"
    "Environment" = "QA"
  }
}
#CREACION DE VOLUMEN PARA INSTANCIA EC2 - JBOSS-HC1
resource "aws_ebs_volume" "ebs-jboss2" {
  availability_zone = var.availability_zone_B
  size              = 40
}
#ATACHAR EL VOLUMEN EN LA INSTANCIA EC2 - JBOSS-HC1
resource "aws_volume_attachment" "ebs_attach2" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.ebs-jboss2.id
  instance_id = aws_instance.jboss_HC2.id
}
#CREACION DE INTERFACE - IP PRIVADA EN SUBNET B
#resource "aws_network_interface" "jboss_HC2" {
#  subnet_id   = aws_subnet.subnet_jboss_AZB.id
#  private_ips = ["172.70.19.103"] #172.70.21.44
#  security_groups = [aws_security_group.sg_jboss_domain.id]
#  attachment {
#    instance     = aws_instance.jboss_HC2.id
#    device_index = 1
#  }
#  tags = {
#    Name = "interface_jboss_HC2"
#  }
#}