-- ===========================================================================================
-- CAPTURA 04 - CARGA DE DATOS, PRUEBAS Y REUBICACION FISICA
-- Proyecto BDII [[BUSSESS]] - BDII5_BDII_5::BUS
-- ===========================================================================================
-- Ejecutar como ALUMNO despues de BUS.sql.
-- ===========================================================================================

SET ECHO ON;
SET FEEDBACK ON;
SET SQLBLANKLINES ON;
SET SERVEROUTPUT ON;
SET LINESIZE 500;
SET PAGESIZE 300;
WHENEVER SQLERROR EXIT SQL.SQLCODE;

-- -------------------------------------------------------------------------------------------
--  MAPA DE EXTENSIONES ANTES DE LA CARGA (evidencia para la memoria)
-- -------------------------------------------------------------------------------------------
-- ==========================
PROMPT Mapa de extensiones ANTES de la carga
-- ==================================================================================================
SELECT tablespace_name, segment_name, segment_type, bytes, blocks, extents
FROM user_segments
WHERE tablespace_name LIKE 'TS_BUS%'
ORDER BY tablespace_name, segment_type, segment_name;

-- -------------------------------------------------------------------------------------------
-- CARGA DE DATOS VALIDOS
-- -------------------------------------------------------------------------------------------

-- Empleados: 1 conductor, 2 gerente, 3 dependiente, 4 mecanico, 5 empleado base
INSERT INTO Empleado (NumEmpleado, Nombre, Salario, NumEmpleado_Supervisor, TipoEmpleado)
VALUES (1, 'Carlos Gomez', 2500, NULL, 'CONDUCTOR');
INSERT INTO Empleado (NumEmpleado, Nombre, Salario, NumEmpleado_Supervisor, TipoEmpleado)
VALUES (2, 'Marta Lopez', 3200, NULL, 'GERENTE');
INSERT INTO Empleado (NumEmpleado, Nombre, Salario, NumEmpleado_Supervisor, TipoEmpleado)
VALUES (3, 'Luis Perez', 1800, 2, 'DEPENDIENTE');
INSERT INTO Empleado (NumEmpleado, Nombre, Salario, NumEmpleado_Supervisor, TipoEmpleado)
VALUES (4, 'Ana Torres', 2200, NULL, 'MECANICO');
INSERT INTO Empleado (NumEmpleado, Nombre, Salario, NumEmpleado_Supervisor, TipoEmpleado)
VALUES (5, 'Pedro Diaz', 2000, 2, NULL);

INSERT INTO Conductor (NumEmpleado) VALUES (1);
INSERT INTO Gerente (NumEmpleado) VALUES (2);
INSERT INTO Dependiente (NumEmpleado) VALUES (3);

INSERT INTO Taller (CodTaller, Telefono, Direccion)
VALUES (1, '+34981123456', 'Poligono Industrial, Santiago');

INSERT INTO Mecanico (NumEmpleado, CodTaller) VALUES (4, 1);

INSERT INTO Carnet (NumEmpleado_Conductor, TipoCarnet, FechaCaducidad)
VALUES (1, 'D1', TO_DATE('2030-12-31','YYYY-MM-DD'));

INSERT INTO Gasolinera (CodGasolinera) VALUES (10);

INSERT INTO Estacion (CodEstacion, CodGasolinera, Ubicacion)
VALUES (100, 10, 'Estacion Central, Santiago');
INSERT INTO Estacion (CodEstacion, CodGasolinera, Ubicacion)
VALUES (101, NULL, 'Parada Aeropuerto');

INSERT INTO Estacion_Telefono (CodEstacion, Telefono) VALUES (100, '981123456');
INSERT INTO Estacion_Telefono (CodEstacion, Telefono) VALUES (100, '981654321');

INSERT INTO Ruta (IdRuta, Origen_Destino, TiempoEstimado)
VALUES (101, 'Santiago - A Coruna', 45);

INSERT INTO Bus (Matricula, Matricula_Sustituto, NumEmpleado_Conductor, Modelo, Estado, plaza)
VALUES ('1234-ABC', NULL, 1, 'Volvo 9700', 'OPERATIVO', 55);
INSERT INTO Bus (Matricula, Matricula_Sustituto, NumEmpleado_Conductor, Modelo, Estado, plaza)
VALUES ('5678-DEF', '1234-ABC', 1, 'Mercedes Tourismo', 'OPERATIVO', 50);

INSERT INTO Cliente (IdCliente, EmailContacto, TipoCliente)
VALUES (50, 'juan.perez@email.com', 'PASAJERO');
INSERT INTO Cliente (IdCliente, EmailContacto, TipoCliente)
VALUES (60, 'compras@empresa.com', 'EMPRESA');

