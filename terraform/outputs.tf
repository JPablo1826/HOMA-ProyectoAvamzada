# ==============================================================
# Terraform - Outputs
# ==============================================================

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "ecs_cluster_name" {
  description = "ECS Cluster Name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  description = "ECS Cluster ARN"
  value       = aws_ecs_cluster.main.arn
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.main.arn
}

output "backend_target_group_arn" {
  description = "ARN of the backend target group"
  value       = aws_lb_target_group.backend.arn
}

output "frontend_target_group_arn" {
  description = "ARN of the frontend target group"
  value       = aws_lb_target_group.frontend.arn
}

output "rds_cluster_endpoint" {
  description = "RDS Cluster Endpoint"
  value       = aws_rds_cluster.main.endpoint
  sensitive   = true
}

output "rds_cluster_reader_endpoint" {
  description = "RDS Cluster Reader Endpoint"
  value       = aws_rds_cluster.main.reader_endpoint
  sensitive   = true
}

output "rds_cluster_port" {
  description = "RDS Cluster Port"
  value       = aws_rds_cluster.main.port
}

output "rds_database_name" {
  description = "RDS Database Name"
  value       = aws_rds_cluster.main.database_name
}

output "backend_service_name" {
  description = "Backend ECS Service Name"
  value       = aws_ecs_service.backend.name
}

output "frontend_service_name" {
  description = "Frontend ECS Service Name"
  value       = aws_ecs_service.frontend.name
}

output "cloudwatch_log_group_backend" {
  description = "Backend CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.backend.name
}

output "cloudwatch_log_group_frontend" {
  description = "Frontend CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.frontend.name
}

output "terraform_state_bucket" {
  description = "S3 bucket for Terraform state"
  value       = "homa-terraform-state"
}
