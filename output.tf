output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.myvpc.id
}

output "public_subnet_id" {
  description = "Public Subnet ID"
  value       = aws_subnet.PublicSubnet.id
}

output "private_subnet_id" {
  description = "Private Subnet ID"
  value       = aws_subnet.PrivateSubnet.id
}

output "bastion_public_ip" {
  description = "Bastion Host Public IP"
  value       = aws_instance.bastion.public_ip
}

output "private_ec2_private_ip" {
  description = "Private EC2 Private IP"
  value       = aws_instance.private_ec2.private_ip
}

output "ssh_command" {
  description = "SSH command to connect to Bastion"
  value       = "ssh -i firstaws.pem ec2-user@${aws_instance.bastion.public_ip}"
}
