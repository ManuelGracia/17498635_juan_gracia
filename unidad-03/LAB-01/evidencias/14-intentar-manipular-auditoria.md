# Actividad 14 — Intentar manipular la auditoría

**1. ¿Qué evidencia permite detectar que hubo un cambio sin auditar?**

Existen dos fuentes clave de evidencia para identificar este bypass:

* La bitácora del servidor (dba.bitacora): Dado que log_statement estaba configurado en ddl o mod, el motor registró en texto claro la secuencia de comandos ejecutados por el administrador:

    * La deshabilitación explícita del disparador (ALTER TABLE clientes DISABLE TRIGGER trg_auditoria_clientes).

    * La sentencia DML ejecutada durante la ventana sin auditoría (UPDATE clientes SET rfc = 'GAMA780912GHI' WHERE id = 3).

    * La reactivación posterior del disparador (ALTER TABLE clientes ENABLE TRIGGER...).

* Discrepancia entre el estado actual y la tabla de auditoría: Al consultar la tabla clientes, el campo rfc del registro 3 refleja 'GAMA780912GHI', mientras que la última entrada en auditoria.cambios_clientes registra que el valor cambió únicamente a 'GAMA780912ZZZ'. Esta inconsistencia entre el dato real en producción y la foto histórica auditada confirma una alteración fuera de control.

**2. ¿Qué control administrativo (no técnico) reduciría este riesgo?**

* Gestión de Cambios Formal y Principio de Cuatro Ojos (Dual Control): Prohibir el uso directo del rol superusuario (postgres) en operaciones rutinarias de producción. Cualquier ventana de mantenimiento o modificación directa requiere una solicitud formal (Change Request), aprobada previamente por el área de Seguridad y ejecutada bajo supervisión cruzada.

* Envío Centralizado y Custodia Externa de Bitácoras (SIEM): Implementar una política corporativa donde los archivos de registro se transmitan en tiempo real a un servidor de bitácoras centralizado (ej. SIEM / Syslog remoto) controlado exclusivamente por el equipo de Seguridad de la Información (SOC), fuera del alcance del equipo de TI/DBA.

* Auditorías de Integridad Periçódicas e Independientes: Programar conciliaciones automatizadas entre áreas independientes (Auditoría Interna vs. TI) para detectar brechas en la secuencia temporal o disparadores desactivados.

**3. Relaciona esta actividad con el principio de separación de funciones de la Unidad II.**

Esta actividad pone de manifiesto el límite técnico de la seguridad cuando se vulnera el Principio de Separación de Funciones (Segregation of Duties - SoD):

* El riesgo del poder absoluto: Si la misma persona u organismo administra la base de datos (DBA/Propietario) y al mismo tiempo custodia la evidencia de auditoría, posee la capacidad técnica para deshabilitar los controles (DISABLE TRIGGER), alterar la información y manipular los registros de bitácora locales para borrar sus huellas.

Aplicación práctica del SoD:

* Separación de roles: Quien opera el negocio (app_ventas) no debe ser dueño del esquema de auditoría ni tener capacidad de DDL.

* Separación de responsabilidades: El DBA administra la disponibilidad y rendimiento de la base de datos, pero no debe tener acceso ni permisos de modificación sobre los sistemas de custodia de evidencia.

* Inmutabilidad de la evidencia: Las bitácoras del servidor deben ser transferidas a un entorno donde el administrador de la base de datos no posea privilegios del sistema operativo para alterar o eliminar los archivos.