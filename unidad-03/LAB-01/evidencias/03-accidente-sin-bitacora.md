# **Actividad 3** — El incidente sin bitácora

**1. ¿Puedes demostrar quién modificó el RFC?**

No, bajo la configuración actual, no existe evidencia técnica que vincule la modificación del registro con una cuenta de usuario específica. Aunque el comando se ejecutó desde la sesión de app_ventas, el motor de base de datos no registró el evento, impidiendo probar técnicamente la identidad del responsable.

**2. ¿Puedes demostrar que el cambio no lo hizo soporte_ana?**

Tampoco, debido a la ausencia de registros de conexiones y de sentencias SQL, es imposible descartar a soporte_ana o a cualquier otro rol con acceso a la base de datos. Ante una investigación o peritaje, todos los usuarios autorizados permanecen como sospechosos por falta de trazabilidad.

**3. Los privilegios de la Unidad II, ¿impidieron el cambio? ¿Debían impedirlo?**

No lo impidieron y no debían impedirlo.

**4. ¿Qué tendría que haber estado configurado antes del incidente?**

Para contar con evidencia válida y demostrar la autoría del cambio antes de que ocurriera el incidente, el servidor debió contar con:

* log_connections = on y log_disconnections = on: Para registrar el momento exacto de entrada/salida y la IP de origen de la sesión.

* log_line_prefix = '%m [%p] %u@%d %h %a ': Para anteceder cada mensaje con fecha/hora (%m), PID (%p), usuario (%u), base de datos (%d), dirección IP (%h) y nombre de la aplicación (%a).

* log_statement = 'mod' (o 'all'): Para forzar la escritura en bitácora de todas las sentencias DML de modificación (INSERT, UPDATE, DELETE, TRUNCATE).

* Mecanismo de auditoría a nivel de dato: Un disparador de auditoría AFTER UPDATE sobre clientes que registrara en una tabla inmutable el valor anterior (OLD.rfc), el valor nuevo (NEW.rfc), la fecha y el usuario de la sesión (session_user).