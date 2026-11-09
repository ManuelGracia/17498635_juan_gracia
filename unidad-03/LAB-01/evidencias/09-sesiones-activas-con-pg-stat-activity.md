# **Actividad 9** — Sesiones activas con pg_stat_activity

**1. ¿Qué columna permite relacionar una sesión con sus líneas de bitácora?**

La columna pid (Process ID o Identificador del proceso del backend). En pg_stat_activity se consulta como pid y en la bitácora queda grabado entre corchetes mediante el marcador %p configurado en el log_line_prefix (por ejemplo, [189]).

**2. Después de que termina el reporte, ¿qué fuente conserva evidencia de que existió?**

La bitácora del servidor (los archivos de registro/log).

pg_stat_activity es una vista volátil en tiempo real que funciona como una "fotografía" del estado presente; en cuanto el proceso del cliente finaliza o se desconecta, su registro desaparece de esa vista. En cambio, la bitácora es la "historia" persistente que conserva la trazabilidad de la conexión, las consultas ejecutadas (si el nivel de log_statement lo permite) y la desconexión.

**3. ¿Por qué client_addr aparece vacío en la sesión del administrador?**

Porque la sesión del administrador se estableció mediante un socket de dominio Unix (conexión local en pg_hba.conf) directamente en el servidor, en lugar de una conexión de red TCP/IP (host).

Al no ser un paquete de red que viaje a través de una pila TCP/IP, no existe una dirección IP origen que registrar, por lo que el motor asigna un valor nulo (NULL/vacío) en client_addr (y en el prefijo de la bitácora se muestra como client=[local]).