# Informe

## 1. Despliegue y Situación Inicial

### 1.1 Despliegue del Servidor
El motor de base de datos PostgreSQL 16 se desplegó en un entorno corporativo contenedorizado / Linux representando la infraestructura de *Comercializadora Norte S.A. de C.V.* Se configuraron esquemas operacionales (`public`) con la tabla `clientes`, y roles con privilegios diferenciados establecidos en la Unidad II (`app_ventas`, `soporte_ana`, `postgres`).

### 1.2 Configuración por Defecto
En su estado inicial, la instancia operaba con los parámetros de registro nativos por omisión:
* `logging_collector = on`
* `log_destination = 'stderr'` (o `csvlog`)
* `log_statement = 'none'`
* `log_connections = off`
* `log_disconnections = off`
* `log_min_error_statement = 'error'`

### 1.3 Causa de la Incapacidad para Responder a Dirección (El Incidente sin Bitácora)
Durante el incidente simulado en la **Actividad 3**, la aplicación ejecutó la instrucción:
```sql
UPDATE clientes SET rfc = 'GAMA780912XXX' WHERE id = 3;
```
Al intentar rastrear la evidencia en `dba.bitacora`, no se obtuvo ningún registro ($0$ filas). 

**Por qué no permitió responder a Dirección:**
1. **Falta de trazabilidad de conexión:** Al estar desactivados `log_connections` y `log_disconnections`, el motor no guardó registro de cuándo ni desde qué IP se conectó la cuenta `app_ventas`.
2. **Ausencia de auditoría de sentencias:** Al valer `log_statement = 'none'`, las modificaciones DML legítimas no se escribieron en disco.
3. **Ausencia de no repudio:** Ante una investigación forense, no fue posible probar técnicamente que el cambio lo realizó `app_ventas`, ni descartar a `soporte_ana` o a otros roles con acceso. Todos permanecían como sospechosos.


## 2. Configuración Aplicada

Para resolver la brecha de visibilidad, se aplicaron ajustes mediante `ALTER SYSTEM`, los cuales fueron consolidados dinámicamente mediante `SELECT pg_reload_conf()`.

### 2.1 Resumen de Parámetros de Auditoría

| Parámetro | Valor Aplicado | Requiere Reinicio | Tipo de Carga | Justificación Técnico-Segura |
| :--- | :--- | :---: | :---: | :--- |
| **`logging_collector`** | `on` | Sí | Reinicio | Habilita el proceso recolector de bitácoras (*logger process*) para capturar salidas de stderr hacia archivos físicos. |
| **`log_destination`** | `stderr` | No | `pg_reload_conf()` | Define el destino de escritura de los eventos en el sistema de archivos del servidor. |
| **`log_line_prefix`** | `'%m [%p] user=%u db=%d app=%a client=%h '` | No | `pg_reload_conf()` | Antepone a cada mensaje: fecha/hora (`%m`), PID (`%p`), usuario (`%u`), BD (`%d`), app (`%a`) e IP cliente (`%h`). |
| **`log_connections`** | `on` | No | `pg_reload_conf()` | Audita cada intento de conexión recibido, registrando la IP de origen, usuario declarado y método de autenticación. |
| **`log_disconnections`** | `on` | No | `pg_reload_conf()` | Registra el fin de cada sesión de base de datos junto con la duración total de la conexión. |
| **`log_statement`** | `'mod'` | No | `pg_reload_conf()` | Audita todas las sentencias de modificación DML (`INSERT`, `UPDATE`, `DELETE`, `TRUNCATE`) y estructuras DDL/DCL. |
| **`log_min_error_statement`** | `'error'` | No | `pg_reload_conf()` | Fuerza la escritura de la sentencia SQL que provocó cualquier error con severidad `ERROR` o superior. |
| **`lc_messages`** | `'C'` | No | `pg_reload_conf()` | Normaliza los mensajes del sistema a codificación estándar ASCII/UTF-8 para evitar fallos de decodificación de caracteres. |



## 3. Eventos Observados e Interpretados

A continuación se presenta la interpretación técnica de los distintos tipos de registros capturados en la bitácora del servidor (`dba.bitacora`):

### 3.1 Cambio de Configuración del Motor
```text
2026-10-25 22:49:50.539 UTC [1] user= db= app= client= LOG: parameter "log_statement" changed to "ddl"
```
* **Interpretación:** Registrado directamente por el proceso maestro de PostgreSQL (*postmaster*, PID 1) tras recibir la señal `SIGHUP` emitida por `SELECT pg_reload_conf()`. Demuestra la auditoría inmutable de cambios de parámetros de seguridad en la instancia.

