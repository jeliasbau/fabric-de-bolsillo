# =====================================================
# FABRIC DE BOLSILLO - FASE 2: MinIO + PostgreSQL
# =====================================================

.PHONY: help up down restart logs test test-connection test-schemas psql clean backup restore

# Variables
TIMESTAMP := $(shell date +"%Y%m%d_%H%M%S")
BACKUP_DIR := ../../backups/fase2

# Default target
help:
	@echo ""
	@echo "🗃️  FASE 2: MinIO + PostgreSQL"
	@echo "================================"
	@echo ""
	@echo "📚 GESTIÓN BÁSICA:"
	@echo "  up          - Levantar MinIO + PostgreSQL"
	@echo "  down        - Parar servicios"
	@echo "  restart     - Reiniciar servicios"
	@echo "  logs        - Ver logs en tiempo real"
	@echo ""
	@echo "🧪 VALIDACIONES:"
	@echo "  test        - Test completo automatizado"
	@echo "  test-connection - Solo conectividad"
	@echo "  test-schemas    - Solo esquemas"
	@echo ""
	@echo "🗃️ BASE DE DATOS:"
	@echo "  psql        - Conectar a PostgreSQL"
	@echo "  create-tables   - Crear tablas del modelo"
	@echo "  drop-tables     - Eliminar tablas (¡cuidado!)"
	@echo ""
	@echo "🛠️ UTILIDADES:"
	@echo "  clean       - Limpiar datos (¡cuidado!)"
	@echo "  backup      - Backup de PostgreSQL"
	@echo "  restore     - Restaurar backup"
	@echo ""
	@echo "💡 INICIO RÁPIDO:"
	@echo "  1. cp .env.example .env"
	@echo "  2. make up"
	@echo "  3. make test"
	@echo "  4. make psql"
	@echo ""

# =====================================================
# GESTIÓN BÁSICA
# =====================================================

up:
	@echo "🚀 Levantando MinIO + PostgreSQL..."
	@if [ ! -f .env ]; then echo "❌ Archivo .env no encontrado. Ejecuta: cp .env.example .env"; exit 1; fi
	docker compose up -d
	@echo "⏳ Esperando a que los servicios estén listos..."
	@sleep 10
	@echo "✅ Servicios iniciados"
	@echo "🌐 MinIO Console: http://localhost:$$(grep MINIO_CONSOLE_PORT .env | cut -d'=' -f2)"
	@echo "🗃️ PostgreSQL: localhost:$$(grep POSTGRES_PORT .env | cut -d'=' -f2)"
	@echo ""
	@echo "🔑 Credenciales:"
	@echo "   MinIO: $$(grep MINIO_ROOT_USER .env | cut -d'=' -f2) / $$(grep MINIO_ROOT_PASSWORD .env | cut -d'=' -f2)"
	@echo "   PostgreSQL: $$(grep POSTGRES_USER .env | cut -d'=' -f2) / $$(grep POSTGRES_PASSWORD .env | cut -d'=' -f2)"

down:
	@echo "🛑 Parando servicios..."
	docker compose down
	@echo "✅ Servicios parados"

restart:
	@echo "🔄 Reiniciando servicios..."
	docker compose down
	docker compose up -d
	@sleep 10
	@echo "✅ Servicios reiniciados"

logs:
	@echo "📋 Logs de servicios (Ctrl+C para salir):"
	docker compose logs -f

# =====================================================
# VALIDACIONES
# =====================================================

test:
	@echo "🧪 Ejecutando test completo..."
	@chmod +x test.sh
	@./test.sh

test-connection:
	@echo "🔗 Verificando conectividad..."
	@echo "  MinIO..."
	@if docker ps | grep -q fabric-minio; then \
		echo "  ✅ MinIO container running"; \
		curl -f http://localhost:$$(grep MINIO_API_PORT .env | cut -d'=' -f2)/minio/health/live >/dev/null 2>&1 && \
		echo "  ✅ MinIO API responding" || echo "  ❌ MinIO API not responding"; \
	else \
		echo "  ❌ MinIO container not running"; \
	fi
	@echo "  PostgreSQL..."
	@if docker ps | grep -q fabric-postgres; then \
		echo "  ✅ PostgreSQL container running"; \
		docker exec fabric-postgres pg_isready -U $$(grep POSTGRES_USER .env | cut -d'=' -f2) -d $$(grep POSTGRES_DB .env | cut -d'=' -f2) >/dev/null 2>&1 && \
		echo "  ✅ PostgreSQL responding" || echo "  ❌ PostgreSQL not responding"; \
	else \
		echo "  ❌ PostgreSQL container not running"; \
	fi

