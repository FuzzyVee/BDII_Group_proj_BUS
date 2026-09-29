-- ===========================================================================================
-- SCRIPT DE CREACION DAS TABLAS E RELACIONS EN ORACLE 26ai
-- PROYECTO BDII [[BUSSESS]]
-- ===========================================================================================

SET ECHO ON;
SET FEEDBACK ON;

-- Primero se Eliminan las Tablas en Orden inverso a la dependencia que tengan --
DROP TABLE Proveedor_Suministra_Pieza CASCADE CONSTRAINTS;
DROP TABLE Mecanico_Repara_Bus CASCADE CONSTRAINTS;
DROP TABLE Bus_LlevaPor_Pasajero CASCADE CONSTRAINTS;
DROP TABLE Ruta_PasaPor_Estacion CASCADE CONSTRAINTS;
DROP TABLE Bono CASCADE CONSTRAINTS;
DROP TABLE Carnet CASCADE CONSTRAINTS;
DROP TABLE Pieza CASCADE CONSTRAINTS;
DROP TABLE Proveedor CASCADE CONSTRAINTS;
DROP TABLE Bus CASCADE CONSTRAINTS;
DROP TABLE Ruta CASCADE CONSTRAINTS; 
DROP TABLE Estacion_Telefono CASCADE CONSTRAINTS; -- its THE MULTIVALUATED ONE
DROP TABLE Estacion CASCADE CONSTRAINTS;
DROP TABLE Gasolinera CASCADE CONSTRAINTS;
DROP TABLE Empresa CASCADE CONSTRAINTS;
DROP TABLE Pasajero CASCADE CONSTRAINTS;
DROP TABLE Cliente CASCADE CONSTRAINTS;
DROP TABLE Mecanico CASCADE CONSTRAINTS;
DROP TABLE Taller CASCADE CONSTRAINTS;
DROP TABLE Conductor CASCADE CONSTRAINTS;
DROP TABLE Dependiente CASCADE CONSTRAINTS;
DROP TABLE Gerente CASCADE CONSTRAINTS;
DROP TABLE Empleado CASCADE CONSTRAINTS;


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
    CodTaller NUMBER(10) PRIMARY KEY
);

CREATE TABLE Mecanico (
    NumEmpleado NUMBER(10) PRIMARY KEY,
    CodTaller NUMBER(10) NOT NULL,
    CONSTRAINT fk_mecanico_empleado FOREIGN KEY (NumEmpleado) 
        REFERENCES Empleado(NumEmpleado) ON DELETE CASCADE,
    CONSTRAINT fk_mecanico_taller FOREIGN KEY (CodTaller) 
        REFERENCES Taller(CodTaller)
);

CREATE TABLE Cliente (
    IdCliente NUMBER(10) PRIMARY KEY,
    TipoCliente VARCHAR2(10) CHECK (TipoCliente IN ('PASAJERO', 'EMPRESA'))
);

CREATE TABLE Pasajero (
    DNI VARCHAR2(9) PRIMARY KEY,
    Nombre VARCHAR2(50),
    Apellidos VARCHAR2(100),
    IdCliente NUMBER(10) UNIQUE NOT NULL,
    CONSTRAINT fk_pasajero_cliente FOREIGN KEY (IdCliente) 
        REFERENCES Cliente(IdCliente) ON DELETE CASCADE
);

CREATE TABLE Empresa (
    CIF VARCHAR2(9) PRIMARY KEY,
    IdCliente NUMBER(10) UNIQUE NOT NULL,
    CONSTRAINT fk_empresa_cliente FOREIGN KEY (IdCliente) 
        REFERENCES Cliente(IdCliente) ON DELETE CASCADE
);

CREATE TABLE Gasolinera (
    CodGasolinera NUMBER(10) PRIMARY KEY
);


CREATE TABLE Estacion (
    CodEstacion NUMBER(10) PRIMARY KEY,
    CodGasolinera NUMBER(10) NOT NULL,
    CONSTRAINT fk_ruta_gasolinera FOREIGN KEY (CodGasolinera) 
        REFERENCES Gasolinera(CodGasolinera)
);

CREATE TABLE Estacion_Telefono (
CodEstacion NUMBER(10),
    Telefono VARCHAR2(15),
    PRIMARY KEY (CodEstacion, Telefono),
    CONSTRAINT fk_estacion_tfno FOREIGN KEY (CodEstacion) 
        REFERENCES Estacion(CodEstacion) ON DELETE CASCADE
);

CREATE TABLE Ruta ( -- problemas con gasolinerias y  Estacion
    IdRuta NUMBER(10) PRIMARY KEY
);

CREATE TABLE Bus (
    Matricula VARCHAR2(10) PRIMARY KEY,
    Matricula_Sustituto VARCHAR2(10),
    NumEmpleado_Conductor NUMBER(10) NOT NULL,
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
    NomeEmpresa VARCHAR2(50)
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
    PRIMARY KEY (IdCliente, NumBono),
    CONSTRAINT fk_bono_cliente FOREIGN KEY (IdCliente) 
        REFERENCES Cliente(IdCliente) ON DELETE CASCADE
);

-----------------------------------------------------------------------------------------------
-- RELATIONS
-----------------------------------------------------------------------------------------------

-- RELACIÓN N:M (Ruta - Estación)
CREATE TABLE Ruta_PasaPor_Estacion (
    IdRuta NUMBER(10),
    CodEstacion NUMBER(10),
    Fecha DATE,
    PRIMARY KEY (IdRuta, CodEstacion, Fecha),
    CONSTRAINT fk_pasa_ruta FOREIGN KEY (IdRuta) REFERENCES Ruta(IdRuta),
    CONSTRAINT fk_pasa_estacion FOREIGN KEY (CodEstacion) REFERENCES Estacion(CodEstacion)
);

-- RELACIÓN N:M (Bus - Ruta - Pasajero)
CREATE TABLE Bus_LlevaPor_Pasajero (
    Matricula VARCHAR2(10),
    IdRuta NUMBER(10),
    DNI_Pasajero VARCHAR2(9) UNIQUE,
    Hora TIMESTAMP,
    PRIMARY KEY (Matricula, IdRuta, DNI_Pasajero, Hora),
    CONSTRAINT fk_lleva_bus FOREIGN KEY (Matricula) REFERENCES Bus(Matricula),
    CONSTRAINT fk_lleva_ruta FOREIGN KEY (IdRuta) REFERENCES Ruta(IdRuta),
    CONSTRAINT fk_lleva_pasajero FOREIGN KEY (DNI_Pasajero) REFERENCES Pasajero(DNI)
);

-- RELACIÓN N:M (Mecánico - Bus)
CREATE TABLE Mecanico_Repara_Bus (
    NumEmpleado_Mecanico NUMBER(10),
    Matricula_Bus VARCHAR2(10),
    FechaReparacion DATE,
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
    FechaSuministro DATE,
    Cantidad NUMBER(5),
    PRIMARY KEY (CIFProveedor, CodPieza, CodTaller, FechaSuministro),
    CONSTRAINT fk_sum_proveedor FOREIGN KEY (CIFProveedor) REFERENCES Proveedor(CIFProveedor),
    CONSTRAINT fk_sum_pieza FOREIGN KEY (CodPieza) REFERENCES Pieza(CodPieza),
    CONSTRAINT fk_sum_taller FOREIGN KEY (CodTaller) REFERENCES Taller(CodTaller),
    CONSTRAINT ck_sum_precio CHECK (Precio > 0),
    constraint ck_sum_cantidad CHECK (Cantidad > 0)
);