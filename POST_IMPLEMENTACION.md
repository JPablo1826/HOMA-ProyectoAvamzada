# 📋 POST-IMPLEMENTACIÓN: Pasos Siguientes

> Checklist para poner en marcha la FASE 4 DevOps

---

## ⏱️ Semana 1: Setup Inicial (2-3 horas)

### 1. Entender la Arquitectura
- [ ] Leer `ARCHITECTURE.md` (diagramas)
- [ ] Leer `QUICK_REFERENCE.md` (comandos)
- [ ] Revisar `DEVOPS.md` (documentación completa)

### 2. Probar Despliegue Local
```bash
# Clonar repo (si aún no lo hiciste)
git clone https://github.com/JPablo1826/HOMA-ProyectoAvamzada.git

# Iniciar servicios
cd HOMA-ProyectoAvamzada
docker-compose up -d

# Verificar
curl http://localhost
curl http://localhost:8080/api

# Ver logs
docker-compose logs -f backend
```

- [ ] Frontend carga en localhost
- [ ] Backend responde en localhost:8080
- [ ] Base de datos está accesible
- [ ] Logs están claros

### 3. Entender Git Flow
```bash
# Crear feature branch de prueba
git checkout -b feature/test-devops

# Hacer cambio pequeño
echo "# Test" >> README.md

# Commit y push
git add README.md
git commit -m "test: verificar git flow"
git push -u origin feature/test-devops

# En GitHub: crear PR (verás template automático)
# Revisar que se ejecutan los workflows
```

- [ ] Feature branch creada correctamente
- [ ] PR creada con template
- [ ] Workflows se ejecutan en GitHub
- [ ] PR puede ser mergeada

---

## ⏱️ Semana 2: Configurar en GitHub (2-3 horas)

### 1. Configurar GitHub Secrets

En GitHub: Settings → Secrets and variables → Actions

```bash
# Necesarios para CI/CD
SONAR_TOKEN              # Token de SonarQube
SONAR_HOST_URL          # URL servidor (http://localhost:9000 dev)

# Necesarios para CD a Staging
STAGING_DEPLOY_KEY      # SSH private key
STAGING_HOST            # IP o dominio
STAGING_USER            # Usuario SSH
STAGING_DEPLOY_PATH     # /home/user/homa

# Necesarios para CD a Producción
PROD_DEPLOY_KEY         # SSH private key
PROD_HOST               # IP o dominio
PROD_USER               # Usuario SSH
PROD_DEPLOY_PATH        # /home/user/homa-prod

# Notificaciones
SLACK_WEBHOOK           # https://hooks.slack.com/services/...
```

**Cómo obtener SSH key:**
```bash
# En tu máquina local
ssh-keygen -t ed25519 -C "github-actions"
# Dejar sin passphrase

# Copiar contenido de id_ed25519 (PRIVATE)
cat ~/.ssh/id_ed25519

# Copiar id_ed25519.pub al servidor (PUBLIC)
# ssh-copy-id -i ~/.ssh/id_ed25519.pub user@server
```

- [ ] Todos los secrets configurados
- [ ] SSH keys en servidores (si aplica)
- [ ] Slack webhook funciona

### 2. Configurar Branch Protection

**Para `main`:**
Settings → Branches → Add rule

```
Pattern: main
✅ Require a pull request before merging
✅ Require 2 approvals (minimum)
✅ Dismiss stale pull request approvals
✅ Require status checks to pass before merging
   - ci/backend-tests
   - ci/frontend-tests
   - ci/sonarqube-analysis
   - ci/build-backend
   - ci/build-frontend
✅ Require branches to be up to date before merging
✅ Include administrators
```

**Para `develop`:**
```
Pattern: develop
✅ Require a pull request before merging
✅ Require 1 approval (minimum)
✅ Require status checks to pass before merging
✅ Require branches to be up to date before merging
```

- [ ] Branch protection en `main`
- [ ] Branch protection en `develop`
- [ ] Status checks configurados

### 3. Crear Primeros Tags

```bash
# Crear versión inicial
git tag v1.0.0
git push origin v1.0.0

# Ver tags
git tag -l
```

- [ ] Tags creados
- [ ] Visibles en GitHub Releases

---

## ⏱️ Semana 3: Configurar AWS (4-5 horas)

### 1. Crear Cuenta AWS

- [ ] Crear AWS Account (o usar existente)
- [ ] Crear IAM user para Terraform
- [ ] Generar Access Key y Secret
- [ ] Guardar credenciales de forma segura