### 3.2 Intento de Autenticación Fallido (Acceso Rechazado)
```text
2026-10-25 22:50:00.334 UTC [91] user=app_ventas db=comercial app=[unknown] client=127.0.0.1 FATAL: password authentication failed for user "app_ventas"
2026-10-25 22:50:00.334 UTC [91] user=app_ventas db=comercial app=[unknown] client=127.0.0.1 DETAIL: Connection matched file "/var/lib/postgresql/data/pg_hba.conf" line 119: "host all all 127.0.0.1/32 scram-sha-256"
```
* **Interpretación:** Un cliente desde la IP `127.0.0.1` intentó conectarse como `app_ventas` enviando una clave incorrecta. El motor rechazó el acceso (`FATAL`) y registró el detalle de la regla en `pg_hba.conf`. La variable `app` se muestra como `[unknown]` porque la sesión no llegó a autenticarse.

### 3.3 Conexión Autenticada y Autorizada Exitosamente
```text
2026-10-25 22:50:00.565 UTC [105] user=app_ventas db=comercial app=[unknown] client=127.0.0.1 LOG: connection authenticated: identity="app_ventas" method=scram-sha-256
2026-10-25 22:50:00.566 UTC [105] user=app_ventas db=comercial app=[unknown] client=127.0.0.1 LOG: connection authorized: user=app_ventas database=comercial application_name=app-ventas-web
```
* **Interpretación:** Establecimiento exitoso de sesión. Se valida la identidad mediante `scram-sha-256` y se vincula el nombre de aplicación `app-ventas-web`.

### 3.4 Sentencia DDL / DCL (Modificación de Estructura o Privilegios)
```text
2026-10-25 22:50:09.367 UTC [119] user=postgres db=comercial app=psql client=[local] LOG: statement: GRANT UPDATE ON clientes TO app_ventas
```
* **Interpretación:** Modificación del catálogo de derechos de acceso. Registrado obligatoriamente con `log_statement = 'ddl'` o `'mod'`.

### 3.5 Error de Autorización (Operación Bloqueada por Control de Acceso)
```text
2026-10-25 22:50:25.102 UTC [168] user=soporte_ana db=comercial app=psql client=127.0.0.1 ERROR: permission denied for table clientes
2026-10-25 22:50:25.102 UTC [168] user=soporte_ana db=comercial app=psql client=127.0.0.1 STATEMENT: DELETE FROM clientes WHERE id = 5
```
* **Interpretación:** El rol autenticado `soporte_ana` intentó ejecutar un `DELETE`. El motor previno la eliminación por falta de Privilegios (`ERROR`) y `log_min_error_statement = 'error'` registró la consulta violatoria.


## 4. Auditoría a Nivel de Dato

Para superar la limitación de la bitácora física (que no guarda el estado de los datos anteriores `OLD`), se diseñó e implementó un mecanismo de auditoría inmutable a nivel de fila.

### 4.1 Diseño del Esquema y Tabla de Auditoría
```sql
CREATE SCHEMA auditoria;
REVOKE ALL ON SCHEMA auditoria FROM PUBLIC;

CREATE TABLE auditoria.cambios_clientes (
    id_evento        BIGSERIAL PRIMARY KEY,
    momento          TIMESTAMPTZ NOT NULL DEFAULT now(),
    usuario_sesion   TEXT        NOT NULL DEFAULT session_user,
    usuario_efectivo TEXT        NOT NULL DEFAULT current_user,
    aplicacion       TEXT        DEFAULT current_setting('application_name'),
    ip_cliente       INET        DEFAULT inet_client_addr(),
    operacion        TEXT        NOT NULL,
    id_cliente       BIGINT,
    valores_antes    JSONB,
    valores_despues  JSONB
);
```

### 4.2 Arquitectura de Seguridad: `SECURITY DEFINER` y `session_user`
1. **Rol de `SECURITY DEFINER`:** Permite que la función del disparador se ejecute con los privilegios elevados del propietario (`postgres`), posibilitando la inserción en `auditoria.cambios_clientes` aun cuando la cuenta operativa (`app_ventas`) no tenga permisos de lectura o escritura sobre el esquema `auditoria`.
2. **Rol de `session_user` vs. `current_user`:** Dentro de una función `SECURITY DEFINER`, `current_user` conmuta al propietario de la función (`postgres`). Si la auditoría usara `current_user`, todos los registros atribuirían la autoría a `postgres`. Utilizar `session_user` garantiza capturar la identidad real autenticada en la conexión (`app_ventas`), preservando el principio de **no repudio**.

