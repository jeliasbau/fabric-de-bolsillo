# 🏗️ Fabric de Bolsillo v2

**Stack local modular que emula Microsoft Fabric usando herramientas open-source**

Diseñado para aprender, experimentar y crear soluciones de datos paso a paso.

## 🎯 Objetivos

- **Aprendizaje gradual**: Construir el stack componente por componente
- **Debugging sencillo**: Identificar problemas de forma aislada
- **Buenas prácticas**: Código limpio, documentado y reutilizable
- **Entorno reproducible**: Configuración consistente y versionada

## 🧩 Componentes del Stack Final

| Servicio | Rol | Puerto | Dependencias |
|----------|-----|--------|--------------|
| **MinIO** | Data Lake (almacén S3-like) | 9000/9001 | Ninguna |
| **PostgreSQL** | Base de datos relacional | 5432 | Ninguna |
| **JupyterLab** | Análisis y transformación | 8888 | MinIO, PostgreSQL |
| **n8n** | Orquestación de flujos | 5678 | MinIO, PostgreSQL |
| **Metabase** | BI y visualización | 3000 | PostgreSQL |

## 🚀 Construcción por Fases

### **Fase 1: MinIO (Data Lake)**
```bash
cd fases/fase-1-minio/
make up
make test
```
**Aprenderás**: Almacenamiento de archivos, buckets, API S3

### **Fase 2: PostgreSQL (Base de Datos)**
```bash
cd fases/fase-2-postgres/
make up
make test
```
**Aprenderás**: Bases de datos, conectividad, esquemas

### **Fase 3: JupyterLab (Análisis)**
```bash
cd fases/fase-3-jupyter/
make up
make test
```
**Aprenderás**: Conexiones desde Python, pandas, análisis de datos

### **Fase 4: n8n (Orquestación)**
```bash
cd fases/fase-4-n8n/
make up
make test
```
**Aprenderás**: Workflows, automatización, ETL

### **Fase 5: Metabase (BI)**
```bash
cd fases/fase-5-metabase/
make up
make test
```
**Aprenderás**: Dashboards, visualización, BI

## 📦 Requisitos

- **Docker Desktop** ≥ 4.x con Docker Compose
- **Git** para versionado
- **8GB RAM** mínimo recomendado
- **10GB espacio libre** para datos y imágenes

## ⚡ Inicio Rápido

```bash
# 1. Clonar y entrar al proyecto
git clone https://github.com/jeliasbau/fabric-de-bolsillo.git
cd fabric-de-bolsillo

# 2. Crear estructura de carpetas
make setup

# 3. Empezar con la Fase 1
cd fases/fase-1-minio/
cp .env.example .env
make up
make test

# 4. Continuar con las siguientes fases...
```

## 🛠️ Comandos Principales

```bash
# En cada fase
make up          # Levantar servicios de la fase
make down        # Parar servicios
make test        # Validar que todo funciona
make logs        # Ver logs en tiempo real
make clean       # Limpiar datos (¡cuidado!)

# Stack completo (carpeta final/)
make up-all      # Levantar stack completo
make test-all    # Validar stack completo
```

## 📚 Documentación

- **[Arquitectura](docs/arquitectura.md)** - Diseño y decisiones técnicas
- **[Troubleshooting](docs/troubleshooting.md)** - Solución de problemas
- **[Buenas Prácticas](docs/buenas-practicas.md)** - Recomendaciones de uso

## 🚨 Troubleshooting Rápido

**Problema**: Puertos ocupados
```bash
# Cambiar puertos en .env y reiniciar
make down && make up
```

**Problema**: Servicios no se conectan
```bash
# Ver logs específicos
make logs
```

**Problema**: Datos corruptos
```bash
# Limpieza completa (¡perderás datos!)
make clean
```

## 🤝 Contribución

1. **Reporta problemas**: Abre un issue con detalles
2. **Sugiere mejoras**: Pull requests son bienvenidos
3. **Comparte experiencias**: Documenta tus casos de uso

## 📄 Licencia

MIT License - Usa como quieras, aprende y comparte

---

**¿Listo para empezar?** 🚀 Ve a `fases/fase-1-minio/` y sigue el README.