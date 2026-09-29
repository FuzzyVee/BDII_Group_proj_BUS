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