# 🗂️ Fase 1: MinIO (Data Lake)

**Objetivo**: Configurar y validar MinIO como almacén de datos tipo S3, y cargar un modelo de datos profesional

## 🎯 Qué aprenderás en esta fase

- **Almacenamiento tipo S3**: Conceptos de buckets y objetos
- **MinIO**: Configuración y uso básico
- **API S3**: Interfaz estándar para almacenamiento
- **Docker networking**: Redes aisladas para servicios
- **Health checks**: Validación automática de servicios
- **Organización de Data Lake**: Estructura profesional de datos
- **Modelo estrella**: Dimensiones y tablas de hechos

## 🏗️ Arquitectura de esta fase

```
┌─────────────────┐
│   MinIO         │
│ (Data Lake S3)  │
│                 │
│ Port 9000: API  │
│ Port 9001: UI   │
│                 │
│ Bucket:         │
│ └─ datalake/    │
│   └─modelo-ventas/
└─────────────────┘
```

## ⚡ Inicio rápido

```bash
# 1. Configurar variables
cp .env.example .env

# 2. Levantar MinIO
make up
# O manualmente: docker compose up -d

# 3. Validar que funciona
make test
# O manualmente: ./test.sh

# 4. Acceder a la consola web
# http://localhost:9001
# Usuario: admin / Contraseña: admin12345
```

## 🔧 Configuración detallada

### Variables de entorno (.env)

| Variable | Descripción | Valor por defecto |
|----------|-------------|-------------------|
| `MINIO_API_PORT` | Puerto para API S3 | 9000 |
| `MINIO_CONSOLE_PORT` | Puerto para consola web | 9001 |
| `MINIO_ROOT_USER` | Usuario administrador | admin |
| `MINIO_ROOT_PASSWORD` | Contraseña admin | admin12345 |
| `MINIO_DEFAULT_BUCKET` | Bucket por defecto | datalake |

### Puertos utilizados

- **9000**: API S3 compatible (para aplicaciones)
- **9001**: Consola web MinIO (para humanos)

## 📊 Modelo de Datos: Ventas (Esquema Estrella)

Este proyecto incluye un **modelo de datos profesional** con:

### 📋 Dimensiones (7 tablas)
- **dim_date.csv**: Calendario 2023-2024 (731 filas) con festivos españoles
- **dim_currency.csv**: 4 monedas (EUR, USD, GBP, MXN)  
- **dim_channel.csv**: 5 canales de venta
- **dim_store.csv**: 30 tiendas (ES, FR, PT, MX, UK)
- **dim_product.csv**: 300 productos en 6 categorías
- **dim_salesperson.csv**: 80 vendedores con equipos
- **dim_customer.csv**: 5,000 clientes B2C/B2B

### 📈 Hechos (2 tablas)
- **fact_exchangerates.csv**: Tipos de cambio diarios
- **fact_sales.csv**: **200,000 líneas de ventas** con métricas completas

## 📁 Estructura del Data Lake

```
datalake/
└── modelo-ventas/
    └── raw/                     # Datos originales
        ├── dimensions/          # Tablas de dimensiones
        │   ├── dim_date.csv
        │   ├── dim_currency.csv
        │   ├── dim_channel.csv
        │   ├── dim_store.csv
        │   ├── dim_product.csv
        │   ├── dim_salesperson.csv
        │   └── dim_customer.csv
        ├── facts/               # Tablas de hechos  
        │   ├── fact_exchangerates.csv
        │   └── fact_sales.csv
        └── metadata/            # Documentación
            └── README_modelo_ventas.md
```

## 🚀 Cómo cargar el modelo de datos

### Paso 1: Crear estructura
1. Acceder a http://localhost:9001 (admin/admin12345)
2. Crear bucket `datalake`
3. Crear carpetas: `modelo-ventas/raw/dimensions/`, `facts/`, `metadata/`

### Paso 2: Subir dimensiones
Navegar a `datalake/modelo-ventas/raw/dimensions/` y subir:
- dim_date.csv
- dim_currency.csv  
- dim_channel.csv
- dim_store.csv
- dim_product.csv
- dim_salesperson.csv
- dim_customer.csv

### Paso 3: Subir hechos
Navegar a `datalake/modelo-ventas/raw/facts/` y subir:
- fact_exchangerates.csv
- fact_sales.csv

### Paso 4: Subir metadata
Navegar a `datalake/modelo-ventas/raw/metadata/` y subir:
- README_modelo_ventas.md

