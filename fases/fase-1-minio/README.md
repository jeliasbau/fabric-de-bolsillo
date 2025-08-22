# 🗄️ Fase 1: MinIO (Data Lake)

**Objetivo**: Configurar y validar MinIO como almacén de datos tipo S3

## 🎯 Qué aprenderás en esta fase

- **Almacenamiento tipo S3**: Conceptos de buckets y objetos
- **MinIO**: Configuración y uso básico
- **API S3**: Interfaz estándar para almacenamiento
- **Docker networking**: Redes aisladas para servicios
- **Health checks**: Validación automática de servicios

## 🏗️ Arquitectura de esta fase

```
┌─────────────────┐
│   MinIO         │
│ (Data Lake S3)  │
│                 │
│ Port 9000: API  │
│ Port 9001: UI   │
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
|----------|-------------|------------------|
| `MINIO_API_PORT` | Puerto para API S3 | 9000 |
| `MINIO_CONSOLE_PORT` | Puerto para consola web | 9001 |
| `MINIO_ROOT_USER` | Usuario administrador | admin |
| `MINIO_ROOT_PASSWORD` | Contraseña admin | admin12345 |
| `MINIO_DEFAULT_BUCKET` | Bucket por defecto | datalake |

### Puertos utilizados

- **9000**: API S3 compatible (para aplicaciones)
- **9001**: Consola web MinIO (para humanos)

## 🧪 Validaciones y tests

### Test automático
```bash
make test
```

Esto ejecuta:
1. ✅ Verifica que el contenedor esté corriendo
2. ✅ Comprueba que responda en el puerto API
3. ✅ Valida acceso a la consola web
4. ✅ Crea bucket de prueba
5. ✅ Sube archivo de ejemplo
6. ✅ Lista archivos del bucket

### Test manual

**Acceso web:**
1. Abre http://localhost:9001
2. Login: `admin` / `admin12345`
3. Crea un bucket llamado `test`
4. Sube un archivo cualquiera

**Verificar con curl:**
```bash
# Health check
curl http://localhost:9000/minio/health/live

# Debe responder: 200 OK
```

## 📊 Datos de ejemplo

En `/sample-data/` tienes archivos CSV de ejemplo para subir:
- `ventas.csv` - Datos de ventas ficticios
- `productos.csv` - Catálogo de productos
- `clientes.csv` - Base de clientes

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

## ✅ Criterios de éxito

Antes de pasar a la Fase 2, asegúrate de que:
- [ ] MinIO arranca sin errores
- [ ] Puedes acceder a http://localhost:9001
- [ ] Puedes crear buckets desde la web
- [ ] Puedes subir y descargar archivos
- [ ] El test automático pasa al 100%
- [ ] Entiendes los conceptos básicos de S3

## 🎯 Próxima fase

Una vez que MinIO funcione perfectamente, continúa con:
**[Fase 2: PostgreSQL](../fase-2-postgres/README.md)**

Ahí añadiremos la base de datos y aprenderás a conectar servicios entre sí.

---

💡 **Tip**: No tengas prisa. Asegúrate de entender bien esta fase antes de continuar. ¡La base sólida es clave para el éxito!