
SHOW CON_NAME;
SHOW USER;
SET ECHO ON;
SET FEEDBACK ON;
SET SQLBLANKLINES ON;
SET SERVEROUTPUT ON;
SET LINESIZE 200;
SET PAGESIZE 100;
WHENEVER SQLERROR EXIT SQL.SQLCODE;

-- -------------------------------------------------------------------------------------------
-- 0. LIMPIEZA DE OBJETOS PREVIOS
-- Se incluyen los nombres antiguos (BUS_LLEVAPOR_PASAJERO) para poder migrar sin conflictos.
-- -------------------------------------------------------------------------------------------
BEGIN
    FOR r IN (
        SELECT table_name
        FROM user_tables
        WHERE table_name IN (
            'VIAJE_PARTICIONADO',
            'PROVEEDOR_SUMINISTRA_PIEZA',
            'MECANICO_REPARA_BUS', 'VIAJE_LLEVA_PASAJERO', 'BUS_LLEVAPOR_PASAJERO',
            'RUTA_PASAPOR_ESTACION', 'DEPENDIENTE_TRABAJA_GASOLINERA',
            'BONO', 'CARNET', 'DOCUMENTO_EMPLEADO', 'DOCUMENTO_BUS', 'PIEZA', 'PROVEEDOR',
            'BILLETE', 'VIAJE', 'BUS', 'RUTA', 'ESTACION_TELEFONO', 'ESTACION',
            'GASOLINERA', 'EMPRESA', 'PASAJERO', 'CLIENTE', 'MECANICO',
            'TALLER', 'CONDUCTOR', 'DEPENDIENTE', 'GERENTE', 'EMPLEADO'
        )
    ) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || r.table_name || ' CASCADE CONSTRAINTS PURGE';
    END LOOP;
END;
/

-- Elimina vistas antiguas para evitar definiciones obsoletas.
BEGIN
    FOR r IN (
        SELECT view_name
        FROM user_views
        WHERE view_name IN ('V_RESUMEN_VIAJES_BUS', 'V_PASAJEROS', 'V_PASAJEROS_ACTIVOS')
    ) LOOP
        EXECUTE IMMEDIATE 'DROP VIEW ' || r.view_name;
    END LOOP;
END;
/

----------------------------------------------------------------------------------------------
-- 1. ENTIDADES FUERTES Y ESPECIALIZACIONES
----------------------------------------------------------------------------------------------

CREATE TABLE Empleado (
    NumEmpleado NUMBER(10) NOT NULL,
    Nombre VARCHAR2(50) NOT NULL,
    Salario NUMBER(10) NOT NULL,
    NumEmpleado_Supervisor NUMBER(10),
    TipoEmpleado VARCHAR2(20), -- 20 para admitir 'DEPENDIENTE' (11 caracteres)
    CONSTRAINT pk_empleado PRIMARY KEY (NumEmpleado) USING INDEX TABLESPACE ts_bus_indices,
    CONSTRAINT fk_empleado_supervisor FOREIGN KEY (NumEmpleado_Supervisor)
        REFERENCES Empleado(NumEmpleado),
    CONSTRAINT ck_empleado_salario CHECK (Salario > 0),
    CONSTRAINT ck_empleado_tipo CHECK (TipoEmpleado IN ('GERENTE','DEPENDIENTE','CONDUCTOR','MECANICO'))
) SEGMENT CREATION IMMEDIATE TABLESPACE ts_bus_datos;

CREATE TABLE Gerente (
    NumEmpleado NUMBER(10) NOT NULL,
    CONSTRAINT pk_gerente PRIMARY KEY (NumEmpleado) USING INDEX TABLESPACE ts_bus_indices,
    CONSTRAINT fk_gerente_empleado FOREIGN KEY (NumEmpleado)
        REFERENCES Empleado(NumEmpleado) ON DELETE CASCADE
) SEGMENT CREATION IMMEDIATE TABLESPACE ts_bus_datos;

CREATE TABLE Dependiente (
    NumEmpleado NUMBER(10) NOT NULL,
    CONSTRAINT pk_dependiente PRIMARY KEY (NumEmpleado) USING INDEX TABLESPACE ts_bus_indices,
    CONSTRAINT fk_dependiente_empleado FOREIGN KEY (NumEmpleado)
        REFERENCES Empleado(NumEmpleado) ON DELETE CASCADE
) SEGMENT CREATION IMMEDIATE TABLESPACE ts_bus_datos;

