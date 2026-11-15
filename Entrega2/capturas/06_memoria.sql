-- ===========================================================================================
-- CAPTURA 06 - CONFIGURACION DE SGA Y PGA
-- Ejecutar como SYS.
-- ===========================================================================================

SET ECHO ON;
SET FEEDBACK ON;
SET LINESIZE 200;
SET PAGESIZE 120;

COLUMN name FORMAT A25;
COLUMN valor_mb FORMAT 9999990.00;
COLUMN value FORMAT A20;
COLUMN valor_mb FORMAT A20;



-- ============================================================
PROMPT Parametros de memoria (MB)
-- ============================================================
SELECT name,
       ROUND(value / 1024 / 1024, 2) AS valor_mb
FROM v$parameter
WHERE name IN ('sga_target',
               'pga_aggregate_target',
               'shared_pool_size',
               'db_cache_size',
               'large_pool_size',
               'java_pool_size',
               'streams_pool_size')
ORDER BY name;

-- ============================================================
PROMPT Limites de procesos y sesiones
-- ============================================================
SELECT name, value
FROM v$parameter
WHERE name IN ('processes', 'sessions', 'transactions')
ORDER BY name;

-- ============================================================
PROMPT Resumen de componentes SGA
-- ============================================================
SELECT name,
       ROUND(bytes / 1024 / 1024, 2) AS mb
FROM v$sgainfo
ORDER BY name;

-- ============================================================
PROMPT Estadisticas de PGA
-- ============================================================
SELECT name, ROUND(value / 1024 / 1024, 2) AS valor_mb
FROM v$pgastat
WHERE name IN ('aggregate PGA target parameter',
               'aggregate PGA auto target',
               'total PGA inuse',
               'total PGA allocated',
               'maximum PGA allocated',
               'cache hit percentage')
ORDER BY name;
