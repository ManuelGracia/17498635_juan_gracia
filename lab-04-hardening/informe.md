# Informe

## Actividad 1 — Identificar la superficie de ataque
Se ejecutaron las consultas de inspección inicial para mapear la exposición del servidor:

```sql
SELECT version();
SHOW port;
SHOW listen_addresses;
SHOW ssl;
SHOW password_encryption;
SELECT pid, usename, datname, client_addr, client_port, application_name FROM pg_stat_activity;
```

#### Matriz de Registro de Superficie de Ataque Inicial:

| Elemento | Estado actual | ¿Es necesario? | Riesgo identificado |
| :--- | :--- | :--- | :--- |
| **Puerto PostgreSQL** | TCP 5432 | **SI** | Puerto por defecto conocido; sin firewall es blanco de escaneos automáticos. |
| **Interfaces de escucha** | `listen_addresses = '*'` | **NO** | Escucha en todas las interfaces de red (públicas y privadas). |
| **Conexiones remotas** | `0.0.0.0/0` en `pg_hba.conf` | **NO** | Cualquier host de Internet puede intentar autenticarse. |
| **Usuarios administrativos** | `postgres` usado por la app | **NO** | Sobreexposición con privilegios `SUPERUSER` innecesarios. |
| **SSL / TLS** | `ssl = off` | **NO** | Tráfico de red y credenciales transmitidas en texto plano. |
| **Métodos de autenticación**| `md5` / `trust` | **NO** | Susceptible a ataques de interceptación (*eavesdropping*) y *replay*. |


**¿Por qué conocer la superficie de ataque debe preceder al hardening?**

Porque no se puede proteger lo que se desconoce. Identificar la superficie de ataque permite mapear todos los puntos de entrada, servicios, interfaces y privilegios expuestos. Si se aplican medidas de hardening a ciegas, se corre el riesgo de dejar puertos o reglas permisivas abiertas por descuido, o por el contrario, interrumpir servicios legítimos por no comprender el flujo de conexiones operativas.


## Actividad 2 - Identificar los archivos de configuración
Se consultaron las rutas físicas del motor relacional:

```sql
SHOW config_file;   -- /var/lib/postgresql/data/postgresql.conf
SHOW hba_file;      -- /var/lib/postgresql/data/pg_hba.conf
SHOW ident_file;    -- /var/lib/postgresql/data/pg_ident.conf
SHOW data_directory;-- /var/lib/postgresql/data
SHOW log_directory; -- /var/lib/postgresql/data/log
```

**¿Por qué es importante conocer la ubicación física de estos archivos?**

Conocer la ubicación física es indispensable para:
1. **Administración de permisos en el SO:** Aplicar controles de acceso estrictos para evitar que usuarios locales lean credenciales o modifiquen reglas de autenticación.
2. **Gestión de Respaldos y Auditoría:** Asegurar que las políticas de seguridad se respalden en el control de versiones y que los archivos de registro (`log_directory`) estén protegidos contra alteración o borrado malicioso.
3. **Mantenimiento y Recuperación:** Aplicar cambios mediante herramientas de automatización y resolver incidentes de arranque.


## Actividad 3 - Revisar `listen_addresses`

**Diagnóstico**:
* **Configuración encontrada:** `listen_addresses = '*'`
* **Interfaces necesarias:** `10.10.10.20` y `127.0.0.1`.
* **Interfaces innecesarias:** Interfaces públicas conectadas a Internet o redes de usuarios finales.

**Análisis de Arquitecturas de Red**:
* **Arquitectura A (Directa):** `Internet -> Firewall -> Servidor PostgreSQL (5432)`.
* **Arquitectura B (Segmentada):** `Internet -X-> Firewall -> Red Privada (DMZ/App) -> Servidor PostgreSQL`.

**Explicación:** 

La **Arquitectura B** reduce drásticamente la exposición porque aísla físicamente la base de datos de Internet. En la Arquitectura B, un atacante externo no puede conectarse ni escanear directamente el puerto 5432, tendría que comprometer primero un servidor intermedio. Al combinar esta segmentación con `listen_addresses = '10.10.10.20'`, el motor ni siquiera escuchará tráfico que no provenga del segmento de red privada autorizado.


## Actividad 4 y 5 — Analizar reglas en `pg_hba.conf`

**Análisis de Regla Permisiva:**

Regla detectada: `host all all 0.0.0.0/0 md5`

1. **Bases de datos permitidas:** `all` (Todas las bases de datos de la instancia).
2. **Usuarios permitidos:** `all` (Todos los roles del sistema, incluyendo `postgres`).
3. **Direcciones de origen:** `0.0.0.0/0` (Cualquier dirección IP del planeta).
4. **Método de autenticación:** `md5` (Método vulnerable a ataques de hash de contraseña).
5. **Riesgo de exposición:** Expone el motor a ataques automatizados de fuerza bruta a nivel mundial y incrementa el riesgo de exfiltración de datos.
6. **Información requerida para restringirla:** Se necesita conocer la IP exacta del servidor de aplicaciones, el nombre de la base de datos operativa y el nombre del rol asignado a la aplicación.

