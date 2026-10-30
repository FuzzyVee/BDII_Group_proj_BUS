-- ===========================================================================================
-- SCRIPT DE CREACION DAS TABLAS E RELACIONS EN ORACLE 26ai
-- PROYECTO BDII [[BUSSESS]]
-- ===========================================================================================

SHOW CON_NAME;
SHOW USER;
SET ECHO ON;
SET FEEDBACK ON;
SET SQLBLANKLINES ON;
WHENEVER SQLERROR EXIT SQL.SQLCODE;

-- BEGIN
--    FOR r IN (
--       SELECT table_name 
--       FROM user_tables 
--       WHERE secondary = 'N' 
--         AND nested = 'NO'
--         AND table_name NOT IN ('REDO_DB', 'REDO_LOG')
--    ) LOOP
--       BEGIN
--          EXECUTE IMMEDIATE 'DROP TABLE "' || r.table_name || '" CASCADE CONSTRAINTS PURGE';
--       EXCEPTION
--          WHEN OTHERS THEN
--             NULL;
--       END;
--    END LOOP;
-- END;
-- /

-- Remove only the BUS tables so this script can be rerun without touching other objects.
BEGIN
    FOR r IN (
        SELECT table_name
        FROM user_tables
        WHERE table_name IN (
            'PROVEEDOR_SUMINISTRA_PIEZA', 'MECANICO_REPARA_BUS',
            'BUS_LLEVAPOR_PASAJERO', 'RUTA_PASAPOR_ESTACION',
            'DEPENDIENTE_TRABAJA_GASOLINERA', 'BONO', 'CARNET',
            'PIEZA', 'PROVEEDOR', 'BUS', 'RUTA', 'ESTACION_TELEFONO',
            'ESTACION', 'GASOLINERA', 'EMPRESA', 'PASAJERO', 'CLIENTE',
            'MECANICO', 'TALLER', 'CONDUCTOR', 'DEPENDIENTE', 'GERENTE',
            'EMPLEADO', 'BILLETE'
        )
    ) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || r.table_name || ' CASCADE CONSTRAINTS PURGE';
    END LOOP;
END;
/


-----------------------------------------------------------------------------------------------
-- STRONG ENTITIES
-----------------------------------------------------------------------------------------------

CREATE TABLE Empleado (
    NumEmpleado NUMBER(10) PRIMARY KEY,
    Nombre varchar2(50) NOT null,
    Salario NUMBER(10) NOT null,
    NumEmpleado_Supervisor NUMBER(10),
    CONSTRAINT fk_empleado_supervisor FOREIGN KEY (NumEmpleado_Supervisor) 
        REFERENCES Empleado(NumEmpleado),
    CONSTRAINT ck_sum_salario CHECK (Salario > 0)
);

CREATE TABLE Gerente (
    NumEmpleado NUMBER(10) PRIMARY KEY,
    CONSTRAINT fk_gerente_empleado FOREIGN KEY (NumEmpleado) 
        REFERENCES Empleado(NumEmpleado) ON DELETE CASCADE
);

CREATE TABLE Dependiente (
    NumEmpleado NUMBER(10) PRIMARY KEY,
    CONSTRAINT fk_dependiente_empleado FOREIGN KEY (NumEmpleado) 
        REFERENCES Empleado(NumEmpleado) ON DELETE CASCADE
);

CREATE TABLE Conductor (
    NumEmpleado NUMBER(10) PRIMARY KEY,
    CONSTRAINT fk_conductor_empleado FOREIGN KEY (NumEmpleado) 
        REFERENCES Empleado(NumEmpleado) ON DELETE CASCADE
);

CREATE TABLE Taller (
    CodTaller NUMBER(10) PRIMARY KEY,
    Telefono VARCHAR2(15) -- its var for +34 and als0 061234567 doesnt turn into 61234567 phone number
);

CREATE TABLE Mecanico (
    NumEmpleado NUMBER(10) PRIMARY KEY,
    CodTaller NUMBER(10) NOT NULL,
    CONSTRAINT fk_mecanico_empleado FOREIGN KEY (NumEmpleado) 
        REFERENCES Empleado(NumEmpleado) ON DELETE CASCADE,
    CONSTRAINT fk_mecanico_taller FOREIGN KEY (CodTaller) 
        REFERENCES Taller(CodTaller)
);


CREATE TABLE Cliente ( -- Desastre Cliente Empresa Pasajero
    IdCliente NUMBER(10) PRIMARY KEY,
    EmailContacto VARCHAR2(100),
    TipoCliente VARCHAR2(10) CHECK (TipoCliente IN ('PASAJERO', 'EMPRESA'))
);

