# **Actividad 10** — Diseñar y crear el registro de auditoría

**Matriz de Diseño de Auditoría:**

| Campo propuesto | Tipo de Dato | ¿Qué pregunta de Dirección responde? | ¿Puede ser nulo? | Justificación / Explicación Técnico-Forense |
| :--- | :--- | :--- | :---: | :--- |
| **`id_evento`** | `BIGSERIAL` | *N/A (Identificador único de evidencia)* | **NO** | Es la clave primaria (`PRIMARY KEY`) de la tabla de auditoría; garantiza la unicidad y el orden cronológico estricto de los eventos. |
| **`momento`** | `TIMESTAMPTZ` | **2. ¿Cuándo?** | **NO** | Registra la marca de tiempo exacta del cambio con zona horaria (`now()`), indispensable para la correlación forense multi-región. |
| **`usuario_sesion`** | `TEXT` | **1. ¿Quién hizo el cambio?** | **NO** | Captura la identidad real autenticada (`session_user`), garantizando el no repudio aunque se utilicen funciones `SECURITY DEFINER`. |
| **`usuario_efectivo`** | `TEXT` | **1. ¿Quién hizo el cambio?** | **NO** | Captura el rol cuyos privilegios están vigentes (`current_user`), permitiendo identificar la cuenta ejecutora en el motor. |
| **`aplicacion`** | `TEXT` | **3. ¿Desde qué aplicación o equipo?** | **SÍ** | Captura `application_name`. Puede ser nulo si el cliente o controlador no especifica una cadena de identificación al conectarse. |
| **`ip_cliente`** | `INET` | **3. ¿Desde qué aplicación o equipo?** | **SÍ** | Registra `inet_client_addr()`. Es nulo cuando la conexión se realiza localmente mediante sockets de dominio Unix (`[local]`). |
| **`operacion`** | `TEXT` | *N/A (Clasificación de acción DML)* | **NO** | Define la operación ejecutada (`INSERT`, `UPDATE`, `DELETE`), requerida para categorizar el tipo de alteración realizada. |
| **`id_cliente`** | `BIGINT` | *N/A (Identificador de objeto afectado)* | **NO** | Almacena la clave primaria del registro afectado en la tabla `clientes`, vinculando la evidencia con la entidad del negocio. |
| **`valores_antes`** | `JSONB` | **5. ¿Qué valor tenía el RFC antes del cambio?** | **SÍ** | Guarda la fotografía completa previa al cambio (`OLD`). Es nulo en operaciones de inserción (`INSERT`). |
| **`valores_despues`** | `JSONB` | *N/A (Estado resultante post-operación)* | **SÍ** | Guarda la fotografía completa posterior al cambio (`NEW`). Es nulo en operaciones de borrado (`DELETE`). |

---

**1. ¿Por qué momento usa TIMESTAMPTZ y no TIMESTAMP?**

TIMESTAMPTZ (TIMESTAMP WITH TIME ZONE) almacena el instante exacto en tiempo absoluto convertido internamente a UTC junto con el desplazamiento de la zona horaria del origen.

A diferencia de TIMESTAMP (que guarda una fecha/hora "ciega" sin contexto geográfico), TIMESTAMPTZ previene la ambigüedad al reconstruir cronologías e investigaciones forenses cuando las conexiones provienen de servidores o clientes ubicados en distintos husos horarios (por ejemplo, Etc/UTC frente a America/Mazatlan), o cuando ocurren ajustes por horario de verano.

**2. ¿Por qué se guarda el registro completo en JSONB y no solo la columna que cambió?**

* Resiliencia ante cambios de esquema (DDL): Si la estructura de la tabla clientes se modifica en el futuro (agregando o eliminando columnas), la tabla de auditoría no requiere mantenimiento ni migraciones DDL, ya que JSONB abstrae dinámicamente cualquier campo.

* Integridad y contexto del registro: Al guardar la fotografía completa (OLD y NEW), se preserva el estado de todos los atributos correlacionados en el instante exacto del cambio, permitiendo auditar el impacto del evento sin depender del estado actual de la base de datos.

* Eficiencia de consulta: El formato binario JSONB permite realizar indexing (GIN) y búsquedas eficientes sobre claves o valores específicos mediante operadores nativos como ->> y @>.

**3. La tabla de auditoría también contendrá RFC. ¿Qué implica eso para su clasificación y su control de acceso?**

* Clasificación de la Información: Al incorporar campos como el RFC, nombres o correos electrónicos, la tabla auditoria.cambios_clientes hereda la clasificación de Información Confidencial / Datos Personales Identificables (PII) bajo normativas de privacidad.

**Control de Acceso:**

* Aislamiento por Esquema: Requiere mantener los privilegios revocados a la comunidad (REVOKE ALL ON SCHEMA auditoria FROM PUBLIC;) y prohibir el acceso de lectura a las cuentas de aplicación (app_ventas) o de soporte (soporte_ana).

* Inmutabilidad de la Evidencia: Los usuarios ordinarios no deben tener permisos de UPDATE o DELETE sobre la tabla de auditoría. Las inserciones se deben gestionar únicamente mediante un disparador ejecutado con privilegios SECURITY DEFINER, reservando la lectura exclusiva al rol de auditoría o DBA.