## 🧪 Validaciones y tests

### Test automático básico
```bash
make test
```

### Validación del modelo de datos
```bash
# Listar todo el modelo cargado
docker exec fabric-minio mc ls -r local/datalake/modelo-ventas/

# Verificar dimensiones
docker exec fabric-minio mc ls local/datalake/modelo-ventas/raw/dimensions/

# Verificar hechos  
docker exec fabric-minio mc ls local/datalake/modelo-ventas/raw/facts/

# Ver estadísticas de archivos
docker exec fabric-minio mc stat local/datalake/modelo-ventas/raw/facts/fact_sales.csv
```

### Exploración rápida
```bash
# Ver las primeras líneas de ventas
docker exec fabric-minio mc cat local/datalake/modelo-ventas/raw/facts/fact_sales.csv | head -5

# Contar registros de fact_sales
docker exec fabric-minio mc cat local/datalake/modelo-ventas/raw/facts/fact_sales.csv | wc -l
```

## 🛠️ Comandos disponibles

```bash
# Gestión básica
make up          # Levantar MinIO
make down        # Parar MinIO
make restart     # Reiniciar MinIO
make logs        # Ver logs en tiempo real

# Validaciones
make test        # Test completo automatizado
make health      # Solo health check
make create-bucket  # Crear bucket por defecto

# Utilidades
make clean       # Limpiar datos (¡cuidado!)
make backup      # Backup de datos
make restore     # Restaurar backup
```

## 🚨 Troubleshooting

### Puerto 9000/9001 ocupado
```bash
# Verificar qué usa el puerto
netstat -ano | findstr :9000

# Cambiar puerto en .env
MINIO_API_PORT=9002
MINIO_CONSOLE_PORT=9003

# Reiniciar
make restart
```

### No se puede acceder a la consola
```bash
# Verificar que el contenedor esté corriendo
docker ps | grep minio

# Ver logs de MinIO
make logs

# Verificar health check
docker inspect fabric-minio | grep Health -A 10
```

### Error de permisos en carpeta data/
```bash
# En Linux/macOS
sudo chown -R $USER:$USER ../../data/minio

# En Windows con WSL2
# Asegúrate de estar en una carpeta WSL, no en /mnt/c/
```

## 📚 Conceptos importantes

### ¿Qué es MinIO?
MinIO es un servidor de almacenamiento de objetos compatible con Amazon S3. Es perfecto para:
- **Data Lakes**: Almacenar grandes volúmenes de datos sin estructura
- **Backups**: Respaldos distribuidos y resilientes  
- **Data pipelines**: Punto central para ETL/ELT
- **ML/AI**: Almacenar datasets y modelos

### ¿Por qué empezar con MinIO?
1. **Sin dependencias**: Funciona solo, sin necesidad de otros servicios
2. **Interfaz familiar**: API S3 es estándar de facto
3. **Fundación sólida**: Todos los demás servicios se conectarán aquí
4. **Fácil de debuggear**: Interfaz web clara y logs comprensibles

### Modelo Estrella en Data Lake
- **Datos raw**: Se almacenan tal como vienen de origen
- **Organización**: Por tipo (dimensiones/hechos) para facilitar ETL
- **Flexibilidad**: Permite múltiples usos (BI, ML, análisis)
- **Escalabilidad**: Estructura profesional preparada para crecer

## ✅ Criterios de éxito

Antes de pasar a la Fase 2, asegúrate de que:
- [ ] MinIO arranca sin errores
- [ ] Puedes acceder a http://localhost:9001
- [ ] Bucket `datalake` creado con estructura modelo-ventas
- [ ] 9 archivos CSV subidos y organizados
- [ ] Puedes listar y explorar archivos con comandos mc
- [ ] El modelo de datos está completo (200k+ registros en fact_sales)
- [ ] Entiendes la estructura de Data Lake profesional

## 🎯 Próxima fase

Una vez que MinIO y tu modelo de datos funcionen perfectamente, continúa con:
**[Fase 2: PostgreSQL](../fase-2-postgres/README.md)**

Ahí importaremos tu modelo estrella a PostgreSQL y verás las dimensiones y hechos en acción como base de datos relacional.

---

💡 **Tip**: Este modelo de 200,000 registros de ventas es perfecto para las siguientes fases. Representa un escenario realista que encontrarás en proyectos profesionales.