# Informe

## 1. Despliegue, edición y limitación

Desplegué el servidor de base de datos de forma local como servicio en Windows con la autorización habilitada mediante el parámetro security.authorization configurado en enabled. Para administrar el entorno y ejecutar las pruebas utilicé MongoDB Compass, mongosh y PowerShell.

Verifiqué que la instancia corresponde a MongoDB 9.0.8 Community Edition ejecutando db.version, comprobando que el arreglo modules devuelto por buildInfo estuviera vacío y revisando los parámetros activos con serverCmdLineOpts. En esta edición no existe auditoría nativa para registrar operaciones CRUD, cambios de estructura DDL ni modificaciones de privilegios de usuarios, así como tampoco un mecanismo que conserve los valores anteriores de los documentos modificados o eliminados.

## 2. Perfilador

El perfilador de base de datos registra la actividad en la colección limitada comercial.system.profile, la cual tiene un tamaño fijo por defecto de 1 MB. En nivel 0 permanece apagado; en nivel 2 captura todas las operaciones de lectura y escritura; en nivel 1 con una expresión filter restringida a insert, update y remove registra únicamente escrituras, desactivando el umbral slowms y el muestreo sampleRate.

Cada documento almacenado en system.profile permite interpretar qué operación se realizó mediante los campos op y command, sobre qué base y colección mediante ns, qué usuario autenticado la ejecutó mediante user, desde qué dirección y aplicación cliente mediante client y appName, en qué instante mediante ts y cuántos documentos fueron examinados o afectados. Sin embargo, el perfilador no conserva imágenes previas del documento antes del cambio.

En cuanto a su costo operativo, el nivel 2 incrementa la carga de escritura en disco e I/O al registrar cada consulta de lectura y agota rápidamente el espacio circular de 1 MB, provocando que las operaciones más recientes sobrescriban y destruyan los registros anteriores.

## 3. Bitácora de mongod

El servidor escribe su bitácora en formato JSON estructurado dentro del archivo físico C:\Program Files\MongoDB\Server\9.0\log\mongod.log y conserva en memoria los últimos 1024 eventos consultables mediante el comando administrativo getLog.

Dentro de la categoría ACCESS, la bitácora distingue los accesos exitosos mediante el mensaje Successfully authenticated con código result igual a 0, frente a los intentos fallidos marcados con Failed to authenticate, código distinto de cero y un detalle interno en attr.error que diferencia entre contraseña incorrecta y usuario inexistente, aunque al cliente se le devuelva el mismo mensaje genérico de fallo de autenticación para evitar la enumeración de cuentas. Cuando el cliente omite el parámetro appName en su cadena de conexión, la bitácora registra el nombre y versión de la herramienta cliente utilizada, como mongosh.

Asimismo, cualquier ajuste en la configuración del perfilador queda asentado con el mensaje Profiler settings changed, indicando los parámetros anteriores y nuevos junto con el identificador de conexión ctx. Al correlacionar ese mismo ctx con un evento previo de Successfully authenticated ocurrido dentro del mismo ciclo de ejecución sin reinicios del servidor y sin cierre intermedio de la sesión, pude atribuir el cambio de configuración al usuario admin.

## 4. Privilegios

Al otorgar el rol dbAdmin sobre comercial al usuario app_ventas con el perfilador activo en nivel 2, comprobé que ni system.profile ni la bitácora de mongod registran comandos administrativos de gestión de permisos como grantRolesToUser o revokeRolesFromUser, obteniendo cero coincidencias en ambas fuentes.

Como control compensatorio implementé instantáneas periódicas en la colección auditoria.instantaneas_privilegios, almacenando la fecha y hora de captura, la identidad del usuario que tomó el registro y la lista de usuarios con sus roles asignados.

El límite de este control compensatorio radica en que permite confirmar si cambiaron los privilegios de una cuenta y qué rol específico fue agregado o revocado dentro del intervalo entre dos instantáneas, pero no determina qué usuario ejecutó la modificación ni el momento exacto en que sucedió.

## 5. Conservación

Identifiqué tres formas en que la evidencia puede perderse sin que nadie la borre deliberadamente: la sobrescritura automática en system.profile al llenarse su límite circular de 1 MB, la expulsión de registros antiguos en getLog cuando se superan los 1024 eventos recientes en memoria y el reinicio del servicio de MongoDB, acción que vacía por completo el búfer en memoria de getLog y restablece el nivel del perfilador a 0 si no se configuró de forma persistente en mongod.cfg.

Para preservar la evidencia antes de reiniciar el servicio, exporté los registros de system.profile al archivo evidencias/system-profile.json, guardé los eventos en memoria de getLog en evidencias/bitacora-mongod.log, copié el archivo físico completo mongod.log y calculé los resúmenes criptográficos SHA-256 de cada archivo exportado en evidencias/hashes.sha256.

## 6. Comparación

