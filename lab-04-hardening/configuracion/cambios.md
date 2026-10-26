# Registro de Cambios y Checklist de Hardening


## 1. Comparativa de Configuración (Antes vs. Después)

| Control | Estado Inicial (Antes) | Estado Endurecido (Después) | Justificación Técnica de Seguridad |
| :--- | :--- | :--- | :--- |
| **`listen_addresses`** | `*` (Todas las interfaces) | `10.10.10.20, 127.0.0.1` | Reduce la exposición de la interfaz pública a la red privada autorizada. |
| **`pg_hba.conf`** | `host all all 0.0.0.0/0 md5` | `hostssl bd_comercial app_comercial 10.10.10.0/24 scram-sha-256` | Elimina el acceso global irrestricto imponiendo una allowlist por red, BD y usuario. |
| **Método de Autenticación** | `md5` / `trust` | `scram-sha-256` | Ofrece resistencia contra ataques de diccionario, replay attacks y fugas de hash. |
| **Usuarios Administrativos** | Conexiones de app usaban `postgres` | `dba_admin` para DBA; `app_comercial` para app | Aplica el principio de mínimo privilegio y evita que la app controle el motor. |
| **Cuentas de Aplicación** | Rol con privilegios `SUPERUSER` | Rol limitado (`NOSUPERUSER`, `NOCREATEDB`, `NOCREATEROLE`) | Mitiga el impacto de vulnerabilidades tipo SQL Injection en la aplicación web. |
| **Puerto de Escucha** | TCP 5432 (Sin firewall de host) | TCP 5432 (Con firewall restringido a IP/Subnet) | Impide el escaneo de puertos desprotegido desde segmentos no autorizados. |
| **Cifrado en Tránsito (TLS)** | `ssl = off` | `ssl = on` (`TLSv1.3`) | Previene el espionaje (*eavesdropping*) y ataques *Man-in-the-Middle* en la red. |
| **Permisos de Archivos SO** | `0644` (Lectura para otros usuarios) | `0600` (Exclusivo para el usuario `postgres`) | Evita que usuarios locales lean credenciales o parámetros de configuración. |
| **Permisos de Directorio PGDATA**| `0755` | `0700` | Garantiza que ningún usuario del SO excepto `postgres` acceda a las tablas físicamente. |
| **Extensiones Instaladas** | Varias extensiones de prueba | Exclusivamente extensiones auditadas y requeridas | Minimiza la superficie de código ejecutable dentro del motor de la base de datos. |
| **Control de Conexiones** | `statement_timeout = 0` (Indefinido) | `statement_timeout = 60000` (60s) | Protege la disponibilidad del servidor contra consultas bloqueantes o ataques DoS. |



## 2. Lista de Verificación de Hardening (Hardening Checklist)

|  | Control de Seguridad | Criterio de Verificación | Estado | Evidencia / Referencia |
| :---: | :--- | :--- | :---: | :--- |
| **1** | Puerto PostgreSQL Documentado | Se conoce y documenta el puerto de escucha (TCP 5432). | **VERIFICADO** | `SHOW port;` -> `5432` |
| **2** | Interfaces de Escucha Restringidas | `listen_addresses` no contiene `*` ni `0.0.0.0`. | **VERIFICADO** | `SHOW listen_addresses;` -> `10.10.10.20, localhost` |
| **3** | `pg_hba.conf` Auditado | Sin reglas con direcciones `0.0.0.0/0` o `::/0`. | **VERIFICADO** | Consulta sobre `pg_hba_file_rules` |
| **4** | Redes Autorizadas Acotadas | Conexiones remotas limitadas a subredes específicas. | **VERIFICADO** | Subred `10.10.10.0/24` en `pg_hba.conf` |
| **5** | Autenticación Robusta Activa | Uso exclusivo de `scram-sha-256` para claves. | **VERIFICADO** | `SHOW password_encryption;` |
| **6** | Superusuarios Identificados | Únicamente la cuenta de administración tiene `SUPERUSER`. | **VERIFICADO** | Consulta sobre `pg_roles` |
| **7** | Cuentas de Aplicación Separadas | La aplicación utiliza una cuenta no administrativa. | **VERIFICADO** | Rol `app_comercial` en `pg_roles` |
| **8** | Privilegios Mínimos Aplicados | Revocados permisos por defecto de `PUBLIC` en esquema. | **VERIFICADO** | `REVOKE ALL ON SCHEMA public FROM PUBLIC;` |
| **9** | Extensiones Revisadas | Inventario de extensiones validado sin componentes extra. | **VERIFICADO** | Consulta sobre `pg_extension` |
| **10** | Cifrado TLS/SSL Forzado | Conexiones cifradas bajo TLSv1.3 activas. | **VERIFICADO** | `SHOW ssl;` -> `on` (`TLSv1.3`) |
| **11** | Archivos de Configuración Protegidos | Permisos del SO en `pg_hba.conf` y `postgresql.conf` son `0600`. | **VERIFICADO** | `ls -l /var/lib/postgresql/data/*.conf` |
| **12** | Directorio de Datos Protegido | Permisos en `PGDATA` son `0700` (`postgres:postgres`). | **VERIFICADO** | `ls -ld /var/lib/postgresql/data` |
| **13** | Firewall de Host Configurado | Reglas de iptables/ufw bloquean orígenes no autorizados. | **VERIFICADO** | Política de Denegación por Defecto |
| **14** | Bitácoras de Conexión Habilitadas | `log_connections` y `log_disconnections` activos. | **VERIFICADO** | Parámetros de auditoría en `postgresql.conf` |
| **15** | Control de Timeouts Configurado | `statement_timeout` e `idle_in_transaction_session_timeout` fijados.| **VERIFICADO** | `SHOW statement_timeout;` |
| **16** | Política de Parches Documentada | Procedimiento de actualización continua definido. | **VERIFICADO** | Documentado en `baseline.md` |
| **17** | Verificación Final Ejecutada | Verificación completa posterior a hardening exitosa. | **VERIFICADO** | Suite `sql/04-verificacion.sql` completada |
