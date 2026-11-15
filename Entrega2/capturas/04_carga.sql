-- ===========================================================================================
-- CAPTURA 4.4 - CARGA DE DOCUMENTOS Y TAMANO REAL DE LOS BLOB DE DOCUMENTOS CARGADOS
-- Ejecutar como ALUMNO.
-- ===========================================================================================
SET LINESIZE 250;
SET PAGESIZE 100;
SET TRIMSPOOL ON;

-- Define explicit, short display widths for every column
COLUMN id_doc    FORMAT A10;
COLUMN num_emp   FORMAT A10;
COLUMN tipo_doc  FORMAT A20;
COLUMN NombreFichero  FORMAT A30;
COLUMN MimeType      FORMAT A25;
COLUMN tam_bytes FORMAT A10;
COLUMN NombreFichero  FORMAT A35;

-- ============================================================
-- Documentos personales cargados
-- ============================================================
SELECT IdDocumento,
       NumEmpleado,
       TipoDocumento,
       NombreFichero,
       MimeType,
       DBMS_LOB.GETLENGTH(Contenido) AS bytes_contenido
FROM Documento_Empleado
ORDER BY IdDocumento;

-- ============================================================
-- Documentos de buses cargados
-- ============================================================
SELECT IdDocumento,
       Matricula,
       TipoDocumento,
       DBMS_LOB.GETLENGTH(Contenido) AS bytes_contenido
FROM Documento_Bus
ORDER BY IdDocumento;

-- ============================================================
-- Extensiones fisicas de los segmentos LOB (USER_EXTENTS)
-- ============================================================
SELECT e.segment_name,
       e.extent_id,
       e.bytes,
       e.blocks,
       e.tablespace_name
FROM user_extents e
WHERE e.segment_name IN (
    SELECT l.segment_name
    FROM user_lobs l
    WHERE l.tablespace_name = 'TS_BUS_BLOB'
)
ORDER BY e.segment_name, e.extent_id;

-- ============================================================
-- Comprobacion de lectura de un BLOB (primeros 4 bytes en HEX)
-- ============================================================
SELECT IdDocumento,
       TipoDocumento,
       RAWTOHEX(DBMS_LOB.SUBSTR(Contenido, 4, 1)) AS primeros_bytes
FROM Documento_Empleado
ORDER BY IdDocumento;