CREATE TABLE Conductor (
    NumEmpleado NUMBER(10) NOT NULL,
    CONSTRAINT pk_conductor PRIMARY KEY (NumEmpleado) USING INDEX TABLESPACE ts_bus_indices,
    CONSTRAINT fk_conductor_empleado FOREIGN KEY (NumEmpleado)
        REFERENCES Empleado(NumEmpleado) ON DELETE CASCADE
) SEGMENT CREATION IMMEDIATE TABLESPACE ts_bus_datos;

CREATE TABLE Taller (
    CodTaller NUMBER(10) NOT NULL,
    Telefono VARCHAR2(15),
    Direccion VARCHAR2(100),
    CONSTRAINT pk_taller PRIMARY KEY (CodTaller) USING INDEX TABLESPACE ts_bus_indices
) SEGMENT CREATION IMMEDIATE TABLESPACE ts_bus_datos;

CREATE TABLE Mecanico (
    NumEmpleado NUMBER(10) NOT NULL,
    CodTaller NUMBER(10) NOT NULL,
    CONSTRAINT pk_mecanico PRIMARY KEY (NumEmpleado) USING INDEX TABLESPACE ts_bus_indices,
    CONSTRAINT fk_mecanico_empleado FOREIGN KEY (NumEmpleado)
        REFERENCES Empleado(NumEmpleado) ON DELETE CASCADE,
    CONSTRAINT fk_mecanico_taller FOREIGN KEY (CodTaller)
        REFERENCES Taller(CodTaller)
) SEGMENT CREATION IMMEDIATE TABLESPACE ts_bus_datos;

CREATE TABLE Cliente (
    IdCliente NUMBER(10) NOT NULL,
    EmailContacto VARCHAR2(100),
    TipoCliente VARCHAR2(10),
    CONSTRAINT pk_cliente PRIMARY KEY (IdCliente) USING INDEX TABLESPACE ts_bus_indices,
    CONSTRAINT ck_cliente_tipo CHECK (TipoCliente IN ('PASAJERO','EMPRESA'))
) SEGMENT CREATION IMMEDIATE TABLESPACE ts_bus_datos;

CREATE TABLE Pasajero (
    IdCliente NUMBER(10) NOT NULL,
    Nombre VARCHAR2(50),
    Apellidos VARCHAR2(100),
    FechaNacimiento DATE,
    NombreCompleto VARCHAR2(151) GENERATED ALWAYS AS (Nombre || ' ' || Apellidos),
    CONSTRAINT pk_pasajero PRIMARY KEY (IdCliente) USING INDEX TABLESPACE ts_bus_indices,
    CONSTRAINT fk_pasajero_cliente FOREIGN KEY (IdCliente)
        REFERENCES Cliente(IdCliente) ON DELETE CASCADE
) SEGMENT CREATION IMMEDIATE TABLESPACE ts_bus_datos;

CREATE TABLE Empresa (
    IdCliente NUMBER(10) NOT NULL,
    NombreEmpresa VARCHAR2(50),
    DireccionFiscal VARCHAR2(100),
    CONSTRAINT pk_empresa PRIMARY KEY (IdCliente) USING INDEX TABLESPACE ts_bus_indices,
    CONSTRAINT fk_empresa_cliente FOREIGN KEY (IdCliente)
        REFERENCES Cliente(IdCliente) ON DELETE CASCADE
) SEGMENT CREATION IMMEDIATE TABLESPACE ts_bus_datos;

CREATE TABLE Gasolinera (
    CodGasolinera NUMBER(10) NOT NULL,
    CONSTRAINT pk_gasolinera PRIMARY KEY (CodGasolinera) USING INDEX TABLESPACE ts_bus_indices
) SEGMENT CREATION IMMEDIATE TABLESPACE ts_bus_datos;

