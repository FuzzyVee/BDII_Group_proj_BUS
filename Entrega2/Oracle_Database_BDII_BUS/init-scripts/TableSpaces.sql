SET ECHO ON;
SET FEEDBACK ON;
SET SERVEROUTPUT ON;
SET LINESIZE 200;
SET PAGESIZE 100;
WHENEVER SQLERROR EXIT SQL.SQLCODE;

-- -------------------------------------------------------------------------------------------
-- Migracion de instalaciones antiguas: el tablespace de LOB se llamaba
-- ts_bus_doc en versiones previas. Se renombra para cumplir la plantilla P2
-- sin perder los segmentos que ya existieran.
-- -------------------------------------------------------------------------------------------
DECLARE
    v_old NUMBER;
    v_new NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_old FROM dba_tablespaces WHERE tablespace_name = 'TS_BUS_DOC';
    SELECT COUNT(*) INTO v_new FROM dba_tablespaces WHERE tablespace_name = 'TS_BUS_BLOB';

    IF v_old > 0 AND v_new = 0 THEN
        EXECUTE IMMEDIATE 'ALTER TABLESPACE ts_bus_doc RENAME TO ts_bus_BLOB';
        DBMS_OUTPUT.PUT_LINE('Tablespace renombrado: ts_bus_doc -> ts_bus_BLOB');
    END IF;
END;
/

-- -------------------------------------------------------------------------------------------
-- Creacion idempotente de los cuatro tablespaces del proyecto
-- -------------------------------------------------------------------------------------------
DECLARE
    v_count NUMBER;

    PROCEDURE crear_tablespace(p_nombre VARCHAR2, p_fichero VARCHAR2) IS
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM dba_tablespaces
        WHERE tablespace_name = UPPER(p_nombre);

        IF v_count = 0 THEN
            EXECUTE IMMEDIATE
                'CREATE SMALLFILE TABLESPACE ' || p_nombre ||
                ' DATAFILE ''' || p_fichero || ''' SIZE 64M' ||
                ' AUTOEXTEND ON NEXT 8M MAXSIZE 128M' ||
                ' EXTENT MANAGEMENT LOCAL AUTOALLOCATE' ||
                ' SEGMENT SPACE MANAGEMENT AUTO';
            DBMS_OUTPUT.PUT_LINE('Tablespace creado: ' || p_nombre);
        ELSE
            DBMS_OUTPUT.PUT_LINE('Tablespace ya existente: ' || p_nombre);
        END IF;
    END;
BEGIN
    crear_tablespace('ts_bus_datos',   '/opt/oracle/oradata/FREE/BDII/ts_datos.dbf');
    crear_tablespace('ts_bus_indices', '/opt/oracle/oradata/FREE/BDII/ts_indices.dbf');
    crear_tablespace('ts_bus_hist',    '/opt/oracle/oradata/FREE/BDII/ts_historial.dbf');
    crear_tablespace('ts_bus_BLOB',    '/opt/oracle/oradata/FREE/BDII/ts_blob.dbf');
END;
/

-- -------------------------------------------------------------------------------------------
-- Comprobacion
-- -------------------------------------------------------------------------------------------
PROMPT ============================================================
PROMPT Tablespaces del proyecto
PROMPT ============================================================
SELECT tablespace_name, block_size, status, contents, extent_management, segment_space_management
FROM dba_tablespaces
WHERE tablespace_name LIKE 'TS_BUS%'
ORDER BY tablespace_name;

SELECT tablespace_name, file_name, bytes, autoextensible, maxbytes
FROM dba_data_files
WHERE tablespace_name LIKE 'TS_BUS%'
ORDER BY tablespace_name;
