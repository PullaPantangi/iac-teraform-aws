output "vpc_id" {
  value = aws_vpc.platinum_aws.id
}
output "pvt_sub_id" {
  value = aws_subnet.pvt_subnet_platinum_aws[*].id
}
output "pub_sub_id" {
  value = aws_subnet.pb_subnet_platinum_aws[*].id
}
output "sg1" {
  value = aws_security_group.platinum_sg1.id
}
# output "pvt_instance-ids" {
#   value = aws_instance.Pvt[*].id
# }
output "pub_instance-ids" {
  value = aws_instance.Pub[*].id
}