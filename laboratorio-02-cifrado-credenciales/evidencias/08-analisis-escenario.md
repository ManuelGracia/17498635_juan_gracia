# Actividad 8 - Analizar un escenario de seguridad

### 1. **¿Cuáles son los principales riesgos?**
* **Contraseñas en texto claro**: Quien lea la tabla obtiene las credenciales de todos los usuarios y puede suplantarlos de inmediato. Además, por la reutilización de contraseñas, el daño se extiende a cuentas en otros servicios.

* **RFC en texto claro**: Exposición directa de datos personales de los clientes, con riesgo de suplantación de identidad y fraude, y posibles sanciones por incumplimiento de la LFPDPPP u otras normativas.

* **Conexiones sin validación adecuada del servidor**: Aunque el tráfico vaya cifrado, si el cliente no verifica el certificado, un atacante puede hacerse pasar por el servidor (man-in-the-middle), leer o modificar consultas y resultados, y capturar credenciales y datos financieros.

* **Claves criptográficas en archivos SQL**: Las claves terminan en repositorios Git, logs, historiales y copias del equipo. Quien las obtenga puede descifrar todo lo que protegen y borrar el archivo no basta porque queda en el historial.

* **Respaldos sin protección adicional**: Un respaldo contiene toda la base de datos y normalmente queda fuera de los controles de usuarios y roles. Si se pierde, se roba o se copia, el atacante accede a toda la información sin tocar el servidor.

### 2. **¿Qué mecanismo utilizarías para cada elemento?**

* **Nombre**: Control de acceso (roles y GRANT/REVOKE) y TLS en tránsito. Es dato personal, pero rara vez requiere cifrado por columna.

* **Correo electrónico**: Control de acceso y TLS. Si se considera sensible o se usa como identificador, puede cifrarse.

* **Contraseña**: Hash con sal y factor de costo, nunca cifrado reversible.

* **RFC**: Cifrado simétrico con la clave fuera de la base de datos.

* **Información financiera**: Cifrado simétrico a nivel de columna o de aplicación, permisos restringidos al mínimo necesario, auditoría de accesos y TLS en tránsito.

* **Claves criptográficas**: Gestor de secretos o KMS (HashiCorp Vault, AWS KMS), con acceso restringido, rotación periódica y jamás en código, SQL ni repositorios.

* **Conexiones**: TLS habilitado en el servidor (ssl = on, mínimo TLS 1.2) y clientes con sslmode=verify-full para validar el certificado y el nombre del servidor.

* **Respaldos**: Cifrado del archivo, almacenamiento con control de acceso y cifrado en reposo, claves guardadas por separado y si viajan por la red, TLS o SSH.

### 3. **¿Cuál problema consideras más crítico y por qué?**

El más crítico es las claves criptográficas expuestas en archivos SQL, porque es el fallo que invalida todas las demás protecciones. Si se corrigieran el RFC (cifrado), los respaldos (cifrados) y la información financiera, pero la clave estuviera publicada, un atacante con cualquier copia de los datos podría descifrarlos todos. Es un punto único de fallo, ya que compromete simultáneamente la base, los respaldos y cualquier dato cifrado con esa clave, y su remediación es costosa (rotar la clave, recifrar todo, limpiar el historial, tratar el hecho como incidente).

### 4. **¿Tener correctamente configurados los usuarios y permisos elimina estos riesgos?**

No. Usuarios y roles aplican el principio de mínimo privilegio, pero solo controlan quién puede pedirle datos al motor de base de datos. No protegen los datos cuando el acceso ocurre por otras vías