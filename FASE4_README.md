# 🏢 HOMA - Proyecto Avanzada Fase 4: DevOps

> Implementación completa de CI/CD, Containerización y Despliegue en la Nube

## 📋 Contenido

1. [Visión General](#visión-general)
2. [Estructura del Proyecto](#estructura-del-proyecto)
3. [Quick Start](#quick-start)
4. [Despliegue](#despliegue)
5. [Documentación](#documentación)

---

## 👀 Visión General

Se ha completado la **FASE 4** de proyecto HOMA con un pipeline DevOps profesional que incluye:

### ✨ Lo que incluye esta fase

- **🐳 Docker**: Containerización optimizada con multi-stage builds
- **🔄 CI/CD**: GitHub Actions con testing, build y análisis automático
- **🏗️ Infraestructura**: Terraform para AWS con todo pre-configurado
- **📊 Monitoreo**: CloudWatch, logs centralizados y alertas
- **🛡️ Seguridad**: SSL/TLS, secret management, security scanning
- **💾 Backup**: Recuperación automática y rollback en fallos
- **🚀 Deploy**: Automático a desarrollo, staging y producción

---

## 🗂️ Estructura del Proyecto

```
HOMA-ProyectoAvamzada/
│
├── 📁 homa/                          # Backend Spring Boot
│   ├── Dockerfile                    # ✨ Multi-stage optimizado
│   ├── src/
│   └── build.gradle
│
├── 📁 frontend/                      # Frontend Angular
│   ├── Dockerfile                    # ✨ Multi-stage optimizado
│   ├── nginx.template.conf           # Nginx production
│   ├── docker-entrypoint.sh
│   └── src/
│
├── 📁 terraform/                     # ✨ Infraestructura como Código
│   ├── provider.tf
│   ├── main.tf                       # VPC, ALB, ECS
│   ├── rds_ecs.tf                    # RDS, ECS tasks
│   ├── iam.tf                        # Security roles
│   ├── outputs.tf
│   ├── variables.tf
│   ├── README.md
│   └── 📁 environments/
│       ├── dev.tfvars
│       ├── staging.tfvars
│       └── prod.tfvars
│
├── 📁 .github/
│   ├── 📁 workflows/
│   │   ├── ci.yml                    # ✨ CI Pipeline
│   │   └── cd.yml                    # ✨ CD Pipeline
│   ├── pull_request_template.md      # Template para PRs
│   └── GIT_FLOW.md                   # Políticas de git flow
│
├── 📁 nginx/
│   └── prod.conf                     # Nginx production-grade
│
├── 📁 db-init/
│   └── init.sql                      # Inicialización de BD
│
├── 📁 docs/
│   └── DEVOPS.md                     # 📚 Documentación DevOps
│
├── docker-compose.yml                # ✨ Desarrollo local
├── docker-compose.prod.yml           # ✨ Producción
├── .env.example                      # Variables de ambiente
├── .gitignore                        # Exclusiones Git
├── deploy.sh                         # Script de despliegue
├── sonar-project.properties          # SonarQube config
│
├── DEVOPS.md                         # 📚 Documentación principal
├── FASE4_COMPLETADA.md               # ✅ Resumen de lo completado
├── QUICK_REFERENCE.md                # 🚀 Referencia rápida
└── README.md                         # Este archivo
```

---

## 🚀 Quick Start

### Requisitos Mínimos

```bash
# Versiones requeridas
Docker >= 20.10
Docker Compose >= 2.0
Git >= 2.30
Terraform >= 1.0 (para infraestructura)
AWS CLI >= 2.0 (para AWS)
```

### Desarrollo Local (5 minutos)

```bash
# 1. Clonar repo
git clone https://github.com/JPablo1826/HOMA-ProyectoAvamzada.git
cd HOMA-ProyectoAvamzada

# 2. Iniciar servicios
docker-compose up -d

# 3. Verificar que funciona
curl http://localhost              # Frontend
curl http://localhost:8080/api     # Backend
docker-compose ps                  # Ver estado

# 4. Ver logs
docker-compose logs -f backend
```

### Detener servicios

```bash
docker-compose down
```

---

## 🚢 Despliegue

### 1️⃣ Despliegue Local

**Perfecto para desarrollo:**

```bash
docker-compose up -d

# Acceder a servicios
# Frontend: http://localhost
# Backend: http://localhost:8080
# Database: localhost:3310
```

### 2️⃣ Despliegue Staging (Automático)

**Cuando haces push a `develop`:**

```bash
# El pipeline automático:
1. Ejecuta todos los tests
2. Analiza código con SonarQube
3. Construye imágenes Docker
4. Deploy a staging
5. Ejecuta smoke tests
```

### 3️⃣ Despliegue Producción (Automático)

**Cuando haces merge a `main`:**

```bash
# El pipeline automático:
1. Backup de base de datos
2. Deploy con salud checks
3. Smoke tests
4. Si falla → Rollback automático
5. Notificación a Slack
```

### 4️⃣ Despliegue con Terraform

**Para crear infraestructura en AWS:**

```bash
cd terraform

# Desarrollo
terraform init
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"

# Producción
terraform plan -var-file="environments/prod.tfvars" -out=tfplan
terraform apply tfplan

# Ver recursos creados
terraform output
```

---

## 📚 Documentación

### Documentos Disponibles

| Documento | Para | Descripción |
|-----------|------|-------------|
| **DEVOPS.md** | 👨‍💼 DevOps | Documentación completa (setup, troubleshooting, etc) |
| **QUICK_REFERENCE.md** | ⚡ Rápida | Comandos y referencias útiles |
| **FASE4_COMPLETADA.md** | ✅ Overview | Resumen de todo lo implementado |
| **GIT_FLOW.md** | 🔀 Git | Políticas y workflow de ramas |
| **terraform/README.md** | 🏗️ Infra | Guía detallada de Terraform |

### Leer Primero

1. **Este README** (estás aquí) ✅
2. **QUICK_REFERENCE.md** (para comandos rápidos)
3. **DEVOPS.md** (para entender todo)

---

## 🔀 Git Flow

### Trabajar en una Funcionalidad

```bash
# 1. Crear feature branch desde develop
git checkout -b feature/nueva-funcionalidad

# 2. Hacer cambios y commits
git add .
git commit -m "feat(scope): descripción"

# 3. Push a GitHub
git push -u origin feature/nueva-funcionalidad

# 4. Crear Pull Request (template automático)
# → En GitHub presiona "New Pull Request"

# 5. Esperar aprobación (min 1 review)

# 6. Merge a develop (automático)
# → Deploy automático a staging

# 7. Para producción, merge a main
# → Deploy automático a producción
```

### Commit Messages

```bash
feat(auth): agregar JWT authentication
fix(users): corregir validación de email
docs(readme): actualizar instrucciones
test(backend): agregar tests de API
refactor(frontend): mejorar componentes
perf(database): optimizar queries
```

---

## 🧪 Testing & Quality

### Tests Locales

```bash
# Backend tests
docker-compose exec backend ./gradlew test

# Frontend tests
docker-compose exec frontend npm test

# Coverage report
docker-compose exec backend ./gradlew jacocoTestReport
docker-compose exec frontend npm run test:coverage
```

### Quality Gates

El pipeline requiere:
- ✅ Tests > 80% coverage
- ✅ No vulnerabilidades críticas
- ✅ SonarQube quality gate
- ✅ Build exitoso
- ✅ 2 aprobaciones en main, 1 en develop

---

## 📊 Monitoreo

### Logs en Desarrollo

```bash
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f database
```

### Logs en Producción (AWS)

```bash
# Ver logs en CloudWatch
aws logs tail /ecs/homa-backend-prod --follow
aws logs tail /ecs/homa-frontend-prod --follow

# Métricas
aws cloudwatch list-metrics --namespace AWS/ECS
```

---

## 🛠️ Troubleshooting

### Problema: Backend no inicia

```bash
# Ver logs
docker-compose logs backend

# Verificar BD está lista
docker-compose logs database

# Reiniciar
docker-compose restart backend
```

### Problema: Frontend no carga

```bash
# Ver logs
docker-compose logs frontend

# Verificar acceso a backend
curl http://localhost:8080/actuator/health

# Reiniciar
docker-compose restart frontend
```

### Problema: Puerto ya en uso

```bash
# Windows
netstat -ano | findstr :8080

# Linux/Mac
lsof -i :8080
```

### Ver más en: **DEVOPS.md → Troubleshooting**

---

## 🔐 Seguridad

### Variables Sensibles

**NUNCA commitear:**
- Contraseñas
- API keys
- SSH keys
- Tokens

**Usar en su lugar:**
- `.env` (local, no subir a git)
- GitHub Secrets (para CI/CD)
- AWS Secrets Manager (para producción)

```bash
# Ejemplo .env (no subir!)
DB_PASSWORD=super_secret
SONAR_TOKEN=token_aqui
SLACK_WEBHOOK=https://...
```

### SSL/TLS

```bash
# Local (desarrollo)
# Nginx está configurado con HTTP

# Producción (AWS)
# ACM certificates automáticamente con Terraform
# HTTPS en puerto 443
# Redirect HTTP → HTTPS
```

---

## 💰 Estimación de Costos (AWS)

### Desarrollo (~$77/mes)
- NAT Gateway: $32
- RDS micro: $25
- ECS Fargate: $20

### Staging (~$142/mes)
- NAT Gateways: $32
- RDS small: $75
- ECS Fargate: $35

### Producción (~$280/mes)
- NAT Gateways (2): $64
- RDS small (Multi-AZ): $150
- ECS Fargate (2 tasks): $50
- ALB: $16

---

## ✅ Checklist de Despliegue a Producción

Antes de hacer merge a `main`:

- [ ] Todos tests pasando
- [ ] Cobertura >= 80%
- [ ] SonarQube quality gate OK
- [ ] PR aprobado por 2 devs
- [ ] No hay TODOs o FIXME
- [ ] Documentación actualizada
- [ ] Database migrations (si aplica)
- [ ] Environment variables configuradas
- [ ] Backup realizado
- [ ] Team notificado

---

## 📞 Contacto y Soporte

- **Repository**: https://github.com/JPablo1826/HOMA-ProyectoAvamzada
- **Issues**: Reportar bugs en GitHub Issues
- **Discussions**: Preguntas en GitHub Discussions

---

## 📖 Referencias

- [Docker Documentation](https://docs.docker.com/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Terraform AWS](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [AWS Best Practices](https://docs.aws.amazon.com/wellarchitected/)
- [Spring Boot Docker](https://spring.io/guides/topicals/spring-boot-docker/)
- [Angular Docker](https://angular.io/guide/universal)

---

## 🎓 Siguientes Pasos

### Inmediatos (Esta semana)
1. ✅ Leer documentación (este README + DEVOPS.md)
2. ✅ Probar despliegue local
3. ✅ Crear feature branch de prueba
4. ✅ Entender el pipeline en GitHub Actions

### Corto Plazo (Este mes)
1. Configurar GitHub Secrets
2. Crear infraestructura en AWS con Terraform
3. Configurar dominio y certificados SSL
4. Configurar SonarQube
5. Configurar alertas en Slack

### Largo Plazo
1. Optimizar perfiles de Terraform
2. Implementar auto-scaling policies
3. Agregar CDN (CloudFront)
4. Implementar canary deployments
5. Multi-region deployment

---

## 📝 Notas de Versión

### v1.0.0 (Noviembre 2024) ✅
- ✅ Dockerización completa
- ✅ CI/CD pipeline con GitHub Actions
- ✅ Infraestructura con Terraform
- ✅ Documentación completa
- ✅ Security scanning
- ✅ Backup & Recovery

---

## 📄 Licencia

Este proyecto es parte del curso Programación Orientada a Objetos Avanzada.

---

<div align="center">

**🚀 Ready for Production**

Implementado por: JPablo1826  
Última actualización: Noviembre 2024  
Estado: ✅ Completado y Validado

[⬆ Volver al inicio](#-homa---proyecto-avanzada-fase-4-devops)

</div>
