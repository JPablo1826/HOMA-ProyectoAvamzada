# 🚀 QUICK REFERENCE - FASE 4 DevOps

## 📂 Archivos Clave

### Docker
- `homa/Dockerfile` - Backend Spring Boot
- `frontend/Dockerfile` - Frontend Angular + Nginx
- `docker-compose.yml` - Desarrollo local
- `docker-compose.prod.yml` - Producción
- `nginx/prod.conf` - Nginx production config

### CI/CD (GitHub Actions)
- `.github/workflows/ci.yml` - Pipeline de CI
- `.github/workflows/cd.yml` - Pipeline de CD
- `.github/pull_request_template.md` - Template de PR

### Git Flow
- `.github/GIT_FLOW.md` - Documentación completa

### Terraform (Infraestructura)
- `terraform/provider.tf` - Configuración AWS
- `terraform/main.tf` - VPC, ALB, ECS
- `terraform/rds_ecs.tf` - RDS + ECS
- `terraform/iam.tf` - IAM roles
- `terraform/environments/*.tfvars` - Por ambiente

### Configuración
- `.env.example` - Variables de ambiente
- `.gitignore` - Exclusiones Git
- `sonar-project.properties` - SonarQube config
- `db-init/init.sql` - Inicialización BD

### Documentación
- `DEVOPS.md` - Documentación completa
- `FASE4_COMPLETADA.md` - Resumen de lo completado
- `terraform/README.md` - Guía de Terraform
- `deploy.sh` - Script de despliegue

---

## 🐳 Comandos Docker

```bash
# Despliegue local
docker-compose up -d
docker-compose down

# Ver logs
docker-compose logs -f backend
docker-compose logs -f frontend

# Ejecutar comandos
docker-compose exec backend ./gradlew test
docker-compose exec frontend npm test

# Despliegue producción
docker-compose -f docker-compose.prod.yml up -d
docker-compose -f docker-compose.prod.yml down

# Construir imágenes
docker-compose build
docker-compose build --no-cache
```

---

## 🔀 Git Flow

```bash
# Feature branch
git checkout -b feature/nombre-funcionalidad
git push -u origin feature/nombre-funcionalidad

# Commit messages
git commit -m "feat(scope): descripción"
git commit -m "fix(scope): descripción"

# Actualizar rama
git pull origin develop
git merge --no-ff feature/nombre

# Limpieza
git branch -d feature/nombre
git push origin --delete feature/nombre
```

---

## 🚀 Terraform

```bash
# Inicializar
terraform init

# Desarrollo
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"

# Staging
terraform plan -var-file="environments/staging.tfvars"
terraform apply -var-file="environments/staging.tfvars"

# Producción (cuidado!)
terraform plan -var-file="environments/prod.tfvars" -out=tfplan
terraform apply tfplan

# Ver outputs
terraform output
terraform output alb_dns_name

# Destruir
terraform destroy -var-file="environments/dev.tfvars"
```

---

## 📊 GitHub Actions

```bash
# Ver workflows
gh workflow list

# Ver ejecuciones
gh run list

# Ver job específico
gh run view RUN_ID

# Trigger workflow manualmente
gh workflow run ci.yml
```

---

## 🐞 Troubleshooting Rápido

| Problema | Solución |
|----------|----------|
| Backend no inicia | `docker-compose logs backend` |
| Frontend no carga | `docker-compose logs frontend` |
| BD no responde | `docker-compose restart database` |
| Puerto en uso | `lsof -i :8080` (Linux/Mac) |
| Permiso denegado | `chmod +x deploy.sh` |
| Terraform error | `terraform validate` |

---

## 🔑 GitHub Secrets Necesarios

```
SONAR_TOKEN
SONAR_HOST_URL
STAGING_DEPLOY_KEY
STAGING_HOST
STAGING_USER
STAGING_DEPLOY_PATH
PROD_DEPLOY_KEY
PROD_HOST
PROD_USER
PROD_DEPLOY_PATH
SLACK_WEBHOOK
```

---

## 📈 Monitoreo

```bash
# CloudWatch logs
aws logs tail /ecs/homa-backend-prod --follow

# Ver métricas
aws cloudwatch list-metrics --namespace AWS/ECS

# Ver alarmas
aws cloudwatch describe-alarms
```

---

## 💾 Backup y Recovery

```bash
# Backup manual
docker exec homa-mariadb mysqldump -u root -pemili123 homa_avanzada_db > backup.sql

# Restore
docker exec -i homa-mariadb mysql -u root -pemili123 homa_avanzada_db < backup.sql

# Terraform state backup
aws s3 sync s3://homa-terraform-state ./state-backup/
```

---

## ✅ Checklist Pre-Deploy

- [ ] Tests pasando (`gh run list`)
- [ ] SonarQube quality gate OK
- [ ] No vulnerabilidades críticas
- [ ] PR aprobado
- [ ] Rama actualizada
- [ ] Backup realizado
- [ ] Monitores activos
- [ ] Team notificado

---

## 📞 URLs Importantes

- Frontend Local: http://localhost
- Backend Local: http://localhost:8080
- Database: localhost:3310
- SonarQube: http://localhost:9000

En Producción:
- Frontend: https://homa.example.com
- Backend API: https://homa.example.com/api
- AWS Console: https://console.aws.amazon.com

---

## 🎯 Flujo de Deploy

```
Feature → GitHub → CI Tests → Build → SonarQube → 
PR Review → Merge to develop → Deploy Staging → 
Merge to main → Deploy Prod → Health Checks → ✅ LIVE
```

---

## 📚 Documentación Detallada

Ver `DEVOPS.md` para:
- Setup completo
- Arquitectura detallada
- Procedimientos de backup/recovery
- Troubleshooting avanzado
- Estimaciones de costo

---

**Last Updated**: Noviembre 2024  
**Version**: 1.0.0  
**Status**: ✅ Production Ready
