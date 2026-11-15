# Actividad 7 — Cambios de privilegios: el límite más importante

**1. ¿Por qué un cambio de privilegios es uno de los eventos auditables más importantes?**

Porque un escalamiento de privilegios compromete todo el modelo de control de acceso de la base de datos. Quien obtiene roles administrativos puede acceder o modificar información sensible, alterar estructuras, crear cuentas ocultas y desactivar o borrar los propios mecanismos de registro (system.profile) para encubrir sus acciones.

**2. ¿Con qué frecuencia tomarías instantáneas? ¿Qué factores influyen?**

* Frecuencia: Cada 15 a 60 minutos de forma automatizada en entornos productivos con datos sensibles, más ejecuciones manuales antes y después de ventanas de mantenimiento.

* Factores que influyen: La ventana máxima de exposición aceptable antes de detectar un cambio no autorizado, la criticidad y requisitos regulatorios de los datos almacenados, la frecuencia esperada de cambios administrativos y el equilibrio entre precisión forense y volumen de almacenamiento.

**3. ¿Quién debería poder escribir en auditoria.instantaneas_privilegios?**

Únicamente una cuenta de servicio automatizada con permisos exclusivos de solo inserción (insert) en auditoria.instantaneas_privilegios (sin permisos de update ni remove), aplicando separación de funciones para evitar que usuarios operativos o aplicaciones puedan alterar o borrar el historial de evidencia.

**4. Redacta en tres líneas cómo comunicarías esta limitación a Dirección.**

* En MongoDB Community Edition no existe auditoría nativa de cambios de permisos, por lo que el servidor no registra quién otorgó o revocó roles ni el momento exacto del cambio.

* Como control compensatorio implementamos instantáneas periódicas automatizadas que detectan qué privilegios cambiaron y acotan la ventana de tiempo en que ocurrió la modificación.

* Para contar con trazabilidad nominal e inmutable de cambios de seguridad en tiempo real se requiere migrar a MongoDB Enterprise/Atlas o gestionar los permisos desde una plataforma externa auditada.