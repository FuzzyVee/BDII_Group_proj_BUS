# Memoria P1 IU
<div style="text-align: right; margin-bottom: -12px;">
  <sup style="font-size: 0.75em; color: #888;">Heads up for future this might mix three languagues so TODO: translate</sup>
---

<div style="text-align: right; margin-bottom: 12px;">
  <span style="font-size: 0.75em; background: #e0e0e0; color: #333; padding: 2px 8px; border-radius: 10px; font-weight: bold;">
     2026-10-26
  </span>
</div>
</div>

**Equipo de Trabajo:** BDII5\_BDII\_5::BUS

---

## 1\. Configuración del Entorno y Despliegue (Trabajo de Equipo)

* [x] Iniciar la instancia local de Oracle 26ai mediante Docker Compose (`docker compose up`).
* [ ] Verificar la conectividad de todos los integrantes del grupo a la PDB de trabajo.
* [x] Comprobar los parámetros del contenedor y la ruta de almacenamiento automático OMF (`db_create_file_dest`).

---

## 2\. Administración de Tablespaces y Cuotas (Rol Administrador / SYS)

* [x] Diseñar la distribución física de almacenamiento para los datos del proyecto del grupo.
* [x] Ejecutar la creación de los tres tablespaces principales con gestión local y espacio automático:
  * `ts_bus_datos`: Destinado a albergar los datos de las tablas del dominio.
  * `ts_bus_indices`: Destinado a aislar los índices de la base de datos.
  * `ts_bus_hist`: Reservado para datos históricos y particiones.
* [x] Establecer los límites de espacio (`SIZE`, `AUTOEXTEND ON`, `MAXSIZE`) requeridos por el enunciado.
* [ ] Conceder privilegios de creación y asignar cuotas de almacenamiento explícitas (`QUOTA`) en los tres tablespaces para las cuentas de los miembros del grupo.

---

## 3\. Asignación Física de Objetos y Poblado (Rol Usuario)

* [ ] Revisar de forma conjunta las sentencias DDL del proyecto para asociar cada tabla a `ts_bus_datos` con la cláusula `TABLESPACE` y `SEGMENT CREATION IMMEDIATE`.
* [ ] Asegurar que la totalidad de los índices del sistema se creen de forma independiente en `ts_bus_indices`.
* [ ] Cargar los datos de prueba iniciales mediante consultas `INSERT` y consolidar la transacción con `COMMIT`.

---

## 4\. Reubicación de Segmentos y Reconstrucción de Índices

* [ ] Ejecutar la reubicación en caliente de una tabla o conjunto de registros históricos hacia el tablespace `ts_bus_hist` mediante `ALTER TABLE ... MOVE TABLESPACE ... UPDATE INDEXES`.
* [ ] Reconstruir los índices afectados para garantizar su validez y disponibilidad mediante `ALTER INDEX ... REBUILD TABLESPACE ...`.
* [ ] Validar la correcta ejecución de operaciones de particionado si el diseño del grupo así lo requiere.

---

## 5\. Auditoría e Inspección del Diccionario de Datos

* [ ] Consultar la vista `USER_TS_QUOTAS` para verificar el consumo de cuota por parte del equipo.
* [ ] Analizar la ocupación física real en bytes y bloques de cada objeto consultando `USER_SEGMENTS`.
* [ ] Inspeccionar la distribución de extensiones y archivos de datos en `USER_EXTENTS`.
* [ ] Emplear las funciones del paquete `DBMS_ROWID` para descodificar la ubicación física (archivo relativo, bloque y fila) de registros de prueba.

---

## 6\. Redacción de la Memoria Técnica en PDF

* [ ] Incluir la portada oficial con el código del equipo (`BDII5_BDII_5::BUS`), temática asignada, fecha y la relación completa de integrantes con Nombre, Apellidos y DNI.
* [ ] Redactar la justificación teórica sobre la relación entre la definición lógica de los objetos y su almacenamiento en segmentos físicos.
* [ ] Adjuntar las capturas de pantalla que acrediten la ejecución de los comandos de administración, reubicación y consultas al diccionario de datos.
* [ ] Incorporar el documento final de hoja de firmas firmado por todos los miembros del equipo.

---

## 7\. Empaquetado, Entrega y Defensa Individual

* [ ] Comprimir en un único archivo ZIP la Memoria en PDF y el script SQL de administración desarrollado por el grupo.
* [ ] Confirmar que cada uno de los integrantes del equipo suba el archivo ZIP individualmente a la plataforma Moovi antes del plazo límite.
* [ ] Preparar de forma individual la defensa oral del trabajo, garantizando que cada miembro sea capaz de explicar las decisiones de diseño físico del equipo y el comportamiento del diccionario de datos.

--- 

<br></br>

<div style="border-left: 3px solid #d26363; padding-left: 14px; margin: 15px 0;">
  <div style="margin-bottom: 12px;">
    <span style="color: #f277ac; font-weight: bold; font-family: monospace; font-size: 0.9rem;">[4:30]</span> 
    <span style="color: #333; font-weight: 600;">Inicio del Proyecto y elección de Alpine</span>
    <p style="margin: 4px 0 0; color: #666; font-size: 0.9rem;">Descartado Ubuntu por ligereza; configurando entorno base.</p>
  </div>
<div> -->
