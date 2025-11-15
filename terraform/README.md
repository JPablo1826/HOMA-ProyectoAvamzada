# HOMA Terraform Infrastructure

Infraestructura como Código (IaC) para desplegar la aplicación HOMA en AWS.

## 📋 Estructura

```
terraform/
├── provider.tf              # Configuración de AWS y backend
├── variables.tf             # Definición de variables
├── main.tf                  # Recursos principales (VPC, ALB, ECS Cluster)
├── rds_ecs.tf              # Configuración de RDS y ECS
├── iam.tf                  # Roles y políticas de IAM
├── outputs.tf              # Salidas de Terraform
├── environments/           # Variables específicas por ambiente
│   ├── dev.tfvars
│   ├── staging.tfvars
│   └── prod.tfvars
└── README.md               # Este archivo
```

## 🚀 Requisitos Previos

1. **AWS Account** con permisos suficientes
2. **Terraform >= 1.0** instalado
3. **AWS CLI** configurado
4. **Git** para control de versiones

Instalar Terraform en Windows:
```powershell
# Con Chocolatey
choco install terraform

# O descargar desde https://www.terraform.io/downloads
```

## 🔧 Configuración Inicial

### 1. Crear S3 Bucket para Terraform State

```bash
# Crear bucket
aws s3 mb s3://homa-terraform-state --region us-east-1

# Crear tabla DynamoDB para locks
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-east-1
```

### 2. Crear archivo de credenciales

```bash
# En ~/.aws/credentials (Linux/Mac) o %USERPROFILE%\.aws\credentials (Windows)
[default]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY
```

### 3. Crear archivo terraform.tfvars

```bash
# Para desarrollo
cp environments/dev.tfvars terraform.tfvars

# Agregar valores sensibles
echo 'db_username = "homa_user"' >> terraform.tfvars
echo 'db_password = "your_secure_password"' >> terraform.tfvars
```

## 📦 Desplegar Infraestructura

### Desarrollo

```bash
# Inicializar Terraform
terraform init

# Ver cambios propuestos
terraform plan -var-file="environments/dev.tfvars"

# Aplicar cambios
terraform apply -var-file="environments/dev.tfvars"
```

### Staging

```bash
terraform init
terraform plan -var-file="environments/staging.tfvars"
terraform apply -var-file="environments/staging.tfvars"
```

### Producción

```bash
# ⚠️ CRÍTICO: Revisar cambios cuidadosamente
terraform init
terraform plan -var-file="environments/prod.tfvars"

# Aplicar con confirmación
terraform apply -var-file="environments/prod.tfvars"
```

## 🔍 Comandos Útiles

```bash
# Ver estado actual
terraform state list
terraform state show aws_ecs_cluster.main

# Refrescar estado sin aplicar cambios
terraform refresh -var-file="environments/dev.tfvars"

# Destruir infraestructura (NO en producción)
terraform destroy -var-file="environments/dev.tfvars"

# Formatear código Terraform
terraform fmt -recursive

# Validar sintaxis
terraform validate

# Ver outputs
terraform output

# Imprimir output específico
terraform output alb_dns_name
```

## 🏗️ Recursos Creados

### Networking
- VPC con CIDR 10.0.0.0/16
- 2 subnets públicas y 2 privadas
- Internet Gateway y NAT Gateways
- Route tables y security groups

### Compute
- ECS Cluster con Fargate
- Task definitions para Backend y Frontend
- ECS Services con Auto Scaling

### Database
- Aurora MySQL Cluster
- RDS con Multi-AZ en producción
- Encryption en reposo con KMS
- CloudWatch logs

### Load Balancing
- Application Load Balancer
- Target groups con health checks
- HTTPS listener (en prod)

### Seguridad
- IAM roles y policies
- KMS encryption keys
- Secrets Manager para credenciales
- Security groups restrictivos

### Observabilidad
- CloudWatch Log Groups
- Container Insights
- ECS Events

## 📊 Estimado de Costos

### Desarrollo
- NAT Gateway: ~$32/mes
- RDS db.t3.micro: ~$25/mes
- ECS Fargate: ~$20/mes (bajo usage)
- **Total: ~$77/mes**

### Producción
- NAT Gateways (2): ~$64/mes
- RDS db.t3.small (2 instances): ~$150/mes
- ECS Fargate (2 tasks): ~$50/mes
- ALB: ~$16/mes
- **Total: ~$280/mes**

## 🔐 Variables Sensibles

Crear archivo `.gitignore.local` (no subir a git):
```
terraform.tfvars
*.tfvars
!*example.tfvars
.terraform/
*.tfstate*
*.tfvars.json
```

## 🛠️ Troubleshooting

### Error: "ResourceInUseException: Cluster already exists"
```bash
# Usar destroy para limpiar
terraform destroy
```

### Error: "User is not authorized to perform"
Verificar credenciales de AWS y permisos de IAM.

### Error: "Could not load state"
Asegurase que el S3 bucket y tabla DynamoDB existan.

## 📚 Recursos Útiles

- [Terraform AWS Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Best Practices](https://docs.aws.amazon.com/whitepapers/latest/aws-well-architected-framework/)
- [Terraform State Management](https://www.terraform.io/docs/language/state/)

## ✅ Checklist de Deployment

- [ ] Credenciales AWS configuradas
- [ ] S3 bucket para state creado
- [ ] Variables de ambiente completadas
- [ ] terraform plan revisado
- [ ] terraform apply ejecutado exitosamente
- [ ] Outputs verificados
- [ ] ALB DNS configurado en Route53
- [ ] ACM certificate creado (si HTTPS)
- [ ] Health checks validados
- [ ] Logs en CloudWatch verificados