### 2. Preparar S3 para Terraform State

```bash
# Crear bucket para estado
aws s3 mb s3://homa-terraform-state --region us-east-1

# Crear tabla DynamoDB para locks
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-east-1

# Habilitar versionamiento en bucket
aws s3api put-bucket-versioning \
  --bucket homa-terraform-state \
  --versioning-configuration Status=Enabled
```

- [ ] Bucket S3 creado
- [ ] Tabla DynamoDB creada
- [ ] Versionamiento habilitado

### 3. Desplegar Infraestructura (Desarrollo)

```bash
# Configurar AWS CLI
aws configure

# Ir a terraform
cd terraform

# Inicializar
terraform init

# Crear terraform.tfvars
cat > terraform.tfvars <<EOF
db_username = "homa_admin"
db_password = "GenerateStrongPassword123!"
EOF

# Validar
terraform validate

# Ver cambios
terraform plan -var-file="environments/dev.tfvars"

# Aplicar (¡cuidado! creará recursos)
terraform apply -var-file="environments/dev.tfvars"
```

Esto creará:
- VPC con subnets
- ALB
- ECS Cluster
- RDS Aurora
- Security Groups
- IAM Roles

- [ ] `terraform init` completado
- [ ] `terraform plan` sin errores
- [ ] `terraform apply` exitoso
- [ ] Recursos visibles en AWS Console

### 4. Obtener Outputs

```bash
# Ver outputs importantes
terraform output

# Guardar ALB DNS para uso posterior
terraform output alb_dns_name
# Ej: homa-alb-dev-123456.us-east-1.elb.amazonaws.com
```

- [ ] ALB DNS obtenido
- [ ] RDS endpoint obtenido
- [ ] ECS cluster accesible

---

## ⏱️ Semana 4: Integración Completa (3-4 horas)

### 1. Actualizar .env Variables

```bash
# Crear .env local (para desarrollo)
cat > .env.dev <<EOF
ENVIRONMENT=dev
APP_VERSION=1.0.0
DB_NAME=homa_avanzada_db
DB_USER=homa_admin
DB_PASSWORD=GenerateStrongPassword123!
API_BASE_URL=http://localhost:8080
EOF

# Para staging/prod usar .env.staging y .env.prod
```

- [ ] .env.dev creado
- [ ] .env.staging creado (si aplica)
- [ ] .env.prod creado (si aplica)
- [ ] **NO subir a git**

### 2. Actualizar docker-compose

```bash
# Verificar que usa variables de .env
source .env.dev
docker-compose up -d

# Verificar variables inyectadas
docker inspect homa-backend | grep -A 10 "Env"
```

- [ ] Variables inyectadas correctamente
- [ ] Servicios inician sin errores
- [ ] Base de datos se conecta

### 3. Configurar SonarQube (Opcional)

```bash
# Opción 1: Docker local
docker run -d --name sonarqube \
  -p 9000:9000 \
  sonarqube:latest

# Opción 2: SonarQube Cloud
# Ir a https://sonarcloud.io
# Crear organización
# Obtener token

# Usar token en GitHub Secrets
```

- [ ] SonarQube accesible
- [ ] SONAR_TOKEN en GitHub Secrets
- [ ] SONAR_HOST_URL en GitHub Secrets

### 4. Probar Pipeline Completo

```bash
# Crear feature branch
git checkout -b feature/demo-pipeline

# Hacer pequeño cambio
echo "# Demo" >> homa/README.md

# Commit y push
git add homa/README.md
git commit -m "docs: demo pipeline"
git push -u origin feature/demo-pipeline

# En GitHub: crear PR y esperar workflows
# Ver en Actions → Todos los jobs
```

Verificar:
- [ ] Backend tests completados
- [ ] Frontend tests completados
- [ ] SonarQube análisis
- [ ] Build backend
- [ ] Build frontend
- [ ] Security scan

### 5. Hacer Merge y Deploy

```bash
# En GitHub: mergear a develop
# Ver en Actions → CD Pipeline inicia

# Esperar deploy a staging
# Verificar en https://staging.homa.example.com (o ALB DNS)

# Para producción: mergear a main
# Ver deploy automático a producción
```

- [ ] Deploy a staging exitoso
- [ ] Health checks pasaron
- [ ] Servicios accesibles
- [ ] Deploy a producción exitoso

---

## 📋 Checklist de Producción

Antes de hacer deploy final a producción:

