# LAB-04 - Hardening y Configuración Segura de PostgreSQL

## Objetivo
Aplicar un proceso integral de hardening sobre una instancia de PostgreSQL 16 para la empresa ficticia Comercializadora Norte S.A. de C.V., reduciendo su superficie de ataque mediante la restricción de interfaces de escucha, el endurecimiento de reglas en `pg_hba.conf`, la aplicación de autenticación robusta (`scram-sha-256`), el cifrado TLSv1.3, el principio de mínimo privilegio en roles y la protección de archivos sensibles a nivel de sistema operativo.

## Entorno
* **Motor de Base de Datos:** PostgreSQL 16.2
* **Sistema Operativo:** Ubuntu 26.04.1 LTS
* **IP de la Base de Datos:** `10.10.10.20`
* **Segmento de Aplicación:** `10.10.10.0/24`
* **IP del Administrador (DBA):** `10.10.10.5`

## Superficie de Ataque Inicial
Antes del proceso de hardening, el servidor presentaba las siguientes condiciones de vulnerabilidad:
1. `listen_addresses = '*'` (El servicio escuchaba en todas las interfaces de red públicas y privadas).
2. Regla permisiva en `pg_hba.conf`: `host all all 0.0.0.0/0 md5` (Aceptaba conexiones desde cualquier IP del mundo).
3. Conexión de la aplicación mediante la cuenta administrativa `postgres` (`SUPERUSER`).
4. Ausencia de cifrado SSL/TLS obligatorio en las comunicaciones de red.
5. Permisos permisivos (`0644` / `0755`) en el directorio de datos y archivos `.conf` en el sistema operativo.
6. Sin límites de tiempo de espera para consultas colgadas o transacciones inactivas.

## Hallazgos
* **Inseguridad por defecto:** La configuración inicial permitía que cualquier host en la red intentara ataques de fuerza bruta contra el puerto 5432.
* **Sobreexposición por SQL Injection:** Al usar la cuenta `postgres` en la aplicación web, una vulnerabilidad en la capa de software le otorgaría a un atacante control absoluto sobre el motor de base de datos y posibilidad de ejecutar comandos en el sistema operativo.
* **Falta de confidencialidad en tránsito:** Las credenciales y datos viajaban en texto plano o con hashes vulnerables.

## Cambios Realizados
1. **Reducción de Red:** Modificación de `listen_addresses` a `'10.10.10.20, 127.0.0.1'`.
2. **Allowlist en `pg_hba.conf`:** Eliminación de `0.0.0.0/0`. Inclusión de reglas por host/usuario/BD específicas con método `scram-sha-256`.
3. **Cifrado TLS:** Activación de SSL/TLS imponiendo `TLSv1.3`.
4. **Separación de Roles:** Creación del rol `app_comercial` sin privilegios administrativos y revocación de permisos públicos en el esquema `public`.
5. **Aislamiento en Sistema Operativo:** Ajuste de permisos en `PGDATA` a `0700` y archivos `.conf` a `0600` asignados a `postgres:postgres`.
6. **Protección de Recursos:** Configuración de `statement_timeout = 30s` e `idle_in_transaction_session_timeout = 60s`.

## Justificación de los Cambios
Cada cambio realizado reduce directamente la probabilidad o el impacto de un incidente de seguridad:
* Restringir las interfaces elimina los vectores de ataque desde redes no autorizadas.
* Forzar `scram-sha-256` previene la captura y reutilización de credenciales.
* Remover el estatus `SUPERUSER` de la aplicación limita el radio del daño ante una intrusión.
* Asignar permisos estrictos en el SO previene la escalada de privilegios local.

## Verificación

* Cero reglas wildcard permisivas en `pg_hba_file_rules`.
* Forzado de conexiones TLSv1.3 verificado en `pg_stat_ssl`.
* Aislamiento de cuentas de aplicación confirmado en `pg_roles`.
* Ejecución de verificación final exitosa.

## Conclusiones
El hardening de bases de datos no es una medida aislada, sino un proceso de Defensa en Profundidad que entrelaza la red, el sistema operativo, la configuración del motor relacional y el diseño de roles. Reducir la superficie de ataque inicial transforma un servidor expuesto e inestable en un entorno seguro y resiliente.