### 4.3 Demostración del Incidente Auditado
Se simuló la alteración del RFC de un cliente por parte de la aplicación de ventas:
```sql
UPDATE clientes SET rfc = 'GAMA780912ZZZ' WHERE id = 3;
```
Al ejecutar la consulta de inspección forense comparando los documentos `JSONB`:
```sql
SELECT a.id_evento, a.momento, a.usuario_sesion, a.ip_cliente,
       d.key                     AS campo,
       a.valores_antes ->> d.key AS antes,
       d.value #>> '{}'          AS despues
FROM auditoria.cambios_clientes a
CROSS JOIN LATERAL jsonb_each(a.valores_despues) d
WHERE a.operacion = 'UPDATE'
  AND a.valores_antes -> d.key IS DISTINCT FROM d.value;
```

**Resultado obtenido:**
```text
 id_evento |            momento            | usuario_sesion | ip_cliente | campo |     antes     |    despues
-----------+-------------------------------+----------------+------------+-------+---------------+---------------
         1 | 2026-10-25 22:50:52.903439+00 | app_ventas     | 127.0.0.1  | rfc   | GAMA780912XYZ | GAMA780912ZZZ
```
**Evidencia forense confirmada:** Se demuestra con precisión milimétrica que el usuario de sesión `app_ventas` desde la IP `127.0.0.1` modificó el campo `rfc` del registro 3, cambiando el valor de `'GAMA780912XYZ'` a `'GAMA780912ZZZ'`.

## 5. Limitaciones del Sistema de Auditoría

1. **Lecturas no auditadas (Consultas `SELECT`):** Con `log_statement = 'mod'`, las consultas de lectura no se registran en la bitácora física ni activan los disparadores DML. La extracción no autorizada de datos sensibles (*Data Exfiltration*) requiere el uso de extensiones avanzadas como `pgaudit`.
2. **Impacto en Volumen y Rendimiento (UPDATE masivo):** Un `UPDATE clientes SET segmento = 'regular'` sobre $1,000,000$ de filas genera 1 línea en la bitácora del servidor, pero desencadena $1,000,000$ de inserciones en `auditoria.cambios_clientes`. Esto puede degradar el I/O, consumir gigabytes de almacenamiento y bloquear la base de datos.
3. **El Administrador con Control Total:** Un usuario superusuario (`postgres`) posee la facultad técnica de ejecutar `ALTER TABLE clientes DISABLE TRIGGER trg_auditoria_clientes;` o `ALTER SYSTEM SET log_statement = 'none';`, evadiendo la auditoría de datos en su sesión.


## 6. Riesgos y Protección de la Bitácora

### 6.1 Exposición de Secretos en Texto Claro
Comandos como `CREATE ROLE rol_temporal LOGIN PASSWORD 'Temporal_Practica_2026'` registran la clave explícita en la bitácora. 

* **Mitigación:** Es obligatorio el uso de metacomandos o interfaces que procesen resúmenes criptográficos (`\password`), transmitiendo únicamente el hash `SCRAM-SHA-256`. En el empaquetado de evidencias, se utilizó `replace()` para redactar secretos antes de la exportación.

### 6.2 Pérdida de Evidencia y Custodia (NIST SP 800-92)
Almacenar la bitácora únicamente en el servidor local expone la evidencia a la destrucción tras una falla de disco, la reinstalación del nodo o la eliminación intencional por un atacante con acceso `root`.

### 6.3 Garantía de Integridad (SHA-256)
Para la bitácora exportada `evidencias/bitacora-lab01.log`, se generó la firma criptográfica:
```bash
sha256sum evidencias/bitacora-lab01.log > evidencias/bitacora-lab01.sha256
```
El hash SHA-256 no impide la modificación del archivo, pero permite demostrar matemáticamente si el archivo ha sido alterado desde su extracción (*tamper-evidence*).


## 7. Cronología y Conclusión

### Respuesta a Dirección General
**¿Con la configuración integrada aplicada puede demostrarse quién cambió un dato sensible y qué valor tenía antes?**