CREATE TABLE Estacion (
    CodEstacion NUMBER(10) NOT NULL,
    CodGasolinera NUMBER(10),
    Ubicacion VARCHAR2(100),
    CONSTRAINT pk_estacion PRIMARY KEY (CodEstacion) USING INDEX TABLESPACE ts_bus_indices,
    CONSTRAINT fk_estacion_gasolinera FOREIGN KEY (CodGasolinera)
        REFERENCES Gasolinera(CodGasolinera)
) SEGMENT CREATION IMMEDIATE TABLESPACE ts_bus_datos;

CREATE TABLE Estacion_Telefono (
    CodEstacion NUMBER(10) NOT NULL,
    Telefono VARCHAR2(15) NOT NULL,
    CONSTRAINT pk_estacion_telefono PRIMARY KEY (CodEstacion, Telefono) USING INDEX TABLESPACE ts_bus_indices,
    CONSTRAINT fk_estacion_tfno FOREIGN KEY (CodEstacion)
        REFERENCES Estacion(CodEstacion) ON DELETE CASCADE
) SEGMENT CREATION IMMEDIATE TABLESPACE ts_bus_datos;

CREATE TABLE Ruta (
    IdRuta NUMBER(10) NOT NULL,
    Origen_Destino VARCHAR2(100) NOT NULL,
    TiempoEstimado NUMBER(5) NOT NULL,
    CONSTRAINT pk_ruta PRIMARY KEY (IdRuta) USING INDEX TABLESPACE ts_bus_indices,
    CONSTRAINT ck_ruta_tiempo CHECK (TiempoEstimado >= 0)
) SEGMENT CREATION IMMEDIATE TABLESPACE ts_bus_datos;

CREATE TABLE Bus (
    Matricula VARCHAR2(10) NOT NULL,
    Matricula_Sustituto VARCHAR2(10),
    NumEmpleado_Conductor NUMBER(10) NOT NULL,
    Modelo VARCHAR2(50),
    Estado VARCHAR2(20),
    plaza NUMBER(3),
    CONSTRAINT pk_bus PRIMARY KEY (Matricula) USING INDEX TABLESPACE ts_bus_indices,
    CONSTRAINT uk_bus_sustituto UNIQUE (Matricula_Sustituto)
        USING INDEX TABLESPACE ts_bus_indices,
    CONSTRAINT fk_bus_sustituto FOREIGN KEY (Matricula_Sustituto)
        REFERENCES Bus(Matricula),
    CONSTRAINT fk_bus_conductor FOREIGN KEY (NumEmpleado_Conductor)
        REFERENCES Conductor(NumEmpleado),
    CONSTRAINT ck_bus_estado CHECK (Estado IN ('OPERATIVO','EN REPARACION','FUERA DE SERVICIO')),
    CONSTRAINT ck_bus_plaza CHECK (plaza > 0),
    CONSTRAINT ck_bus_no_autosustituto CHECK (Matricula_Sustituto IS NULL OR Matricula_Sustituto <> Matricula)
) SEGMENT CREATION IMMEDIATE TABLESPACE ts_bus_datos;

CREATE TABLE Viaje (
    IdViaje NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    Matricula VARCHAR2(10) NOT NULL,
    IdRuta NUMBER(10) NOT NULL,
    FechaHoraSalida TIMESTAMP NOT NULL,
    CONSTRAINT pk_viaje PRIMARY KEY (IdViaje) USING INDEX TABLESPACE ts_bus_indices,
    CONSTRAINT fk_viaje_bus FOREIGN KEY (Matricula) REFERENCES Bus(Matricula),
    CONSTRAINT fk_viaje_ruta FOREIGN KEY (IdRuta) REFERENCES Ruta(IdRuta)
) SEGMENT CREATION IMMEDIATE TABLESPACE ts_bus_datos;

CREATE TABLE Billete (
    CodBillete NUMBER(10) NOT NULL,
    Matricula_Bus VARCHAR2(10) NOT NULL,
    CONSTRAINT pk_billete PRIMARY KEY (CodBillete) USING INDEX TABLESPACE ts_bus_indices,
    CONSTRAINT fk_billete_bus FOREIGN KEY (Matricula_Bus) REFERENCES Bus(Matricula)
) SEGMENT CREATION IMMEDIATE TABLESPACE ts_bus_datos;

