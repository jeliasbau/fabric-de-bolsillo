#!/bin/bash
# =====================================================
# FABRIC DE BOLSILLO - Test automatizado Fase 2
# =====================================================

set -e  # Salir si cualquier comando falla

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funciones de utilidad
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Leer variables del .env
if [ ! -f .env ]; then
    log_error "Archivo .env no encontrado. Ejecuta: cp .env.example .env"
    exit 1
fi

source .env

log_info "🧪 Iniciando test de MinIO + PostgreSQL - Fase 2"
echo "================================================="

# Test 1: Verificar contenedores corriendo
log_info "Test 1: Verificando contenedores..."
if docker ps | grep -q fabric-minio && docker ps | grep -q fabric-postgres; then
    log_success "Ambos contenedores están corriendo"
else
    log_error "Uno o más contenedores no están corriendo"
    log_info "Ejecuta: make up"
    exit 1
fi

# Test 2: Health check MinIO
log_info "Test 2: Health check MinIO..."
if curl -f "http://localhost:${MINIO_API_PORT}/minio/health/live" >/dev/null 2>&1; then
    log_success "MinIO API respondiendo en puerto ${MINIO_API_PORT}"
else
    log_error "MinIO API no responde"
    exit 1
fi

# Test 3: Health check PostgreSQL
log_info "Test 3: Health check PostgreSQL..."
if docker exec fabric-postgres pg_isready -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" >/dev/null 2>&1; then
    log_success "PostgreSQL respondiendo en puerto ${POSTGRES_PORT}"
else
    log_error "PostgreSQL no responde"
    exit 1
fi

# Test 4: Verificar esquemas
log_info "Test 4: Verificando esquemas de BD..."
SCHEMAS=$(docker exec fabric-postgres psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -t -c "SELECT schema_name FROM information_schema.schemata WHERE schema_name IN ('dw', 'staging');" 2>/dev/null | tr -d ' ' | grep -v '^$' | wc -l)
if [ "$SCHEMAS" -eq 2 ]; then
    log_success "Esquemas 'dw' y 'staging' creados correctamente"
else
    log_error "Esquemas no encontrados o incompletos"
    exit 1
fi

# Test 5: Conectividad entre servicios
log_info "Test 5: Conectividad entre servicios..."
if docker exec fabric-minio ping -c 1 fabric-postgres >/dev/null 2>&1; then
    log_success "MinIO puede conectar con PostgreSQL"
else
    log_warning "Conectividad directa no disponible (puede ser normal)"
fi

if docker exec fabric-postgres ping -c 1 fabric-minio >/dev/null 2>&1; then
    log_success "PostgreSQL puede conectar con MinIO"
else
    log_warning "Conectividad directa no disponible (puede ser normal)"
fi

# Test 6: Verificar red Docker
log_info "Test 6: Verificando red Docker..."
if docker network ls | grep -q fabric_net; then
    log_success "Red 'fabric_net' existe"
    CONTAINERS_IN_NETWORK=$(docker network inspect fabric_net | grep -c '"Name": "fabric-')
    log_success "$CONTAINERS_IN_NETWORK contenedores en la red"
else
    log_error "Red 'fabric_net' no encontrada"
    exit 1
fi

# Test 7: Verificar Data Lake (de Fase 1)
log_info "Test 7: Verificando Data Lake..."
# Configurar MinIO Client
docker exec fabric-minio mc alias set local "http://localhost:9000" "${MINIO_ROOT_USER}" "${MINIO_ROOT_PASSWORD}" >/dev/null 2>&1

MODEL_FILES=$(docker exec fabric-minio mc ls -r local/datalake/modelo-ventas/ 2>/dev/null | wc -l)
if [ "$MODEL_FILES" -gt 8 ]; then
    log_success "Modelo de datos detectado en Data Lake ($MODEL_FILES archivos)"
else
    log_warning "Modelo de datos no encontrado o incompleto"
    log_info "Asegúrate de haber completado la Fase 1 primero"
fi

# Test 8: Verificar acceso consola MinIO
log_info "Test 8: Verificando consola MinIO..."
if curl -f "http://localhost:${MINIO_CONSOLE_PORT}" >/dev/null 2>&1; then
    log_success "Consola MinIO accesible en puerto ${MINIO_CONSOLE_PORT}"
else
    log_warning "Consola MinIO no responde (puede tardar en estar lista)"
fi

# Test 9: Test básico de SQL
log_info "Test 9: Test básico de SQL..."
SQL_TEST=$(docker exec fabric-postgres psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -t -c "SELECT 'PostgreSQL funcionando correctamente' as test;" 2>/dev/null | tr -d ' ' | grep -v '^$')
if [ "$SQL_TEST" = "PostgreSQLfuncionandocorrectamente" ]; then
    log_success "PostgreSQL acepta consultas SQL"
else
    log_error "Error ejecutando consultas SQL"
    exit 1
fi

# Test 10: Verificar versiones
log_info "Test 10: Verificando versiones..."
PG_VERSION=$(docker exec fabric-postgres psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -t -c "SELECT version();" 2>/dev/null | head -1 | cut -d',' -f1)
log_success "PostgreSQL: $PG_VERSION"

MINIO_VERSION=$(docker exec fabric-minio minio --version 2>/dev/null | head -1)
log_success "$MINIO_VERSION"

# Resumen final
echo ""
log_success "🎉 ¡Todos los tests de Fase 2 pasaron correctamente!"
echo "================================================="
echo ""
log_info "📊 Información de acceso:"
echo "   🌐 MinIO Console: http://localhost:${MINIO_CONSOLE_PORT}"
echo "   🔑 MinIO: ${MINIO_ROOT_USER} / ${MINIO_ROOT_PASSWORD}"
echo ""
echo "   🗃️ PostgreSQL: localhost:${POSTGRES_PORT}"
echo "   🔑 PostgreSQL: ${POSTGRES_USER} / ${POSTGRES_PASSWORD}"
echo "   💾 Base de datos: ${POSTGRES_DB}"
echo ""
log_info "🗂️ Esquemas disponibles:"
echo "   📊 dw - Data Warehouse (tablas finales)"
echo "   🔄 staging - Área temporal ETL"
echo ""
log_info "🚀 Próximos pasos:"
echo "   1. Explorar PostgreSQL: make psql"
echo "   2. Importar el modelo de datos (Paso 3)"
echo "   3. Continuar con: cd ../fase-3-jupyter/"
echo ""