INSERT INTO Pasajero (IdCliente, Nombre, Apellidos, FechaNacimiento)
VALUES (50, 'Juan', 'Perez Garcia', TO_DATE('1998-05-15','YYYY-MM-DD'));

INSERT INTO Empresa (IdCliente, NombreEmpresa, DireccionFiscal)
VALUES (60, 'Transportes Galicia S.L.', 'Rua Nova 10, Santiago');

INSERT INTO Bono (IdCliente, NumBono, FechaCaducidad, Saldo, TipoBono, DistanciaValidez)
VALUES (50, 1, TO_DATE('2027-12-31','YYYY-MM-DD'), 50, 'MENSUAL', 100);

INSERT INTO Dependiente_Trabaja_Gasolinera
    (NumEmpleado_Dependiente, CodGasolinera, NumEmpleado_Gerente, FechaInicio)
VALUES (3, 10, 2, TO_DATE('2025-01-15','YYYY-MM-DD'));

INSERT INTO Ruta_PasaPor_Estacion (IdRuta, CodEstacion, Fecha)
VALUES (101, 100, TO_DATE('2026-01-01','YYYY-MM-DD'));

INSERT INTO Proveedor (CIFProveedor, NomeProveedor) VALUES ('A12345678', 'Repuestos Bus');
INSERT INTO Pieza (CodPieza, Descripcion) VALUES (500, 'Filtro de aceite');
INSERT INTO Proveedor_Suministra_Pieza
    (CIFProveedor, CodPieza, CodTaller, Precio, FechaSuministro, Cantidad)
VALUES ('A12345678', 500, 1, 12.50, TO_DATE('2026-01-10','YYYY-MM-DD'), 20);

INSERT INTO Documento_Bus (IdDocumento, Matricula, TipoDocumento, Contenido, FechaSubida)
VALUES (1, '1234-ABC', 'ITV', HEXTORAW('4954562032303236'), SYSTIMESTAMP);

-- -------------------------------------------------------------------------------------------
-- DOCUMENTACION PERSONAL DE TRABAJADORES (BLOB en ts_bus_BLOB)
-- -------------------------------------------------------------------------------------------
INSERT INTO Documento_Empleado
    (IdDocumento, NumEmpleado, TipoDocumento, NombreFichero, MimeType, Contenido, FechaSubida)
VALUES
    (1, 1, 'DNI', 'dni_carlos.pdf', 'application/pdf',
     HEXTORAW('255044462D312E340A25C3A4C3B6C3BC'), SYSTIMESTAMP);

INSERT INTO Documento_Empleado
    (IdDocumento, NumEmpleado, TipoDocumento, NombreFichero, MimeType, Contenido, FechaSubida)
VALUES
    (2, 1, 'FOTO', 'foto_carlos.jpg', 'image/jpeg',
     HEXTORAW('FFD8FFE000104A46494600010100000100010000'), SYSTIMESTAMP);

INSERT INTO Documento_Empleado
    (IdDocumento, NumEmpleado, TipoDocumento, NombreFichero, MimeType, Contenido, FechaSubida)
VALUES
    (3, 2, 'CONTRATO', 'contrato_marta.pdf', 'application/pdf',
     HEXTORAW('255044462D312E340A25454F46'), SYSTIMESTAMP);

INSERT INTO Documento_Empleado
    (IdDocumento, NumEmpleado, TipoDocumento, NombreFichero, MimeType, Contenido, FechaSubida)
VALUES
    (4, 4, 'TITULO', 'titulo_mecanico_ana.pdf', 'application/pdf',
     HEXTORAW('255044462D312E340A2525454F46'), SYSTIMESTAMP);

-- Documento de mayor tamano (128 KB) para que Oracle lo almacene fuera de la
-- fila y cree extensiones propias en ts_bus_BLOB.
DECLARE
    v_blob  BLOB;
    v_chunk RAW(32767) := UTL_RAW.CAST_TO_RAW(RPAD('BUS', 32767, 'X'));
BEGIN
    INSERT INTO Documento_Empleado
        (IdDocumento, NumEmpleado, TipoDocumento, NombreFichero, MimeType, Contenido, FechaSubida)
    VALUES
        (5, 3, 'NOMINA', 'nomina_luis_2026.pdf', 'application/pdf',
         EMPTY_BLOB(), SYSTIMESTAMP)
    RETURNING Contenido INTO v_blob;

    FOR i IN 1..4 LOOP
        DBMS_LOB.WRITEAPPEND(v_blob, UTL_RAW.LENGTH(v_chunk), v_chunk);
    END LOOP;
END;
/

