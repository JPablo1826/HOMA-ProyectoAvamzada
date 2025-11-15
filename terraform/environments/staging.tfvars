# ==============================================================
# Terraform - Staging Environment Variables
# ==============================================================

environment            = "staging"
aws_region             = "us-east-1"
app_name               = "homa"
vpc_cidr               = "10.0.0.0/16"
availability_zones     = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs    = ["10.0.10.0/24", "10.0.11.0/24"]
private_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]

# Database
db_instance_class     = "db.t3.small"
db_allocated_storage  = 50
db_name               = "homa_avanzada_db"

# ECS
backend_container_cpu     = 256
backend_container_memory  = 512
frontend_container_cpu    = 128
frontend_container_memory = 256
ecs_desired_count         = 1

# ALB/SSL
enable_https     = true
certificate_arn  = "arn:aws:acm:us-east-1:ACCOUNT_ID:certificate/CERTIFICATE_ID"
domain_name      = "staging.homa.example.com"

# For sensitive variables, create a terraform.tfvars file with:
# db_username = "homa_staging_user"
# db_password = "your_secure_password_here"
