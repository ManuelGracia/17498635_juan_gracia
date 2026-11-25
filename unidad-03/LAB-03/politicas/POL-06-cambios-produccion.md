POL-06 — Gestión de Cambios en el Ambiente de Producción

Objetivo:        Reducir el riesgo de interrupciones del servicio, pérdida de trazabilidad o alteraciones estructurales y de permisos no autorizadas en la operación real de la empresa.

Alcance:         Aplica al ambiente de producción (instancia operativa que soporta las transacciones reales de Comercializadora Norte S.A. de C.V., aislada de los ambientes de desarrollo y pruebas según la definición de la Unidad I) en PostgreSQL 16 y MongoDB 7.

Regla:           Antes de aplicar cualquier cambio de estructura (DDL), privilegios o configuración en producción, debe existir una solicitud aprobada por el Comité de cambios con ventana de mantenimiento definida y probada previamente en desarrollo/pruebas. Durante la ventana autorizada, el DBA ejecuta únicamente el cambio aprobado manteniendo activos los mecanismos de auditoría (`log_statement = 'mod'` y disparadores). Después del cambio, el DBA actualiza el diccionario/catálogo y Auditoría Interna concilia los eventos de la bitácora contra las solicitudes aprobadas.

Responsable:     Solicita: Área usuaria / Gerencia Comercial. Aprueba: Comité de cambios. Ejecuta: DBA. Concilia: Auditoría Interna.

Excepciones:     Cambios de emergencia (*hotfix*) para contener fallas críticas o brechas de seguridad activas; pueden ejecutarse con autorización expedita del responsable de Seguridad/TI y registrarse retroactivamente en `gobierno.solicitudes_cambio` en menos de 24 horas.

Evidencia:       Registros aprobados en `gobierno.solicitudes_cambio` (LAB-03, Actividad 7, ej. folio `CAM-2026-014`) + sentencias DDL/DCL en `dba.bitacora` (LAB-03, Actividad 7) + diccionario actualizado (`COMMENT ON COLUMN clientes.canal_alta`).

Revisión:        Cada 6 meses o tras detectar cambios no autorizados en la conciliación mensual.