CREATE TABLE Proveedor (
    CIFProveedor VARCHAR2(9) NOT NULL,
    NomeProveedor VARCHAR2(50),
    CONSTRAINT pk_proveedor PRIMARY KEY (CIFProveedor) USING INDEX TABLESPACE ts_bus_indices
) SEGMENT CREATION IMMEDIATE TABLESPACE ts_bus_datos;

CREATE TABLE Pieza (
    CodPieza NUMBER(10) NOT NULL,
    Descripcion VARCHAR2(200),
    CONSTRAINT pk_pieza PRIMARY KEY (CodPieza) USING INDEX TABLESPACE ts_bus_indices
) SEGMENT CREATION IMMEDIATE TABLESPACE ts_bus_datos;

----------------------------------------------------------------------------------------------
-- 2. ENTIDADES DEBILES
----------------------------------------------------------------------------------------------

CREATE TABLE Carnet (
    NumEmpleado_Conductor NUMBER(10) NOT NULL,
    TipoCarnet VARCHAR2(10) NOT NULL,
    FechaCaducidad DATE,
    CONSTRAINT pk_carnet PRIMARY KEY (NumEmpleado_Conductor, TipoCarnet) USING INDEX TABLESPACE ts_bus_indices,
    CONSTRAINT fk_carnet_conductor FOREIGN KEY (NumEmpleado_Conductor)
        REFERENCES Conductor(NumEmpleado) ON DELETE CASCADE
) SEGMENT CREATION IMMEDIATE TABLESPACE ts_bus_datos;

CREATE TABLE Bono (
    IdCliente NUMBER(10) NOT NULL,
    NumBono NUMBER(10) NOT NULL,
    FechaCaducidad DATE,
    Saldo NUMBER(10),
    TipoBono VARCHAR2(20),
    DistanciaValidez NUMBER(10),
    CONSTRAINT pk_bono PRIMARY KEY (IdCliente, NumBono) USING INDEX TABLESPACE ts_bus_indices,
    CONSTRAINT fk_bono_cliente FOREIGN KEY (IdCliente)
        REFERENCES Cliente(IdCliente) ON DELETE CASCADE,
    CONSTRAINT ck_bono_saldo CHECK (Saldo > 0)
) SEGMENT CREATION IMMEDIATE TABLESPACE ts_bus_datos;

----------------------------------------------------------------------------------------------
-- 3. RELACIONES Y ENTIDADES ASOCIATIVAS
----------------------------------------------------------------------------------------------

CREATE TABLE Dependiente_Trabaja_Gasolinera (
    NumEmpleado_Dependiente NUMBER(10) NOT NULL,
    CodGasolinera NUMBER(10) NOT NULL,
    NumEmpleado_Gerente NUMBER(10),
    FechaInicio DATE DEFAULT SYSDATE,
    CONSTRAINT pk_dtg PRIMARY KEY (NumEmpleado_Dependiente) USING INDEX TABLESPACE ts_bus_indices,
    CONSTRAINT fk_dtg_dependiente FOREIGN KEY (NumEmpleado_Dependiente)
        REFERENCES Dependiente(NumEmpleado) ON DELETE CASCADE,
    CONSTRAINT fk_dtg_gasolinera FOREIGN KEY (CodGasolinera)
        REFERENCES Gasolinera(CodGasolinera),
    CONSTRAINT fk_dtg_gerente FOREIGN KEY (NumEmpleado_Gerente)
        REFERENCES Gerente(NumEmpleado)
) SEGMENT CREATION IMMEDIATE TABLESPACE ts_bus_datos;

CREATE TABLE Ruta_PasaPor_Estacion (
    IdRuta NUMBER(10) NOT NULL,
    CodEstacion NUMBER(10) NOT NULL,
    Fecha DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT pk_ruta_pasa_estacion PRIMARY KEY (IdRuta, CodEstacion, Fecha) USING INDEX TABLESPACE ts_bus_indices,
    CONSTRAINT fk_pasa_estacion FOREIGN KEY (CodEstacion)
        REFERENCES Estacion(CodEstacion),
    CONSTRAINT fk_pasa_ruta FOREIGN KEY (IdRuta)
        REFERENCES Ruta(IdRuta)
) SEGMENT CREATION IMMEDIATE TABLESPACE ts_bus_datos;

