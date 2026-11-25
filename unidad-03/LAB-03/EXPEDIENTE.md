# Expediente

## 1. Alcance

* **Sistemas evaluados:**
  * **PostgreSQL 16** (base de datos operativa `comercial`; esquemas `public`, `auditoria`, `gobierno` y `dba`), desplegado mediante contenedor Docker (`docker compose`, servicio `postgres`).
  * **MongoDB 7 Community Edition** (base de datos `comercial`; colecciones `clientes` y `system.profile`), desplegado mediante contenedor Docker (`docker compose`, servicio `mongo`).
* **Periodo revisado:** Ciclo operativo de prácticas de la Unidad III (octubre – noviembre de 2026), cubriendo desde la habilitación de bitácoras y disparadores en LAB-01/LAB-02 hasta la conciliación de cambios en LAB-03.
* **Responsable de la integración del expediente:** [Tu Nombre Completo] — Administrador de Bases de Datos (DBA, en rol de Custodio técnico).

## 2. Configuración de auditoría (A3)

Los mecanismos activos de registro y trazabilidad en ambos motores se respaldan en las evidencias técnicas del directorio `evidencias/`:

* **Bitácora de servidor en PostgreSQL 16 (`evidencias/E1-configuracion-registro.txt`):**
  * `logging_collector = on`: redirige la salida estándar a archivos gestionados por el colector.
  * `log_connections = on` y `log_disconnections = on`: registran el inicio y cierre de cada sesión con IP, puerto y usuario.
  * `log_statement = mod`: registra todas las sentencias que modifican datos o estructura (`INSERT`, `UPDATE`, `DELETE`, `TRUNCATE`, `DDL`/`DCL`).
  * `log_line_prefix = '%m [%p] %q%u@%d '`: garantiza marca de tiempo con milisegundos, PID, usuario y base de datos en cada línea.
* **Auditoría del dato a nivel de fila (`evidencias/E3-disparadores.txt` y `evidencias/E4-muestra-auditoria.txt`):**
  * Disparador `trg_auditoria_clientes` asociado a `public.clientes` en estado activo (`tgenabled = O`), ejecutado `AFTER INSERT OR UPDATE OR DELETE FOR EACH ROW`.
  * Invoca la función `auditoria.registrar_cambio_cliente()` (`SECURITY DEFINER`), almacenando en `auditoria.cambios_clientes` el estado previo (`valores_antes`) y nuevo (`valores_despues`) en formato `JSONB`, junto con `usuario_sesion`, `usuario_efectivo`, `aplicacion` e `ip_cliente`.
* **Privilegios de acceso vigentes (`evidencias/E2-privilegios.txt`):**
  * Registra la matriz actual de permisos sobre objetos de usuario (`app_ventas` con `SELECT, UPDATE` y `soporte_ana` con `SELECT` sobre `public.clientes`).
* **Perfilado y bitácora en MongoDB 7 (`evidencias/system-profile.json`, `evidencias/bitacora-mongod.log` y `evidencias/09-comparacion.md`):**
  * Perfilador configurado en nivel 2 (`db.setProfilingLevel(2)`) sobre la colección *capped* `comercial.system.profile` (1 MB) para capturar operaciones ejecutadas, y bitácora operativa en `mongod`.

## 3. Bitácora interpretada (A3, A5)

A continuación se interpretan cuatro eventos críticos extraídos de `evidencias/E5-bitacora-postgresql.log` y `evidencias/E4-muestra-auditoria.txt`:

### Evento 1 — Modificación del RFC de María García (`id = 3`) desde la aplicación
* **Quién:** Usuario de sesión `app_ventas` (ejecutado con privilegios efectivos de `postgres` vía `SECURITY DEFINER`), operando desde la aplicación declarada `app-ventas-web`.
* **Cuándo:** Registrado en el evento de auditoría de LAB-01 Parte B / `evidencias/E4-muestra-auditoria.txt` (posterior a la activación de `trg_auditoria_clientes`).
* **Desde dónde:** `127.0.0.1` (conexión local/loopback dentro del entorno del contenedor).
* **Qué ocurrió:** Se ejecutó una sentencia `UPDATE public.clientes SET rfc = ... WHERE id = 3`, alterando el RFC de María García.
* **Tipo de evento:** Modificación de dato personal y fiscal (DML auditado a nivel de sentencia y de fila).
* **Qué prueba:** Demuestra qué usuario de aplicación realizó el cambio, desde qué dirección IP, y conserva el valor exacto anterior y posterior en `auditoria.cambios_clientes`, permitiendo a Facturación restaurar el RFC original. Asimismo, evidencia que el campo `application_name` es autodeclarado por el cliente y no constituye autenticación fuerte de la aplicación.