#### Registro de Corrección:
* **Regla actual (Insegura):** `host all all 0.0.0.0/0 md5`
* **Origen necesario:** Subred de Servidores de Aplicación (`10.10.10.0/24`) y IP de DBA (`10.10.10.5/32`).
* **Base de datos:** `bd_comercial`
* **Usuario:** `app_comercial` / `dba_admin`
* **Regla propuesta (Segura):**
  ```Plaintext
  hostssl  bd_comercial  app_comercial  10.10.10.0/24  scram-sha-256
  hostssl  bd_comercial  dba_admin      10.10.10.5/32  scram-sha-256
  ```

## Actividad 6 y 7 - Revisar Autenticación

#### Verificación:
`SHOW password_encryption;` -> Retorna `scram-sha-256`.

#### Respuestas a Preguntas de Autenticación:
1. **Diferencia entre autenticación y autorización:**
   * **Autenticación:** Proceso de verificar la identidad de quien intenta conectarse (¿Quién eres? Ej. Validar usuario y contraseña).
   * **Autorización:** Proceso de verificar los permisos del usuario ya autenticado sobre los objetos del sistema (¿Qué tienes permitido hacer? Ej. `SELECT` en tabla `clientes`).
2. **Protección de `scram-sha-256`:** Protege contra ataques de interceptación mediante un esquema de desafío-respuesta con sal que evita la transmisión de la clave en la red, resiste ataques de diccionario/tablas rainbow y evita ataques de replay.
3. **Contraseña almacenada vs. Cifrado reversible:** El almacenamiento de contraseñas mediante `scram-sha-256` utiliza funciones hash criptográficas irreversibles de un solo sentido. No es cifrado reversible, el sistema nunca guarda ni puede reconstruir la contraseña en texto plano, solo compara el resultado matemático del proceso de verificación.
4. **Consecuencias de permisos excesivos con contraseña fuerte:** Si una cuenta tiene privilegios excesivos (ej. `SUPERUSER`), una vez autenticada exitosamente o en caso de sufrir una vulnerabilidad de SQL Injection a nivel de aplicación el atacante obtendrá control total sobre la base de datos, destruyendo cualquier barrera de seguridad previa.

## Actividad 8 y 9 - Roles y Cuentas de Servicio

**Tabla de Roles Identificados:**

| Rol | LOGIN | SUPERUSER | CREATEROLE | CREATEDB | Función / Propósito propuesto |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **`postgres`** | Sí | Sí | Sí | Sí | Cuenta nativa de administración del sistema (Uso local exclusivo). |
| **`dba_admin`**| Sí | Sí | Sí | Sí | Cuenta administrativa para el personal de DBA. |
| **`app_comercial`**| Sí | **No** | **No** | **No** | Cuenta de servicio para la aplicación web (Mínimo privilegio). |
| **`consulta_user`**| Sí | **No** | **No** | **No** | Cuenta de solo lectura para reportería y analítica. |

**¿Por qué no debería utilizarse una cuenta SUPERUSER para la aplicación?**

Porque violaría el principio de mínimo privilegio. Si la aplicación se conecta como `SUPERUSER` y sufre una falla de seguridad (como SQL Injection), el atacante podría ejecutar comandos del sistema operativo, alterar la configuración del motor, leer credenciales de otros usuarios o borrar bases de datos completas.

## Actividad 10 y 11 - Extensiones, Parámetros y Conexiones

#### Parámetros de Control de Recursos:
* `max_connections = 100`: Limita el número máximo de conexiones concurrentes para evitar el agotamiento de memoria RAM y CPU.
* `superuser_reserved_connections = 3`: Reserva slots de conexión exclusivos para que los administradores puedan conectarse y solucionar problemas cuando la base de datos alcance su capacidad máxima.
* `statement_timeout = 30000` (30s): Cancela automáticamente cualquier consulta individual que supere los 30 segundos, evitando bloqueos crónicos.
* `idle_in_transaction_session_timeout = 60000` (60s): Aborta sesiones que inician una transacción (`BEGIN`) y se quedan inactivas por más de 60 segundos, liberando cerrojos retendidos.

**¿Por qué mantener conexiones indefinidamente abiertas es un problema?**

Mantiene recursos asignados de memoria y descriptores de archivos ocupados en el servidor, además de sostener locks sobre tablas que impiden operaciones de mantenimiento o transacciones operativas, llevando al agotamiento de conexiones y denegación de servicio.

## Actividad 12 y 13 - Permisos del Sistema Operativo y Exposición de Red