**SÍ, ABSOLUTAMENTE.**
Gracias a la combinación del registro de conexiones (`log_connections`), el prefijo ampliado (`log_line_prefix`), el nivel de captura DML (`log_statement = 'mod'`) y la tabla de auditoría por disparador `SECURITY DEFINER` con almacenamiento `JSONB`:
1. Se identifica inequívocamente al responsable mediante `usuario_sesion` (`session_user`).
2. Se registra la ubicación de origen (`ip_cliente`).
3. Se conserva la estampa de tiempo exacta (`TIMESTAMPTZ`).
4. Se cuantifica el cambio exacto mediante el diferencial de `valores_antes` (`OLD`) y `valores_despues` (`NEW`).


## 8. Preguntas de Reflexión

### 1. ¿Por qué la auditoría no puede configurarse después de un incidente para investigarlo?
Porque la auditoría en bases de datos opera de manera **prospectiva, no retroactiva**. Los motores de base de datos no almacenan el historial de sentencias SQL ni los estados intermedios de los datos a menos que los mecanismos de captura (`log_statement`, disparadores) hayan estado activos en el momento exacto en que ocurrió la transacción. Configurar la auditoría tras el incidente solo permitirá auditar eventos futuros, pero los datos del pasado no auditados resultan irrecuperables.

### 2. ¿Por qué conviene que la bitácora la administre el propio servidor y no el mecanismo de despliegue?
Porque el motor de la base de datos (`logging_collector`) intercepta los eventos internamente a nivel de proceso antes de que se pierdan en búferes del sistema operativo o contenedores. Si se delega el registro exclusivamente al mecanismo de despliegue (ej. `docker logs` o redirección de `stdout`), un reinicio del contenedor, un desbordamiento de búfer o la caída del proceso puede truncar o descartar los eventos sin garantía de escritura persistente en disco.

### 3. ¿Por qué el prefijo de línea es tan importante como el nivel de `log_statement`?
`log_statement` determina **qué se registra** (la sentencia SQL), pero `log_line_prefix` proporciona el **contexto forense indispensable** (quién, cuándo, desde dónde y mediante qué proceso). Una sentencia SQL registrada sin prefijo (`LOG: statement: UPDATE clientes...`) carece de valor pericial porque es imposible atribuirla a un usuario (`%u`), a un instante de tiempo (`%m`), a una IP de origen (`%h`) o a un ID de proceso (`%p`).

### 4. ¿Qué diferencia práctica hay entre registrar la sentencia y registrar el cambio en el dato?
* **Registrar la sentencia (Bitácora del Servidor / `log_statement`):** Registra el comando SQL enviado por el cliente (ej. `UPDATE clientes SET estado = 'inactivo' WHERE edad > 60`). Es ligero en almacenamiento, pero no muestra cuántas ni cuáles filas fueron afectadas, ni cuáles eran sus valores originales.
* **Registrar el cambio en el dato (Disparadores / Tabla de Auditoría):** Registra el impacto real fila por fila en la base de datos, almacenando la fotografía previa (`OLD`) y posterior (`NEW`). Es indispensable para la reversión de datos (*rollback* manual) y la inspección forense detallada.

### 5. ¿Qué evidencia ofrece `pg_stat_activity` que no ofrece la bitácora, y viceversa?
* **`pg_stat_activity`:** Ofrece **evidencia operacional en tiempo real (estado presente)**. Muestra consultas actualmente en ejecución, tiempo de bloqueo, estado de transacciones activas y uso de memoria en el instante exacto del muestreo. Sin embargo, no guarda historial: en cuanto la consulta finaliza, la información desaparece.
* **La Bitácora (`dba.bitacora`):** Ofrece **evidencia histórica persistente (estado pasado)**. Registra conexiones, desconexiones, errores y sentencias ejecutadas a lo largo del tiempo, permitiendo análisis forenses de eventos ocurridos en el pasado.

### 6. Si el administrador puede cambiar `log_statement` a `none` y desactivar el disparador, ¿quién audita al administrador?
Al administrador lo auditan **los controles externos fuera del alcance del motor de la base de datos**:
1. **Envío de bitácoras en tiempo real (Syslog remoto / SIEM):** La bitácora del servidor se transmite instantáneamente a un servidor de registros inmutable gestionado exclusivamente por el equipo de Seguridad (SOC). Aunque el DBA desactive la auditoría en la base de datos, la sentencia `ALTER SYSTEM SET log_statement = 'none'` o `DISABLE TRIGGER` queda registrada y enviada al SIEM en tiempo real antes de surtir efecto.
2. **Principio de Separación de Funciones (SoD) y Control de Cambios:** Prohibir el uso del rol `postgres` sin una ventana de mantenimiento autorizada y supervisada bajo auditoría de sesión (*Privileged Access Management* - PAM).