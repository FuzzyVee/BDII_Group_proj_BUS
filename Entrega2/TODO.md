# Plan de Trabajo y Guía de Tareas para la Entregable 2 (P2 BDII)

**Equipo de Trabajo:** BDII5_BDII_5::BUS  
**Dominio:** Sistema de Gestión de Red de Autobuses  
**Asignatura:** Bases de Datos II - Grado en Ingeniería Informática  
**Objetivo:** Guía clara paso a paso para completar la memoria técnica y los scripts SQL de la P2 en Oracle 26ai.

---

## 1. Fase Previa: Preparación del Entorno Local y Conectividad

- [ ] **Tarea 1.1: Iniciar la base de datos Oracle 26ai en Docker**
  - [ ] Abrir la terminal en la carpeta del proyecto.
  - [ ] Ejecutar `docker compose up -d` (o `docker compose up --build --force-recreate` si hay errores).
  - [ ] Obtener captura de pantalla de la terminal con el contenedor activo (`Up / Running`).

- [ ] **Tarea 1.2: Conexión de todos los integrantes a la PDB de trabajo**
  - [ ] Conectarse desde cliente SQL (DBeaver, SQL Developer o VS Code) con usuario/clave a la PDB.
  - [ ] Ejecutar la consulta de verificación:
    ```sql
    SELECT SYS_CONTEXT('USERENV','SESSION_USER') AS usuario, 
           SYS_CONTEXT('USERENV','CON_NAME') AS pdb FROM dual;
    ```
  - [ ] Confirmar que el usuario activo y la PDB corresponden al entorno del grupo.

---

## 2. Sección A: Análisis de Sistemas y Necesidades de Uso

- [ ] **Tarea 2.1: Definir los subsistemas del proyecto BUS**
  - [ ] Completar la tabla de subsistemas en el informe identificando:
    - [ ] Terminales de Venta de Billetes en Estaciones.
    - [ ] Panel de Gestión de Rutas y Conductores.
    - [ ] Taller de Mantenimiento de Mecánicos.

- [ ] **Tarea 2.2: Estimar la carga de trabajo y requisitos de disponibilidad**
  - [ ] Rellenar la tabla de estimación de carga indicando:
    - [ ] Usuarios concurrentes esperados en hora punta.
    - [ ] Crecimiento estimado a 1 y 3 años (filas en viajes, billetes y reparaciones).
    - [ ] Objetivos de recuperación RPO (tiempo de datos perdibles) y RTO (tiempo máximo de parada).

---

## 3. Sección B: Organización Física en Tablespaces y Cuotas de Almacenamiento

- [ ] **Tarea 3.1: Crear los Tablespaces del proyecto (Rol Administrador / SYS)**
  - [ ] Ejecutar el DDL de creación de `ts_bus_datos`:
    ```sql
    CREATE SMALLFILE TABLESPACE ts_bus_datos 
    DATAFILE 'ts_bus_datos' SIZE 32M 
    AUTOEXTEND ON NEXT 8M MAXSIZE 128M   
    EXTENT MANAGEMENT LOCAL AUTOALLOCATE 
    SEGMENT SPACE MANAGEMENT AUTO;
    ```
  - [ ] Ejecutar el DDL de creación de `ts_bus_indices`:
    ```sql
    CREATE SMALLFILE TABLESPACE ts_bus_indices 
    DATAFILE 'ts_bus_indices' SIZE 32M 
    AUTOEXTEND ON NEXT 8M MAXSIZE 128M   
    EXTENT MANAGEMENT LOCAL AUTOALLOCATE 
    SEGMENT SPACE MANAGEMENT AUTO;
    ```
  - [ ] Ejecutar el DDL de creación de `ts_bus_hist`:
    ```sql
    CREATE SMALLFILE TABLESPACE ts_bus_hist 
    DATAFILE 'ts_bus_hist' SIZE 32M 
    AUTOEXTEND ON NEXT 8M MAXSIZE 128M   
    EXTENT MANAGEMENT LOCAL AUTOALLOCATE 
    SEGMENT SPACE MANAGEMENT AUTO;
    ```

