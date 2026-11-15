# Actividad 1 — Lo que no existe en esta edición

**1. ¿Qué edición de MongoDB estás usando? ¿Qué evidencia lo demuestra?**

Se utiliza MongoDB 9.0.8 Community Edition. La evidencia técnica es el resultado de db.adminCommand({ buildInfo: 1 }).modules, que devuelve un arreglo vacío ([]). En MongoDB Enterprise Edition, dicho arreglo contiene el identificador "enterprise".

**2. ¿A dónde escribe tu servidor su bitácora? ¿Cómo lo sabes?**

El servidor escribe su bitácora en el archivo C:\Program Files\MongoDB\Server\9.0\log\mongod.log.

Esto se comprueba mediante db.serverCmdLineOpts().parsed, que refleja la configuración activa cargada desde C:\Program Files\MongoDB\Server\9.0\bin\mongod.cfg, donde systemLog establece destination: 'file', logAppend: true y la ruta de destino en path.

**3. Según REF-U3-04, ¿qué cuatro categorías de eventos registraría la auditoría nativa?**

* Cambios de esquema.

* Eventos de conjuntos de réplicas y clústeres fragmentados.

* Autenticación y autorización.

* Operaciones CRUD.

**4. ¿Qué tendría que evaluar una organización antes de licenciar Enterprise o migrar a Atlas solo para obtener auditoría?**

* Costo total de propiedad (TCO) vs. riesgo: El costo de suscripción Enterprise o de instancias Atlas M10+ frente al impacto real de un incidente o incumplimiento.

* Obligaciones regulatorias: Si marcos normativos (LFPDPPP, PCI-DSS, ISO 27001) exigen registros de auditoría completos e inmutables que Community no puede proporcionar.

* Suficiencia de controles compensatorios: Si la trazabilidad requerida puede cubrirse mediante el perfilador filtrado, recolección centralizada del archivo mongod.log, auditoría en la capa de aplicación e instantáneas periódicas de privilegios.

* Impacto en rendimiento y almacenamiento: La carga adicional de CPU, I/O en disco e ingestión en herramientas SIEM al auditar operaciones CRUD de alto volumen.

* Políticas de nube y soberanía de datos: Requisitos sobre ubicación física de los datos, latencia con los servicios locales y costos de red.

