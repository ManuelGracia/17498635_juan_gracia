# Actividad 6 — Correlacionar un cambio de configuración con su autor

**1. ¿Qué usuario cambió la configuración del perfilador? ¿Qué dos eventos lo demuestran?**

El cambio fue realizado por el usuario admin (admin@admin). Lo demuestran dos eventos vinculados por el mismo identificador de contexto (ctx):

* Successfully authenticated (ACCESS): Confirma que la conexión ctx autenticó al usuario admin en la base admin desde el cliente registrado en attr.client.
* Profiler settings changed (COMMAND): Confirma que esa misma conexión ctx, posteriormente, modificó los parámetros del perfilador (from $\rightarrow$ to) en la base comercial.

**2. ¿Qué condición debe cumplirse para que esta correlación sea válida?**

Dado que los identificadores de conexión (connN) son secuenciales en memoria y se reinician a conn1 cada vez que el proceso mongod se reinicia, la correlación es válida únicamente si:

- Ambos eventos ocurrieron dentro del mismo ciclo de vida (uptime) del servidor, sin un reinicio intermedio de mongod.

- El evento de autenticación ocurrió antes que el cambio de configuración.

- La conexión ctx no cerró (Connection ended) ni cambió de identidad entre ambos eventos.

**3. ¿Por qué es relevante que quede registrado un cambio de configuración del propio mecanismo de registro?**

Porque permite detectar intentos de evasión y borrado de huellas por parte de un atacante o usuario privilegiado malintencionado (por ejemplo, apagar el perfilador o alterar su filtro antes de realizar acciones no autorizadas). Dejar constancia inmutable del estado anterior (from), el nuevo estado (to) y la conexión (ctx) protege la integridad de la auditoría y permite alertar al equipo de seguridad ante pérdida de visibilidad.