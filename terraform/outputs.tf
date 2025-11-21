output "alb_dns" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.alb.dns_name
}

output "ec2_public_ips" {
  description = "Public IPs of the EC2 nodes"
  value       = aws_instance.nodes[*].public_ip
}
