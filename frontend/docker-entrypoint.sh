#!/bin/sh
set -e

# Variables de ambiente
API_BASE_URL=${API_BASE_URL:-http://homa-backend:8080}
FRONTEND_API_URL=${FRONTEND_API_URL:-/api}

# Generar configuraci?n de Nginx
envsubst '$API_BASE_URL' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

# Generar config.js con la URL din?mica
cat > /usr/share/nginx/html/assets/config.js <<EOF
// Configuraci?n din?mica inyectada en tiempo de ejecuci?n
window.__APP_CONFIG__ = {
  API_URL: "${FRONTEND_API_URL}"
};
console.log("[App Config] API URL set to:", window.__APP_CONFIG__.API_URL);
EOF

echo " API_BASE_URL: $API_BASE_URL"
echo " FRONTEND_API_URL: $FRONTEND_API_URL"
echo " config.js generado"

exec "$@"
