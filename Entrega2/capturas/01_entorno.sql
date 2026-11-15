-- ===========================================================================================
-- CAPTURA 01 - ENTORNO, USUARIO Y PDB
-- Ejecutar como SYS: sqlplus 'sys/Oracle12345@//localhost:15211/BDII as sysdba'
-- ===========================================================================================

SET ECHO ON;
SET FEEDBACK ON;
SET LINESIZE 200;
SET PAGESIZE 100;
SET SQLBLANKLINES ON;

COLUMN usuario FORMAT A20;
COLUMN contenedor FORMAT A20;
COLUMN banner FORMAT A120;

PROMPT ============================================================
PROMPT Usuario y contenedor actuales
PROMPT ============================================================
SELECT SYS_CONTEXT('USERENV', 'SESSION_USER') AS usuario,
       SYS_CONTEXT('USERENV', 'CON_NAME')     AS contenedor,
       SYS_CONTEXT('USERENV', 'DB_NAME')      AS base_de_datos
FROM dual;

PROMPT ============================================================
PROMPT Version de Oracle
PROMPT ============================================================
SELECT banner FROM v$version;

PROMPT ============================================================
PROMPT Parametros de almacenamiento automatico (OMF)
PROMPT ============================================================
SHOW PARAMETER db_create_file_dest;
SHOW PARAMETER db_name;
SHOW PARAMETER service_names;

PROMPT ============================================================
PROMPT Fecha y hora de la captura
PROMPT ============================================================
SELECT TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') AS fecha_captura FROM dual;
