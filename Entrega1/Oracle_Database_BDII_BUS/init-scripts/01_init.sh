#!/bin/bash
set -e

echo "============================================"
echo " 1. Verificando entorno, tablespaces y usuarios"
echo "============================================"

sqlplus -s 'sys/Oracle12345@//localhost:1521/BDII as sysdba' <<'EOF'
SET SERVEROUTPUT ON;
SET FEEDBACK ON;
SET VERIFY OFF;
WHENEVER SQLERROR EXIT SQL.SQLCODE;

DECLARE
  v_count      NUMBER;
  v_datafile   VARCHAR2(1000);
  v_directory  VARCHAR2(1000);
BEGIN
  -- Verificar y crear ALUMNO_DATA
  SELECT COUNT(*) INTO v_count FROM dba_tablespaces WHERE tablespace_name = 'ALUMNO_DATA';
  IF v_count = 0 THEN
    SELECT file_name INTO v_datafile FROM (SELECT file_name FROM dba_data_files WHERE tablespace_name = 'USERS' ORDER BY file_id) WHERE ROWNUM = 1;
    v_directory := SUBSTR(v_datafile, 1, INSTR(v_datafile, '/', -1));
    EXECUTE IMMEDIATE 'CREATE TABLESPACE ALUMNO_DATA DATAFILE ''' || v_directory || 'alumno01.dbf'' SIZE 200M AUTOEXTEND ON NEXT 50M MAXSIZE 2G EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO';
  END IF;

  -- Verificar y crear CAMPO_VALOR
  SELECT COUNT(*) INTO v_count FROM dba_tablespaces WHERE tablespace_name = 'CAMPO_VALOR';
  IF v_count = 0 THEN
    SELECT file_name INTO v_datafile FROM (SELECT file_name FROM dba_data_files WHERE tablespace_name = 'USERS' ORDER BY file_id) WHERE ROWNUM = 1;
    v_directory := SUBSTR(v_datafile, 1, INSTR(v_datafile, '/', -1));
    EXECUTE IMMEDIATE 'CREATE TABLESPACE CAMPO_VALOR DATAFILE ''' || v_directory || 'campo_valor01.dbf'' SIZE 200M AUTOEXTEND ON NEXT 50M MAXSIZE 2G EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO';
  END IF;

  -- Verificar y crear usuario ALUMNO
  SELECT COUNT(*) INTO v_count FROM dba_users WHERE username = 'ALUMNO';
  IF v_count = 0 THEN
    EXECUTE IMMEDIATE 'CREATE USER ALUMNO IDENTIFIED BY ALUMNO DEFAULT TABLESPACE ALUMNO_DATA TEMPORARY TABLESPACE TEMP QUOTA UNLIMITED ON ALUMNO_DATA';
  END IF;
END;
/

GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE SEQUENCE, CREATE PROCEDURE, CREATE TRIGGER, CREATE TYPE, CREATE SYNONYM TO ALUMNO;
ALTER USER ALUMNO IDENTIFIED BY ALUMNO;
ALTER USER ALUMNO DEFAULT TABLESPACE ALUMNO_DATA;
ALTER USER ALUMNO TEMPORARY TABLESPACE TEMP;
ALTER USER ALUMNO QUOTA UNLIMITED ON ALUMNO_DATA;

-- Configuración de SYSTEM (Administrador) con la tablespace CAMPO_VALOR
ALTER USER SYSTEM DEFAULT TABLESPACE CAMPO_VALOR;
ALTER USER SYSTEM QUOTA UNLIMITED ON CAMPO_VALOR;

EXIT;
EOF

echo "============================================"
echo " 2. Ejecutando BUS.sql como ALUMNO"
echo "============================================"
sqlplus -L -s 'ALUMNO/ALUMNO@//localhost:1521/BDII' @/container-entrypoint-initdb.d/BUS.sql

echo "============================================"
echo " 3. Ejecutando BUS.sql como SYSTEM (Administrador)"
echo "============================================"
sqlplus -L -s 'SYSTEM/Oracle12345@//localhost:1521/BDII' @/container-entrypoint-initdb.d/BUS.sql

echo "============================================"
echo " ¡Inicialización y carga completadas con éxito!"
echo "============================================"