### Seguridad
- [ ] Contraseñas fuertes (16+ caracteres)
- [ ] SSH keys configuradas
- [ ] IAM roles restrictivos
- [ ] Security groups correctos
- [ ] SSL certificates válidos
- [ ] Secrets en AWS Secrets Manager

### Monitoreo
- [ ] CloudWatch alarms configuradas
- [ ] Slack notifications activas
- [ ] Logs centralizados
- [ ] Métricas monitoreadas
- [ ] Email alerts configuradas

### Backup
- [ ] RDS backups automatizados
- [ ] S3 backups configurados
- [ ] Restore procedures testeadas
- [ ] Recovery time objetivo (RTO) definido
- [ ] Recovery point objective (RPO) definido

### Testing
- [ ] Tests unitarios > 80% coverage
- [ ] Tests integración pasando
- [ ] SonarQube quality gate OK
- [ ] Smoke tests post-deployment
- [ ] Load testing completado

### Documentation
- [ ] Runbook para deployments
- [ ] Troubleshooting guide
- [ ] Escalation procedures
- [ ] Contact list actualizada
- [ ] Disaster recovery plan

---

## 🚨 Troubleshooting Común

### Problem: "docker-compose: command not found"
```bash
# Solución
brew install docker-compose  # Mac
# o descargar desde https://docs.docker.com/compose/install/
```

### Problem: "Port already in use"
```bash
# En Windows
netstat -ano | findstr :8080
taskkill /PID XXXX /F

# En Mac/Linux
lsof -i :8080
kill -9 PID
```

### Problem: "terraform state locked"
```bash
# Si terraform queda bloqueado
terraform force-unlock <lock_id>

# Ver ID en error message
```

### Problem: "RDS not responding"
```bash
# Esperar a que esté lista (puede tomar 5-10 min)
aws rds describe-db-clusters \
  --db-cluster-identifier homa-db-cluster-dev
# Ver "Status": "available"
```

---

## 📊 Métricas de Éxito

Después de completar la implementación:

| Métrica | Meta |
|---------|------|
| Deploy time | < 5 minutos |
| Rollback time | < 2 minutos |
| Test coverage | > 80% |
| MTTR (Mean Time to Recovery) | < 10 minutos |
| SLA uptime | > 99.5% |
| Security scan results | 0 críticos |

---

## 📞 Soporte

Si tienes problemas:

1. **Ver DEVOPS.md** → Troubleshooting section
2. **Ver QUICK_REFERENCE.md** → Comando rápida
3. **Ver logs**: `docker-compose logs service-name`
4. **Crear issue en GitHub** con:
   - [ ] Descripción del problema
   - [ ] Steps to reproduce
   - [ ] Output de logs
   - [ ] Versión de Docker/Terraform
   - [ ] Sistema operativo

---

## 🎓 Recursos de Aprendizaje

- Docker: https://docs.docker.com/
- GitHub Actions: https://docs.github.com/en/actions
- Terraform: https://www.terraform.io/docs/
- AWS: https://docs.aws.amazon.com/
- Spring Boot: https://spring.io/projects/spring-boot
- Angular: https://angular.io/docs

---

## 📅 Timeline Sugerido

```
Semana 1: Setup & Testing Local
  ├─ Lunes: Leer documentación
  ├─ Martes: Despliegue local
  ├─ Miércoles: Git Flow
  └─ Jueves-Viernes: Tests & validación

Semana 2: GitHub Configuration
  ├─ Lunes-Martes: Secrets & Protection
  ├─ Miércoles: Branch policies
  ├─ Jueves: Primeros workflows
  └─ Viernes: Validación

Semana 3: AWS Infrastructure
  ├─ Lunes-Martes: Preparar AWS
  ├─ Miércoles: Terraform plan
  ├─ Jueves: Terraform apply
  └─ Viernes: Validar recursos

Semana 4: Integración Completa
  ├─ Lunes-Martes: Variables & config
  ├─ Miércoles: Pipelines completos
  ├─ Jueves: Deploy a staging
  └─ Viernes: Deploy a producción ✅
```

---

## ✨ Felicidades 🎉

Si completaste todo esto, tienes:

✅ **Pipeline DevOps completo y profesional**  
✅ **Infraestructura escalable en AWS**  
✅ **CI/CD automático con GitHub Actions**  
✅ **Monitoreo y alertas 24/7**  
✅ **Backup y recovery procedures**  
✅ **Documentación completa**  

**¡Tu aplicación está lista para producción!**

---

**Actualizado**: Noviembre 2024  
**Versión**: 1.0.0