- [ ] **Tarea 3.2: Asignar permisos y cuotas de espacio a los usuarios**
  - [ ] Otorgar permiso `GRANT CREATE TABLE TO alumno;`.
  - [ ] Asignar cuota `ALTER USER alumno QUOTA 64M ON ts_bus_datos;`.
  - [ ] Asignar cuota `ALTER USER alumno QUOTA 64M ON ts_bus_indices;`.
  - [ ] Asignar cuota `ALTER USER alumno QUOTA 64M ON ts_bus_hist;`.

- [ ] **Tarea 3.3: Adaptar las sentencias DDL del script BUS.md**
  - [ ] Añadir a cada `CREATE TABLE`: `SEGMENT CREATION IMMEDIATE TABLESPACE ts_bus_datos`.
  - [ ] Añadir a cada `CREATE INDEX`: `TABLESPACE ts_bus_indices`.

- [ ] **Tarea 3.4: Realizar la auditoría de espacio Antes y Después de la carga**
  - [ ] **Antes de cargar:** Ejecutar la consulta en `USER_SEGMENTS` con tablas vacías:
    ```sql
    SELECT tablespace_name, segment_name, segment_type, bytes/1024 AS kib_usados 
    FROM user_segments;
    ```
  - [ ] Guardar captura de pantalla de `USER_SEGMENTS` con las tablas vacías.
  - [ ] **Carga de datos:** Ejecutar los `INSERT` de datos de prueba y hacer `COMMIT;`.
  - [ ] **Después de cargar:** Volver a consultar `USER_SEGMENTS` y `USER_EXTENTS`.
  - [ ] Guardar captura de pantalla de `USER_SEGMENTS` y `USER_EXTENTS` tras la carga.
  - [ ] Completar la tabla comparativa de bytes y bloques en el informe.

---

## 4. Sección C: Particionado de Tablas e Índices para Datos Históricos

- [ ] **Tarea 4.1: Seleccionar la tabla candidata a particionado**
  - [ ] Seleccionar la tabla de mayor volumen de inserción (ejemplo: `Viaje` o `Bus_LlevaPor_Pasajero`).

- [ ] **Tarea 4.2: Crear la tabla particionada en Oracle**
  - [ ] Ejecutar el DDL de creación de la tabla particionada por rango de fechas:
    ```sql
    CREATE TABLE Viaje_Particionado (
        id_viaje NUMBER,
        matricula VARCHAR2(10),
        fecha_salida DATE,
        precio NUMBER(6,2)
    )
    PARTITION BY RANGE (fecha_salida) (
        PARTITION p_2024 VALUES LESS THAN (TO_DATE('2025-01-01', 'YYYY-MM-DD')) TABLESPACE ts_bus_datos,
        PARTITION p_2025 VALUES LESS THAN (TO_DATE('2026-01-01', 'YYYY-MM-DD')) TABLESPACE ts_bus_datos,
        PARTITION p_historico VALUES LESS THAN (MAXVALUE) TABLESPACE ts_bus_hist
    );
    ```

- [ ] **Tarea 4.3: Probar la reubicación de datos y reconstrucción de índices (MOVE y REBUILD)**
  - [ ] Ejecutar `ALTER TABLE Viaje MOVE TABLESPACE ts_bus_hist UPDATE INDEXES;`.
  - [ ] Ejecutar `ALTER INDEX idx_viaje_fecha REBUILD TABLESPACE ts_bus_hist;`.
  - [ ] Guardar captura de pantalla demostrando que la tabla y el índice han sido trasladados y permanecen en estado activo (`VALID`).

---

## 5. Sección D: Configuración y Propuesta de Memoria (SGA y PGA)

- [ ] **Tarea 5.1: Consultar la asignación de memoria actual de la instancia**
  - [ ] Ejecutar la consulta SQL de parámetros de memoria:
    ```sql
    SELECT name, value/1048576 AS mbytes 
    FROM v$parameter 
    WHERE name IN ('sga_target', 'pga_aggregate_target', 'shared_pool_size', 'db_cache_size');
    ```
  - [ ] Guardar captura de la salida con los valores en Megabytes.

