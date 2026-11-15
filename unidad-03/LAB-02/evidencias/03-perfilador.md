# Actividad 3 — Activar el perfilador y registrar operaciones

Interpretación de los documentos (Sección 9.1)

| | op | Usuario | Cliente | Aplicación | Momento | Qué hizo | Documentos afectados |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | query | app_ventas@comercial | 127.0.0.1 | app-ventas-web | <ts_query> | Consultó clientes cuya ciudad fuera "Culiacán", proyectando únicamente nombre y ciudad (find) | 5 examinados (docsExamined: 5), 3 devueltos (nreturned: 3) |
| 2 | update | app_ventas@comercial | 127.0.0.1 | app-ventas-web | <ts_update> | Modificó el campo rfc a "GAMA780912XYZ" en el documento con _id: 3 (updateOne) | 1 examinado (docsExamined: 1), 1 modificado (nModified: 1) |
| 3 | remove | app_ventas@comercial | 127.0.0.1 | app-ventas-web | <ts_remove> | Eliminó el documento correspondiente al cliente con _id: 2 (deleteOne) | 1 examinado (docsExamined: 1), 1 eliminado (ndeleted: 1) |
---

**1. ¿Puedes saber cuál era el RFC antes del cambio con la información de system.profile?**

No hay evidencia con esta edición. El perfilador registra únicamente la sentencia de actualización enviada y el número de documentos modificados, pero no almacena la imagen previa del documento antes de ser sobrescrito.

**2. ¿Puedes saber qué datos tenía el documento eliminado?**
No hay evidencia con esta edición. En una operación remove, system.profile solo guarda el criterio de filtrado utilizado y el conteo de eliminaciones, sin conservar copia del contenido del documento borrado.

**3. A diferencia de log_statement = 'mod' en PostgreSQL, el nivel 2 sí registró la consulta. ¿Qué ventaja y qué riesgo tiene eso?**

* Ventaja: Brinda visibilidad sobre las operaciones de lectura, permitiendo detectar consultas no autorizadas o posible exfiltración de datos sensibles, además de analizar problemas de rendimiento.

* Riesgos: En entornos con alto tráfico de lecturas, degrada el desempeño del servidor y agota rápidamente el límite de 1 MB de la colección limitada system.profile, sobrescribiendo los registros más antiguos y borrando evidencia de operaciones posteriores de escritura o eliminación. Además, expone parámetros y filtros sensibles en texto plano dentro de command.

**4. ¿Por qué el campo user incluye @comercial?**

Porque en MongoDB los usuarios se definen dentro de una base de datos de autenticación específica. El identificador completo sigue el formato *usuario*@*base_de_autenticación*, como app_ventas fue creado en la base comercial, MongoDB califica su nombre con @comercial para distinguirlo de cuentas homónimas en otras bases de datos.