CREATE TABLE Pasajero ( -- Desastre Cliente Empresa Pasajero
    IdCliente NUMBER(10) PRIMARY KEY,
    Nombre VARCHAR2(50),
    Apellidos VARCHAR2(100),
    FechaNacimiento DATE,
    NombreCompleto VARCHAR2(151) GENERATED ALWAYS AS (Nombre || ' ' || Apellidos), -- ESPECIAL DE ORACLE :O
    CONSTRAINT fk_pasajero_cliente FOREIGN KEY (IdCliente) 
        REFERENCES Cliente(IdCliente) ON DELETE CASCADE
    
);

CREATE TABLE Empresa ( -- Desastre Cliente Pasajero
    IdCliente NUMBER(10) PRIMARY KEY,
    NombreEmpresa VARCHAR2(50),
    DireccionFiscal VARCHAR2(100),
    CONSTRAINT fk_empresa_cliente FOREIGN KEY (IdCliente) 
        REFERENCES Cliente(IdCliente) ON DELETE CASCADE
);

CREATE TABLE Gasolinera (
    CodGasolinera NUMBER(10) PRIMARY KEY
);


CREATE TABLE Estacion (
    CodEstacion NUMBER(10) PRIMARY KEY,
    CodGasolinera NUMBER(10) NOT NULL,
    Ubicacion VARCHAR2(100),
    CONSTRAINT fk_ruta_gasolinera FOREIGN KEY (CodGasolinera) 
        REFERENCES Gasolinera(CodGasolinera)
);

CREATE TABLE Estacion_Telefono ( -- Multivalued attribute for Estacion
    CodEstacion NUMBER(10),
    Telefono VARCHAR2(15),
    PRIMARY KEY (CodEstacion, Telefono),
    CONSTRAINT fk_estacion_tfno FOREIGN KEY (CodEstacion) 
        REFERENCES Estacion(CodEstacion) ON DELETE CASCADE
);

CREATE TABLE Ruta ( -- problemas con gasolinerias y  Estacion
    IdRuta NUMBER(10) PRIMARY KEY,
    Origen_Destino VARCHAR2(100) NOT NULL,
    TiempoEstimado NUMBER(5) NOT NULL CHECK (TiempoEstimado >= 0)
);

CREATE TABLE Bus (
    Matricula VARCHAR2(10) PRIMARY KEY,
    Matricula_Sustituto VARCHAR2(10),
    NumEmpleado_Conductor NUMBER(10) NOT NULL,
    Modelo VARCHAR2(50),
    Estado VARCHAR2(20) CHECK (Estado IN ('OPERATIVO', 'EN REPARACION', 'FUERA DE SERVICIO')),
    plaza NUMBER(3) CHECK (plaza > 0),
    CONSTRAINT fk_bus_sustituto FOREIGN KEY (Matricula_Sustituto) 
        REFERENCES Bus(Matricula),
    CONSTRAINT fk_bus_conductor FOREIGN KEY (NumEmpleado_Conductor) 
        REFERENCES Conductor(NumEmpleado)
);

CREATE TABLE Billete (
    CodBillete NUMBER(10) PRIMARY KEY,
    Matricula_Bus VARCHAR2(10) NOT NULL,
    CONSTRAINT fk_billete_bus FOREIGN KEY (Matricula_Bus) 
        REFERENCES Bus(Matricula)
);

CREATE TABLE Proveedor (
    CIFProveedor VARCHAR2(9) PRIMARY KEY,
    NomeProveedor VARCHAR2(50)
);

CREATE TABLE Pieza (
    CodPieza NUMBER(10) PRIMARY KEY,
    Descripcion VARCHAR2(200)
);

-----------------------------------------------------------------------------------------------
-- WEAK ENTITIES
-----------------------------------------------------------------------------------------------

CREATE TABLE Carnet (
    NumEmpleado_Conductor NUMBER(10),
    TipoCarnet VARCHAR2(10),
    PRIMARY KEY (NumEmpleado_Conductor, TipoCarnet),
    CONSTRAINT fk_carnet_conductor FOREIGN KEY (NumEmpleado_Conductor) 
        REFERENCES Conductor(NumEmpleado) ON DELETE CASCADE
);

CREATE TABLE Bono (
    IdCliente NUMBER(10),
    NumBono NUMBER(10),
    FechaCaducidad DATE,
    Saldo NUMBER(10) CHECK (Saldo > 0),
    PRIMARY KEY (IdCliente, NumBono),
    CONSTRAINT fk_bono_cliente FOREIGN KEY (IdCliente) 
        REFERENCES Cliente(IdCliente) ON DELETE CASCADE
);

-----------------------------------------------------------------------------------------------
-- ADDITIONAL RELATIONS
-----------------------------------------------------------------------------------------------