- [ ] **Tarea 5.2: Documentar la propuesta de ajuste de memoria**
  - [ ] Completar la tabla comparativa indicando si se modifican o mantienen los valores de SGA (Buffer Cache y Shared Pool) y PGA según la carga definida en la Sección A.

---

## 6. Sección E: Registros de Rediseño (Redo Log y Archive Log)

- [ ] **Tarea 6.1: Consultar los grupos de Redo Log y el modo de operación**
  - [ ] Consultar el estado de los grupos de Redo Log: `SELECT group#, members, bytes/1048576 AS mbytes, status FROM v$log;`.
  - [ ] Consultar la ubicación de los archivos físicos: `SELECT group#, member FROM v$logfile;`.
  - [ ] Consultar el modo de archivo de la base de datos: `SELECT log_mode FROM v$database;`.
  - [ ] Guardar capturas de las consultas a `v$log`, `v$logfile` y `v$database`.

- [ ] **Tarea 6.2: Redactar la justificación de tolerancia a fallos**
  - [ ] Justificar en el informe la necesidad de contar con al menos 2 miembros multiplexados por grupo.
  - [ ] Explicar por qué el entorno de producción debe operar en modo `ARCHIVELOG` para garantizar recuperaciones ante fallos de disco.

---

## 7. Sección F: Seguridad, Cuotas de Usuario y Control de Conexiones

- [ ] **Tarea 7.1: Consultar el uso de cuota del usuario**
  - [ ] Ejecutar la consulta en `USER_TS_QUOTAS`:
    ```sql
    SELECT tablespace_name, bytes/1048576 AS mib_usados, max_bytes/1048576 AS mib_limite 
    FROM user_ts_quotas;
    ```
  - [ ] Guardar captura del consumo de cuota actual.

- [ ] **Tarea 7.2: Provocar un fallo controlado por superación de cuota**
  - [ ] Reducir la cuota del usuario: `ALTER USER alumno QUOTA 1K ON ts_bus_datos;`.
  - [ ] Ejecutar sentencias `INSERT` adicionales hasta forzar el error `ORA-01536: space quota exceeded for tablespace`.
  - [ ] Guardar captura de pantalla con el mensaje de error ORA devuelto por Oracle.
  - [ ] Restaurar la cuota normal del usuario: `ALTER USER alumno QUOTA 64M ON ts_bus_datos;`.

---

## 8. Confección del Informe PDF y Entrega en Moovi

- [ ] **Tarea 8.1: Rellenar la plantilla oficial (Plantilla_Entrega_Practica_Oracle.docx)**
  - [ ] Completar la portada con el equipo `BDII5_BDII_5::BUS`, temática `Autobuses`, fecha y datos de todos los integrantes (Nombre, Apellidos y DNI).
  - [ ] Insertar todas las explicaciones teóricas y tablas comparativas de las Secciones A a F.
  - [ ] Adjuntar las capturas de pantalla de los comandos SQL y salidas del diccionario de datos.
  - [ ] Incluir la hoja de firmas escaneada y firmada por todos los miembros del equipo.

- [ ] **Tarea 8.2: Preparación del empaquetado ZIP y entrega individual**
  - [ ] Generar la memoria técnica final exportada en formato PDF (ejemplo: `P2_ADMON_BDII5_BUS.pdf`).
  - [ ] Guardar el script SQL ejecutable completo (ejemplo: `P2_ADMON_BUS.sql`).
  - [ ] Comprimir ambos archivos en un único paquete ZIP.
  - [ ] Confirmar que **cada miembro del equipo** realiza la subida del archivo ZIP individualmente a Moovi antes del plazo límite.

- [ ] **Tarea 8.3: Preparación de la defensa oral individual**
  - [ ] Repasar la diferencia entre la definición DDL y el segmento físico en `USER_SEGMENTS`.
  - [ ] Explicar por qué `ALTER TABLE MOVE` deja los índices en estado `UNUSABLE` y requiere un `REBUILD`.
  - [ ] Saber interpretar las extensiones y bloques mostrados en `USER_EXTENTS` y `USER_TS_QUOTAS`.
