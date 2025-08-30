# 🗃️ Fase 2: PostgreSQL (Data Warehouse)

**Objetivo**: Añadir PostgreSQL como Data Warehouse y conectarlo con MinIO para crear un stack de datos completo

## 🎯 Qué aprenderás en esta fase

- **Data Warehouse**: Diferencia con Data Lake, estructuración de datos
- **PostgreSQL**: Configuración, esquemas, tablas relacionales  
- **Conectividad**: Servicios Docker comunicándose entre sí
- **Modelo estrella**: Implementación en base de datos relacional
- **ETL básico**: Importar datos desde CSV a tablas SQL
- **Integridad referencial**: Claves primarias y foráneas

## 🏗️ Arquitectura de esta fase

```
┌─────────────────┐    ┌─────────────────┐
│   MinIO         │    │  PostgreSQL     │
│ (Data Lake)     │    │ (Data Warehouse)│
│                 │    │                 │
│ Port 9000: API  │    │ Port 5432: DB   │
│ Port 9001: UI   │    │                 │
│                 │    │ Schemas:        │
│ Bucket:         │    │ ├─ dw (tables)  │
│ └─ datalake/    │    │ └─ staging      │
│   └─modelo-ventas/ │  │                 │
└─────────────────┘    └─────────────────┘
         │                        ▲
         └── CSV Import ──────────┘
```

## ⚡ Inicio rápido

```bash
# 1. Configurar variables
cp .env.example .env

# 2. Levantar MinIO + PostgreSQL
make up
# O manualmente: docker compose up -d

# 3. Validar que funciona
make test
# O manualmente: ./test.sh

# 4. Acceder a los servicios
# MinIO: http://localhost:9001 (admin/admin12345)
# PostgreSQL: localhost:5432 (fabric_user/fabric_pass123)
```

## 🔧 Configuración detallada

### Variables de entorno (.env)

| Variable | Descripción | Valor por defecto |
|----------|-------------|-------------------|
| **MinIO** | | |
| `MINIO_API_PORT` | Puerto API S3 | 9000 |
| `MINIO_CONSOLE_PORT` | Puerto consola web | 9001 |
| `MINIO_ROOT_USER` | Usuario MinIO | admin |
| `MINIO_ROOT_PASSWORD` | Contraseña MinIO | admin12345 |
| **PostgreSQL** | | |
| `POSTGRES_PORT` | Puerto PostgreSQL | 5432 |
| `POSTGRES_USER` | Usuario PostgreSQL | fabric_user |
| `POSTGRES_PASSWORD` | Contraseña PostgreSQL | fabric_pass123 |
| `POSTGRES_DB` | Base de datos | fabricdb |
| **Data Warehouse** | | |
| `DW_SCHEMA` | Esquema principal | dw |
| `DW_STAGING_SCHEMA` | Esquema temporal | staging |

### Puertos utilizados

- **9000**: API S3 MinIO  
- **9001**: Consola web MinIO
- **5432**: Base de datos PostgreSQL

## 📊 Estructura de la base de datos

### Esquemas organizacionales

- **`dw`**: Data Warehouse - Tablas del modelo estrella final
- **`staging`**: Área temporal para procesos ETL

### Modelo estrella (esquema `dw`)

**Dimensiones:**
- `dw.dim_date` - Calendario con 731 registros
- `dw.dim_currency` - 4 monedas
- `dw.dim_channel` - 5 canales de venta  
- `dw.dim_store` - 30 tiendas
- `dw.dim_product` - 300 productos
- `dw.dim_salesperson` - 80 vendedores
- `dw.dim_customer` - 5,000 clientes

**Hechos:**
- `dw.fact_exchangerates` - Tipos de cambio diarios
- `dw.fact_sales` - 200,000 líneas de ventas

## 🧪 Validaciones y tests

### Test automático completo
```bash
make test
```

