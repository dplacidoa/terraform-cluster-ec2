output "instance_ippaddr1" {
  value       = aws_instance.jboss_HC1.private_ip
  description = "print private ip for the instance"
}

output "instance_ippaddr2" {
  value       = aws_instance.jboss_HC2.private_ip
  description = "print private ip for the instance"
}

output "instance_id1" {
  value       = aws_instance.jboss_HC1.id
  description = "print id for the instance1"
}

output "instance_id2" {
  value       = aws_instance.jboss_HC2.id
  description = "print id for the instance2"
}