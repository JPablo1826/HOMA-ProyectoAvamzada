#!/bin/bash
# ==============================================================
# HOMA Deployment Script
# ==============================================================
# Para ejecutar manualmente o desde CD pipeline
# Uso: ./deploy.sh [environment] [action]
# Ejemplo: ./deploy.sh prod deploy
# ==============================================================

set -e  # Salir si hay error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
ENVIRONMENT="${1:-dev}"
ACTION="${2:-deploy}"
PROJECT_NAME="homa"
DOCKER_REGISTRY="ghcr.io"
APP_VERSION="${CI_COMMIT_SHA:0:8}"

# ==============================================================
# Funciones
# ==============================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ==============================================================
# Validación
# ==============================================================

validate_environment() {
    if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
        log_error "Environment must be: dev, staging, or prod"
        exit 1
    fi
}

validate_action() {
    if [[ ! "$ACTION" =~ ^(deploy|rollback|status|logs)$ ]]; then
        log_error "Action must be: deploy, rollback, status, or logs"
        exit 1
    fi
}

# ==============================================================
# Pre-deployment Checks
# ==============================================================

pre_deployment_checks() {
    log_info "Ejecutando pre-deployment checks..."
    
    # Verificar que Docker está corriendo
    if ! docker ps > /dev/null 2>&1; then
        log_error "Docker no está corriendo o no tienes permisos"
        exit 1
    fi
    log_success "Docker está disponible"
    
    # Verificar que Docker Compose existe
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose no está instalado"
        exit 1
    fi
    log_success "Docker Compose está disponible"
    
    # Verificar archivos necesarios
    if [[ ! -f "docker-compose.${ENVIRONMENT}.yml" ]]; then
        if [[ "$ENVIRONMENT" == "prod" ]]; then
            log_info "Usando docker-compose.prod.yml"
            export COMPOSE_FILE="docker-compose.prod.yml"
        else
            log_error "docker-compose.${ENVIRONMENT}.yml no existe"
            exit 1
        fi
    fi
}

# ==============================================================
# Load Environment Variables
# ==============================================================

load_env_vars() {
    log_info "Cargando variables de ambiente para ${ENVIRONMENT}..."
    
    if [[ -f ".env.${ENVIRONMENT}" ]]; then
        export $(cat .env.${ENVIRONMENT} | xargs)
        log_success "Variables cargadas desde .env.${ENVIRONMENT}"
    else
        log_warning ".env.${ENVIRONMENT} no encontrado, usando valores por defecto"
    fi
}

# ==============================================================
# Deploy Function
# ==============================================================

deploy() {
    log_info "Iniciando deploy a ${ENVIRONMENT}..."
    
    pre_deployment_checks
    load_env_vars
    
    # Crear backup si es producción
    if [[ "$ENVIRONMENT" == "prod" ]]; then
        create_backup
    fi
    
    # Pull latest images
    log_info "Descargando latest images..."
    if [[ "$ENVIRONMENT" == "prod" ]]; then
        docker-compose -f docker-compose.prod.yml pull
    else
        docker-compose pull
    fi
    log_success "Imágenes descargadas"
    
    # Stop old containers gracefully
    log_info "Deteniendo contenedores antiguos..."
    if [[ "$ENVIRONMENT" == "prod" ]]; then
        docker-compose -f docker-compose.prod.yml down --timeout=30
    else
        docker-compose down --timeout=30
    fi
    log_success "Contenedores detenidos"
    
    # Start new containers
    log_info "Iniciando nuevos contenedores..."
    if [[ "$ENVIRONMENT" == "prod" ]]; then
        docker-compose -f docker-compose.prod.yml up -d
    else
        docker-compose up -d
    fi
    log_success "Contenedores iniciados"
    
    # Wait for services to be healthy
    log_info "Esperando a que los servicios estén saludables..."
    wait_for_health_checks
    
    # Run smoke tests
    log_info "Ejecutando smoke tests..."
    run_smoke_tests
    
    log_success "✅ Deploy a ${ENVIRONMENT} completado exitosamente"
}

# ==============================================================
# Create Backup
# ==============================================================

create_backup() {
    log_info "Creando backup de base de datos..."
    
    BACKUP_DIR="backups"
    mkdir -p "$BACKUP_DIR"
    
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="$BACKUP_DIR/backup_${TIMESTAMP}.sql"
    
    # Backup database
    docker exec homa-mariadb-prod mysqldump \
        -u "$DB_USER" \
        -p"$DB_PASSWORD" \
        "$DB_NAME" > "$BACKUP_FILE"
    
    log_success "Backup creado: $BACKUP_FILE"
    
    # Keep only last 10 backups
    ls -t "$BACKUP_DIR"/backup_*.sql | tail -n +11 | xargs -r rm
}

