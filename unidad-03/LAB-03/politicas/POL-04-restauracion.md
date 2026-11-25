POL-04 — Restauración de Datos y Recuperación de Valores

Objetivo:        Reducir el riesgo de sobrescritura indebida de información productiva, pérdida de integridad referencial o alteración de evidencia durante actividades de recuperación.

Alcance:         Aplica a toda restauración completa de base de datos o restauración puntual de registros (como corrección de RFC o datos maestros) en las bases `comercial` de PostgreSQL 16 y MongoDB 7 en producción.

Regla:           Ninguna restauración completa o modificación correctiva de datos en producción puede ejecutarse sin autorización escrita del Propietario del dato afectado (Gerencia Comercial) y sin validar previamente el estado en un ambiente aislado de pruebas. Toda restauración puntual de registros debe realizarse mediante sentencias auditadas sin desactivar disparadores de auditoría. (El procedimiento técnico se definirá en la Unidad V).

Responsable:     Autoriza: Propietario del dato (Gerencia Comercial) y Comité de cambios (para restauraciones totales). Ejecuta: DBA.

Excepciones:     Recuperación de emergencia ante caída total del servidor productivo; requiere autorización verbal inmediata de Gerencia de TI/Seguridad y regularización documental dentro de las siguientes 12 horas.

Evidencia:       Registro histórico de valores previos en `auditoria.cambios_clientes` (LAB-01 Parte B, Pasos 4 y 5) + solicitud aprobada en `gobierno.solicitudes_cambio` (LAB-03, Actividad 7) + registro de ejecución en `dba.bitacora`. (Nota: hoy no existe bitácora formal de simulacros de restauración completa; se cubrirá en la Unidad V).

Revisión:        Anual y después de cada incidente mayor que requiera recuperación.