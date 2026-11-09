# Actividad 12

**1. Comparación con la hipótesis de la Actividad 11**

El resultado del experimento confirma plenamente la hipótesis formulada:

Efectividad de SECURITY DEFINER: Al ejecutar la sentencia UPDATE, el disparador pudo escribir el registro en auditoria.cambios_clientes sin errores porque la función operó con los privilegios de su propietario (postgres), como lo demuestra el valor del campo usuario_efectivo = postgres.

Aislamiento del esquema de auditoría: Cuando la aplicación intentó consultar directamente la auditoría (SELECT * FROM auditoria.cambios_clientes), el motor rechazó la operación con ERROR: permission denied for schema auditoria. Esto prueba que es posible permitir la escritura transparente de eventos de auditoría mediante un disparador sin conceder acceso directo de lectura o manipulación a las cuentas operativas.

Trazabilidad real: La variable session_user conservó la identidad autenticada real (app_ventas), evitando la suplantación de identidad que habría ocurrido si la función únicamente registrara current_user.

**2. Sentencia SQL para restaurar el valor anterior**

Con base en la consulta de auditoría que identificó la alteración del campo rfc para el id_cliente = 3, la consulta para revertir el cambio exacto al estado original (antes) es:

```SQL
UPDATE clientes 
SET rfc = 'GAMA780912XYZ' 
WHERE id = 3;
```

**3. Valor probatorio: aplicacion frente a ip_cliente
Columna que conserva más valor probatorio: ip_cliente (inet_client_addr()).**

ip_cliente se extrae directamente en las capas de red y transporte (Capas 3 y 4 del modelo OSI) mediante el socket TCP establecido con el servidor. En una conexión TCP/IP, realizar IP Spoofing para completar exitosamente un apretón de manos (TCP Three-Way Handshake) y autenticarse en el motor requiere ataques avanzados de red (como envenenamiento BGP o acceso a la misma subred física). Por ello, posee un peso forense considerablemente mayor.

Columna que el cliente puede falsificar con mayor facilidad: aplicacion (application_name).

application_name es un parámetro arbitrario de capa de aplicación (Capa 7) declarado voluntariamente por el cliente en la cadena de conexión (?application_name=...) o modificado en cualquier momento mediante SET application_name = '...'. Cualquier cliente o script atacante puede declarar llamarse app-ventas-web o sistema-nominas sin que el motor realice alguna validación. Es útil para la organización operacional en tiempo real (pg_stat_activity), pero carece de valor como prueba irrefutable de identidad.