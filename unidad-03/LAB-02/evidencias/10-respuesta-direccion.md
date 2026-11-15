# Actividad 10 — Responder a Dirección

**1. ¿Quién cambió el RFC de María García en la Actividad 2? ¿Y en la Actividad 3?**

* En la Actividad 2: No hay evidencia con esta edición.

    Al momento de ejecutarse esa modificación, el perfilador de base de datos estaba apagado (was: 0), por lo que la colección system.profile registró 0 documentos. Por su parte, la bitácora del servidor en MongoDB Community Edition solo registra metadatos de red y eventos de inicio de sesión, pero no audita operaciones CRUD (updateOne). Aunque la bitácora muestra que el usuario app_ventas se conectó y autenticó en ese intervalo, no existe evidencia técnica directa que atribuya la ejecución de dicha modificación a una sesión o cuenta específica.

* En la Actividad 3: El usuario app_ventas@comercial.

    Con el perfilador activado en nivel 2 (db.setProfilingLevel(2)), la colección comercial.system.profile registró la operación op: "update" sobre ns: "comercial.clientes" con el comando { q: { _id: 3 }, u: { $set: { rfc: "GAMA780912XYZ" } } } (nModified: 1), atribuida explícitamente al usuario autenticado user: "app_ventas@comercial".

**2. ¿Cuándo y desde qué aplicación?**

* En la Actividad 2: No hay evidencia con esta edición respecto al instante exacto y la aplicación que ejecutó la sentencia de actualización.

    Al encontrarse desactivado el perfilador (was: 0) y no existir auditoría nativa CRUD en MongoDB Community, no quedó registrada ninguna marca de tiempo ni identificador de aplicación vinculados a la operación updateOne. (La bitácora del servidor únicamente deja constancia de la hora en que se estableció y autenticó una conexión con appName: "app-ventas-web", sin registrar las consultas ejecutadas dentro de ella).

* En la Actividad 3:

    * Cuándo: En la marca de tiempo capturada en el documento op: "update" de system.profile durante la Actividad 3 (2026-11-15T07:32:21.569Z).

    * Desde qué aplicación: Desde app-ventas-web, según consta en el campo appName: "app-ventas-web" del registro en system.profile.

**3. ¿Qué valor tenía antes?**

* No hay evidencia con esta edición.

    MongoDB Community Edition no cuenta con mecanismos de auditoría ni bitácoras que almacenen imágenes previas de los documentos antes de ser modificados. El perfilador únicamente registra la instrucción recibida (command.u: { $set: { rfc: "GAMA780912XYZ" } }) y el contador de documentos afectados, sin conservar el valor anterior del campo rfc.

**4. ¿Cambió alguien los privilegios de app_ventas?**

* Detección del cambio y rol asignado (mediante control compensatorio):

    Sí. Al comparar las dos instantáneas almacenadas en auditoria.instantaneas_privilegios, se demuestra que entre la primera captura (momento 1, donde app_ventas únicamente poseía { role: "readWrite", db: "comercial" }) y la segunda captura (momento 2), se le otorgó el rol adicional dbAdmin sobre la base comercial (rol que posteriormente fue revocado para restablecer el estado inicial).

* Autoría y momento exacto del cambio: 

    No hay evidencia con esta edición.

    MongoDB Community Edition no audita comandos administrativos de gestión de usuarios y privilegios, funcionalidad exclusiva de la auditoría nativa de MongoDB Enterprise y MongoDB Atlas (REF-U3-04). Incluso con el perfilador configurado en nivel 2 (was: 2), ni system.profile ni la bitácora del servidor registraron el otorgamiento del rol. El control compensatorio de instantáneas periódicas permite confirmar que los privilegios cambiaron y acotar el intervalo de tiempo en que sucedió, pero no determina quién ejecutó el cambio ni cuándo exactamente ocurrió.