# **Actividad 5**— Accesos exitosos y fallidos

**1. La bitácora registra el usuario app_ventas en el intento fallido. ¿Eso prueba que la aplicación de ventas intentó entrar? ¿Qué prueba realmente?**

No. No prueba que la aplicación de ventas legítima intentó ingresar.

Lo único que prueba técnicamente es que un cliente ubicado en la dirección IP 127.0.0.1 intentó iniciar sesión declarando ser el usuario app_ventas y envió credenciales incorrectas. Cualquier entidad o usuario malicioso con acceso a la red puede ejecutar un cliente (como psql) e ingresar el nombre de usuario de la aplicación para intentar adivinar su contraseña.

**2. ¿Qué información adicional registra PostgreSQL cuando el rol no existe? ¿Por qué aparece en la bitácora y no en el mensaje que recibe el cliente?**

* Información adicional en la bitácora: Registra la línea de detalle DETAIL: Role "usuario_inexistente" does not exist., especificando que el nombre de usuario ni siquiera está registrado en el catálogo de datos del sistema (pg_roles).

* Por qué no se envía al cliente: Para prevenir ataques de enumeración de usuarios (User Enumeration). Si el motor de base de datos le confirmara al cliente externo que el rol no existe, un atacante podría probar miles de nombres hasta descubrir cuáles cuentas son válidas en la empresa. Para el cliente, PostgreSQL enmascara el error devolviendo un mensaje genérico de autenticación fallida (FATAL: password authentication failed), mientras que en la bitácora interna de auditoría guarda la causa real para análisis forense del administrador.

**3. ¿Por qué app=[unknown] en el intento fallido, pero app=app-ventas-web en la desconexión?**

Porque la variable de aplicación (application_name) se procesa y asigna formalmente a la sesión únicamente después de que el usuario supera con éxito el proceso de autenticación.

En los intentos fallidos, el proceso de la sesión se destruye en la etapa de verificación de contraseña, antes de entablar el contexto de la aplicación, quedando como [unknown]. En el intento exitoso, la sesión se autoriza, se vincula la variable application_name=app-ventas-web enviada en la cadena de conexión y, por lo tanto, el prefijo de línea de los eventos posteriores (incluyendo disconnection) ya refleja la aplicación que ejecutó la transacción.

**4. ¿Qué patrón de varias líneas te haría sospechar de un ataque de fuerza bruta? Escribe la consulta que contaría los intentos fallidos por usuario.**

Patrón Sospechoso: Múltiples líneas de bitácora consecutivas con nivel de severidad FATAL, mensajes de password authentication failed, generadas en un intervalo de tiempo muy corto (segundos/minutos) proviniendo del mismo client (misma IP de origen) con puertos de origen efímeros incrementales y dirigidas al mismo usuario o a una lista de usuarios probables.