CREATE TABLE Viaje_Lleva_Pasajero (
    IdViaje NUMBER(10) NOT NULL,
    IdCliente NUMBER(10) NOT NULL,
    CONSTRAINT pk_viaje_lleva_pasajero PRIMARY KEY (IdViaje, IdCliente) USING INDEX TABLESPACE ts_bus_indices,
    CONSTRAINT fk_lleva_viaje FOREIGN KEY (IdViaje)
        REFERENCES Viaje(IdViaje) ON DELETE CASCADE,
    CONSTRAINT fk_lleva_pasajero FOREIGN KEY (IdCliente)
        REFERENCES Pasajero(IdCliente) ON DELETE CASCADE
) SEGMENT CREATION IMMEDIATE TABLESPACE ts_bus_datos;

CREATE TABLE Mecanico_Repara_Bus (
    NumEmpleado_Mecanico NUMBER(10) NOT NULL,
    Matricula_Bus VARCHAR2(10) NOT NULL,
    FechaReparacion TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT pk_mecanico_repara_bus PRIMARY KEY (NumEmpleado_Mecanico, Matricula_Bus, FechaReparacion) USING INDEX TABLESPACE ts_bus_indices,
    CONSTRAINT fk_repara_mecanico FOREIGN KEY (NumEmpleado_Mecanico)
        REFERENCES Mecanico(NumEmpleado),
    CONSTRAINT fk_repara_bus FOREIGN KEY (Matricula_Bus)
        REFERENCES Bus(Matricula)
) SEGMENT CREATION IMMEDIATE TABLESPACE ts_bus_datos;

CREATE TABLE Proveedor_Suministra_Pieza (
    CIFProveedor VARCHAR2(9) NOT NULL,
    CodPieza NUMBER(10) NOT NULL,
    CodTaller NUMBER(10) NOT NULL,
    Precio NUMBER(10),
    FechaSuministro DATE DEFAULT SYSTIMESTAMP NOT NULL,
    Cantidad NUMBER(5),
    CONSTRAINT pk_proveedor_suministra_pieza PRIMARY KEY (CIFProveedor, CodPieza, CodTaller, FechaSuministro) USING INDEX TABLESPACE ts_bus_indices,
    CONSTRAINT fk_sum_proveedor FOREIGN KEY (CIFProveedor)
        REFERENCES Proveedor(CIFProveedor),
    CONSTRAINT fk_sum_pieza FOREIGN KEY (CodPieza)
        REFERENCES Pieza(CodPieza),
    CONSTRAINT fk_sum_taller FOREIGN KEY (CodTaller)
        REFERENCES Taller(CodTaller),
    CONSTRAINT ck_sum_precio CHECK (Precio > 0),
    CONSTRAINT ck_sum_cantidad CHECK (Cantidad > 0)
) SEGMENT CREATION IMMEDIATE TABLESPACE ts_bus_datos;

----------------------------------------------------------------------------------------------
-- 4. ENTIDADES DOCUMENTALES (ET2 - BLOB en ts_bus_BLOB)
----------------------------------------------------------------------------------------------

CREATE TABLE Documento_Bus (
    IdDocumento NUMBER(10) NOT NULL,
    Matricula VARCHAR2(10) NOT NULL,
    TipoDocumento VARCHAR2(30),
    Contenido BLOB,
    FechaSubida TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT pk_documento_bus PRIMARY KEY (IdDocumento) USING INDEX TABLESPACE ts_bus_indices,
    CONSTRAINT fk_doc_bus FOREIGN KEY (Matricula)
        REFERENCES Bus(Matricula) ON DELETE CASCADE
) SEGMENT CREATION IMMEDIATE TABLESPACE ts_bus_datos
LOB (Contenido) STORE AS SECUREFILE (
    TABLESPACE ts_bus_BLOB
    ENABLE STORAGE IN ROW
    CHUNK 8192
    NOCACHE
    LOGGING
);

