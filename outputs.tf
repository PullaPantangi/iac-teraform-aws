output vpc_id {
  value = aws_vpc.pulla-main.id
}
output sub_id {
  value = aws_subnet.public-1.id
}
output sg1 {
  value = aws_security_group.pulla-main_sg1.id
}
output instance_arn {
  value = aws_instance.Pub1.arn
}        