-- ===========================================================================================
-- CAPTURA 03 - LISTADOS DE TABLAS, INDICES Y PARTICIONES (EVIDENCIAS)
-- Ejecutar como ALUMNO.
-- ===========================================================================================

SET ECHO ON;
SET FEEDBACK ON;
SET LINESIZE 500;
SET PAGESIZE 200;

COLUMN table_name FORMAT A32;
COLUMN index_name FORMAT A32;
COLUMN partition_name FORMAT A16;
COLUMN tablespace_name FORMAT A18;
COLUMN segment_type FORMAT A18;
COLUMN status FORMAT A10;

PROMPT Listado de tablas y su tablespace
SELECT table_name, tablespace_name, status
FROM user_tables
ORDER BY table_name;

PROMPT Particiones de Viaje_Particionado
SELECT table_name, partition_name, tablespace_name, num_rows
FROM user_tab_partitions
WHERE table_name = 'VIAJE_PARTICIONADO'
ORDER BY partition_position;

PROMPT Numero de filas por tabla (carga realizada)
SELECT 'EMPLEADO' AS tabla, COUNT(*) AS filas FROM Empleado
UNION ALL SELECT 'GERENTE', COUNT(*) FROM Gerente
UNION ALL SELECT 'DEPENDIENTE', COUNT(*) FROM Dependiente
UNION ALL SELECT 'CONDUCTOR', COUNT(*) FROM Conductor
UNION ALL SELECT 'MECANICO', COUNT(*) FROM Mecanico
UNION ALL SELECT 'TALLER', COUNT(*) FROM Taller
UNION ALL SELECT 'CLIENTE', COUNT(*) FROM Cliente
UNION ALL SELECT 'PASAJERO', COUNT(*) FROM Pasajero
UNION ALL SELECT 'EMPRESA', COUNT(*) FROM Empresa
UNION ALL SELECT 'GASOLINERA', COUNT(*) FROM Gasolinera
UNION ALL SELECT 'ESTACION', COUNT(*) FROM Estacion
UNION ALL SELECT 'ESTACION_TELEFONO', COUNT(*) FROM Estacion_Telefono
UNION ALL SELECT 'RUTA', COUNT(*) FROM Ruta
UNION ALL SELECT 'BUS', COUNT(*) FROM Bus
UNION ALL SELECT 'VIAJE', COUNT(*) FROM Viaje
UNION ALL SELECT 'BILLETE', COUNT(*) FROM Billete
UNION ALL SELECT 'PROVEEDOR', COUNT(*) FROM Proveedor
UNION ALL SELECT 'PIEZA', COUNT(*) FROM Pieza
UNION ALL SELECT 'CARNET', COUNT(*) FROM Carnet
UNION ALL SELECT 'BONO', COUNT(*) FROM Bono
UNION ALL SELECT 'DEPENDIENTE_TRABAJA_GASOLINERA', COUNT(*) FROM Dependiente_Trabaja_Gasolinera
UNION ALL SELECT 'RUTA_PASAPOR_ESTACION', COUNT(*) FROM Ruta_PasaPor_Estacion
UNION ALL SELECT 'VIAJE_LLEVA_PASAJERO', COUNT(*) FROM Viaje_Lleva_Pasajero
UNION ALL SELECT 'MECANICO_REPARA_BUS', COUNT(*) FROM Mecanico_Repara_Bus
UNION ALL SELECT 'PROVEEDOR_SUMINISTRA_PIEZA', COUNT(*) FROM Proveedor_Suministra_Pieza
UNION ALL SELECT 'DOCUMENTO_BUS', COUNT(*) FROM Documento_Bus
UNION ALL SELECT 'DOCUMENTO_EMPLEADO', COUNT(*) FROM Documento_Empleado
UNION ALL SELECT 'VIAJE_PARTICIONADO', COUNT(*) FROM Viaje_Particionado
ORDER BY tabla;
