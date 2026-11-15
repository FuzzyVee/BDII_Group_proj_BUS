-- ===========================================================================================
-- CAPTURA 07 - REDO LOG, ARCHIVE LOG Y RECUPERACION
-- Ejecutar como SYS.
-- ===========================================================================================

SET ECHO ON;
SET FEEDBACK ON;
SET LINESIZE 200;
SET PAGESIZE 120;

COLUMN member FORMAT A70;
COLUMN log_mode FORMAT A14;
COLUMN open_mode FORMAT A18;
COLUMN status FORMAT A12;
COLUMN archived FORMAT A10;

-- ============================================================
PROMPT Grupos de redo log
-- ============================================================
SELECT group#, members, ROUND(bytes / 1024 / 1024, 2) AS mb, status, archived
FROM v$log
ORDER BY group#;

-- ============================================================
PROMPT Miembros fisicos de cada grupo
-- ============================================================
SELECT group#, member
FROM v$logfile
ORDER BY group#, member;

-- ============================================================
PROMPT Modo de la base de datos
-- ============================================================
SELECT name, log_mode, open_mode, database_role
FROM v$database;

-- ============================================================
PROMPT Destinos de archivo y area de recuperacion
-- ============================================================
SHOW PARAMETER log_archive_dest;
SHOW PARAMETER log_archive_format;
SHOW PARAMETER db_recovery_file_dest;
SHOW PARAMETER db_recovery_file_dest_size;

-- ============================================================
PROMPT Uso actual del area de recuperacion
-- ============================================================
SELECT FILE_TYPE,
       PERCENT_SPACE_USED AS porcentaje_usado,
       PERCENT_SPACE_RECLAIMABLE AS porcentaje_recuperable,
       NUMBER_OF_FILES
FROM v$flash_recovery_area_usage;