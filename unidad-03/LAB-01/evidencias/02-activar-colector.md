# **Actividad 2** — Que el servidor administre su propia bitácora

**1. ¿Por me logging_collector requiere reinicio y log_statement solo recarga?**

logging_collector: Controla el inicio del proceso de fondo encargado de la recolección de logs. Activarlo implica modificar la arquitectura de entrada y salida del proceso principal de PostgreSQL, redirigir el flujo de stderr a archivos físicos y asignar estructuras de memoria en la inicialización del servicio.

log_statement: Es un parámetro dinámico del analizador de consultas. El motor simplemente revisa el valor de esta variable en memoria antes de ejecutar una sentencia SQL. Por ello, basta con enviar una señal de recarga de configuración (SELECT pg_reload_conf();) para que el cambio surta efecto inmediatamente sin interrumpir sesiones activas.

**2. ¿Qué ventaja tiene que la bitácora se lea con SQL y no con una herramienta del sistema operativo o del contenedor? ¿Qué riesgo introduce?**

**Ventajas:**

* Portabilidad e independencia de infraestructura: Abstrae por completo el entorno subyacente (Linux, Windows, Docker, Kubernetes). El administrador o auditor no requiere acceso mediante SSH, terminal de línea de comandos ni credenciales del sistema operativo para revisar los logs.

* Capacidad de análisis con la potencia de SQL: Permite realizar búsquedas complejas, filtrado por expresiones regulares (regexp_split_to_table), ordenamientos y agregaciones sin depender de utilidades externas (grep, awk, tail, Select-String).

**Riesgos:**

* Fuga de datos sensibles: Si la vista no está adecuadamente aislada o si se otorgan permisos indebidos a pg_read_file(), usuarios sin privilegios podrían leer fragmentos de código SQL que contengan información confidencial, datos personales o contraseñas en texto plano grabadas por error.

* Consumo excesivo de recursos (DoS involuntario): Ejecutar pg_read_file() sobre archivos de log de gran tamaño (cientos de megabytes o gigabytes) y procesarlos en memoria con funciones de división de texto puede saturar la memoria RAM y el procesador del motor de base de datos en producción.

**3. ¿Quién debería poder consultar dba.bitacora?**

Únicamente el Administrador de la Base de Datos (DBA / Superusuario) y los Roles de Auditoría o Seguridad de la Información (rol_auditoria, DPO) expresamente designados.