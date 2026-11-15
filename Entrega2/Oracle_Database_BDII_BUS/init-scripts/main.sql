-- ===========================================================================================
-- ENTREGA 2 - SCRIPT MAESTRO
-- Proyecto BDII [[BUSSESS]] - BDII5_BDII_5::BUS
-- ===========================================================================================
-- Ejecutar como ALUMNO desde SQL*Plus / SQL Developer, situado en esta carpeta.
--
-- Requisito previo (como SYS):
--   1) @@TableSpaces.sql
--   2) @@Privilegues.sql
--
-- Este maestro crea el esquema y carga los datos de prueba:
--   3) @@BUS.sql
--   4) @@Inserts.sql
-- ===========================================================================================

SET ECHO ON;
SET FEEDBACK ON;
SET SQLBLANKLINES ON;
SET SERVEROUTPUT ON;

PROMPT ============================================
PROMPT 1/2 - Creacion del esquema (BUS.sql)
PROMPT ============================================
@@BUS.sql

PROMPT ============================================
PROMPT 2/2 - Carga de datos y pruebas (Inserts.sql)
PROMPT ============================================
@@Inserts.sql

PROMPT ============================================
PROMPT Proceso completado.
PROMPT ============================================