-- RELACIÓN N:1 (GASOLINERA - DEPENDIENTE) /+ GERENTE
CREATE TABLE Dependiente_Trabaja_Gasolinera (
    NumEmpleado_Dependiente NUMBER(10) PRIMARY KEY,
    CodGasolinera NUMBER(10) NOT NULL,
    NumEmpleado_Gerente NUMBER(10), -- Representa la agregacion "Supervisa"
    FechaInicio DATE DEFAULT SYSDATE,
    CONSTRAINT fk_dtg_dependiente FOREIGN KEY (NumEmpleado_Dependiente) 
        REFERENCES Dependiente(NumEmpleado) ON DELETE CASCADE,
    CONSTRAINT fk_dtg_gasolinera FOREIGN KEY (CodGasolinera) 
        REFERENCES Gasolinera(CodGasolinera),
    CONSTRAINT fk_dtg_gerente FOREIGN KEY (NumEmpleado_Gerente) 
        REFERENCES Gerente(NumEmpleado)
);

-- RELACIÓN N:M (Ruta - Estación)
CREATE TABLE Ruta_PasaPor_Estacion (
    IdRuta NUMBER(10),
    CodEstacion NUMBER(10),
    Fecha DATE DEFAULT SYSDATE,
    PRIMARY KEY (IdRuta, CodEstacion, Fecha),
    CONSTRAINT fk_pasa_estacion FOREIGN KEY (CodEstacion) REFERENCES Estacion(CodEstacion),
    CONSTRAINT fk_pasa_ruta FOREIGN KEY (IdRuta) REFERENCES Ruta(IdRuta)
);

-- RELACIÓN N:M (Bus - Ruta - Pasajero)
CREATE TABLE Bus_LlevaPor_Pasajero (
    IdViaje NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Matricula VARCHAR2(10) NOT NULL,
    IdRuta NUMBER(10) NOT NULL,
    IdCliente NUMBER(10) NOT NULL,
    Hora TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    
    CONSTRAINT fk_lleva_bus FOREIGN KEY (Matricula) REFERENCES Bus(Matricula),
    CONSTRAINT fk_lleva_ruta FOREIGN KEY (IdRuta) REFERENCES Ruta(IdRuta),
    CONSTRAINT fk_lleva_pasajero FOREIGN KEY (IdCliente) REFERENCES Pasajero(IdCliente) ON DELETE CASCADE,
    -- Restricción UNIQUE para evitar que el mismo pasajero compre dos billetes idénticos
    CONSTRAINT uk_viaje_cliente UNIQUE (Matricula, IdRuta, IdCliente, Hora)
);

-- RELACIÓN N:M (Mecánico - Bus)
CREATE TABLE Mecanico_Repara_Bus (
    NumEmpleado_Mecanico NUMBER(10),
    Matricula_Bus VARCHAR2(10),
    FechaReparacion TIMESTAMP default SYSTIMESTAMP,
    PRIMARY KEY (NumEmpleado_Mecanico, Matricula_Bus, FechaReparacion),
    CONSTRAINT fk_repara_mecanico FOREIGN KEY (NumEmpleado_Mecanico) REFERENCES Mecanico(NumEmpleado),
    CONSTRAINT fk_repara_bus FOREIGN KEY (Matricula_Bus) REFERENCES Bus(Matricula)
);

-- RELACIÓN TERNARIA (Proveedor - Pieza - Taller)
CREATE TABLE Proveedor_Suministra_Pieza (
    CIFProveedor VARCHAR2(9),
    CodPieza NUMBER(10),
    CodTaller NUMBER(10),
    Precio NUMBER(10),
    FechaSuministro DATE default SYSTIMESTAMP,
    Cantidad NUMBER(5),
    PRIMARY KEY (CIFProveedor, CodPieza, CodTaller, FechaSuministro),
    CONSTRAINT fk_sum_proveedor FOREIGN KEY (CIFProveedor) REFERENCES Proveedor(CIFProveedor),
    CONSTRAINT fk_sum_pieza FOREIGN KEY (CodPieza) REFERENCES Pieza(CodPieza),
    CONSTRAINT fk_sum_taller FOREIGN KEY (CodTaller) REFERENCES Taller(CodTaller),
    CONSTRAINT ck_sum_precio CHECK (Precio > 0),
    constraint ck_sum_cantidad CHECK (Cantidad > 0)
);




------------------------------------------------------------------------------
-- VISTAS OBLIGATORIAS
------------------------------------------------------------------------------

-- Vista No Actualizable (Agregada)
CREATE OR REPLACE VIEW v_resumen_viajes_bus AS
SELECT b.Matricula, r.IdRuta, COUNT(l.IdCliente) AS Total_Pasajeros
FROM Bus b
JOIN Bus_LlevaPor_Pasajero l ON b.Matricula = l.Matricula
JOIN Ruta r ON l.IdRuta = r.IdRuta
GROUP BY b.Matricula, r.IdRuta;