-- Documentacion personal de los trabajadores. Los datos relacionales de la
-- ficha del empleado siguen en ts_bus_datos; el contenido binario (DNI,
-- contrato, nomina, titulo, certificado, foto) se aisla en ts_bus_BLOB.
CREATE TABLE Documento_Empleado (
    IdDocumento NUMBER(10) NOT NULL,
    NumEmpleado NUMBER(10) NOT NULL,
    TipoDocumento VARCHAR2(30) NOT NULL,
    NombreFichero VARCHAR2(200) NOT NULL,
    MimeType VARCHAR2(100),
    Contenido BLOB NOT NULL,
    FechaSubida TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT pk_documento_empleado PRIMARY KEY (IdDocumento)
        USING INDEX TABLESPACE ts_bus_indices,
    CONSTRAINT fk_doc_empleado FOREIGN KEY (NumEmpleado)
        REFERENCES Empleado(NumEmpleado) ON DELETE CASCADE,
    CONSTRAINT ck_doc_empleado_tipo
        CHECK (TipoDocumento IN ('DNI','CONTRATO','NOMINA','TITULO','CERTIFICADO','FOTO'))
) SEGMENT CREATION IMMEDIATE TABLESPACE ts_bus_datos
LOB (Contenido) STORE AS SECUREFILE (
    TABLESPACE ts_bus_BLOB
    ENABLE STORAGE IN ROW
    CHUNK 8192
    NOCACHE
    LOGGING
);

----------------------------------------------------------------------------------------------
-- 5. TABLA PARTICIONADA (ET2 - datos historicos)
----------------------------------------------------------------------------------------------

CREATE TABLE Viaje_Particionado (
    IdViaje NUMBER(10) NOT NULL,
    Matricula VARCHAR2(10) NOT NULL,
    FechaSalida DATE NOT NULL,
    Precio NUMBER(6,2),
    CONSTRAINT pk_viaje_particionado PRIMARY KEY (IdViaje, FechaSalida)
        USING INDEX TABLESPACE ts_bus_indices
)
SEGMENT CREATION IMMEDIATE
PARTITION BY RANGE (FechaSalida) (
    PARTITION p_2024 VALUES LESS THAN (TO_DATE('2025-01-01','YYYY-MM-DD')) TABLESPACE ts_bus_datos,
    PARTITION p_2025 VALUES LESS THAN (TO_DATE('2026-01-01','YYYY-MM-DD')) TABLESPACE ts_bus_datos,
    PARTITION p_2026 VALUES LESS THAN (TO_DATE('2027-01-01','YYYY-MM-DD')) TABLESPACE ts_bus_datos,
    PARTITION p_historico VALUES LESS THAN (MAXVALUE) TABLESPACE ts_bus_hist
);

----------------------------------------------------------------------------------------------
-- 6. INDICES (todos en ts_bus_indices)
----------------------------------------------------------------------------------------------

CREATE INDEX idx_empleado_nombre ON Empleado(Nombre) TABLESPACE ts_bus_indices;
CREATE INDEX idx_empleado_supervisor ON Empleado(NumEmpleado_Supervisor) TABLESPACE ts_bus_indices;
CREATE INDEX idx_mecanico_taller ON Mecanico(CodTaller) TABLESPACE ts_bus_indices;
CREATE INDEX idx_estacion_gasolinera ON Estacion(CodGasolinera) TABLESPACE ts_bus_indices;
CREATE INDEX idx_ruta_origen_destino ON Ruta(Origen_Destino) TABLESPACE ts_bus_indices;
CREATE INDEX idx_bus_conductor ON Bus(NumEmpleado_Conductor) TABLESPACE ts_bus_indices;
CREATE INDEX idx_viaje_fecha ON Viaje(FechaHoraSalida) TABLESPACE ts_bus_indices;
CREATE INDEX idx_viaje_bus ON Viaje(Matricula) TABLESPACE ts_bus_indices;
CREATE INDEX idx_viaje_ruta ON Viaje(IdRuta) TABLESPACE ts_bus_indices;
CREATE INDEX idx_billete_bus ON Billete(Matricula_Bus) TABLESPACE ts_bus_indices;
CREATE INDEX idx_dtg_gasolinera ON Dependiente_Trabaja_Gasolinera(CodGasolinera) TABLESPACE ts_bus_indices;
CREATE INDEX idx_dtg_gerente ON Dependiente_Trabaja_Gasolinera(NumEmpleado_Gerente) TABLESPACE ts_bus_indices;
CREATE INDEX idx_rpe_estacion ON Ruta_PasaPor_Estacion(CodEstacion) TABLESPACE ts_bus_indices;
CREATE INDEX idx_vlp_pasajero ON Viaje_Lleva_Pasajero(IdCliente) TABLESPACE ts_bus_indices;
CREATE INDEX idx_mrb_bus ON Mecanico_Repara_Bus(Matricula_Bus) TABLESPACE ts_bus_indices;
CREATE INDEX idx_psp_pieza ON Proveedor_Suministra_Pieza(CodPieza) TABLESPACE ts_bus_indices;
CREATE INDEX idx_psp_taller ON Proveedor_Suministra_Pieza(CodTaller) TABLESPACE ts_bus_indices;
CREATE INDEX idx_documento_bus ON Documento_Bus(Matricula) TABLESPACE ts_bus_indices;
CREATE INDEX idx_documento_empleado ON Documento_Empleado(NumEmpleado) TABLESPACE ts_bus_indices;
CREATE INDEX idx_viaje_part_fecha ON Viaje_Particionado(FechaSalida) TABLESPACE ts_bus_indices;

