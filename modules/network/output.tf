output "vpc_id" {
  value = aws_vpc.main.id
}
output "nat_gateway_ips" {
  value = [aws_eip.nat_1.public_ip, aws_eip.nat_2.public_ip]
}
output "eks_subnet_ids" {
  value = [aws_subnet.eks_az1.id, aws_subnet.eks_az2.id, aws_subnet.eks_az3.id]
}
output "db_subnet_ids" {
  value = [aws_subnet.db_az1.id, aws_subnet.db_az2.id, aws_subnet.db_az3.id]
}
