resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "MyTerraformVPC"
  }
}
#public subnet
resource "aws_subnet" "PublicSubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
}
#private subnet
resource "aws_subnet" "PrivateSubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.2.0/24"
}
# internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myvpc.id
}
# route table
resource "aws_route_table" "publicRT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "RT_association" {
  subnet_id      = aws_subnet.PublicSubnet.id
  route_table_id = aws_route_table.publicRT.id
}
#----------------bastion public ------------------------------------------------------------
resource "aws_security_group" "bastion" {
  name        = "BastionSG"  
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  tags = {
    Name = "bastion"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.bastion.id
  cidr_ipv4         = "103.115.206.103/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.bastion.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

#-----------------bastion private------------------------------------------
resource "aws_security_group" "private_ec2_sg" {
  name        = "private_ec2_sg"
  description = "Allow SSH from Bastion only"
  vpc_id      = aws_vpc.myvpc.id
  tags = {
    Name = "private_ec2_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "private_ssh" {
  security_group_id            = aws_security_group.private_ec2_sg.id
  referenced_security_group_id = aws_security_group.bastion.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_egress_rule" "private_outbound" {
  security_group_id = aws_security_group.private_ec2_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
#------------------elastic ip nat ------------------------------------------------
resource "aws_eip" "nat_eip" {
  domain = "vpc"    
}
#----------------------nat gateway --------------------------------
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.PublicSubnet.id

  tags = {
    Name = "gw NAT"
  }
  depends_on = [aws_internet_gateway.gw]
}

#------------------------------------ private route table--------------------
resource "aws_route_table" "privateRT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id   
  }
}

resource "aws_route_table_association" "private_RT_association" {
  subnet_id      = aws_subnet.PrivateSubnet.id  
  route_table_id = aws_route_table.privateRT.id
}
#-------------------------------------- bastion instance -------------------------------
resource "aws_instance" "bastion" {
  ami           = "ami-07a00cf47dbbc844c"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.PublicSubnet.id
  key_name      = "firstaws"
  
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true

  tags = {
    Name = "Bastion"
  }
}
#------------------------------ private instance ----------------------------------
resource "aws_instance" "private_ec2" {
  ami           = "ami-07a00cf47dbbc844c"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.PrivateSubnet.id
  key_name      = "firstaws"

  vpc_security_group_ids      = [aws_security_group.private_ec2_sg.id]
  associate_public_ip_address = false

  tags = {
    Name = "Private-EC2"
  }
}