-- -------------------------------------------------------------------------------------------
--  VIAJES (IdViaje es GENERATED ALWAYS AS IDENTITY: no se inserta explicitamente)
-- -------------------------------------------------------------------------------------------
DECLARE
    v_id_viaje NUMBER(10);
BEGIN
    INSERT INTO Viaje (Matricula, IdRuta, FechaHoraSalida)
    VALUES ('1234-ABC', 101, TIMESTAMP '2026-02-01 08:30:00')
    RETURNING IdViaje INTO v_id_viaje;

    INSERT INTO Viaje_Lleva_Pasajero (IdViaje, IdCliente) VALUES (v_id_viaje, 50);
END;
/

DECLARE
    v_id_viaje NUMBER(10);
BEGIN
    INSERT INTO Viaje (Matricula, IdRuta, FechaHoraSalida)
    VALUES ('5678-DEF', 101, TIMESTAMP '2026-02-01 10:00:00')
    RETURNING IdViaje INTO v_id_viaje;

    INSERT INTO Viaje_Lleva_Pasajero (IdViaje, IdCliente) VALUES (v_id_viaje, 50);
END;
/

INSERT INTO Billete (CodBillete, Matricula_Bus) VALUES (9001, '1234-ABC');
INSERT INTO Billete (CodBillete, Matricula_Bus) VALUES (9002, '5678-DEF');

INSERT INTO Mecanico_Repara_Bus (NumEmpleado_Mecanico, Matricula_Bus, FechaReparacion)
VALUES (4, '1234-ABC', TIMESTAMP '2026-01-20 09:00:00');

-- -------------------------------------------------------------------------------------------
-- HISTORICO PARTICIONADO (una fila por cada particion: p_2024, p_2025, p_2026 y p_historico)
-- -------------------------------------------------------------------------------------------
INSERT INTO Viaje_Particionado (IdViaje, Matricula, FechaSalida, Precio)
VALUES (1, '1234-ABC', TO_DATE('2025-06-15','YYYY-MM-DD'), 12.50);
INSERT INTO Viaje_Particionado (IdViaje, Matricula, FechaSalida, Precio)
VALUES (2, '5678-DEF', TO_DATE('2026-03-10','YYYY-MM-DD'), 15.00);
INSERT INTO Viaje_Particionado (IdViaje, Matricula, FechaSalida, Precio)
VALUES (3, '1234-ABC', TO_DATE('2024-11-02','YYYY-MM-DD'), 10.00);
INSERT INTO Viaje_Particionado (IdViaje, Matricula, FechaSalida, Precio)
VALUES (4, '5678-DEF', TO_DATE('2030-01-01','YYYY-MM-DD'), 20.00);

COMMIT;

-- -------------------------------------------------------------------------------------------
-- CONSULTAS DE COMPROBACION
-- -------------------------------------------------------------------------------------------
-- ==============================================================
PROMPT Viajes cargados y pasajeros
-- ==============================================================
SELECT v.IdViaje, v.Matricula, v.IdRuta, v.FechaHoraSalida, l.IdCliente
FROM Viaje v
LEFT JOIN Viaje_Lleva_Pasajero l ON v.IdViaje = l.IdViaje
ORDER BY v.IdViaje;

-- ==============================================================
PROMPT Distribucion de filas por particion
-- ==============================================================
SELECT partition_name, tablespace_name, num_rows
FROM user_tab_partitions
WHERE table_name = 'VIAJE_PARTICIONADO'
ORDER BY partition_position;

SELECT 'p_2024' AS particion, COUNT(*) AS filas FROM Viaje_Particionado PARTITION (p_2024)
UNION ALL
SELECT 'p_2025', COUNT(*) FROM Viaje_Particionado PARTITION (p_2025)
UNION ALL
SELECT 'p_2026', COUNT(*) FROM Viaje_Particionado PARTITION (p_2026)
UNION ALL
SELECT 'p_historico', COUNT(*) FROM Viaje_Particionado PARTITION (p_historico);

-- ==============================================================
PROMPT Vistas
-- ==============================================================
SELECT * FROM v_resumen_viajes_bus ORDER BY IdViaje;
SELECT * FROM v_pasajeros;

-- -------------------------------------------------------------------------------------------
-- PRUEBAS NEGATIVAS (cada bloque debe fallar con el error esperado)
-- -------------------------------------------------------------------------------------------
-- ==============================================================
PROMPT Pruebas negativas: se esperan errores controlados
-- ==============================================================

-- 5.1 Salario no positivo -> ORA-02290 (ck_empleado_salario)
BEGIN
    INSERT INTO Empleado (NumEmpleado, Nombre, Salario, TipoEmpleado)
    VALUES (99, 'Invalido', 0, 'CONDUCTOR');
    DBMS_OUTPUT.PUT_LINE('ERROR: se permitio un salario no positivo');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('OK salario: ' || SQLERRM);
