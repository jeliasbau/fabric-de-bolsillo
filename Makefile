# =====================================================
# FABRIC DE BOLSILLO - Makefile Principal
# =====================================================

.PHONY: help setup clean-all status

# Variables
TIMESTAMP := $(shell date +"%Y%m%d_%H%M%S")

# Default target
help:
	@echo ""
	@echo "🏗️  FABRIC DE BOLSILLO - Comandos Principales"
	@echo "==============================================" 
	@echo ""
	@echo "📚 GESTIÓN DEL PROYECTO:"
	@echo "  setup         - Crear estructura inicial de carpetas"
	@echo "  status        - Ver estado de todos los servicios Docker"
	@echo "  clean-all     - ⚠️  Limpiar TODOS los datos (peligroso)"
	@echo ""
	@echo "🚀 FASES DE CONSTRUCCIÓN:"
	@echo "  fase1         - Ir a Fase 1 (MinIO)"
	@echo "  fase2         - Ir a Fase 2 (MinIO + PostgreSQL)"
	@echo "  fase3         - Ir a Fase 3 (+ JupyterLab)"
	@echo "  fase4         - Ir a Fase 4 (+ n8n)"
	@echo "  fase5         - Ir a Fase 5 (+ Metabase)"
	@echo ""
	@echo "🎯 STACK COMPLETO:"
	@echo "  final         - Ir al stack final completo"
	@echo "  up-all        - Levantar stack completo"
	@echo "  down-all      - Parar stack completo"
	@echo "  test-all      - Validar stack completo"
	@echo ""
	@echo "💡 EJEMPLO DE USO:"
	@echo "  make setup    # Crear estructura"
	@echo "  make fase1    # Ir a Fase 1"
	@echo "  # Dentro de fase1/: make up && make test"
	@echo ""

# =====================================================
# GESTIÓN DEL PROYECTO
# =====================================================

setup:
	@echo "📁 Creando estructura de carpetas..."
	@mkdir -p fases/fase-1-minio
	@mkdir -p fases/fase-2-postgres
	@mkdir -p fases/fase-3-jupyter/notebooks
	@mkdir -p fases/fase-4-n8n
	@mkdir -p fases/fase-5-metabase
	@mkdir -p final/scripts
	@mkdir -p data/{minio,postgres,jupyter,n8n,metabase}
	@mkdir -p docs
	@touch data/.gitkeep
	@echo "✅ Estructura creada correctamente"
	@echo ""
	@echo "📋 Próximos pasos:"
	@echo "  1. make fase1    # Ir a la Fase 1"
	@echo "  2. Seguir las instrucciones del README de cada fase"

status:
	@echo "📊 Estado de contenedores Docker:"
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "No hay contenedores ejecutándose"

clean-all:
	@echo "🚨 ¡CUIDADO! Esto eliminará TODOS los datos de Docker"
	@echo "Incluyendo: contenedores, volúmenes, networks, imágenes no usadas"
	@read -p "¿Estás SEGURO? Escribe 'SI' en mayúsculas: " confirm; \
	if [ "$$confirm" = "SI" ]; then \
		echo "🧹 Limpiando contenedores..."; \
		docker container prune -f; \
		echo "🧹 Limpiando volúmenes..."; \
		docker volume prune -f; \
		echo "🧹 Limpiando networks..."; \
		docker network prune -f; \
		echo "🧹 Limpiando imágenes no usadas..."; \
		docker image prune -a -f; \
		echo "🧹 Limpiando datos locales..."; \
		rm -rf data/*; \
		echo "✅ Limpieza completa terminada"; \
	else \
		echo "❌ Operación cancelada"; \
	fi

# =====================================================
# NAVEGACIÓN A FASES
# =====================================================

fase1:
	@echo "🚀 Cambiando a Fase 1 (MinIO)..."
	@cd fases/fase-1-minio && pwd && echo "Ejecuta: make help"

fase2:
	@echo "🚀 Cambiando a Fase 2 (MinIO + PostgreSQL)..."
	@cd fases/fase-2-postgres && pwd && echo "Ejecuta: make help"

fase3:
	@echo "🚀 Cambiando a Fase 3 (+ JupyterLab)..."
	@cd fases/fase-3-jupyter && pwd && echo "Ejecuta: make help"

fase4:
	@echo "🚀 Cambiando a Fase 4 (+ n8n)..."
	@cd fases/fase-4-n8n && pwd && echo "Ejecuta: make help"

fase5:
	@echo "🚀 Cambiando a Fase 5 (+ Metabase)..."
	@cd fases/fase-5-metabase && pwd && echo "Ejecuta: make help"

final:
	@echo "🎯 Cambiando al stack final..."
	@cd final && pwd && echo "Ejecuta: make help"

# =====================================================
# STACK COMPLETO (desde carpeta principal)
# =====================================================

up-all:
	@echo "🚀 Levantando stack completo..."
	@cd final && docker compose up -d

down-all:
	@echo "🛑 Parando stack completo..."
	@cd final && docker compose down

test-all:
	@echo "🧪 Validando stack completo..."
	@cd final && make test

# =====================================================
# UTILIDADES
# =====================================================

logs-all:
	@echo "📋 Logs del stack completo:"
	@cd final && docker compose logs -f --tail=50