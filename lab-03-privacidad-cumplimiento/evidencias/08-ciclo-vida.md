# ACTIVIDAD 8 - Derecho de cancelación y ciclo de vida

**¿Por qué eliminar un registro de una tabla no necesariamente significa que toda la información relacionada con esa persona haya desaparecido de la organización?** 

Ejecutar una instrucción DELETE en la tabla principal de la base de datos únicamente elimina el puntero o la fila activa dentro del sistema transaccional de producción (OLTP). No garantiza la desaparición total de la información por las siguientes razones:

* **Persistencia en la cadena de respaldos:** Los backups y logs de transacciones generados con anterioridad continúan almacenando el dato de forma inalterable hasta que se cumpla su ciclo de vida y sean sobrescritos o destruidos.

* **Desacoplamiento de entornos analíticos y réplicas:** Los datos analíticos funcionan con pipelines de sincronización asíncrona. Si no existe un flujo explícito de propagación de supresión, la información persiste en los reportes.

* **Sistemas de terceros e integraciones:** Si los datos fueron transmitidos a sistemas externos (pasarelas de pago, CRM, herramientas de envío masivo de correos), el registro sigue existiendo en las bases de datos de esos proveedores hasta que se envíe una notificación formal de cancelación a cada uno.

* **Archivos y copias locales no estructuradas:** Los datos exportados manualmente por el personal (archivos CSV, reportes PDF) quedan fuera del alcance del motor de base de datos y de las sentencias SQL.

* **Logs de auditoría y trazabilidad:** Los motores de base de datos y sistemas de seguridad guardan registros históricos de los cambios para evitar manipulación maliciosa. Estos registros pueden contener la PII eliminada como parte de la evidencia histórica de la transacción.

Por esta razón, atender técnicamente un Derecho de Cancelación requiere un Procedimiento de Cancelación Definitiva y Supresión a nivel de Gobernanza de Datos, que incluya el bloqueo del dato, la notificación a encargados/terceros, el borrado en sistemas analíticos y la gestión del ciclo de vida en la política de retención de respaldos.