test-schemas:
	@echo "📊 Verificando esquemas..."
	@docker exec fabric-postgres psql -U $$(grep POSTGRES_USER .env | cut -d'=' -f2) -d $$(grep POSTGRES_DB .env | cut -d'=' -f2) -c "\dn" 2>/dev/null | grep -E "(dw|staging)" && echo "✅ Esquemas creados" || echo "❌ Esquemas no encontrados"

# =====================================================
# BASE DE DATOS
# =====================================================

psql:
	@echo "🗃️ Conectando a PostgreSQL..."
	@echo "Comandos útiles:"
	@echo "  \dn          - Listar esquemas"
	@echo "  \dt dw.*     - Listar tablas del esquema dw"
	@echo "  \q           - Salir"
	@echo ""
	docker exec -it fabric-postgres psql -U $$(grep POSTGRES_USER .env | cut -d'=' -f2) -d $$(grep POSTGRES_DB .env | cut -d'=' -f2)

create-tables:
	@echo "📊 Creando tablas del modelo..."
	@echo "(Pendiente - Paso 3 del proceso)"

drop-tables:
	@echo "🚨 ¡CUIDADO! Esto eliminará todas las tablas"
	@read -p "¿Estás seguro? Escribe 'SI' en mayúsculas: " confirm; \
	if [ "$$confirm" = "SI" ]; then \
		echo "🗑️ Eliminando tablas..."; \
		docker exec fabric-postgres psql -U $$(grep POSTGRES_USER .env | cut -d'=' -f2) -d $$(grep POSTGRES_DB .env | cut -d'=' -f2) -c "DROP SCHEMA IF EXISTS dw CASCADE; DROP SCHEMA IF EXISTS staging CASCADE;"; \
		echo "✅ Tablas eliminadas"; \
	else \
		echo "❌ Operación cancelada"; \
	fi

# =====================================================
# UTILIDADES
# =====================================================

clean:
	@echo "🚨 ¡CUIDADO! Esto eliminará todos los datos"
	@read -p "¿Estás seguro? Escribe 'SI' en mayúsculas: " confirm; \
	if [ "$$confirm" = "SI" ]; then \
		echo "🧹 Limpiando..."; \
		docker compose down; \
		rm -rf ../../data/minio/* ../../data/postgres/*; \
		echo "✅ Datos eliminados"; \
	else \
		echo "❌ Operación cancelada"; \
	fi

backup:
	@echo "💾 Creando backup de PostgreSQL..."
	@mkdir -p $(BACKUP_DIR)
	@docker exec fabric-postgres pg_dump -U $$(grep POSTGRES_USER .env | cut -d'=' -f2) -d $$(grep POSTGRES_DB .env | cut -d'=' -f2) | gzip > $(BACKUP_DIR)/postgres_$(TIMESTAMP).sql.gz
	@echo "✅ Backup guardado en $(BACKUP_DIR)/postgres_$(TIMESTAMP).sql.gz"

restore:
	@echo "📂 Listando backups disponibles:"
	@ls -la $(BACKUP_DIR)/*.sql.gz 2>/dev/null || echo "No hay backups disponibles"
	@read -p "Nombre del archivo a restaurar: " backup_file; \
	if [ -f "$(BACKUP_DIR)/$$backup_file" ]; then \
		echo "🔄 Restaurando $$backup_file..."; \
		zcat $(BACKUP_DIR)/$$backup_file | docker exec -i fabric-postgres psql -U $$(grep POSTGRES_USER .env | cut -d'=' -f2) -d $$(grep POSTGRES_DB .env | cut -d'=' -f2); \
		echo "✅ Backup restaurado"; \
	else \
		echo "❌ Archivo no encontrado"; \
	fi

# =====================================================
# DESARROLLO Y DEBUG
# =====================================================

network:
	@echo "🌐 Información de red Docker:"
	@docker network inspect fabric_net | grep -E '"Name"|"IPv4Address"' || echo "Red no encontrada"

status:
	@echo "📊 Estado de contenedores:"
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep fabric