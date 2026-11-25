POL-01 — Control de Acceso y Revisión de Privilegios

Objetivo:       Reducir el riesgo de acceso no autorizado, escalamiento de privilegios y exposición de datos personales o credenciales en los motores de bases de datos.

Alcance:         Aplica a todos los roles, usuarios y cuentas de aplicación en las bases de datos `comercial` de PostgreSQL 16 y MongoDB 7, en los ambientes de desarrollo, pruebas y producción.

Regla:           Todo acceso a datos o cambio de privilegios en producción debe ser solicitado por el jefe de área o líder técnico, aprobado formalmente por el Propietario del dato correspondiente (Gerencia Comercial o Auditoría Interna) bajo el principio de mínimo privilegio y ejecutado por el DBA. El DBA y Auditoría Interna revisan trimestralmente los privilegios activos y los concilian contra las solicitudes aprobadas.

Responsable:     Decide y aprueba: Propietario del dato (Gerencia Comercial / Auditoría Interna). Ejecuta y revisa: DBA.

Excepciones:     Accesos temporales de emergencia ante incidentes críticos en producción; deben ser autorizados por Seguridad de la Información o Gerencia Comercial y revocados en un plazo máximo de 24 horas.

Evidencia:       Líneas `statement: GRANT/REVOKE` y `CREATE/ALTER ROLE` en `dba.bitacora` (LAB-01, Actividad 6; LAB-03, Actividad 7) + instantáneas en `auditoria.instantaneas_privilegios` (LAB-02) + registros en `gobierno.solicitudes_cambio` (LAB-03, Actividad 7). (Nota: hoy no existe un acta formal automatizada de revisión trimestral).

Revisión:        Cada 6 meses o tras cambios organizacionales mayores.