# **Actividad 1** — Revisar la configuración de registro por defecto

**1. Con esta configuración, ¿se registra quién se conecta?**
No. El parámetro log_connections se encuentra en off. Por lo tanto, PostgreSQL no registra en la bitácora los intentos de conexión (sean exitosos o fallidos) ni la identidad de los usuarios que establecen sesión.

**2. ¿Se registran las sentencias UPDATE?**
No. El parámetro log_statement está configurado en none. Con este valor no se guarda el texto de ninguna sentencia SQL ejecutada (SELECT, INSERT, UPDATE, DELETE o DDL).

**3. ¿La línea de bitácora incluye el usuario o la dirección IP del cliente?**
No. El formato configurado en log_line_prefix es únicamente %m [%p]. Esto solo captura:

* %m: Fecha y hora con milisegundos.

* %p: Identificador del proceso (PID).

Faltan los marcadores %u (usuario de la sesión), %d (base de datos) y %h (host o dirección IP del cliente), por lo que cualquier mensaje registrado carece de contexto sobre quién o desde dónde se ejecutó la acción.

**4. ¿En qué zona horaria se registran los eventos? ¿Por qué importa al reconstruir una cronología?**
Se registran en la zona horaria Etc/UTC (Tiempo Universal Coordinado).

Importancia forense: Correlacionar marcas de tiempo es crítico durante la investigación de un incidente. Si la base de datos registra en UTC pero la aplicación web, el servidor proxy o el firewall registran en una zona horaria local (por ejemplo, America/Mazatlan / UTC-7), los eventos parecerán desfasados por varias horas. Si no se estandariza o documenta la zona horaria, se vuelve imposible reconstruir el orden cronológico exacto de las acciones cometidas por un atacante.

**5. Con logging_collector = off, ¿quién decide dónde termina la bitácora: PostgreSQL o el mecanismo con que se desplegó el servidor?**

Lo decide el mecanismo con que se desplegó el servidor.

Cuando logging_collector = off, PostgreSQL simplemente envía sus mensajes a la salida estándar de error (stderr). La captura y destino final de esa salida dependen del entorno del sistema operativo o contenedor:

Linux (systemd/journald): Termina en el log del sistema o en /var/log/postgresql/.

Docker / Kubernetes: Termina en la salida estándar del contenedor (docker logs).

macOS / Windows: Termina en los servicios de logs de la plataforma (Homebrew o Visor de eventos).