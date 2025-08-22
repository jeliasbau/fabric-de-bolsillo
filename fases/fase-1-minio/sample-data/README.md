# 📊 Datos de Ejemplo - Fase 1

Esta carpeta contiene datos de ejemplo para probar MinIO.

## 📁 Archivos incluidos

### `ventas.csv`
- **Propósito**: Datos de transacciones de venta
- **Registros**: 15 ventas de ejemplo
- **Campos**: fecha, producto_id, cliente_id, cantidad, precio_unitario, total
- **Uso**: Ideal para practicar análisis de ventas y joins

### `productos.csv`
- **Propósito**: Catálogo de productos
- **Registros**: 10 productos diferentes
- **Campos**: producto_id, nombre, categoría, precio, stock, activo
- **Uso**: Tabla maestra para relacionar con ventas

### `clientes.csv`
- **Propósito**: Base de datos de clientes
- **Registros**: 9 clientes
- **Campos**: cliente_id, nombre, email, teléfono, ciudad, país, fecha_registro
- **Uso**: Información demográfica para análisis

## 🚀 Cómo usar estos datos

### 1. Subir a MinIO manualmente
1. Accede a http://localhost:9001
2. Login con admin/admin12345
3. Crea un bucket llamado `sample-data`
4. Sube los 3 archivos CSV

### 2. Subir con MinIO Client (dentro del contenedor)
```bash
# Crear bucket
docker exec fabric-minio mc mb local/sample-data

# Subir archivos (desde esta carpeta)
docker exec -i fabric-minio mc pipe local/sample-data/ventas.csv < ventas.csv
docker exec -i fabric-minio mc pipe local/sample-data/productos.csv < productos.csv  
docker exec -i fabric-minio mc pipe local/sample-data/clientes.csv < clientes.csv
```

### 3. Verificar datos subidos
```bash
# Listar archivos
docker exec fabric-minio mc ls local/sample-data/

# Ver contenido de un archivo
docker exec fabric-minio mc cat local/sample-data/ventas.csv
```

## 🔍 Análisis que puedes hacer

### Análisis básico con estas tablas:
- **Ventas por producto**: ¿Cuál es el producto más vendido?
- **Ventas por cliente**: ¿Quién es el mejor cliente?
- **Ventas por región**: ¿Qué ciudades compran más?
- **Análisis temporal**: ¿Cómo evolucionan las ventas?

### Joins interesantes:
```sql
-- En fases posteriores podrás hacer:
SELECT v.fecha, p.nombre, c.ciudad, v.total
FROM ventas v
JOIN productos p ON v.producto_id = p.producto_id  
JOIN clientes c ON v.cliente_id = c.cliente_id
ORDER BY v.fecha;
```

## 📈 Escalabilidad

Estos datos son pequeños pero representativos. En un entorno real:
- **ventas.csv** podría tener millones de registros
- **productos.csv** podría incluir imágenes y descripciones
- **clientes.csv** podría tener datos de comportamiento

## 💡 Tips para las siguientes fases

1. **Fase 2 (PostgreSQL)**: Importarás estos CSV a tablas
2. **Fase 3 (Jupyter)**: Harás análisis con pandas
3. **Fase 4 (n8n)**: Automatizarás la carga de datos  
4. **Fase 5 (Metabase)**: Crearás dashboards visuales

---

¡Estos datos te acompañarán durante todo el proyecto! 🎯