-- Vista Actualizable
CREATE OR REPLACE VIEW v_pasajeros_activos AS
SELECT IdCliente, Nombre, Apellidos, FechaNacimiento
FROM Pasajero;

------------------------------------------------------------------------------
-- POBLADO DE DATOS VÁLIDOS (PRUEBA DE ÉXITO)
------------------------------------------------------------------------------

INSERT INTO Empleado (NumEmpleado, Nombre, Salario, NumEmpleado_Supervisor) 
VALUES (1, 'Carlos Gómez', 2500, NULL);

INSERT INTO Conductor (NumEmpleado) VALUES (1);

INSERT INTO Carnet (NumEmpleado_Conductor, TipoCarnet) VALUES (1, 'D1');

INSERT INTO Gasolinera (CodGasolinera) VALUES (10);

INSERT INTO Ruta (IdRuta, Origen_Destino, TiempoEstimado) 
VALUES (101, 'Santiago - A Coruña', 45);

INSERT INTO Bus (Matricula, Matricula_Sustituto, NumEmpleado_Conductor, Modelo, Estado, plaza) 
VALUES ('1234-ABC', NULL, 1, 'Volvo 9700', 'OPERATIVO', 55);

INSERT INTO Cliente (IdCliente, EmailContacto, TipoCliente) 
VALUES (50, 'juan.perez@email.com', 'PASAJERO');

INSERT INTO Pasajero (IdCliente, Nombre, Apellidos, FechaNacimiento) 
VALUES (50, 'Juan', 'Pérez García', TO_DATE('1998-05-15', 'YYYY-MM-DD'));

INSERT INTO Bus_LlevaPor_Pasajero (Matricula, IdRuta, IdCliente, Hora) 
VALUES ('1234-ABC', 101, 50, TO_TIMESTAMP('2026-10-01 08:30:00', 'YYYY-MM-DD HH24:MI:SS'));

COMMIT;

------------------------------------------------------------------------------
-- PRUEBAS DE COMPROBACIÓN RECHAZADAS (VALIDACIÓN DE RESTRICCIONES PL/SQL)
------------------------------------------------------------------------------

-- Prueba 1: Debe fallar por TipoCliente inválido en el CHECK
BEGIN
    INSERT INTO Cliente (IdCliente, EmailContacto, TipoCliente) 
    VALUES (99, 'error@test.com', 'INVALIDO');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error esperado (CHECK TipoCliente): ' || SQLERRM);
END;
/

-- Prueba 2: Debe fallar por Precio negativo en Proveedor_Suministra_Pieza
BEGIN
    INSERT INTO Proveedor (CIFProveedor, NomeProveedor) VALUES ('A12345678', 'Repuestos Bus');
    INSERT INTO Pieza (CodPieza, Descripcion) VALUES (500, 'Filtro de Aceite');
    INSERT INTO Taller (CodTaller) VALUES (1);
    INSERT INTO Proveedor_Suministra_Pieza (CIFProveedor, CodPieza, CodTaller, Precio, FechaSuministro, Cantidad) 
    VALUES ('A12345678', 500, 1, -10, SYSDATE, 5);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error esperado (CHECK Precio positivo): ' || SQLERRM);
END;
/


------------------------------------------------------------------------------
-- Tablespaces de cada tipo de datos
------------------------------------------------------------------------------


-- Tablespace para los datos de las tablas
CREATE SMALLFILE TABLESPACE ts_bus_datos 
DATAFILE 'ts_bus_datos' SIZE 32M -- Initial Weight
AUTOEXTEND ON NEXT 8M MAXSIZE 128M -- Extending Weight/Max Weight
EXTENT MANAGEMENT LOCAL AUTOALLOCATE --
SEGMENT SPACE MANAGEMENT AUTO;

-- Tablespace exclusivo para los índices
CREATE SMALLFILE TABLESPACE ts_bus_indices 
DATAFILE 'ts_bus_indices' SIZE 32M 
AUTOEXTEND ON NEXT 8M MAXSIZE 128M   
EXTENT MANAGEMENT LOCAL AUTOALLOCATE 
SEGMENT SPACE MANAGEMENT AUTO;

-- Tablespace para datos históricos o particiones
CREATE SMALLFILE TABLESPACE ts_bus_hist 
DATAFILE 'ts_bus_hist' SIZE 32M 
AUTOEXTEND ON NEXT 8M MAXSIZE 128M   
EXTENT MANAGEMENT LOCAL AUTOALLOCATE 
SEGMENT SPACE MANAGEMENT AUTO;

