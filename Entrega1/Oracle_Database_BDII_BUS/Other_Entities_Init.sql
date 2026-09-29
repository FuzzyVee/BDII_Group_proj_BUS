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
    DNI_Pasajero VARCHAR2(9),
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
    CONSTRAINT fk_sum_taller FOREIGN KEY (CodTaller) REFERENCES Taller(CodTaller)
);