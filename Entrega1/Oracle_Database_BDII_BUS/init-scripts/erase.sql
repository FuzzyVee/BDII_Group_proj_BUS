BEGIN
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
            -- Safely skip any system-restricted object
            NULL;
      END;
   END LOOP;
END;
/