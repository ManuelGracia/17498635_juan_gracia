# Actividad 11 — Crear la función y el disparador

**1. ¿Por qué se ejecuta REVOKE ALL ON FUNCTION ... FROM PUBLIC si el disparador seguirá funcionando para app_ventas?**

Porque los disparadores son invocados internamente por el motor de PostgreSQL a nivel de núcleo cuando se ejecuta una operación DML (INSERT, UPDATE, DELETE) sobre la tabla auditada. El usuario que ejecuta la consulta no requiere permisos de ejecución directa (EXECUTE) sobre la función del disparador para que este se active.

Revocar el permiso EXECUTE a PUBLIC es una medida de endurecimiento que impide que un usuario malicioso o una cuenta de aplicación (app_ventas, soporte_ana) invoque la función directamente desde una consulta SQL (por ejemplo, mediante SELECT auditoria.registrar_cambio_cliente()), lo que permitiría inyectar registros falsos en la tabla de auditoría, causar excepciones en la sesión o alterar la integridad del registro forense.

**2. ¿Qué pasaría si la función no fuera SECURITY DEFINER?**

Si se omite SECURITY DEFINER, la función se ejecutará con el comportamiento por defecto (SECURITY INVOKER), utilizando la identidad y los privilegios del rol que invoca la consulta (por ejemplo, app_ventas).

Hipótesis de comportamiento:
Dado que el rol app_ventas solo posee privilegios de SELECT y UPDATE sobre la tabla clientes y se le ha revocado el acceso al esquema auditoria, al intentar modificar la tabla clientes, el disparador intentará insertar una fila en auditoria.cambios_clientes bajo los permisos de app_ventas. Esto provocará que PostgreSQL aborte inmediatamente la transacción con un error de autorización:

```Plaintext
ERROR: permission denied for schema auditoria
-- o --
ERROR: permission denied for table cambios_clientes
```

En consecuencia, app_ventas no podrá realizar ninguna inserción, actualización ni borrado en la tabla del negocio. SECURITY DEFINER permite que la función se ejecute con los privilegios de su propietario (el DBA/superusuario), haciendo posible que el disparador escriba en la tabla de auditoría de forma transparente sin tener que otorgar permisos de escritura a app_ventas en el esquema de auditoría.

**3. Consulta a dba.bitacora. ¿Quedó registrada la creación del esquema, la tabla, la función y el disparador? ¿Por qué?**

Sí, quedaron registradas en la bitácora.

Las sentencias CREATE SCHEMA, CREATE TABLE, CREATE FUNCTION, CREATE TRIGGER y REVOKE pertenecen a la categoría DDL (Lenguaje de Definición de Datos) y DCL (Lenguaje de Control de Datos, que PostgreSQL procesa en el nivel DDL).

Dado que en las actividades previas se configuró log_statement = 'ddl' (o 'mod'), el motor intercepta y escribe obligatoriamente en el archivo de registro la línea con el prefijo LOG: statement: para cualquier comando que altere la estructura de los objetos o los metadatos de los catálogos del sistema.