**Revisión de Permisos en SO (Terminal de Linux):**
```bash
ls -ld /var/lib/postgresql/data        # drwx------ 19 postgres postgres (0700)
ls -l /var/lib/postgresql/data/*.conf  # -rw-------  1 postgres postgres (0600)
ss -lntp | grep 5432                   # LISTEN 10.10.10.20:5432, 127.0.0.1:5432
```

**¿Por qué no basta con proteger PostgreSQL con `GRANT` y `REVOKE` si los archivos del SO son legibles por otros?**

Porque `GRANT` y `REVOKE` son controles lógicos internos del motor PostgreSQL. Si un usuario del sistema operativo tiene permisos de lectura sobre los archivos de la base de datos, puede saltarse completamente el motor de base de datos, leer los archivos de configuración (`pg_hba.conf`, certificados TLS) o copiar directamente los archivos físicos de tablas (`PGDATA`) para analizarlos fuera del servidor sin pasar por la autenticación de PostgreSQL.

## Actividad 14 y 15 - Política de Firewall y Cifrado TLS

**Matriz Conceptual de Firewall:**

| Origen | Destino | Puerto | Acción | Justificación |
| :--- | :--- | :---: | :---: | :--- |
| `10.10.10.0/24` (Subnet App) | `10.10.10.20` | TCP 5432 | **Permitir** | Tráfico legítimo de la aplicación web. |
| `10.10.10.5/32` (IP DBA) | `10.10.10.20` | TCP 5432 | **Permitir** | Administración remota autorizada. |
| `0.0.0.0/0` (Cualquier otro) | `10.10.10.20` | TCP 5432 | **Denegar** | Bloqueo por defecto de cualquier tráfico no autorizado. |

**¿Por qué `pg_hba.conf` y el firewall no son controles equivalentes?**

Pertenecen a diferentes capas del modelo OSI:
* **Firewall (Capa de Red/Transporte - Capas 3 y 4):** Bloquea o permite paquetes IP antes de que lleguen al proceso de PostgreSQL. Evita que el motor consuma CPU procesando apretones de manos TCP no autorizados.
* **`pg_hba.conf` (Capa de Aplicación - Capa 7):** Aplica la política de autenticación interna de PostgreSQL una vez establecida la conexión TCP. Controla a qué base de datos y con qué rol específico se permite ingresar. Ambos son complementarios en una estrategia de **Defensa en Profundidad**.

## Caso Integral

**Identificación de 10 Problemas o Riesgos y Controles Propuestos:**

| # | Problema Identificado | Riesgo Asociado | Control Técnico Propuesto |
| :---: | :--- | :--- | :--- |
| **1** | Acepta conexiones desde cualquier IPv4 (`0.0.0.0/0`). | Ataques globales de fuerza bruta y escaneo. | Modificar `pg_hba.conf` limitando la IP al segmento `10.10.10.0/24`. |
| **2** | La aplicación web usa un usuario con privilegios `SUPERUSER`. | Exfiltración total y ejecución de comandos en SO por SQLi. | Crear el rol `app_comercial` con privilegios strictly operativos. |
| **3** | El servidor escucha en todas las interfaces (`listen_addresses='*'`). | Exposición del puerto 5432 en la red pública de Internet. | Ajustar `listen_addresses = '10.10.10.20, 127.0.0.1'`. |
| **4** | El firewall permite el puerto 5432 desde cualquier origen. | Tráfico malicioso directo alcanzando el daemon de PostgreSQL. | Implementar regla *Default Deny* en el firewall de host (`ufw`). |
| **5** | Regla `all/all` permisiva en `pg_hba.conf`. | Acceso a cualquier base de datos por cualquier usuario. | Especificar la BD `bd_comercial` y usuario `app_comercial` en `pg_hba.conf`. |
| **6** | Dependencia exclusiva en la "fortaleza de la contraseña". | Vulnerable a ingeniería social, phishing, o fugas de código. | Implementar Defensa en Profundidad (Red + SO + RBAC + TLS). |
| **7** | Ausencia de cifrado SSL/TLS forzado. | Interceptación de credenciales en la red local/privada. | Configurar `ssl = on` con `ssl_min_protocol_version = 'TLSv1.3'`. |
| **8** | Método de autenticación inseguro o heredado (`md5`/`trust`). | Suceptible a captura de hashes o evasión de autenticación. | Configurar `password_encryption = 'scram-sha-256'`. |
| **9** | Sin límites de tiempo de espera (*timeouts*) en consultas. | Denegación de Servicio (DoS) por agotamiento de recursos. | Ajustar `statement_timeout = 60s` e `idle_in_transaction_session_timeout = 5m`. |
| **10**| Sin permisos restringidos en archivos de configuración del SO. | Lectura de credenciales por usuarios locales no autorizados. | Aplicar `chmod 0600` a archivos `.conf` y `chmod 0700` a `PGDATA`. |