### Evento 2 — Evasión deliberada del disparador de auditoría por el superusuario
* **Quién:** Usuario `postgres` (superusuario / DBA).
* **Cuándo:** `2026-10-25 22:50:53.549` y `2026-10-25 22:50:53.554` (`evidencias/E5-bitacora-postgresql.log`, líneas 169 y 171).
* **Desde dónde:** Sesión local de administración (`postgres@comercial`).
* **Qué ocurrió:** Se ejecutó `ALTER TABLE clientes DISABLE TRIGGER trg_auditoria_clientes`, se modificó el RFC de un cliente sin dejar registro en `auditoria.cambios_clientes`, y 5 milisegundos después se ejecutó `ALTER TABLE clientes ENABLE TRIGGER trg_auditoria_clientes`.
* **Tipo de evento:** Alteración de estructura/control (DDL) y manipulación de evidencia.
* **Qué prueba:** Prueba que un administrador con privilegios de superusuario puede suspender temporalmente la auditoría a nivel de tabla para ocultar cambios en los datos, pero demuestra también que la bitácora externa del servidor (`log_statement = mod`) delata la maniobra cuando los controles están separados.

### Evento 3 — Intento no autorizado de desactivación de control por cuenta de aplicación
* **Quién:** Usuario `app_ventas`.
* **Cuándo:** `2026-10-25 22:50:53.460` (`evidencias/E5-bitacora-postgresql.log`, línea 163).
* **Desde dónde:** Sesión de red de la aplicación (`app_ventas@comercial`).
* **Qué ocurrió:** La cuenta `app_ventas` intentó ejecutar `ALTER TABLE clientes DISABLE TRIGGER trg_auditoria_clientes`, recibiendo rechazo del motor (`ERROR: must be owner of table clientes`).
* **Tipo de evento:** Intento fallido de alteración de estructura (DDL no autorizado).
* **Qué prueba:** Prueba que el principio de separación de propiedad funciona en el motor: la cuenta de aplicación no es dueña de la tabla `clientes` ni del esquema `auditoria`, por lo que no puede desactivar sus propios controles ni borrar su rastro.

### Evento 4 — Cambio estructural autorizado dentro de ventana de mantenimiento (`CAM-2026-014`)
* **Quién:** Usuario `postgres` (DBA).
* **Cuándo:** `2026-10-25 22:54:26.533` (`evidencias/E5-bitacora-postgresql.log`, línea 216).
* **Desde dónde:** Sesión administrativa `postgres@comercial`.
* **Qué ocurrió:** Se ejecutó `ALTER TABLE clientes ADD COLUMN canal_alta VARCHAR(20);` y se documentó su metadato mediante `COMMENT ON COLUMN clientes.canal_alta`.
* **Tipo de evento:** Cambio de esquema aprobado (DDL gobernado).
* **Qué prueba:** Demuestra el flujo correcto de gobierno: una solicitud previamente aprobada por el Comité de cambios en `gobierno.solicitudes_cambio` (`folio = CAM-2026-014`), ejecutada dentro de su ventana autorizada (`dentro_de_ventana = t`) y reflejada en el diccionario de datos.

## 4. Elementos de gobierno (A1, A2)

### 4.1 Roles y responsabilidades (Actividad 2)
Se separan las figuras de **Propietario** (decide finalidad, accesos y correcciones), **Custodio** (opera y resguarda técnicamente) y **Usuario** (consume para operación autorizada):
* **`comercial.public.clientes` (PostgreSQL) y `comercial.clientes` (MongoDB):** Propietario: *Gerencia Comercial*; Custodio: *DBA*; Usuarios: *`app_ventas`, Facturación, Soporte*.
* **`auditoria.cambios_clientes` (PostgreSQL) y `comercial.system.profile` (MongoDB):** Propietario: *Auditoría Interna / Seguridad de la Información*; Custodio: *DBA* (sin permiso de alteración de registros); Usuarios: *Auditoría Interna (lectura)*.
* **Bitácora de PostgreSQL y `gobierno.solicitudes_cambio`:** Propietario: *Seguridad de la Información / Comité de cambios*; Custodio: *DBA*.

