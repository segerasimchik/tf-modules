output "default_vpc_id" {
  value       = data.aws_vpc.default.id
  description = "Default VPC id."
}

output "subnet" {
  value       = data.aws_subnets.default.ids
  description = "List of subnets id for autoscaling group."
}

output "alb_dns_name" {
  value       = aws_alb.example.dns_name
  description = "The dns of LB"
}

output "asg_name" {
  value       = aws_autoscaling_group.example.name
  description = "The autoscaling group name."
}

output "asg_min_value" {
  value       = aws_autoscaling_group.example.min_size
  description = "Minimum quantity of autoscaling group members."
}

output "asg_max_value" {
  value       = aws_autoscaling_group.example.max_size
  description = "Minimum quantity of autoscaling group members."
}

output "alb_security_group" {
  value       = aws_security_group.alb.id
  description = "The id of the Security Group of the alb."
}