**¿Es suficiente tener contraseñas fuertes?**

No. Una contraseña fuerte es únicamente un control de autenticación. Si un atacante aprovecha una vulnerabilidad en la red (escuchando el tráfico sin TLS), una falla en el software (SQL Injection), una mala configuración de permisos en el sistema operativo (leyendo el archivo de configuración con la clave), o un agotamiento de recursos por falta de timeouts, la fortaleza de la contraseña queda completamente anulada. La seguridad requiere la integración de Autenticación + Autorización + Control de Red + Seguridad en SO + Monitoreo.

## Preguntas

1. **¿Cuál era la principal superficie de ataque?**
   * La combinación de `listen_addresses = '*'` escuchando en la interfaz pública con una regla `0.0.0.0/0` en `pg_hba.conf` y firewall abierto.

2. **¿Qué configuración representaba el mayor riesgo?**
   * El uso de una cuenta con privilegios `SUPERUSER` por parte de la aplicación web, combinado con la exposición pública del puerto 5432.

3. **¿Qué cambio produjo la mayor reducción de exposición?**
   * Restringir `listen_addresses` a la IP privada y reemplazar la regla `0.0.0.0/0` por una allowlist estricta en `pg_hba.conf`.

4. **¿Qué diferencia existe entre firewall y `pg_hba.conf`?**
   * El firewall filtra paquetes a nivel de red (IP/puerto TCP), mientras que `pg_hba.conf` evalúa la identidad del usuario, la base de datos solicitada y el método de autenticación a nivel de aplicación.

5. **¿Qué diferencia existe entre autenticación y autorización?**
   * Autenticación valida la identidad del usuario (quién es); autorización determina los permisos asignados a esa identidad sobre las tablas y funciones (qué puede hacer).

6. **¿Por qué una cuenta de aplicación no debe ser SUPERUSER?**
   * Para limitar el impacto de vulnerabilidades tipo SQL Injection, evitando que un atacante tome control total del motor o ejecute comandos a nivel de sistema operativo.

7. **¿Por qué cambiar el puerto de PostgreSQL no constituye hardening suficiente?**
   * Porque es solo "seguridad por obscuridad". Los escáneres de puertos automatizados identifican el servicio PostgreSQL en cuestión de segundos independientemente del puerto en que escuche.

8. **¿Por qué `listen_addresses='*'` puede ser innecesario?**
   * Porque un servidor de base de datos generalmente solo necesita comunicarse con el servidor de aplicaciones dentro de una red privada específica y no con todas las interfaces de red del servidor.

9. **¿Qué papel tiene el sistema operativo en la seguridad de PostgreSQL?**
   * Proporciona la capa física y de aislamiento base: gestiona los permisos de archivos, la cuenta de usuario que ejecuta el servicio, los certificados SSL/TLS y las reglas del firewall de host.

10. **¿Qué controles deberían revisarse periódicamente?**
    * Cuentas y roles activos (`pg_roles`), reglas en `pg_hba.conf`, logs de conexiones fallidas, parches de seguridad de PostgreSQL y permisos en el sistema operativo.

## Reflexión

**¿Qué cambiarías primero si recibieras la responsabilidad de asegurar un servidor PostgreSQL que ya se encuentra funcionando en producción?**

Si recibiera la responsabilidad de asegurar un servidor PostgreSQL que ya opera en producción, mi primer cambio inmediato sería revisar y restringir las reglas de acceso en `pg_hba.conf` y el Firewall, asegurando que solo las IP de los servidores de aplicación legítimos puedan conectarse.

1. **Riesgo y Exposición:** Un servidor expuesto a `0.0.0.0/0` o escuchando en interfaces públicas está bajo ataque constante e ininterrumpido de bots automatizados de fuerza bruta. Cortar el acceso no autorizado en la red elimina inmediatamente el 99% del tráfico malicioso externo.
2. **Disponibilidad y Continuidad:** Modificar `pg_hba.conf` y ejecutar `SELECT pg_reload_conf();` **NO requiere reiniciar el servicio de PostgreSQL**. Por lo tanto, se logra una reducción crítica e inmediata del riesgo sin causar tiempo de inactividad (*zero downtime*) ni afectar las operaciones activas de la empresa.
3. **Mínimo Impacto Operativo:** A diferencia de revocar permisos SQL o cambiar nombres de usuario de la aplicación (que romperían la aplicación si no se coordina un despliegue de software), restringir el acceso por IP para permitir únicamente las fuentes autorizadas existentes protege el entorno de forma transparente sin alterar el funcionamiento del software productivo.

Posteriormente, en ventanas de mantenimiento programadas, aplicaría la separación de roles (`SUPERUSER`), la activación de TLS y los ajustes en el sistema operativo.