### 4.2 Catálogo mínimo de datos (Actividad 4)
Inventario consolidado de activos de datos en PostgreSQL 16 y MongoDB 7:

| ID | Conjunto de datos | Motor | Ubicación | Propietario | Custodio | Clasificación | Datos personales |
|---|---|---|---|---|---|---|---|
| **CAT-01** | Clientes | PostgreSQL 16 | `postgres / comercial / public.clientes` | Gerencia Comercial | DBA | Confidencial | Sí |
| **CAT-02** | Auditoría de clientes | PostgreSQL 16 | `postgres / comercial / auditoria.cambios_clientes` | Auditoría Interna / Seguridad | DBA | Restringida | Sí |
| **CAT-03** | Registro de cambios | PostgreSQL 16 | `postgres / comercial / gobierno.solicitudes_cambio` | Comité de cambios | DBA | Interna / Restringida | No |
| **CAT-04** | Clientes (tienda) | MongoDB 7 | `mongo / comercial / clientes` | Gerencia Comercial | DBA | Confidencial | Sí |
| **CAT-05** | Perfilado | MongoDB 7 | `mongo / comercial / system.profile` | Seguridad / Auditoría Interna | DBA | Restringida | Sí |

### 4.3 Diccionario de datos operativo (Actividad 3)
Los metadatos estructurales de `public.clientes` se documentaron directamente dentro del motor mediante `COMMENT ON TABLE` y `COMMENT ON COLUMN` (consultables vía `information_schema.columns` y `col_description()`), exportándose en `evidencias/diccionario-clientes.csv`. Se identificaron como **datos personales sensibles/confidenciales** las columnas `nombre`, `correo`, `telefono`, `rfc`, `edad` y `codigo_postal`, asociando cada una a su finalidad operativa, control de enmascaramiento y regla de calidad.

## 5. Conservación (A3)

Conforme al criterio definido en la **Actividad 5** (basado en NIST SP 800-92 y las evidencias `evidencias/E5-bitacora-postgresql.log`, `evidencias/system-profile.json` y `evidencias/bitacora-mongod.log`):

* **Accesos de PostgreSQL y bitácora de `mongod`:** Conservación de **90 días en línea + 9 meses en archivo histórico (1 año total)** en servidor centralizado de logs, con eliminación segura automatizada al vencer.
* **Cambios de privilegios, estructura (`dba.bitacora`) e instantáneas de privilegios (`auditoria.instantaneas_privilegios`):** Conservación de **2 años** en almacenamiento inmutable (WORM) previo saneamiento de credenciales en texto plano (como la censura aplicada en `evidencias/E5-bitacora-postgresql.log`).
* **Modificaciones de datos (`log_statement = mod`):** Conservación de **6 meses** en repositorio centralizado fuera del alcance operativo.
* **`auditoria.cambios_clientes` (`CAT-02`):** Conservación de **12 meses en línea**; plazo total histórico *a confirmar con el área jurídica* respecto a obligaciones fiscales (SAT) y derechos de cancelación (ARCO / LFPDPPP). Al vencer el plazo o ejercerse cancelación, se aplica anonimización de campos personales (`rfc`, `nombre`, `correo`).
* **`system.profile` de MongoDB (`CAT-05`):** Retención operativa de **7 días** en colección *capped* de 1 MB (30 días en exportaciones puntuales de investigación) debido a su alta tasa de sobrescritura.

## 6. Políticas (A4)

Las reglas de gobierno se formalizaron en seis políticas verificables ubicadas en el directorio `politicas/`:

1. **`politicas/POL-01-acceso.md` (Control de Acceso):** Exige aprobación del Propietario del dato para todo privilegio y revisión trimestral. *Evidencia:* `evidencias/E2-privilegios.txt`, `evidencias/E5-bitacora-postgresql.log` (líneas 34–37) y `auditoria.instantaneas_privilegios`. *(Brecha: hoy no existe acta formal de revisión trimestral).*
2. **`politicas/POL-02-respaldo.md` (Respaldo):** Establece respaldo diario de bases y bitácoras con verificación mensual de integridad (el procedimiento técnico se definirá en la Unidad V). *Evidencia:* Exportaciones puntuales `evidencias/E5-bitacora-postgresql.log` y `evidencias/E5-bitacora-postgresql.sha256`. *(Brecha: hoy no existe respaldo automatizado ni bitácora de pruebas).*
3. **`politicas/POL-03-retencion.md` (Retención):** Define plazos mínimos de 12 meses para auditoría y 2 años para cambios de privilegios, exigiendo anonimización o purga al vencer. *Evidencia:* Tabla de conservación (Actividad 5) y catálogo (Actividad 4). *(Brecha: hoy no existe script automatizado de purga/anonimización).*
4. **`politicas/POL-04-restauracion.md` (Restauración):** Prohíbe restauraciones o correcciones en producción sin autorización del Propietario y prohíbe desactivar disparadores durante recuperaciones (el procedimiento técnico se definirá en la Unidad V). *Evidencia:* `evidencias/E4-muestra-auditoria.txt` y `gobierno.solicitudes_cambio`. *(Brecha: sin simulacros documentados aún).*
5. **`politicas/POL-05-datos-sensibles.md` (Datos Sensibles):** Restringe el acceso directo a datos personales, exige vistas enmascaradas para soporte y auditoría de modificaciones. *Evidencia:* `evidencias/diccionario-clientes.csv`, `evidencias/E3-disparadores.txt`, `evidencias/E4-muestra-auditoria.txt` y `evidencias/system-profile.json`. *(Brecha: lecturas `SELECT` en PostgreSQL no auditadas).*
6. **`politicas/POL-06-cambios-produccion.md` (Cambios en Producción):** Exige solicitud aprobada en `gobierno.solicitudes_cambio`, ejecución en ventana autorizada y conciliación posterior. *Evidencia:* Registro `CAM-2026-014` en `gobierno.solicitudes_cambio` y `evidencias/E5-bitacora-postgresql.log` (línea 216).

## 7. Conciliación de cambios (A5)

Al cruzar las sentencias DDL y DCL registradas en `evidencias/E5-bitacora-postgresql.log` contra la tabla `gobierno.solicitudes_cambio` (Actividad 7):

* **Cambios autorizados (1):**
  * `ALTER TABLE clientes ADD COLUMN canal_alta VARCHAR(20);` (`evidencias/E5-bitacora-postgresql.log`, línea 216) — Respaldado por el folio **`CAM-2026-014`**, aprobado por el Comité de cambios y ejecutado dentro de la ventana autorizada.
* **Cambios no autorizados / sin folio (7 eventos detectados en bitácora):**
  * `REVOKE UPDATE ON clientes FROM soporte_ana` (línea 34), `GRANT UPDATE ON clientes TO app_ventas` (línea 35) y `ALTER TABLE clientes ADD COLUMN segmento VARCHAR(20)` (línea 36): ejecutados durante la configuración técnica de LAB-01 antes de existir registro de gobierno, sin regularización documental.
  * `CREATE ROLE rol_temporal LOGIN PASSWORD '<REDACTED>'` (línea 37): creación de rol sin folio de aprobación, sin vigencia de baja y con contraseña registrada en texto plano en la bitácora original.
  * `ALTER TABLE clientes DISABLE TRIGGER trg_auditoria_clientes` por `app_ventas` (línea 163): intento no autorizado rechazado por permisos.
  * `ALTER TABLE clientes DISABLE TRIGGER trg_auditoria_clientes` (línea 169) y `ENABLE TRIGGER` (línea 171) por `postgres`: evasión crítica de auditoría sin folio ni autorización.
* **Hueco de evidencia identificado:** La creación de la vista `dba.bitacora` no aparece en `evidencias/E5-bitacora-postgresql.log` porque se ejecutó mientras `log_statement` aún tenía valor `none`.

## 8. Hallazgos