# ==============================================================
# Wait for Health Checks
# ==============================================================

wait_for_health_checks() {
    MAX_ATTEMPTS=30
    ATTEMPT=1
    
    while [[ $ATTEMPT -le $MAX_ATTEMPTS ]]; do
        log_info "Health check attempt $ATTEMPT/$MAX_ATTEMPTS..."
        
        # Check backend
        if curl -f http://localhost:8080/actuator/health > /dev/null 2>&1; then
            log_success "Backend is healthy"
        else
            log_warning "Backend not ready yet..."
            sleep 2
            ((ATTEMPT++))
            continue
        fi
        
        # Check frontend
        if curl -f http://localhost/healthz > /dev/null 2>&1; then
            log_success "Frontend is healthy"
        else
            log_warning "Frontend not ready yet..."
            sleep 2
            ((ATTEMPT++))
            continue
        fi
        
        # Check database
        if [[ "$ENVIRONMENT" == "prod" ]]; then
            if docker exec homa-mariadb-prod mysql -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" -e "SELECT 1" > /dev/null 2>&1; then
                log_success "Database is healthy"
                return 0
            fi
        else
            if docker exec homa-mariadb mysql -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" -e "SELECT 1" > /dev/null 2>&1; then
                log_success "Database is healthy"
                return 0
            fi
        fi
        
        sleep 2
        ((ATTEMPT++))
    done
    
    log_error "Health checks failed after $MAX_ATTEMPTS attempts"
    exit 1
}

# ==============================================================
# Run Smoke Tests
# ==============================================================

run_smoke_tests() {
    log_info "Ejecutando smoke tests..."
    
    # Test API
    API_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/api/health)
    if [[ "$API_RESPONSE" == "200" ]]; then
        log_success "API smoke test passed"
    else
        log_error "API smoke test failed (status: $API_RESPONSE)"
        return 1
    fi
    
    # Test Frontend
    FRONTEND_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/)
    if [[ "$FRONTEND_RESPONSE" == "200" ]]; then
        log_success "Frontend smoke test passed"
    else
        log_error "Frontend smoke test failed (status: $FRONTEND_RESPONSE)"
        return 1
    fi
}

# ==============================================================
# Rollback Function
# ==============================================================

rollback() {
    log_warning "Iniciando rollback..."
    
    if [[ ! -d "backups" ]]; then
        log_error "No backup directory found"
        exit 1
    fi
    
    LATEST_BACKUP=$(ls -t backups/backup_*.sql 2>/dev/null | head -1)
    
    if [[ -z "$LATEST_BACKUP" ]]; then
        log_error "No backups found"
        exit 1
    fi
    
    log_info "Restaurando desde: $LATEST_BACKUP"
    
    # Get latest git tag
    PREVIOUS_VERSION=$(git describe --tags --abbrev=0 HEAD~1 2>/dev/null || echo "latest")
    
    log_info "Checkout a versión anterior: $PREVIOUS_VERSION"
    git checkout "$PREVIOUS_VERSION"
    
    # Restart services
    if [[ "$ENVIRONMENT" == "prod" ]]; then
        docker-compose -f docker-compose.prod.yml restart
    else
        docker-compose restart
    fi
    
    log_success "✅ Rollback completado"
}

# ==============================================================
# Status Function
# ==============================================================

status() {
    log_info "Estado de servicios en ${ENVIRONMENT}..."
    
    if [[ "$ENVIRONMENT" == "prod" ]]; then
        docker-compose -f docker-compose.prod.yml ps
    else
        docker-compose ps
    fi
}

# ==============================================================
# Logs Function
# ==============================================================

logs() {
    log_info "Mostrando logs de ${ENVIRONMENT}..."
    
    if [[ "$ENVIRONMENT" == "prod" ]]; then
        docker-compose -f docker-compose.prod.yml logs -f
    else
        docker-compose logs -f
    fi
}

# ==============================================================
# Main
# ==============================================================

main() {
    log_info "HOMA Deployment Script"
    log_info "Environment: $ENVIRONMENT"
    log_info "Action: $ACTION"
    
    validate_environment
    validate_action
    
    case "$ACTION" in
        deploy)
            deploy
            ;;
        rollback)
            rollback
            ;;
        status)
            status
            ;;
        logs)
            logs
            ;;
        *)
            log_error "Unknown action: $ACTION"
            exit 1
            ;;
    esac
}

main "$@"
