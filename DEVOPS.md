# 📋 Documentación DevOps - HOMA Proyecto Avanzada

> Plan completo de Despliegue, CI/CD e Infraestructura como Código

---

## 📑 Tabla de Contenidos

1. [Overview](#overview)
2. [Arquitectura](#arquitectura)
3. [Despliegue Local](#despliegue-local)
4. [CI/CD Pipeline](#cicd-pipeline)
5. [Infraestructura en Cloud](#infraestructura-en-cloud)
6. [Monitoreo y Logging](#monitoreo-y-logging)
7. [Disaster Recovery](#disaster-recovery)
8. [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

Este proyecto implementa un pipeline DevOps completo con:

- ✅ **Containerización**: Docker multi-stage para backend y frontend
- ✅ **Orquestación**: Docker Compose para desarrollo y producción
- ✅ **CI/CD**: GitHub Actions con testing automático
- ✅ **Infraestructura**: Terraform para AWS
- ✅ **Calidad**: SonarQube, análisis de seguridad, coverage
- ✅ **Monitoreo**: CloudWatch, logs centralizados

### Ciclo de Vida del Código

```
Feature Branch → Tests → Build → SonarQube → Staging → Production
     ↓             ↓        ↓         ↓          ↓           ↓
 Desarrollador   JUnit   Docker   Quality    Health      Live
               Jasmine   Images    Gates      Checks
```

---

## 🏗️ Arquitectura

### Ambiente Local (Desarrollo)

```
┌─────────────────────────────────────────┐
│         Docker Compose (Local)          │
├─────────────────────────────────────────┤
│  Frontend      │  Backend      │  DB    │
│  (nginx)       │ (Spring Boot) │(MariaDB)
│   :80          │   :8080       │ :3306  │
└─────────────────────────────────────────┘
```

### Ambiente Cloud (AWS)

```
┌─────────────────────────────────────────────────────────┐
│                    AWS Infrastructure                   │
├─────────────────────────────────────────────────────────┤
│  Internet                                               │
│     ↓                                                   │
│  ┌──────────────────────────────────────────┐          │
│  │  Application Load Balancer (ALB)         │          │
│  │  - HTTPS/TLS termination                │          │
│  │  - Path-based routing (/api, /)         │          │
│  └───────────┬──────────────────┬───────────┘          │
│              ↓                  ↓                       │
│  ┌──────────────────┐  ┌──────────────────┐           │
│  │  ECS Frontend    │  │  ECS Backend     │           │
│  │  - 2 tasks       │  │  - 2 tasks       │           │
│  │  - Fargate       │  │  - Fargate       │           │
│  └──────────────────┘  └────────┬─────────┘           │
│                                  ↓                      │
│                       ┌──────────────────┐             │
│                       │  RDS Aurora      │             │
│                       │  - MySQL         │             │
│                       │  - Multi-AZ      │             │
│                       │  - Encrypted     │             │
│                       └──────────────────┘             │
└─────────────────────────────────────────────────────────┘
```

---

## 🐳 Despliegue Local

### Requisitos

- Docker >= 20.10
- Docker Compose >= 2.0
- Node.js 18+ (para desarrollo frontend)
- Java 17+ (para desarrollo backend)

### Quick Start

```bash
# 1. Clonar repositorio
git clone https://github.com/JPablo1826/HOMA-ProyectoAvamzada.git
cd HOMA-ProyectoAvamzada

# 2. Construir imágenes Docker
docker-compose build

# 3. Iniciar servicios
docker-compose up -d

# 4. Verificar estado
docker-compose ps

# 5. Ver logs
docker-compose logs -f backend  # o frontend, database
```

### Verificar que todo funcione

```bash
# Frontend
curl http://localhost

# Backend API
curl http://localhost:8080/api/health

# Base de datos
docker exec -it homa-mariadb mysql -u root -pemili123 -e "USE homa_avanzada_db; SHOW TABLES;"
```

### Desarrollo

```bash
# Desarrollo Angular (hot reload)
cd frontend
npm start

# Desarrollo Spring Boot (hot reload)
cd homa
./gradlew bootRun

# Ejecutar tests
docker-compose exec backend ./gradlew test
docker-compose exec frontend npm test
```

---

## 🔄 CI/CD Pipeline

### Flujo del Pipeline

1. **Trigger**: Push a `develop` o PR a `main`/`develop`
2. **CI Stage**: Tests, Build, Analysis
3. **CD Stage**: Deploy a Staging o Producción

### GitHub Actions Workflows

#### CI Pipeline (`.github/workflows/ci.yml`)

**Ejecuta cuando:**
- Push a `develop` o `main`
- Pull Request a `develop` o `main`

**Etapas:**
1. **Backend Tests** (JUnit + JaCoCo)
   - Compila código
   - Ejecuta tests unitarios
   - Genera reporte de cobertura
   - Mínimo 80% coverage

2. **Frontend Tests** (Jasmine/Karma)
   - Instala dependencias
   - Lint de código
   - Ejecuta tests
   - Genera reporte de cobertura

3. **SonarQube Analysis**
   - Analiza calidad de código
   - Detecta bugs y vulnerabilidades
   - Valida quality gates

4. **Build Backend**
   - Construye JAR
   - Crea imagen Docker
   - Push a GitHub Container Registry

5. **Build Frontend**
   - Compile Angular
   - Crea imagen Docker
   - Push a GitHub Container Registry

6. **Security Scan**
   - Trivy vulnerability scanner
   - Detecta vulnerabilidades en dependencias
   - SAST analysis

#### CD Pipeline (`.github/workflows/cd.yml`)

**Deploy a Staging (develop)**
- Deploy automático cuando se hace merge a `develop`
- Environment: https://staging.homa.example.com
- Smoke tests post-deployment

**Deploy a Producción (main)**
- Deploy automático cuando se hace merge a `main`
- Environment: https://homa.example.com
- Backup automático de BD antes de deploy
- Rollback automático si hay fallos
- Notificación a Slack

### Configuración de GitHub Secrets

Necesarios en Settings → Secrets:

```bash
SONAR_TOKEN          # Token de SonarQube
SONAR_HOST_URL       # URL del servidor SonarQube

STAGING_DEPLOY_KEY   # SSH private key
STAGING_HOST         # Servidor staging
STAGING_USER         # Usuario SSH
STAGING_DEPLOY_PATH  # Path del deploy

PROD_DEPLOY_KEY      # SSH private key
PROD_HOST            # Servidor producción
PROD_USER            # Usuario SSH
PROD_DEPLOY_PATH     # Path del deploy

SLACK_WEBHOOK        # Webhook para notificaciones
```

### Monitoreo del Pipeline

```bash
# Ver workflows ejecutados
gh workflow list

# Ver ejecución específica
gh run view <run-id>

# Ver logs de job
gh run view <run-id> --log
```

---

## ☁️ Infraestructura en Cloud

### Proveedores Soportados

- **AWS** (Recomendado)
- **Azure** (Adaptable)
- **Railway** (Simple)

### Despliegue con Terraform en AWS

```bash
cd terraform

# Desarrollo
terraform init
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"

# Staging
terraform plan -var-file="environments/staging.tfvars"
terraform apply -var-file="environments/staging.tfvars"

# Producción
terraform plan -var-file="environments/prod.tfvars" -out=tfplan
# Revisar cambios...
terraform apply tfplan
```

### Recursos Creados

- **VPC**: Red privada aislada
- **Subnets**: Públicas y privadas en 2 AZs
- **ALB**: Load balancer con SSL/TLS
- **ECS Fargate**: Orquestación de contenedores
- **RDS Aurora**: Base de datos MySQL managed
- **IAM Roles**: Permisos y seguridad
- **CloudWatch**: Logs y monitoreo
- **KMS**: Encryption de datos

### Costo Estimado

| Ambiente | Compute | Database | Networking | Total |
|----------|---------|----------|-----------|-------|
| Dev      | $20     | $25      | $32       | $77   |
| Staging  | $35     | $75      | $32       | $142  |
| Prod     | $50     | $150     | $64       | $264  |

---

## 📊 Monitoreo y Logging

### CloudWatch Logs

```bash
# Ver logs del backend
aws logs tail /ecs/homa-backend-prod --follow

# Ver logs del frontend
aws logs tail /ecs/homa-frontend-prod --follow

# Crear métrica personalizada
aws cloudwatch put-metric-alarm \
  --alarm-name high-cpu \
  --alarm-description "Alert on high CPU" \
  --metric-name CPUUtilization \
  --namespace AWS/ECS
```

### Métricas Monitoreadas

- CPU Utilization
- Memory Utilization
- Task Count
- Request Count
- Error Rate
- Response Time

### Dashboards

- **Backend**: Requests/sec, Error rate, DB connections
- **Frontend**: Page load time, JS errors, User sessions
- **Database**: Connections, Slow queries, Replication lag

### Alertas

```bash
# Backend down
- Condition: HealthyHostCount == 0
- Action: PagerDuty + Slack

# High error rate
- Condition: ErrorRate > 5%
- Action: Slack

# Low disk space
- Condition: FreeStorageSpace < 20%
- Action: Slack + Email
```

---

## 🚨 Disaster Recovery

### Backup Strategy

```bash
# Daily database backups
0 2 * * * aws s3 cp /backups/ s3://homa-backups/daily-$(date +%Y%m%d).sql

# Weekly snapshots
0 3 * * 0 aws rds create-db-cluster-snapshot \
  --db-cluster-identifier homa-db \
  --db-cluster-snapshot-identifier homa-backup-$(date +%Y%m%d)
```

### Recovery Procedures

**Restaurar base de datos desde backup**
```bash
# Listar backups disponibles
aws rds describe-db-cluster-snapshots

# Restaurar desde snapshot
aws rds restore-db-cluster-from-snapshot \
  --db-cluster-identifier homa-restored \
  --snapshot-identifier homa-backup-20240101
```

**Rollback automático**
```bash
# El pipeline CD ejecuta automáticamente:
- Backup previo
- Deploy nuevo
- Health checks
- Si falla → Rollback automático
```

**RTO y RPO**

| Scenario | RTO | RPO |
|----------|-----|-----|
| Task failure | 5 min | 0 min |
| AZ failure | 10 min | 0 min |
| DB corruption | 30 min | 24 hrs |
| Region failure | 2 hrs | 24 hrs |

---

## 🔍 Troubleshooting

### Problema: Deploy fallido

```bash
# 1. Ver logs del workflow
gh run view <run-id> --log

# 2. Ver logs en CloudWatch
aws logs tail /ecs/homa-backend-prod --follow

# 3. Ver estado de ECS
aws ecs describe-services \
  --cluster homa-cluster-prod \
  --services homa-backend-service

# 4. Si es necesario, rollback manual
cd terraform
terraform apply -var-file="environments/prod.tfvars" -refresh=true
```

### Problema: Base de datos no responde

```bash
# 1. Ver estado de RDS
aws rds describe-db-clusters \
  --db-cluster-identifier homa-db

# 2. Conectar a base de datos
aws rds describe-db-instances | jq '.DBInstances[] | {Endpoint, Status}'

# 3. Ver eventos recientes
aws rds describe-events --duration 60

# 4. Rebootear si es necesario (cuidado!)
aws rds reboot-db-instance --db-instance-identifier homa-db-1
```

### Problema: Contenedores crasheando

```bash
# 1. Ver logs del contenedor
docker logs homa-backend

# 2. Ver health check
docker inspect homa-backend | grep -A 10 '"Health"'

# 3. Verificar recursos
docker stats

# 4. Si es imagen Docker, rebuildar
docker-compose build --no-cache backend
docker-compose up -d backend
```

---

## 📚 Guías Rápidas

### Git Flow

```bash
# Crear feature branch
git checkout -b feature/nueva-funcionalidad
git push -u origin feature/nueva-funcionalidad

# Crear PR y esperar aprobación

# Después de merge a develop
git pull origin develop

# Después de merge a main
git pull origin main
git tag v1.0.0
git push origin v1.0.0
```

### SonarQube

```bash
# Local analysis
cd homa
./gradlew sonarqube \
  -Dsonar.projectKey=HOMA \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=YOUR_TOKEN

# Ver resultados
open http://localhost:9000/projects
```

### Certificados SSL

```bash
# Crear certificado self-signed (desarrollo)
openssl req -x509 -newkey rsa:4096 -nodes \
  -out cert.pem -keyout key.pem -days 365

# Copiar a directorio nginx
cp cert.pem nginx/ssl/
cp key.pem nginx/ssl/

# En producción usar AWS Certificate Manager (ACM)
```

---

## ✅ Checklist de Deployment a Producción

- [ ] Todos los tests pasando
- [ ] Cobertura >= 80%
- [ ] SonarQube quality gate pasado
- [ ] No hay vulnerabilidades críticas
- [ ] PR aprobado por 2 senior devs
- [ ] Rama `main` actualizada
- [ ] Backup de BD realizado
- [ ] Health checks configurados
- [ ] Monitores y alertas activos
- [ ] Rollback plan documentado
- [ ] Equipo notificado

---

## 📞 Contacto y Soporte

**Responsable DevOps**: Tu nombre  
**Slack Channel**: #devops  
**Documentación Adicional**: https://wiki.homa.local

---

**Última actualización**: Noviembre 2024
**Versión**: 1.0.0
