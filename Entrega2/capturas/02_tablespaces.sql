-- ===============================
-- CAPTURA 0 - TABLESPACES, DATAFILES Y CUOTAS
-- Ejecutar como SYS.
-- ===============================

SET LINESIZE 500;
SET PAGESIZE 220;

COLUMN tablespace_name FORMAT A20;
COLUMN file_name FORMAT A60;
COLUMN status FORMAT A12;
COLUMN contents FORMAT A12;
COLUMN extent_management FORMAT A20;
COLUMN segment_space_management FORMAT A25;
COLUMN username FORMAT A15;

PROMPT Tablespaces del proyecto
SELECT tablespace_name,
       block_size,
       status,
       contents,
       extent_management,
       segment_space_management
FROM dba_tablespaces
WHERE tablespace_name LIKE 'TS_BUS%'
ORDER BY tablespace_name;

PROMPT Datafiles, tamano inicial, autoextend y maximo
SELECT tablespace_name,
       file_name,
       ROUND(bytes / 1024 / 1024, 2)     AS tamano_inicial_mb,
       autoextensible,
       ROUND(maxbytes / 1024 / 1024, 2)  AS maximo_mb,
       increment_by
FROM dba_data_files
WHERE tablespace_name LIKE 'TS_BUS%'
ORDER BY tablespace_name;

PROMPT Cuotas del usuario ALUMNO
SELECT username,
       tablespace_name,
       ROUND(bytes / 1024 / 1024, 2)     AS usado_mb,
       ROUND(max_bytes / 1024 / 1024, 2) AS limite_mb
FROM dba_ts_quotas
WHERE username = 'ALUMNO'
ORDER BY tablespace_name;

PROMPT Estado del usuario ALUMNO
SELECT username, account_status, default_tablespace, temporary_tablespace
FROM dba_users
WHERE username = 'ALUMNO';
