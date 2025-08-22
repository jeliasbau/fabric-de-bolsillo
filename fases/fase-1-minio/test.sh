#!/bin/bash
# =====================================================
# FABRIC DE BOLSILLO - Test automatizado Fase 1: MinIO
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

# Variables de test
TEST_BUCKET="test-bucket-$(date +%s)"
TEST_FILE="test-file.txt"
TEST_CONTENT="Hola desde Fabric de Bolsillo - Fase 1 MinIO Test"

log_info "🧪 Iniciando test de MinIO - Fase 1"
echo "==========================================="

# Test 1: Verificar que el contenedor esté corriendo
log_info "Test 1: Verificando contenedor..."
if docker ps | grep -q fabric-minio; then
    log_success "Contenedor fabric-minio está corriendo"
else
    log_error "Contenedor fabric-minio no está corriendo"
    log_info "Ejecuta: make up"
    exit 1
fi

# Test 2: Health check de la API
log_info "Test 2: Health check de la API..."
if curl -f "http://localhost:${MINIO_API_PORT}/minio/health/live" >/dev/null 2>&1; then
    log_success "API MinIO respondiendo en puerto ${MINIO_API_PORT}"
else
    log_error "API MinIO no responde en puerto ${MINIO_API_PORT}"
    log_info "Verifica los logs: make logs"
    exit 1
fi

# Test 3: Verificar acceso a la consola web
log_info "Test 3: Verificando consola web..."
if curl -f "http://localhost:${MINIO_CONSOLE_PORT}" >/dev/null 2>&1; then
    log_success "Consola web accesible en puerto ${MINIO_CONSOLE_PORT}"
else
    log_warning "Consola web no responde en puerto ${MINIO_CONSOLE_PORT}"
    log_info "Puede tardar un momento en estar lista"
fi

# Test 4: Configurar MinIO Client dentro del contenedor
log_info "Test 4: Configurando MinIO Client..."
docker exec fabric-minio mc alias set local "http://localhost:9000" "${MINIO_ROOT_USER}" "${MINIO_ROOT_PASSWORD}" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    log_success "MinIO Client configurado correctamente"
else
    log_error "Error configurando MinIO Client"
    exit 1
fi

# Test 5: Crear bucket de prueba
log_info "Test 5: Creando bucket de prueba..."
docker exec fabric-minio mc mb "local/${TEST_BUCKET}" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    log_success "Bucket '${TEST_BUCKET}' creado"
else
    log_error "Error creando bucket '${TEST_BUCKET}'"
    exit 1
fi

# Test 6: Subir archivo de prueba
log_info "Test 6: Subiendo archivo de prueba..."
echo "${TEST_CONTENT}" | docker exec -i fabric-minio mc pipe "local/${TEST_BUCKET}/${TEST_FILE}" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    log_success "Archivo '${TEST_FILE}' subido correctamente"
else
    log_error "Error subiendo archivo '${TEST_FILE}'"
    exit 1
fi

# Test 7: Listar archivos del bucket
log_info "Test 7: Listando archivos del bucket..."
FILES=$(docker exec fabric-minio mc ls "local/${TEST_BUCKET}" 2>/dev/null | wc -l)
if [ "$FILES" -gt 0 ]; then
    log_success "Bucket contiene $FILES archivo(s)"
else
    log_error "No se encontraron archivos en el bucket"
    exit 1
fi

# Test 8: Descargar y verificar contenido
log_info "Test 8: Verificando contenido del archivo..."
DOWNLOADED_CONTENT=$(docker exec fabric-minio mc cat "local/${TEST_BUCKET}/${TEST_FILE}" 2>/dev/null)
if [ "$DOWNLOADED_CONTENT" = "$TEST_CONTENT" ]; then
    log_success "Contenido del archivo verificado correctamente"
else
    log_error "El contenido del archivo no coincide"
    exit 1
fi

# Test 9: Limpiar bucket de prueba
log_info "Test 9: Limpiando bucket de prueba..."
docker exec fabric-minio mc rm -r "local/${TEST_BUCKET}" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    log_success "Bucket de prueba eliminado"
else
    log_warning "No se pudo eliminar el bucket de prueba"
fi

# Test 10: Crear bucket por defecto si no existe
log_info "Test 10: Verificando bucket por defecto..."
docker exec fabric-minio mc mb "local/${MINIO_DEFAULT_BUCKET}" >/dev/null 2>&1
log_success "Bucket por defecto '${MINIO_DEFAULT_BUCKET}' disponible"

# Resumen final
echo ""
log_success "🎉 ¡Todos los tests de MinIO pasaron correctamente!"
echo "==========================================="
echo ""
log_info "📊 Información de acceso:"
echo "   🌐 Consola web: http://localhost:${MINIO_CONSOLE_PORT}"
echo "   🔑 Usuario: ${MINIO_ROOT_USER}"
echo "   🔐 Contraseña: ${MINIO_ROOT_PASSWORD}"
echo "   📦 Bucket por defecto: ${MINIO_DEFAULT_BUCKET}"
echo ""
log_info "🚀 ¡MinIO está listo! Puedes continuar con la Fase 2."
echo ""
log_info "💡 Próximos pasos:"
echo "   1. Explora la consola web"
echo "   2. Sube algunos archivos CSV de prueba"
echo "   3. Continúa con: cd ../fase-2-postgres/"