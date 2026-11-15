-- ===========================================================================================
-- ENTREGA 2 - LIMPIEZA COMPLETA DEL ESQUEMA
-- Proyecto BDII [[BUSSESS]] - BDII5_BDII_5::BUS
-- ===========================================================================================
-- Ejecutar como ALUMNO. Elimina vistas, tablas y secuencias del esquema para
-- poder reejecutar BUS.sql + Inserts.sql desde cero.
--
-- ADVERTENCIA: no ejecutar como SYS/SYSTEM; borraria objetos del diccionario.
-- ===========================================================================================

SET ECHO ON;
SET FEEDBACK ON;
SET SERVEROUTPUT ON;

BEGIN
    -- Vistas primero (pueden depender de tablas).
    FOR r IN (
        SELECT view_name
        FROM user_views
    ) LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP VIEW "' || r.view_name || '"';
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
    END LOOP;

    -- Tablas (CASCADE CONSTRAINTS elimina FKs dependientes).
    FOR r IN (
        SELECT table_name
        FROM user_tables
        WHERE secondary = 'N'
          AND nested = 'NO'
          AND table_name NOT IN ('REDO_DB', 'REDO_LOG')
    ) LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE "' || r.table_name || '" CASCADE CONSTRAINTS PURGE';
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('No se pudo borrar ' || r.table_name || ': ' || SQLERRM);
        END;
    END LOOP;

    -- Secuencias asociadas a las tablas.
    FOR r IN (
        SELECT sequence_name
        FROM user_sequences
    ) LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP SEQUENCE "' || r.sequence_name || '"';
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
    END LOOP;
END;
/

PROMPT ============================================================
PROMPT Objetos restantes en el esquema
PROMPT ============================================================
SELECT object_type, COUNT(*) AS total
FROM user_objects
GROUP BY object_type
ORDER BY object_type;
