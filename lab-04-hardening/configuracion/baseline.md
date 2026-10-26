# Línea Base de Seguridad - Baseline


## 1. Red y Control de Acceso Perimetral

* **listen_addresses:** Configurado en `10.10.10.20, 127.0.0.1`. Se prohíbe explícitamente el uso de wildcards (`*` o `0.0.0.0`).
* **Puerto de Servicio:** TCP 5432.
* **Firewall perimetral y de host:**
  * **Regla de Entrada (*Inbound*):** Permitir TCP 5432 únicamente desde el segmento de servidores de aplicación (`10.10.10.0/24`) y desde la IP de administración del DBA (`10.10.10.5/32`).
  * **Regla por Defecto:** Denegar explícitamente todo el tráfico entrante no autorizado.
* **Segmentación:** La base de datos debe residir en una VLAN privada de datos (*DB Subnet*) sin direccionamiento ni enrutamiento hacia Internet.



## 2. Autenticación y Control de Host (`pg_hba.conf`)

* **Mecanismo de Autenticación:** Se exige `scram-sha-256` para todas las conexiones TCP/IP remotas y locales. Se prohíben métodos heredados o inseguros (`md5`, `trust`, `password`).
* **Política de Allowlist en `pg_hba.conf`:**
  * Conexiones locales de administración del SO: Método `peer` exclusivo para el usuario del sistema `postgres`.
  * Conexiones de aplicación: `hostssl bd_comercial app_comercial 10.10.10.0/24 scram-sha-256`.
  * Conexiones administrativas remotas: `hostssl bd_comercial dba_admin 10.10.10.5/32 scram-sha-256`.
* **Prohibición de Wildcards:** Queda strictly prohibida cualquier regla con origen `0.0.0.0/0` o `::/0`.

## 3. Autorización y Gestión de Roles (Mínimo Privilegio)

* **Separación de Cuentas:**
  * **Superusuario (`postgres` / `dba_admin`):** Reservado exclusivamente para mantenimiento de infraestructura y emergencias. Prohibido su uso en aplicaciones.
  * **Cuenta de Servicio/Aplicación (`app_comercial`):** Atributos `NOSUPERUSER`, `NOCREATEDB`, `NOCREATEROLE`. Permisos limitados a `SELECT`, `INSERT`, `UPDATE`, `DELETE` sobre las tablas operativas del esquema asignado.
  * **Cuenta de Consulta/Reportes (`usr_consulta`):** Atributos `NOSUPERUSER`, `NOCREATEDB`, `NOCREATEROLE`, permisos restringidos a `SELECT` (Solo Lectura).
* **Esquema `public`:** Se revocan todos los permisos por defecto a `PUBLIC` (`REVOKE ALL ON SCHEMA public FROM PUBLIC`).


## 4. Configuración del Servidor y Gestión de Recursos

* **Cifrado en Tránsito:** SSL/TLS activo obligatoriamente (`ssl = on`), versión mínima obligatoria `TLSv1.3`.
* **Auditoría y Registros:**
  * `log_connections = on`
  * `log_disconnections = on`
  * Prefix de bitácora: `%m [%p] %u@%d %h ` (Fecha, PID, usuario, BD e IP de origen).
* **Mitigación de DoS y Control de Sesiones:**
  * `statement_timeout = 30000` (Timeout de ejecución de consultas: 30 segundos).
  * `idle_in_transaction_session_timeout = 60000` (Timeout de transacciones inactivas colgadas: 60 segundos).
  * `max_connections = 100` (Sintonizado según la capacidad de memoria del servidor).


## 5. Seguridad del Sistema Operativo

* **Usuario de Ejecución:** El servicio de PostgreSQL debe ejecutarse bajo una cuenta de servicio dedicada no privilegiada (`postgres`).
* **Permisos del Directorio de Datos:** Propietario `postgres:postgres`, permisos de directorio `0700` (`drwx------`).
* **Permisos de Archivos de Configuración:** Propietario `postgres:postgres`, permisos `0600` (`-rw-------`) para `postgresql.conf`, `pg_hba.conf` y `pg_ident.conf`.
* **Máscara de Creación:** Configurada en `0077` para evitar que otros usuarios del SO lean archivos generados por la BD.


## 6. Mantenimiento, Parches y Gestión de Cambios

* **Política de Actualización:** Aplicación de parches secundarios de seguridad de PostgreSQL 16 dentro de los 30 días posteriores a su liberación oficial.
* **Revisiones Periódicas:** Auditoría trimestral de cuentas activas, revisión de reglas `pg_hba.conf` y verificación de integridad de permisos en el sistema operativo.
* **Control de Versiones:** Todos los cambios en la configuración deben registrarse mediante scripts SQL (`ALTER SYSTEM`) e integrarse en el repositorio de infraestructura como código (IaC).
