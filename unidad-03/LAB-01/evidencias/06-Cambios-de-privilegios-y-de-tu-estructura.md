# **Actividad 6** — Cambios de privilegios y de estructura

**1. ¿Qué tipo de evento es cada una de las tres primeras sentencias?**

REVOKE UPDATE ON clientes FROM soporte_ana; 
-> Privilegio (Evento de control de acceso / DCL).

GRANT UPDATE ON clientes TO app_ventas; -> Privilegio (Evento de control de acceso / DCL).

ALTER TABLE clientes ADD COLUMN segmento VARCHAR(20); -> Estructura (Evento de definición de esquema / DDL).

**2. ¿Por qué GRANT y REVOKE quedan registrados con log_statement = 'ddl'?**

PostgreSQL incluye las sentencias GRANT, REVOKE y COMMENT dentro de la categoría ddl porque modifican los metadatos y la estructura de seguridad de los objetos almacenados en los catálogos del sistema. Para el motor de la base de datos, alterar las reglas de autorización asociadas a un objeto es una modificación directa a la definición de ese objeto dentro del catálogo.

**3. Si la bitácora contiene contraseñas, ¿quién debería poder leerla? Relaciónalo con la gestión de secretos de la Unidad II.**

* ¿Quién debe leerla?: Únicamente el Administrador de Base de Datos (DBA) y los Oficiales de Auditoría / Seguridad de la Información formalmente autorizados.

**Relación con la Unidad II:**

* Conversión del archivo de log en activo sensible: En la Unidad II se estableció que las credenciales nunca deben almacenarse ni transmitirse en texto plano. Si se ejecutan sentencias con contraseñas explícitas (CREATE ROLE ... PASSWORD '...'), la bitácora se transforma inmediatamente en un archivo con secretos expuestos.

* Uso obligatorio de resúmenes criptográficos: Se debe evitar incluir claves explícitas en SQL. Al utilizar metacomandos como \password, el cliente calcula el resumen criptográfico SCRAM-SHA-256 localmente y solo transmite el hash al servidor, impidiendo que la contraseña plana quede en el archivo de registro.

* Controles de acceso estrictos (Defensa en profundidad): Como no siempre se puede garantizar que los desarrolladores o administradores eviten escribir secretos en sentencias SQL, los archivos de log deben estar estrictamente protegidos a nivel de sistema operativo (permisos 0600 exclusivos para el usuario postgres) y en la base de datos mediante esquemas aislados (dba.bitacora), asegurando que cuentas operativas o de aplicación (app_ventas, soporte_ana) no puedan leer el archivo y exfiltrar credenciales.