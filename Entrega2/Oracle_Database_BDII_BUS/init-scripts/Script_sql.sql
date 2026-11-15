-- ===========================================================================================
-- ENTREGA 2 - AYUDANTE: RENOMBRADO DINAMICO DE PK AUTOGENERADAS
-- Proyecto BDII [[BUSSESS]] - BDII5_BDII_5::BUS
-- ===========================================================================================
-- Ejecutar como ALUMNO. Recorre las restricciones PRIMARY KEY con nombre
-- autogenerado (SYS_C%) y las renombra a PK_<TABLA>.
--
-- En el esquema de la ET2 todas las PK ya tienen nombre explicito, por lo que
-- este script normalmente no modificara nada. Se conserva como utilidad.
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
        SELECT table_name, constraint_name
        FROM user_constraints
        WHERE constraint_type = 'P'
          AND constraint_name LIKE 'SYS_C%'
    ) LOOP
        v_new := 'PK_' || SUBSTR(r.table_name, 1, 26);

        SELECT COUNT(*) INTO v_exists
        FROM user_constraints
        WHERE constraint_name = v_new;

        IF v_exists = 0 THEN
            v_sql := 'ALTER TABLE "' || r.table_name ||
                     '" RENAME CONSTRAINT "' || r.constraint_name ||
                     '" TO "' || v_new || '"';
            DBMS_OUTPUT.PUT_LINE('Ejecutando: ' || v_sql);
            EXECUTE IMMEDIATE v_sql;
            v_changes := v_changes + 1;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Omitido ' || r.constraint_name ||
                                 ': ya existe ' || v_new);
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('PK renombradas: ' || v_changes);
END;
/
