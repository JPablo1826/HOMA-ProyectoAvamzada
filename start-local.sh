#!/bin/bash
# Script para iniciar HOMA en modo local (Linux/Mac)
# Uso: ./start-local.sh

set -e

echo "🏠 INICIANDO HOMA EN MODO LOCAL"
echo "================================"

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📋 Verificando requisitos...${NC}"

# Verificar Java
if ! command -v java &> /dev/null; then
    echo "❌ Java no está instalado. Por favor instala Java 17+"
    exit 1
fi

# Verificar Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js no está instalado. Por favor instala Node.js 18+"
    exit 1
fi

echo -e "${GREEN}✅ Requisitos verificados${NC}"
echo ""

# Iniciar Backend
echo -e "${BLUE}🚀 Iniciando Backend (Spring Boot)...${NC}"
cd Homa
./gradlew bootRun &
BACKEND_PID=$!
cd ..

echo -e "${GREEN}✅ Backend iniciado en http://localhost:8080${NC}"
echo -e "${BLUE}⏳ Esperando 30 segundos para que el backend esté listo...${NC}"
sleep 30

# Iniciar Frontend
echo ""
echo -e "${BLUE}🚀 Iniciando Frontend (Angular)...${NC}"
cd frontend
npm install
npm start &
FRONTEND_PID=$!
cd ..

echo ""
echo -e "${GREEN}✅ Frontend iniciado en http://localhost:4200${NC}"
echo ""
echo "🏠 HOMA está corriendo!"
echo "======================="
echo "📱 Frontend: http://localhost:4200"
echo "⚙️  Backend API: http://localhost:8080/api"
echo "📚 Swagger UI: http://localhost:8080/swagger-ui.html"
echo ""
echo "Usuarios de prueba:"
echo "  👤 Admin: admin@homa.com / admin123"
echo "  👤 Huésped: huesped1@homa.com / huesped123"
echo "  👤 Anfitrión: anfitrion1@homa.com / anfitrion123"
echo ""
echo "Presiona Ctrl+C para detener todos los servicios"
echo ""

# Esperar y limpiar al salir
trap "echo ''; echo '🛑 Deteniendo servicios...'; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; exit 0" INT

wait