Al contrastar los tres escenarios analizados en la Actividad 9, PostgreSQL con bitácora y disparadores cubre accesos exitosos y fallidos, cambios de privilegios, cambios de estructura, modificaciones de datos y captura del valor anterior mediante el registro previo del disparador, mientras que el registro de lecturas sensibles es parcial porque requiere auditar todas las consultas con alto impacto en rendimiento.

MongoDB Community con perfilador y bitácora cubre de forma observada los accesos exitosos y fallidos y los cambios de configuración del registro en mongod.log, pero ofrece cobertura parcial en modificaciones de datos, lecturas sensibles y cambios de estructura al depender de un perfilador volátil de 1 MB, no conserva el valor anterior de los documentos y solo cubre parcialmente los cambios de privilegios mediante instantáneas compensatorias.

Por último, MongoDB Enterprise y MongoDB Atlas, conforme a la documentación de REF-U3-04, proporcionan auditoría nativa persistente sobre accesos, cambios de privilegios, cambios de estructura DDL, modificaciones CRUD y lecturas de datos sensibles mediante auditAuthorizationSuccess, aunque tampoco almacenan el valor previo del dato dentro de su auditoría nativa.

## 7. Recomendación

Para una organización que requiera auditar cambios de privilegios en MongoDB, recomiendo adoptar MongoDB Enterprise o MongoDB Atlas con auditoría nativa habilitada para eventos de autenticación y autorización, complementada con el resguardo de bitácoras fuera del servidor de base de datos y controles de separación de funciones sobre las cuentas administrativas.

Hechos verificados durante este laboratorio:
* MongoDB Community Edition no genera evidencia nativa en system.profile ni en mongod.log cuando se ejecutan comandos de otorgamiento o revocación de roles.
* El perfilador configurado en tiempo de ejecución regresa a nivel 0 al reiniciar el servicio y su colección está restringida a 1 MB circular.
* Las instantáneas periódicas permiten detectar qué roles cambiaron entre dos tomas, pero no identifican al autor del cambio ni el segundo exacto en que se aplicó.

Supuestos considerados para la recomendación:
* Se asume que la organización dispone de presupuesto para adquirir licenciamiento Enterprise o contratar MongoDB Atlas.
* Se asume que la organización cuenta con infraestructura externa para almacenar y proteger los archivos de auditoría frente a alteraciones locales.
* Se asume que la administración de usuarios y roles se canaliza bajo procesos operativos autorizados.

## 20. Preguntas de reflexión

**1. ¿Por qué el perfilador no debe presentarse como un mecanismo de auditoría de seguridad?**

Porque su propósito es diagnosticar el desempeño de las operaciones y no garantizar trazabilidad de seguridad. Su colección system.profile tiene un tamaño circular de 1 MB que sobrescribe registros antiguos de forma automática, su nivel vuelve a 0 al reiniciar el servicio si no se fija en mongod.cfg, ignora comandos administrativos de gestión de privilegios como grantRolesToUser, no conserva valores anteriores de los documentos y puede ser desactivado o eliminado por un usuario con privilegios administrativos.

**2. ¿Por qué el perfilador sí aporta trazabilidad aunque no sea auditoría?**

Porque mientras se encuentra activo registra la identidad autenticada en user, el origen de red y la aplicación declarada en client y appName, la marca de tiempo exacta en ts y la sentencia ejecutada en command junto con la colección afectada. Esto permite reconstruir qué operaciones ocurrieron y vincularlas con una cuenta y aplicación específicas durante una investigación cuando los registros aún permanecen en system.profile.

**3. ¿Qué riesgo introduce el nivel 2 al registrar filtros de consultas que pueden contener datos personales?**

El nivel 2 guarda en texto plano dentro del campo command los filtros y parámetros enviados en cada consulta de lectura o escritura, los cuales pueden contener RFC, correos electrónicos, números telefónicos u otros datos personales. Esto expone información confidencial a cualquier usuario con acceso de lectura a system.profile o a los archivos exportados si no se aplican controles estrictos de acceso.

**4. ¿Qué diferencia hay entre detectar un cambio y atribuirlo a alguien?**

Detectar un cambio consiste en verificar que un dato o un conjunto de permisos fue alterado respecto a un estado previo, como ocurre al observar un RFC modificado en la colección o una diferencia de roles entre dos instantáneas de privilegios. Atribuirlo a alguien implica demostrar mediante registros íntegros qué cuenta autenticada, desde qué conexión y en qué momento preciso ejecutó la acción, algo que no fue posible en la Actividad 2 con el perfilador apagado ni en la Actividad 7 respecto al autor del cambio de privilegios.

**5. ¿Por qué reconocer una limitación técnica es parte del trabajo profesional del DBA?**

Porque permite evaluar con rigor el alcance real de la edición del motor instalada sin asumir ni prometer capacidades de auditoría inexistentes ante Dirección o áreas de cumplimiento. Identificar con precisión qué eventos quedan registrados y cuáles no permite implementar controles compensatorios adecuados, documentar los riesgos residuales con sustento técnico y justificar decisiones de arquitectura o actualización de edición basadas en evidencia verificable.