END;
/

-- 5.2 Saldo de bono no positivo -> ORA-02290 (ck_bono_saldo)
BEGIN
    INSERT INTO Bono (IdCliente, NumBono, Saldo, TipoBono)
    VALUES (50, 99, 0, 'MENSUAL');
    DBMS_OUTPUT.PUT_LINE('ERROR: se permitio un saldo no positivo');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('OK bono: ' || SQLERRM);
END;
/

-- 5.3 Especializacion disjunta -> ORA-20001 (trigger)
BEGIN
    INSERT INTO Conductor (NumEmpleado) VALUES (2);
    DBMS_OUTPUT.PUT_LINE('ERROR: se permitio un conductor que ya era gerente');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('OK disjunta: ' || SQLERRM);
END;
/

-- 5.4 FK inexistente -> ORA-02291
BEGIN
    INSERT INTO Viaje (Matricula, IdRuta, FechaHoraSalida)
    VALUES ('9999-ZZZ', 101, TIMESTAMP '2026-02-01 12:00:00');
    DBMS_OUTPUT.PUT_LINE('ERROR: se permitio un viaje con bus inexistente');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('OK FK viaje: ' || SQLERRM);
END;
/

-- 5.5 Duplicado de PK -> ORA-00001
BEGIN
    INSERT INTO Taller (CodTaller, Telefono) VALUES (1, '000');
    DBMS_OUTPUT.PUT_LINE('ERROR: se permitio un taller duplicado');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('OK PK taller: ' || SQLERRM);
END;
/

ROLLBACK;

-- -------------------------------------------------------------------------------------------
-- 6. ADMINISTRACION FISICA: MOVE / REBUILD
-- -------------------------------------------------------------------------------------------
-- ==============================================================
PROMPT Reubicacion de tabla y reconstruccion de indices
-- ==============================================================

-- Mover la tabla principal al tablespace de datos (consolida extensiones).
ALTER TABLE Empleado MOVE TABLESPACE ts_bus_datos;

-- Reconstruir los indices afectados por el MOVE.
ALTER INDEX pk_empleado REBUILD TABLESPACE ts_bus_indices;
ALTER INDEX idx_empleado_nombre REBUILD TABLESPACE ts_bus_indices;
ALTER INDEX idx_empleado_supervisor REBUILD TABLESPACE ts_bus_indices;

-- Mover la particion de 2024 al tablespace de historicos.
ALTER TABLE Viaje_Particionado MOVE PARTITION p_2024 TABLESPACE ts_bus_hist UPDATE INDEXES;

-- Reconstruir el indice global de la tabla particionada.
ALTER INDEX idx_viaje_part_fecha REBUILD TABLESPACE ts_bus_indices;

-- ==============================================================
PROMPT Estado final de tablas e indices
-- ==============================================================
SELECT table_name, tablespace_name, status
FROM user_tables
ORDER BY table_name;

SELECT index_name, table_name, tablespace_name, status
FROM user_indexes
ORDER BY table_name, index_name;

SELECT table_name, partition_name, tablespace_name, status
FROM user_tab_partitions
WHERE table_name = 'VIAJE_PARTICIONADO'
ORDER BY partition_position;

-- ==============================================================
PROMPT Mapa de extensiones DESPUES de la carga
-- ==============================================================
SELECT tablespace_name, segment_name, segment_type, bytes, blocks, extents
FROM user_segments
WHERE tablespace_name LIKE 'TS_BUS%'
ORDER BY tablespace_name, segment_type, segment_name;

-- ==============================================================
PROMPT Documentos personales cargados y tamaño real del BLOB
-- ==============================================================
SELECT d.IdDocumento,
       d.NumEmpleado,
       d.TipoDocumento,
       d.NombreFichero,
       d.MimeType,
       DBMS_LOB.GETLENGTH(d.Contenido) AS Bytes_Contenido
FROM Documento_Empleado d
ORDER BY d.IdDocumento;

-- ==============================================================
PROMPT Evidencia: columnas LOB y su tablespace (USER_LOBS)
-- ==============================================================
SELECT table_name, column_name, segment_name, tablespace_name, chunk, cache
FROM user_lobs
ORDER BY table_name, column_name;

-- ==============================================================
PROMPT Evidencia: segmentos fisicos en TS_BUS_BLOB (USER_SEGMENTS)
-- ==============================================================
SELECT segment_name, segment_type, tablespace_name, bytes, blocks, extents
FROM user_segments
WHERE tablespace_name = 'TS_BUS_BLOB'
ORDER BY segment_name;

COMMIT;