----------------------------------------------------------------------------------------------
-- 7. VISTAS
----------------------------------------------------------------------------------------------

CREATE OR REPLACE VIEW v_resumen_viajes_bus AS
SELECT b.Matricula,
       r.IdRuta,
       v.IdViaje,
       v.FechaHoraSalida,
       COUNT(DISTINCT l.IdCliente) AS Total_Pasajeros
FROM Bus b
JOIN Viaje v ON b.Matricula = v.Matricula
JOIN Ruta r ON v.IdRuta = r.IdRuta
LEFT JOIN Viaje_Lleva_Pasajero l ON v.IdViaje = l.IdViaje
GROUP BY b.Matricula, r.IdRuta, v.IdViaje, v.FechaHoraSalida;

CREATE OR REPLACE VIEW v_pasajeros AS
SELECT IdCliente, Nombre, Apellidos, FechaNacimiento, NombreCompleto
FROM Pasajero;

----------------------------------------------------------------------------------------------
-- 8. TRIGGERS DE EXCLUSION (especializaciones disjuntas)
----------------------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER trg_conductor_exclusivo
BEFORE INSERT OR UPDATE ON Conductor
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM Gerente WHERE NumEmpleado = :NEW.NumEmpleado;
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El empleado ya es Gerente: especializacion disjunta.');
    END IF;
    SELECT COUNT(*) INTO v_count FROM Dependiente WHERE NumEmpleado = :NEW.NumEmpleado;
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'El empleado ya es Dependiente: especializacion disjunta.');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_gerente_exclusivo
BEFORE INSERT OR UPDATE ON Gerente
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM Conductor WHERE NumEmpleado = :NEW.NumEmpleado;
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'El empleado ya es Conductor: especializacion disjunta.');
    END IF;
    SELECT COUNT(*) INTO v_count FROM Dependiente WHERE NumEmpleado = :NEW.NumEmpleado;
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'El empleado ya es Dependiente: especializacion disjunta.');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_dependiente_exclusivo
BEFORE INSERT OR UPDATE ON Dependiente
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM Conductor WHERE NumEmpleado = :NEW.NumEmpleado;
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'El empleado ya es Conductor: especializacion disjunta.');
    END IF;
    SELECT COUNT(*) INTO v_count FROM Gerente WHERE NumEmpleado = :NEW.NumEmpleado;
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'El empleado ya es Gerente: especializacion disjunta.');
    END IF;
END;
/

----------------------------------------------------------------------------------------------
-- 9. COMENTARIOS DE DICCIONARIO (visibles en USER_TAB_COMMENTS)
----------------------------------------------------------------------------------------------

