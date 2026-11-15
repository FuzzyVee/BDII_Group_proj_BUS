-- ===========================================================================================
-- CAPTURA 05 - PARTICIONADO Y ESTADO TRAS MOVE / REBUILD
-- Ejecutar como ALUMNO.
-- ===========================================================================================

SET ECHO ON;
SET FEEDBACK ON;
SET LINESIZE 220;
SET PAGESIZE 120;

COLUMN table_name FORMAT A24;
COLUMN partition_name FORMAT A16;
COLUMN tablespace_name FORMAT A18;
COLUMN index_name FORMAT A32;
COLUMN status FORMAT A10;

PROMPT Particiones de Viaje_Particionado
SELECT table_name,
       partition_name,
       tablespace_name,
       num_rows
FROM user_tab_partitions
WHERE table_name = 'VIAJE_PARTICIONADO'
ORDER BY partition_position;

PROMPT Filas por particion
SELECT 'p_2024' AS particion, COUNT(*) AS filas FROM Viaje_Particionado PARTITION (p_2024)
UNION ALL
SELECT 'p_2025', COUNT(*) FROM Viaje_Particionado PARTITION (p_2025)
UNION ALL
SELECT 'p_2026', COUNT(*) FROM Viaje_Particionado PARTITION (p_2026)
UNION ALL
SELECT 'p_historico', COUNT(*) FROM Viaje_Particionado PARTITION (p_historico);

PROMPT Estado de tablas reubicadas
SELECT table_name, tablespace_name, status
FROM user_tables
WHERE table_name IN ('EMPLEADO', 'VIAJE_PARTICIONADO')
ORDER BY table_name;

PROMPT Estado de indices reconstruidos
SELECT index_name, table_name, tablespace_name, status
FROM user_indexes
WHERE table_name IN ('EMPLEADO', 'VIAJE_PARTICIONADO')
ORDER BY table_name, index_name;

PROMPT Reubicacion reproducible (MOVE / REBUILD)
ALTER TABLE Empleado MOVE TABLESPACE ts_bus_datos;
ALTER INDEX pk_empleado REBUILD TABLESPACE ts_bus_indices;
ALTER INDEX idx_empleado_nombre REBUILD TABLESPACE ts_bus_indices;
ALTER INDEX idx_empleado_supervisor REBUILD TABLESPACE ts_bus_indices;
ALTER TABLE Viaje_Particionado MOVE PARTITION p_2024 TABLESPACE ts_bus_hist UPDATE INDEXES;
ALTER INDEX idx_viaje_part_fecha REBUILD TABLESPACE ts_bus_indices;

PROMPT Estado final (debe ser VALID)
SELECT table_name, tablespace_name, status
FROM user_tables
WHERE table_name IN ('EMPLEADO', 'VIAJE_PARTICIONADO')
ORDER BY table_name;

SELECT index_name, table_name, tablespace_name, status
FROM user_indexes
WHERE table_name IN ('EMPLEADO', 'VIAJE_PARTICIONADO')
ORDER BY table_name, index_name;
