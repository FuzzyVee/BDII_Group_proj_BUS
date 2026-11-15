-- ===========================================================================================
-- ENTREGA 2 - NORMALIZACION DE NOMBRES DE RESTRICCIONES
-- Proyecto BDII [[BUSSESS]] - BDII5_BDII_5::BUS
-- ===========================================================================================
-- Ejecutar como ALUMNO despues de BUS.sql.
--
-- En esta entrega todas las PK/UK/FK/CHECK se crean con nombre explicito
-- (pk_*, uk_*, fk_*, ck_*), por lo que este script no deberia encontrar
-- ninguna restriccion autogenerada SYS_C%. Se mantiene como red de seguridad
-- para esquemas antiguos o creados sin nombres.
-- ===========================================================================================

SET ECHO ON;
SET FEEDBACK ON;
SET SERVEROUTPUT ON;

DECLARE
    v_sql     VARCHAR2(500);
    v_new     VARCHAR2(128);
    v_exists  NUMBER;
    v_changes NUMBER := 0;
BEGIN
    FOR r IN (
        SELECT table_name, constraint_name, constraint_type
        FROM user_constraints
        WHERE constraint_name LIKE 'SYS_C%'
          AND constraint_type IN ('P', 'U')
        ORDER BY table_name, constraint_type
    ) LOOP
        IF r.constraint_type = 'P' THEN
            v_new := 'PK_' || SUBSTR(r.table_name, 1, 26);
        ELSE
            v_new := 'UK_' || SUBSTR(r.table_name, 1, 26);
        END IF;

        -- Evitar colisiones si el nombre ya existe en el esquema.
        SELECT COUNT(*) INTO v_exists
        FROM user_constraints
        WHERE constraint_name = v_new;

        IF v_exists = 0 THEN
            v_sql := 'ALTER TABLE "' || r.table_name || '" RENAME CONSTRAINT "' ||
                     r.constraint_name || '" TO "' || v_new || '"';
            DBMS_OUTPUT.PUT_LINE('Ejecutando: ' || v_sql);
            EXECUTE IMMEDIATE v_sql;
            v_changes := v_changes + 1;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Omitido ' || r.constraint_name ||
                                 ': ya existe ' || v_new);
        END IF;
    END LOOP;

    IF v_changes = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No hay restricciones SYS_C% que renombrar.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Restricciones renombradas: ' || v_changes);
    END IF;
END;
/

ALTER SYSTEM SET db_recovery_file_dest_size = 10G;
ALTER SYSTEM SET db_recovery_file_dest = '/u01/app/oracle/fast_recovery_area';

PROMPT ============================================================
PROMPT Restricciones autogeneradas restantes (deberia estar vacio)
PROMPT ============================================================
SELECT table_name, constraint_name, constraint_type
FROM user_constraints
WHERE constraint_name LIKE 'SYS_C%'
ORDER BY table_name;

COMMIT;
