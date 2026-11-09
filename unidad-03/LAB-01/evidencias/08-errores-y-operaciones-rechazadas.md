# **Actividad 8** — Errores y operaciones rechazadas

**1. ¿El intento de soporte_ana causó algún daño? ¿Por qué debe auditarse de todos modos?**

¿Causó daño?: No, la capa de autorización de PostgreSQL bloqueó la ejecución de la sentencia (permission denied), por lo que la tabla clientes no sufrió ninguna alteración ni pérdida de datos.

¿Por qué debe auditarse?:

* Detección de intenciones maliciosas o sondeo de seguridad: Un número recurrente de errores de autorización indica un posible intento de escalada de privilegios, un usuario interno actuando fuera de sus funciones (insider threat) o una cuenta comprometida explorando los límites del sistema.

* Cumplimiento normativo: Los estándares de seguridad e higiene digital (ISO 27001, SOC 2, LFPDPPP) exigen la trazabilidad de los accesos u operaciones no autorizadas rechazadas por el motor.

* Identificación de errores de aplicación o procesos: Permite detectar fallos en la interfaz de la aplicación web o errores de capacitación de los usuarios (ej. un botón de "Eliminar" expuesto a un perfil de solo lectura).

**2. ¿Qué diferencia hay entre un error de autorización (esta actividad) y uno de autenticación (Actividad 5)?**

* Error de Autenticación (Actividad 5): Ocurre en la fase de establecimiento de conexión (¿Quién eres?). El servidor no logra verificar la identidad declarada (por clave incorrecta o usuario inexistente) y rechaza el acceso al sistema. Ocurre antes de que el proceso inicie una sesión operativa.

* Error de Autorización (Actividad 8): Ocurre en la fase de ejecución de operaciones (¿Qué tienes permitido hacer?). El usuario ya ha demostrado quién es y tiene una sesión activa válida (soporte_ana), pero intenta ejecutar una instrucción (DELETE) para la cual no se le concedió el permiso necesario (GRANT).

**3. ¿Qué indica el error de DROP ROLE sobre el orden correcto para dar de baja a un usuario?**

Indica que en PostgreSQL un rol no puede ser eliminado si posee objetos asociados o mantiene privilegios asignados en los catálogos del sistema (pg_shdepend).

El procedimiento técnico correcto para dar de baja (deprovisioning) a un usuario exige el siguiente orden:

1. Inhabilitar el inicio de sesión inmediatamente:

```SQL
ALTER ROLE soporte_ana NOLOGIN;
```

2. Reasignar o eliminar los objetos y privilegios dependientes:

```SQL
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM soporte_ana;
DROP OWNED BY soporte_ana;
```

3. Eliminar el rol de la instancia:

```SQL
DROP ROLE soporte_ana;
```