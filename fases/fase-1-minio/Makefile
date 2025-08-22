# =====================================================
# FABRIC DE BOLSILLO - FASE 1: MinIO
# =====================================================

.PHONY: help up down restart logs test health create-bucket clean backup restore

# Variables
TIMESTAMP := $(shell date +"%Y%m%d_%H%M%S")
BACKUP_DIR := ../../backups/fase1

# Default target
help:
	@echo ""
	@echo "🗄️  FASE 1: MinIO (Data Lake)"
	@echo "============================"
	@echo ""
	@echo "📚 GESTIÓN BÁSICA:"
	@echo "  up          - Levantar MinIO"
	@echo "  down        - Parar MinIO"
	@echo "  restart     - Reiniciar MinIO"
	@echo "  logs        - Ver logs en tiempo real"
	@echo ""
	@echo "🧪 VALIDACIONES:"
	@echo "  test        - Test completo automatizado"
	@echo "  health      - Solo health check"
	@echo "  create-bucket - Crear bucket por defecto"
	@echo ""
	@echo "🛠️ UTILIDADES:"
	@echo "  clean       - Limpiar datos (¡cuidado!)"
	@echo "  backup      - Backup de datos"
	@echo "  restore     - Restaurar último backup"
	@echo ""
	@echo "💡 INICIO RÁPIDO:"
	@echo "  1. cp .env.example .env"
	@echo "  2. make up"
	@echo "  3. make test"
	@echo "  4. Abrir http://localhost:9001"
	@echo ""

# =====================================================
# GESTIÓN BÁSICA
# =====================================================

up:
	@echo "🚀 Levantando MinIO..."
	@if [ ! -f .env ]; then echo "❌ Archivo .env no encontrado. Ejecuta: cp .env.example .env"; exit 1; fi
	docker compose up -d
	@echo "✅ MinIO iniciado"
	@echo "🌐 Consola web: http://localhost:$$(grep MINIO_CONSOLE_PORT .env | cut -d'=' -f2)"
	@echo "🔑 Usuario: $$(grep MINIO_ROOT_USER .env | cut -d'=' -f2)"

down:
	@echo "🛑 Parando MinIO..."
	docker compose down
	@echo "✅ MinIO parado"

restart:
	@echo "🔄 Reiniciando MinIO..."
	docker compose down
	docker compose up -d
	@echo "✅ MinIO reiniciado"

logs:
	@echo "📋 Logs de MinIO (Ctrl+C para salir):"
	docker compose logs -f

# =====================================================
# VALIDACIONES
# =====================================================

test:
	@echo "🧪 Ejecutando test completo de MinIO..."
	@chmod +x test.sh
	@./test.sh

health:
	@echo "🏥 Verificando health de MinIO..."
	@if docker ps | grep -q fabric-minio; then \
		echo "✅ Contenedor corriendo"; \
		curl -f http://localhost:$$(grep MINIO_API_PORT .env | cut -d'=' -f2)/minio/health/live >/dev/null 2>&1 && \
		echo "✅ API respondiendo" || echo "❌ API no responde"; \
	else \
		echo "❌ Contenedor no está corriendo"; \
	fi

create-bucket:
	@echo "📦 Creando bucket por defecto..."
	@docker exec fabric-minio mc mb /data/$$(grep MINIO_DEFAULT_BUCKET .env | cut -d'=' -f2) 2>/dev/null || true
	@echo "✅ Bucket creado o ya existía"

# =====================================================
# UTILIDADES
# =====================================================

clean:
	@echo "🚨 ¡CUIDADO! Esto eliminará todos los datos de MinIO"
	@read -p "¿Estás seguro? Escribe 'SI' en mayúsculas: " confirm; \
	if [ "$$confirm" = "SI" ]; then \
		echo "🧹 Limpiando..."; \
		docker compose down; \
		rm -rf ../../data/minio/*; \
		echo "✅ Datos eliminados"; \
	else \
		echo "❌ Operación cancelada"; \
	fi

backup:
	@echo "💾 Creando backup de MinIO..."
	@mkdir -p $(BACKUP_DIR)
	@tar -czf $(BACKUP_DIR)/minio_$(TIMESTAMP).tar.gz -C ../../data/minio .
	@echo "✅ Backup guardado en $(BACKUP_DIR)/minio_$(TIMESTAMP).tar.gz"

restore:
	@echo "📂 Listando backups disponibles:"
	@ls -la $(BACKUP_DIR)/*.tar.gz 2>/dev/null || echo "No hay backups disponibles"
	@read -p "Nombre del archivo a restaurar: " backup_file; \
	if [ -f "$(BACKUP_DIR)/$$backup_file" ]; then \
		echo "🔄 Restaurando $$backup_file..."; \
		docker compose down; \
		rm -rf ../../data/minio/*; \
		tar -xzf $(BACKUP_DIR)/$$backup_file -C ../../data/minio; \
		echo "✅ Backup restaurado"; \
	else \
		echo "❌ Archivo no encontrado"; \
	fi

# =====================================================
# DESARROLLO Y DEBUG
# =====================================================

shell:
	@echo "🖥️ Accediendo al shell de MinIO..."
	docker exec -it fabric-minio sh

mc:
	@echo "🔧 Ejecutando MinIO Client..."
	docker exec -it fabric-minio mc --help