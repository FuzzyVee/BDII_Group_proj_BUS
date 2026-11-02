SET ECHO ON;
SET FEEDBACK ON;

PROMPT ============================================
PROMPT Ejecutando creación de entidades fuertes...  
PROMPT ============================================
@@../Strong_Entities_Init.sql;

PROMPT ============================================
PROMPT Ejecutando creación de entidades débiles...
PROMPT ============================================
@@../Weak_Entities_Init.sql;

PROMPT ============================================
PROMPT Ejecutando creación de otras entidades...
PROMPT ============================================
@@../Other_Entities_Init.sql;

PROMPT ============================================
PROMPT Inicialización completada con éxito.
PROMPT ============================================