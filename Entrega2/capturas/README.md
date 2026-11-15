# Capturas y evidencias de la P2

Este directorio contiene el **guion reproducible** para obtener las capturas que
pide la plantilla de la P2. No se incluyen imágenes inventadas: las capturas
deben salir de una instancia Oracle real con el esquema ya cargado.

## 1. Requisitos

- Docker con el contenedor `oracle-26ai` levantado.
- Cliente `sqlplus` (incluido en la imagen de Oracle) o SQL Developer/DBeaver.
- Esquema creado con `Entrega2/Oracle_Database_BDII_BUS/init-scripts/`.

Conexiones usadas por los scripts:

| Rol | Cadena de conexión |
|---|---|
| Administrador | `sys/Oracle12345@//localhost:15211/BDII as sysdba` |
| Usuario del proyecto | `ALUMNO/ALUMNO@//localhost:15211/BDII` |

Se pueden cambiar con las variables `ORACLE_SYS_CONNECT` y
`ORACLE_CONNECT`.

## 2. Ejecución automática

```bash
cd Entrega2/capturas
chmod +x run_capturas.sh
./run_capturas.sh
```

El script:

1. Comprueba que el puerto `15211` responde.
2. Ejecuta cada consulta con SQL*Plus.
3. Guarda la salida en `salida/NN_nombre.txt` y una versión HTML en
   `salida/NN_nombre.html`.

Para convertir el HTML a PNG (opcional, requiere `wkhtmltoimage` o Chromium):

```bash
./run_capturas.sh --png
```

Si no hay conversor instalado, abra cada `.html` en el navegador y use la
captura de pantalla del sistema. También puede ejecutar las consultas en
DBeaver/SQL Developer y capturar la pestaña de resultados.

## 3. Capturas que exige la plantilla

| Nº | Archivo | Qué debe verse | Sección de la memoria |
|---|---|---|---|
| 01 | `01_entorno.sql` | Usuario, PDB, versión de Oracle y `db_create_file_dest`. | Entorno |
| 02 | `02_tablespaces.sql` | Los cuatro tablespaces (`datos`, `indices`, `hist`, `BLOB`), datafiles, autoextend y cuotas. | B. Tablespaces |
| 03 | `03_lobs.sql` | `USER_LOBS` con `DOCUMENTO_EMPLEADO` y `DOCUMENTO_BUS` en `TS_BUS_BLOB`, más sus segmentos. | B. Tablespaces |
| 04 | `04_carga.sql` | Documentos cargados, tamaño real de cada BLOB y extensiones del LOB. | B. Carga y comparación |
| 05 | `05_particionado.sql` | Particiones de `VIAJE_PARTICIONADO`, tabla e índices en estado `VALID`. | C. Particionado |
| 06 | `06_memoria.sql` | `SGA_TARGET`, `PGA_AGGREGATE_TARGET`, `shared_pool_size`, `db_cache_size` y estadísticas PGA. | D. SGA/PGA |
| 07 | `07_redo.sql` | Grupos de redo, miembros, tamaño, estado, `log_mode` y destinos de archivo. | E. Redo/Archive |
| 08 | `08_cuotas.sql` | Cuotas de `ALUMNO`, perfil y límites de sesión. | F. Seguridad y cuotas |

Además, para la prueba de cuota agotada (ORA-01536):

```sql
-- Como SYS
ALTER USER ALUMNO QUOTA 1K ON ts_bus_datos;
-- Como ALUMNO: insertar hasta superar la cuota y capturar el ORA-01536
-- Restaurar después:
ALTER USER ALUMNO QUOTA UNLIMITED ON ts_bus_datos;
```

Capture también el error completo, no solo el mensaje resumido.

## 4. Capturas específicas de los LOB y de las "fotos de las acciones"

Para justificar `ts_bus_BLOB` en la memoria, se recomienda incluir:

1. `SELECT * FROM user_lobs;` mostrando las dos columnas LOB y su tablespace.
2. `SELECT * FROM user_segments WHERE tablespace_name = 'TS_BUS_BLOB';`
   mostrando los segmentos `SYS_LOB...`.
3. `SELECT IdDocumento, TipoDocumento, DBMS_LOB.GETLENGTH(Contenido) ...`
   mostrando que el documento `NOMINA` ocupa 131 068 bytes.
4. Una foto de la aplicación o del cliente SQL abriendo un documento
   (`DOCUMENTO_EMPLEADO` con `TipoDocumento = 'FOTO'`). Si no existe interfaz,
   basta con la consulta anterior y una captura del contenido descargado.

## 5. Nota sobre el entorno de este repositorio

En el entorno de generación de este cambio no había Docker, `sqlplus` ni un
listener Oracle accesible (`127.0.0.1:15211` cerrado). Por eso no se han podido
producir las imágenes reales aquí. Los scripts están preparados para que el
grupo las obtenga en su equipo en un solo paso, sin inventar resultados.
