-- ===========================================================================================
-- CAPTURA 03 - COLUMNAS LOB Y SEGMENTOS EN TS_BUS_BLOB
-- Ejecutar como ALUMNO.
-- ===========================================================================================

SET ECHO ON;
SET FEEDBACK ON;
SET LINESIZE 220;
SET PAGESIZE 120;

COLUMN table_name FORMAT A24;
COLUMN column_name FORMAT A16;
COLUMN segment_name FORMAT A36;
COLUMN tablespace_name FORMAT A18;
COLUMN segment_type FORMAT A18;
COLUMN cache FORMAT A8;
COLUMN logging FORMAT A8;

PROMPT ============================================================
PROMPT Columnas LOB del esquema (USER_LOBS)
PROMPT ============================================================
SELECT table_name,
       column_name,
       segment_name,
       tablespace_name,
       chunk,
       cache,
       logging
FROM user_lobs
ORDER BY table_name, column_name;

PROMPT ============================================================
PROMPT Tablas documentales y su tablespace de fila
PROMPT ============================================================
SELECT table_name, tablespace_name, status
FROM user_tables
WHERE table_name IN ('DOCUMENTO_BUS', 'DOCUMENTO_EMPLEADO')
ORDER BY table_name;

PROMPT ============================================================
PROMPT Columnas de las tablas documentales
PROMPT ============================================================
SELECT table_name, column_name, data_type, nullable
FROM user_tab_columns
WHERE table_name IN ('DOCUMENTO_BUS', 'DOCUMENTO_EMPLEADO')
ORDER BY table_name, column_id;

PROMPT ============================================================
PROMPT Segmentos fisicos en TS_BUS_BLOB (USER_SEGMENTS)
PROMPT ============================================================
SELECT segment_name,
       segment_type,
       tablespace_name,
       bytes,
       blocks,
       extents
FROM user_segments
WHERE tablespace_name = 'TS_BUS_BLOB'
ORDER BY segment_name;