| ID | Hallazgo | Fuente | Severidad | Impacto | Recomendación | Decisión requerida de |
|---|---|---|---|---|---|---|
| **H-01** | Desactivación temporal del disparador `trg_auditoria_clientes` por el superusuario `postgres` para modificar datos sin rastro en `auditoria.cambios_clientes`. | `evidencias/E5-bitacora-postgresql.log` (líneas 169–171) | **Alta** | Pérdida de integridad y confiabilidad de la auditoría del dato; posibilidad de fraude interno no detectado en tabla de auditoría. | Enviar bitácoras en tiempo real a un servidor externo inmutable (SIEM/WORM) fuera del alcance del DBA y configurar alertas inmediatas ante cualquier sentencia `DISABLE TRIGGER`. | Seguridad de la Información / Auditoría Interna |
| **H-02** | Exposición de contraseña en texto plano (`Temporal_Practica_2026`) dentro de la bitácora del servidor al ejecutar `CREATE ROLE`. | `evidencias/E5-bitacora-postgresql.log` (línea 37) | **Alta** | Compromiso de credenciales si un usuario no autorizado lee los logs operativos; incumplimiento de POL-05. | Prohibir creación de roles con contraseñas en texto plano en scripts SQL (usar autenticación SCRAM/certificados o variables encriptadas) y restringir lectura de logs. | Seguridad de la Información / DBA |
| **H-03** | Permiso directo `SELECT` del rol `soporte_ana` sobre la tabla base `public.clientes` en lugar de usar exclusivamente la vista enmascarada. | `evidencias/E2-privilegios.txt` (línea 4) | **Alta** | Exposición directa de RFC, teléfono y correo electrónico completo a personal de soporte, violando POL-05 y principio de mínimo privilegio. | Revocar `SELECT` sobre `public.clientes` a `soporte_ana` mediante solicitud aprobada y otorgar acceso únicamente sobre la vista enmascarada de la Unidad II. | Gerencia Comercial (Propietario) |
| **H-04** | Cambios previos de permisos (`GRANT`/`REVOKE`), estructura (`ADD COLUMN segmento`) y creación de `rol_temporal` ejecutados sin folio en `gobierno.solicitudes_cambio`. | `evidencias/E5-bitacora-postgresql.log` (líneas 34–37) | **Media** | Incumplimiento de POL-01 y POL-06; imposibilidad de distinguir cambios legítimos de alteraciones indebidas. | Regularizar retroactivamente los cambios operativos vigentes mediante folios de cierre y revocar `rol_temporal` si ya no es necesario. | Comité de cambios / Gerencia Comercial |
| **H-05** | Defectos de calidad en `public.clientes`: correo duplicado (`id` 1 y 7), RFC incompleto/nulo (`id` 7 y 8), correo inválido (`sin-correo`) y edad negativa (`-3`). | Actividad 1 (`public.clientes`) | **Media** | Errores en facturación (CFDI), duplicidad de expedientes de clientes y analítica comercial distorsionada. | Solicitar corrección al propietario del dato y aprobar restricciones `UNIQUE` (correo normalizado) y `CHECK` (formato RFC, correo y rango de edad 18–120). | Gerencia Comercial / Facturación |
| **H-06** | Hueco de trazabilidad inicial: creación de `dba.bitacora` ejecutada cuando `log_statement = none`. | `evidencias/E5-bitacora-postgresql.log` | **Baja** | Ausencia de registro en bitácora sobre la creación inicial de objetos administrativos del esquema `dba`. | Mantener `log_statement = mod` (o `ddl`) activo desde el aprovisionamiento inicial de toda instancia mediante plantilla estándar. | DBA / Seguridad de la Información |
| **H-07** | Ausencia de controles automatizados de respaldo, verificación de integridad y purga/anonimización por retención (POL-02 y POL-03). | `politicas/POL-02-respaldo.md`, `politicas/POL-03-retencion.md` | **Media** | Riesgo de pérdida de datos ante fallas y riesgo de incumplimiento legal (LFPDPPP) por retención indefinida de datos personales en auditoría. | Implementar plan técnico de respaldos y scripts programados de anonimización tras vencer el plazo legal en la Unidad V. | Gerencia Comercial / Área Jurídica / DBA |

## 9. Limitaciones conocidas y riesgos aceptados (A6)

Se distinguen las limitaciones **verificadas técnicamente en los laboratorios** frente a las capacidades **documentadas pero no practicadas** por restricciones de edición o alcance:

1. **Lecturas (`SELECT`) no auditadas en PostgreSQL (Verificado técnicamente — LAB-01 Parte B, Paso 8):**
   * *Limitación:* PostgreSQL nativo (`log_statement = mod` y disparadores DML) no registra qué usuario consultó o extrajo datos sensibles (`SELECT rfc FROM clientes`).
   * *Capacidades documentadas no practicadas:* La extensión **`pgaudit`** permite auditar lecturas a nivel de objeto y columna, pero no está instalada/habilitada en el despliegue actual.
   * *Aceptación formal requerida de:* **Seguridad de la Información y Gerencia Comercial**.

