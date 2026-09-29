CREATE TABLE Empleado (
    NumEmpleado NUMBER(10) PRIMARY KEY,
    NumEmpleado_Supervisor NUMBER(10),
    CONSTRAINT fk_empleado_supervisor FOREIGN KEY (NumEmpleado_Supervisor) 
        REFERENCES Empleado(NumEmpleado)
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
    CodEstacion NUMBER(10) PRIMARY KEY
);

CREATE TABLE Estacion_Telefono (
    CodEstacion NUMBER(10),
    Telefono VARCHAR2(15),
    PRIMARY KEY (CodEstacion, Telefono),
    CONSTRAINT fk_estacion_tfno FOREIGN KEY (CodEstacion) 
        REFERENCES Estacion(CodEstacion) ON DELETE CASCADE
);

CREATE TABLE Ruta (
    IdRuta NUMBER(10) PRIMARY KEY,
    CodGasolinera NUMBER(10) NOT NULL,
    CONSTRAINT fk_ruta_gasolinera FOREIGN KEY (CodGasolinera) 
        REFERENCES Gasolinera(CodGasolinera)
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
    CIFProveedor VARCHAR2(9) PRIMARY KEY
);

CREATE TABLE Pieza (
    CodPieza NUMBER(10) PRIMARY KEY
);