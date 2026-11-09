# **Actividad 4** — Configurar la bitácora

**1. ¿Por qué el proceso que registra el cambio es el principal y no tu sesión?**

El comando ALTER SYSTEM únicamente escribe el nuevo valor en el archivo postgresql.auto.conf. La configuración no surte efecto hasta que se ejecuta SELECT pg_reload_conf(), función que envía una señal del sistema operativo al proceso principal de PostgreSQL.

El proceso postmaster es el único responsable de reevaluar los archivos de configuración en el servidor y coordinar la actualización de los parámetros compartidos. Por esta razón, el evento del cambio de parámetro es generado y emitido directamente por el proceso maestro de la instancia (PID 1) y no por la sesión individual del usuario que solicitó la recarga.

**2. ¿Qué pasaría si alguien ejecutara ALTER SYSTEM SET log_statement = 'none'? ¿Quedaría rastro?**

Sí, sí quedaría rastro.

Aunque desactivar log_statement impedirá que el motor registre las sentencias SQL ejecutadas con posterioridad, la acción de recargar la configuración (pg_reload_conf()) obligará al proceso principal (postmaster) a escribir en la bitácora un evento explícito de auditoría de configuración:

```Plaintext
LOG: parameter "log_statement" changed to "none"
```

Por lo tanto, aunque las consultas futuras dejen de auditarse, el hecho de que alguien desactivó el parámetro, el momento exacto en que lo hizo y la conexión activa en ese instante (registrada en pg_stat_activity o por log_connections) dejarán una huella imborrable en el archivo de registro.

**3. ¿Por qué no se recomienda editar postgresql.auto.conf a mano?**

* Sobreescritura automática: El archivo postgresql.auto.conf está diseñado para ser administrado exclusivamente por el motor mediante comandos ALTER SYSTEM. Si se edita manualmente (por ejemplo, agregando comentarios o formatos personalizados), la siguiente ocasión en que un usuario ejecute un ALTER SYSTEM o ALTER SYSTEM RESET, PostgreSQL regenerará completamente el archivo y sobrescribirá o borrará cualquier cambio manual.

* Riesgo de corrupción de configuración: Un error de sintaxis o un parámetro mal escrito en postgresql.auto.conf puede impedir la recarga correcta de parámetros o incluso provocar que el servicio de PostgreSQL no pueda iniciar durante un reinicio.

* Control de prioridad y validación: El uso de ALTER SYSTEM permite que PostgreSQL valide la sintaxis y los tipos de datos de las configuraciones antes de escribirlos en disco, garantizando la integridad del sistema.