### Validaciones específicas
```bash
# Test de conectividad
make test-connection

# Test de esquemas
make test-schemas  

# Test de datos (después de importar)
make test-data
```

### Exploración manual
```bash
# Conectar a PostgreSQL
make psql
# O manualmente:
docker exec -it fabric-postgres psql -U fabric_user -d fabricdb

# Verificar esquemas
\dn

# Ver tablas en el esquema dw
\dt dw.*

# Consulta de ejemplo
SELECT count(*) FROM dw.fact_sales;
```

## 📥 Importación del modelo de datos

**(En desarrollo - Paso 4 del proceso)**

Comandos para importar desde MinIO:
```bash
# Importar todas las dimensiones
make import-dimensions

# Importar tablas de hechos
make import-facts

# Validar importación completa
make validate-import
```

## 🛠️ Comandos disponibles

```bash
# Gestión básica
make up          # Levantar MinIO + PostgreSQL
make down        # Parar servicios
make restart     # Reiniciar servicios
make logs        # Ver logs en tiempo real

# Validaciones
make test        # Test completo automatizado
make test-connection # Solo conectividad
make test-schemas    # Solo esquemas

# Base de datos
make psql        # Conectar a PostgreSQL
make create-tables   # Crear tablas del modelo
make drop-tables     # Eliminar tablas (¡cuidado!)

# Utilidades
make clean       # Limpiar datos (¡cuidado!)
make backup      # Backup de PostgreSQL
make restore     # Restaurar backup
```

## 🚨 Troubleshooting

### Puerto 5432 ocupado
```bash
# Verificar qué usa el puerto
netstat -ano | findstr :5432

# Cambiar puerto en .env
POSTGRES_PORT=5433

# Reiniciar
make restart
```

### PostgreSQL no arranca
```bash
# Ver logs específicos
docker compose logs postgres

# Verificar health check
docker inspect fabric-postgres | grep Health -A 10

# Limpiar datos corruptos (¡perderás datos!)
make clean
```

### Error de conexión entre servicios
```bash
# Verificar red Docker
docker network ls | grep fabric_net

# Verificar conectividad interna
docker exec fabric-minio ping fabric-postgres
docker exec fabric-postgres ping fabric-minio
```

## 📚 Conceptos importantes

### Data Lake vs Data Warehouse

| Aspecto | Data Lake (MinIO) | Data Warehouse (PostgreSQL) |
|---------|-------------------|-----------------------------|
| **Estructura** | Sin estructura | Altamente estructurado |
| **Formato** | Archivos (CSV, JSON, etc.) | Tablas relacionales |
| **Flexibilidad** | Muy alta | Media |
| **Rendimiento consultas** | Bajo | Alto |
| **Uso ideal** | Exploración, ML | Reporting, BI |

### ¿Por qué ambos?
1. **Flexibilidad**: Data Lake para todo tipo de datos
2. **Rendimiento**: Data Warehouse para consultas rápidas
3. **Escalabilidad**: Cada uno optimizado para su propósito
4. **Flujo moderno**: Raw → Processed → Analytics

## ✅ Criterios de éxito

Antes de pasar a la Fase 3, asegúrate de que:
- [ ] MinIO y PostgreSQL arrancan sin errores
- [ ] Puedes conectarte a PostgreSQL (puerto 5432)
- [ ] Esquemas `dw` y `staging` están creados
- [ ] Los servicios se comunican entre sí
- [ ] Health checks pasan correctamente
- [ ] Entiendes la diferencia Data Lake vs Data Warehouse

## 🎯 Próxima fase

Una vez que MinIO + PostgreSQL funcionen perfectamente:
**[Fase 3: JupyterLab](../fase-3-jupyter/README.md)**

Ahí añadiremos capacidades de análisis y exploración de datos con Python.

---

💡 **Tip**: Esta fase es fundamental. La combinación Data Lake + Data Warehouse es la base de cualquier arquitectura moderna de datos.