2. **Ausencia de auditoría nativa en MongoDB Community Edition (Verificado técnicamente — LAB-02 y `evidencias/09-comparacion.md`):**
   * *Limitación:* MongoDB 7 Community no incluye subsistema nativo de auditoría de eventos de seguridad. El laboratorio utilizó el perfilador (`system.profile`, limitado a 1 MB y sujeto a sobrescritura) e instantáneas manuales de privilegios como controles compensatorios.
   * *Capacidades documentadas no practicadas:* **MongoDB Enterprise Advanced** ofrece el módulo `auditLog` nativo con filtrado por evento/usuario y salida inmutable, no practicado por licencia.
   * *Aceptación formal requerida de:* **Gerencia de TI y Seguridad de la Información**.

3. **Privilegio irrestricto del superusuario (`postgres`) para desactivar disparadores o purgar tablas locales (Verificado técnicamente — LAB-01 Parte B, Paso 7):**
   * *Limitación:* Mientras el DBA opere con rol `SUPERUSER` dentro de la misma instancia donde residen las tablas de auditoría, puede ejecutar `DISABLE TRIGGER` o `TRUNCATE auditoria.cambios_clientes`.
   * *Mitigación parcial:* Envío de bitácoras externas (`E5`) y separación administrativa pendiente de infraestructura externa (SIEM).
   * *Aceptación formal requerida de:* **Auditoría Interna y Dirección de TI**.

4. **Volatilidad de archivos de bitácora en contenedores efímeros (Verificado técnicamente — LAB-01 y LAB-02):**
   * *Limitación:* Si el contenedor Docker se recrea sin volúmenes externos o sin extracción previa, las bitácoras locales y `getLog` en memoria de MongoDB se pierden.
   * *Aceptación formal requerida de:* **DBA y Gerencia de Infraestructura / TI**.

## 10. Índice de evidencias

Todos los archivos que respaldan este expediente se encuentran organizados en el repositorio de la práctica:

| Archivo / Ruta | Descripción | Hash SHA-256 / Integridad |
|---|---|---|
| `EXPEDIENTE.md` | Documento integrador de auditoría interna (este expediente). | Documento maestro |
| `evidencias/E1-configuracion-registro.txt` | Parámetros activos de bitácora en PostgreSQL 16 (`pg_settings`). | Verificable en motor |
| `evidencias/E2-privilegios.txt` | Matriz vigente de privilegios de roles sobre tablas (`role_table_grants`). | Verificable en motor |
| `evidencias/E3-disparadores.txt` | Estado activo (`tgenabled = O`) del disparador `trg_auditoria_clientes`. | Verificable en motor |
| `evidencias/E4-muestra-auditoria.txt` | Muestra anonimizada (metadatos) de los últimos 10 eventos en `auditoria.cambios_clientes`. | Verificable en motor |
| `evidencias/E5-bitacora-postgresql.log` | Bitácora completa exportada de PostgreSQL con contraseñas saneadas (`<REDACTED>`). | Ver `E5-bitacora-postgresql.sha256` |
| `evidencias/E5-bitacora-postgresql.sha256` | Suma de verificación criptográfica SHA-256 de `E5-bitacora-postgresql.log`. | `[Pegar aquí el hash de E5-bitacora-postgresql.sha256]` |
| `evidencias/diccionario-clientes.csv` | Diccionario operativo exportado desde `information_schema` y `col_description()`. | Verificable en motor |
| `evidencias/system-profile.json` | Exportación del perfilador de operaciones de MongoDB 7 (LAB-02). | Ver `system-profile.json.sha256` |
| `evidencias/bitacora-mongod.log` | Bitácora operativa exportada del servidor `mongod` (LAB-02). | Ver `bitacora-mongod.log.sha256` |
| `evidencias/09-comparacion.md` | Análisis comparativo de capacidades de auditoría entre PostgreSQL 16 y MongoDB 7 (LAB-02). | Documento técnico de referencia |
| `politicas/POL-01-acceso.md` | Política práctica de control de acceso y revisión trimestral de privilegios. | Política vigente |
| `politicas/POL-02-respaldo.md` | Política práctica de respaldo y verificación de integridad. | Política vigente |
| `politicas/POL-03-retencion.md` | Política práctica de retención y disposición final de datos y bitácoras. | Política vigente |
| `politicas/POL-04-restauracion.md` | Política práctica de autorización y ejecución de restauraciones. | Política vigente |
| `politicas/POL-05-datos-sensibles.md` | Política práctica de protección y uso de datos personales y sensibles. | Política vigente |
| `politicas/POL-06-cambios-produccion.md` | Política práctica de gestión y conciliación de cambios en producción. | Política vigente |