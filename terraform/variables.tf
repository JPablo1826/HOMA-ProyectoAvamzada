# ==============================================================
# Terraform - Variables
# ==============================================================

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "homa"
}

# ==============================================================
# VPC Configuration
# ==============================================================

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

# ==============================================================
# RDS Configuration
# ==============================================================

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "homa_avanzada_db"
}

variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

# ==============================================================
# ECS Configuration
# ==============================================================

variable "backend_container_port" {
  description = "Backend container port"
  type        = number
  default     = 8080
}

variable "backend_container_memory" {
  description = "Backend container memory (MB)"
  type        = number
  default     = 512
}

variable "backend_container_cpu" {
  description = "Backend container CPU units"
  type        = number
  default     = 256
}

variable "frontend_container_port" {
  description = "Frontend container port"
  type        = number
  default     = 80
}

variable "frontend_container_memory" {
  description = "Frontend container memory (MB)"
  type        = number
  default     = 256
}

variable "frontend_container_cpu" {
  description = "Frontend container CPU units"
  type        = number
  default     = 128
}

variable "ecs_desired_count" {
  description = "Desired number of containers"
  type        = number
  default     = 1
}

# ==============================================================
# ALB Configuration
# ==============================================================

variable "enable_https" {
  description = "Enable HTTPS"
  type        = bool
  default     = true
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  type        = string
  default     = ""
}

# ==============================================================
# Domain Configuration
# ==============================================================

variable "domain_name" {
  description = "Domain name"
  type        = string
  default     = ""
}

variable "create_route53_record" {
  description = "Create Route53 record"
  type        = bool
  default     = false
}
