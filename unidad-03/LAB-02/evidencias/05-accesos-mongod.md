# Actividad 5 — Accesos en la bitácora de mongod

**1. ¿Qué campo distingue un acceso fallido de uno exitoso?**

* msg: Muestra "Failed to authenticate" en los intentos rechazados y "Successfully authenticated" en los accesos válidos.

* Campos complementarios: id (5286307 para fallo vs. 5286306 para éxito) y attr.result (0 en éxito vs. códigos distintos de cero como 18 o 11 en fallo, acompañado de attr.error).

**2. ¿Qué diferencia hay entre el error de contraseña incorrecta y el de usuario inexistente? ¿Por qué el cliente recibe el mismo mensaje en ambos casos?**

Diferencia en bitácora (attr.error y attr.result): Con contraseña incorrecta, el usuario existe y falla la verificación criptográfica SCRAM (AuthenticationFailed: SCRAM authentication failed, storedKey mismatch, result: 18). Con usuario inexistente, la cuenta no se encuentra en la base de autenticación (UserNotFound: Could not find user "usuario_inexistente" for db "comercial", result: 11).

Mismo mensaje al cliente: Se devuelve el mensaje genérico MongoServerError: Authentication failed. para evitar la enumeración de usuarios, impidiendo que un atacante descubra qué nombres de cuenta son válidos en el servidor.

**3. ¿Por qué el nombre de la aplicación del intento fallido es mongosh 2.10.0 (o la versión instalada de mongosh) y no app-ventas-web?**

Porque la cadena de conexión utilizada en los intentos fallidos omitió el parámetro ?appName=app-ventas-web. Al no especificarse appName en la URI, el driver envía por defecto el nombre y la versión del cliente que origina la conexión.