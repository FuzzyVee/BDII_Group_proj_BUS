
DECLARE
    v_sql VARCHAR2(500);
BEGIN
    FOR r IN (
        SELECT table_name, constraint_name
        FROM all_constraints
        WHERE owner = 'ALUMNO'
          AND constraint_type = 'P'
          AND constraint_name LIKE 'SYS_C%'
    ) LOOP
        v_sql := 'ALTER TABLE "ALUMNO"."' || r.table_name || 
                 '" RENAME CONSTRAINT "' || r.constraint_name || 
                 '" TO "PK_' || SUBSTR(r.table_name, 1, 26) || '"';
        
        DBMS_OUTPUT.PUT_LINE('Ejecutando: ' || v_sql);
        EXECUTE IMMEDIATE v_sql;
    END LOOP;
END;
/