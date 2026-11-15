-- ===========================================================================================
-- ENTREGA 2 - USUARIO, PRIVILEGIOS Y CUOTAS
-- Proyecto BDII [[BUSSESS]] - BDII5_BDII_5::BUS
-- ===========================================================================================
-- Ejecutar como SYS DESPUES de TableSpaces.sql.
--
-- El usuario ALUMNO es el propietario del esquema del proyecto. Si ya existe
-- (por ejemplo, creado por docker-compose), este script solo completa sus
-- privilegios y cuotas. Si no existe, lo crea con el tablespace por defecto
-- ts_bus_datos.
-- ===========================================================================================

SET ECHO ON;
SET FEEDBACK ON;
SET SERVEROUTPUT ON;
SET LINESIZE 200;
SET PAGESIZE 100;
WHENEVER SQLERROR EXIT SQL.SQLCODE;

-- -------------------------------------------------------------------------------------------
-- 1. Crear ALUMNO si no existe
-- -------------------------------------------------------------------------------------------
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM dba_users WHERE username = 'ALUMNO';
    IF v_count = 0 THEN
        EXECUTE IMMEDIATE 'CREATE USER ALUMNO IDENTIFIED BY ALUMNO ' ||
                          'DEFAULT TABLESPACE ts_bus_datos ' ||
                          'TEMPORARY TABLESPACE TEMP ' ||
                          'QUOTA UNLIMITED ON ts_bus_datos';
        DBMS_OUTPUT.PUT_LINE('Usuario ALUMNO creado.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Usuario ALUMNO ya existe.');
    END IF;
END;
/

-- -------------------------------------------------------------------------------------------
-- 2. Privilegios de sistema necesarios para el DDL de la practica
-- -------------------------------------------------------------------------------------------
ALTER USER ALUMNO IDENTIFIED BY ALUMNO;
ALTER USER ALUMNO ACCOUNT UNLOCK;

GRANT CREATE SESSION     TO ALUMNO;
GRANT CREATE TABLE       TO ALUMNO;
GRANT CREATE VIEW        TO ALUMNO;
GRANT CREATE SEQUENCE    TO ALUMNO;
GRANT CREATE PROCEDURE   TO ALUMNO;
GRANT CREATE TRIGGER     TO ALUMNO;
GRANT CREATE TYPE        TO ALUMNO;
GRANT CREATE SYNONYM     TO ALUMNO;

-- -------------------------------------------------------------------------------------------
-- 3. Cuotas sobre los tablespaces del proyecto
-- -------------------------------------------------------------------------------------------
ALTER USER ALUMNO QUOTA UNLIMITED ON ts_bus_datos;
ALTER USER ALUMNO QUOTA UNLIMITED ON ts_bus_indices;
ALTER USER ALUMNO QUOTA UNLIMITED ON ts_bus_hist;
ALTER USER ALUMNO QUOTA UNLIMITED ON ts_bus_BLOB;

ALTER USER ALUMNO DEFAULT TABLESPACE ts_bus_datos;
ALTER USER ALUMNO TEMPORARY TABLESPACE TEMP;

-- -------------------------------------------------------------------------------------------
-- 4. Comprobacion
-- -------------------------------------------------------------------------------------------
PROMPT ============================================================
PROMPT Privilegios de sistema de ALUMNO
PROMPT ============================================================
SELECT privilege
FROM dba_sys_privs
WHERE grantee = 'ALUMNO'
ORDER BY privilege;

PROMPT ============================================================
PROMPT Cuotas de ALUMNO
PROMPT ============================================================
SELECT tablespace_name, bytes, max_bytes
FROM dba_ts_quotas
WHERE username = 'ALUMNO'
ORDER BY tablespace_name;