COMMENT ON TABLE Empleado IS 'Datos laborales comunes de todo el personal.';
COMMENT ON TABLE Gerente IS 'Especializacion disjunta de Empleado con funciones de direccion.';
COMMENT ON TABLE Dependiente IS 'Especializacion disjunta de Empleado que trabaja en una gasolinera.';
COMMENT ON TABLE Conductor IS 'Especializacion disjunta de Empleado habilitado para conducir.';
COMMENT ON TABLE Taller IS 'Taller de mantenimiento de la red de autobuses.';
COMMENT ON TABLE Mecanico IS 'Especializacion solapada de Empleado asignada a un taller.';
COMMENT ON TABLE Cliente IS 'Cliente persona fisica o empresa.';
COMMENT ON TABLE Pasajero IS 'Categoria disjunta de Cliente para personas fisicas.';
COMMENT ON TABLE Empresa IS 'Categoria disjunta de Cliente para personas juridicas.';
COMMENT ON TABLE Gasolinera IS 'Empresa suministradora de combustible.';
COMMENT ON TABLE Estacion IS 'Parada de la red de autobuses.';
COMMENT ON TABLE Estacion_Telefono IS 'Telefonos de contacto de una estacion (atributo multivalorado).';
COMMENT ON TABLE Ruta IS 'Trayecto con origen, destino y tiempo estimado.';
COMMENT ON TABLE Bus IS 'Autobus de la flota.';
COMMENT ON TABLE Viaje IS 'Servicio concreto de un bus sobre una ruta.';
COMMENT ON TABLE Billete IS 'Titulo de transporte emitido para un bus.';
COMMENT ON TABLE Proveedor IS 'Empresa que suministra piezas.';
COMMENT ON TABLE Pieza IS 'Repuesto o material de mantenimiento.';
COMMENT ON TABLE Carnet IS 'Carnet profesional de un conductor (entidad debil).';
COMMENT ON TABLE Bono IS 'Bono de transporte de un cliente (entidad debil).';
COMMENT ON TABLE Dependiente_Trabaja_Gasolinera IS 'Asignacion de dependiente a gasolinera y gerente supervisor.';
COMMENT ON TABLE Ruta_PasaPor_Estacion IS 'Estaciones por las que pasa cada ruta.';
COMMENT ON TABLE Viaje_Lleva_Pasajero IS 'Pasajeros que viajan en cada viaje (N:M).';
COMMENT ON TABLE Mecanico_Repara_Bus IS 'Historial de reparaciones de buses por mecanicos.';
COMMENT ON TABLE Proveedor_Suministra_Pieza IS 'Relacion ternaria de suministro de piezas a talleres.';
COMMENT ON TABLE Documento_Bus IS 'Documentacion digital asociada a un bus (LOB en ts_bus_BLOB).';
COMMENT ON TABLE Documento_Empleado IS 'Documentacion personal de un trabajador (LOB en ts_bus_BLOB).';
COMMENT ON TABLE Viaje_Particionado IS 'Historico de viajes particionado por rango de fecha.';

----------------------------------------------------------------------------------------------
-- 10. VERIFICACION DEL DICCIONARIO DE DATOS
----------------------------------------------------------------------------------------------

PROMPT ============================================================
PROMPT Tablas, tablespaces y estado
PROMPT ============================================================
SELECT table_name, tablespace_name, status
FROM user_tables
ORDER BY table_name;

PROMPT ============================================================
PROMPT Indices y tablespaces
PROMPT ============================================================
SELECT index_name, table_name, tablespace_name, status
FROM user_indexes
ORDER BY table_name, index_name;

PROMPT ============================================================
PROMPT Particiones de Viaje_Particionado
PROMPT ============================================================
SELECT table_name, partition_name, tablespace_name, num_rows
FROM user_tab_partitions
WHERE table_name = 'VIAJE_PARTICIONADO'
ORDER BY partition_position;

PROMPT ============================================================
PROMPT Columnas LOB y su tablespace
PROMPT ============================================================
SELECT table_name, column_name, segment_name, tablespace_name, chunk, cache
FROM user_lobs
ORDER BY table_name, column_name;

PROMPT ============================================================
PROMPT Segmentos LOB ubicados en ts_bus_BLOB
PROMPT ============================================================
SELECT segment_name, segment_type, tablespace_name, bytes, blocks, extents
FROM user_segments
WHERE tablespace_name = 'TS_BUS_BLOB'
ORDER BY segment_name;

PROMPT ============================================================
PROMPT Restricciones
PROMPT ============================================================
SELECT table_name, constraint_name, constraint_type, status
FROM user_constraints
ORDER BY table_name, constraint_type, constraint_name;

COMMIT;
