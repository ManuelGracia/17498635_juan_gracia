# **Actividad 15** — Límites: lecturas y volumen

**1. Si clientes tuviera un millón de registros, ¿qué ocurriría con la auditoría tras un UPDATE sin WHERE?**

Ocurriría una severa degradación del sistema y un consumo masivo de almacenamiento en dos frentes diferenciados:

* En la tabla de auditoría (auditoria.cambios_clientes):
Dado que el disparador está definido FOR EACH ROW, el motor intentará ejecutar 1,000,000 de inserciones individuales dentro de la misma transacción. Cada inserción construirá y serializará dos objetos JSONB (OLD y NEW), lo que generará:

* Gigabytes de datos escritos de golpe: Multiplicar el tamaño de cada registro de cliente por 2 más la metadata de auditoría provocará una expansión drástica e inmediata de la base de datos.

* Bloqueo y degradación Extrema: La transacción se volverá extremadamente lenta, bloqueando la tabla clientes durante minutos u horas, aumentando la contención de I/O y congelando la operación del negocio.

* Riesgo de falla total: Si el volumen agota el espacio en disco o excede los tiempos de espera de la sesión (statement_timeout), la transacción completa fallará y se aplicará un rollback.

* En la bitácora del servidor (dba.bitacora):
Con log_statement = 'mod', la bitácora física escribirá únicamente 1 línea con la sentencia SQL ejecutada (LOG: statement: UPDATE clientes SET segmento = 'regular'), reflejando la diferencia abismal entre la auditoría a nivel de sentencia (ligera en log) y la auditoría a nivel de dato (pesada en disparadores).

**2. Propón quién podría autorizar la depuración de auditoria.cambios_clientes.**

La depuración o purga (purging) de la tabla de auditoría jamás debe ser autorizada ni ejecutada unilateralmente por el Administrador de Base de Datos (DBA) debido al conflicto de interés y la violación de la separación de funciones.

Flujo de Autorización Propuesto:

* Solicitud Operativa: El DBA justifica la necesidad técnica (ej. cumplimiento del ciclo de vida de datos o liberación de espacio).

* Aprobación Formal Colegiada: Debe ser autorizada conjuntamente por el Comité de Riesgos y Cumplimiento Legal, el Oficial de Seguridad de la Información (CISO) y el Oficial de Protección de Datos (DPO).

* Criterio de Depuración: La autorización debe especificar la ventana de retención legal (por ejemplo, "depurar registros con antigüedad mayor a 5 años") y constatar que previamente se generó un respaldo inmutable y firmado criptográficamente para su custodia a largo plazo.

**3. ¿Por qué log_statement = 'all' puede convertir la bitácora en un nuevo depósito de datos sensibles?**

Porque log_statement = 'all' intercepta y escribe en texto claro en los archivos del sistema de archivos (.log) la totalidad de las sentencias recibidas por el motor, incluyendo:

* Filtros con datos personales en lecturas (SELECT): Consultas como SELECT * FROM clientes WHERE rfc = 'GAMA780912XYZ' o WHERE telefono = '6679990000' graban directamente los datos identificables del cliente en el log.

* Valores literales en inserciones y modificaciones (INSERT/UPDATE): Contraseñas en texto plano, números de tarjetas, sueldos o datos de salud quedan plasmados en la bitácora.

* Riesgo de Seguridad: El archivo de log se transforma en un repositorio desprotegido de Datos Personales Identificables (PII). Administradores del sistema operativo, personal de monitoreo de infraestructura o herramientas de análisis de logs (como Elasticsearch o Datadog) que no tienen permisos de lectura en la base de datos terminan teniendo acceso irrestricto a información confidencial, violando leyes de privacidad (LFPDPPP/GDPR) y el principio de minimización de datos.