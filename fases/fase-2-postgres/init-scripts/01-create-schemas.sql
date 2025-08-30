-- =====================================================
-- FABRIC DE BOLSILLO - Inicialización Base de Datos
-- =====================================================

-- Crear esquemas para organizar las tablas
CREATE SCHEMA IF NOT EXISTS dw;          -- Data Warehouse (tablas finales)
CREATE SCHEMA IF NOT EXISTS staging;     -- Área temporal para ETL

-- Comentarios de documentación
COMMENT ON SCHEMA dw IS 'Data Warehouse - Tablas del modelo estrella para análisis';
COMMENT ON SCHEMA staging IS 'Staging Area - Tablas temporales para procesos ETL';

-- Log de inicialización
INSERT INTO pg_stat_statements_info(dealloc) VALUES (0) 
ON CONFLICT DO NOTHING; -- Solo si pg_stat_statements está habilitado

-- Mostrar esquemas creados
SELECT 
    schema_name,
    schema_owner,
    obj_description(oid) as description
FROM information_schema.schemata s
JOIN pg_namespace n ON n.nspname = s.schema_name
WHERE schema_name IN ('dw', 'staging')
ORDER BY schema_name;