# Actividad 4 — Catálogo mínimo de datos

| ID | Conjunto de datos | Motor | Ubicación | Propietario | Custodio | Clasificación | Contiene datos personales | Finalidad | Conservación | Diccionario |
|---|---|---|---|---|---|---|---|---|---|---|
| CAT-01 | Clientes | PostgreSQL 16 | `<servidor-pg> / comercial / public.clientes` | Gerencia Comercial | DBA | Confidencial | Sí | Operación comercial, facturación y contacto | Mientras exista relación comercial activa + plazo legal fiscal (5 años) | `diccionario-clientes.csv` |
| CAT-02 | Auditoría de clientes | PostgreSQL 16 | `<servidor-pg> / comercial / auditoria.cambios_clientes` | Auditoría Interna / Seguridad de la Información | DBA | Restringida | Sí | Trazabilidad de modificaciones (valores antes/después) en `clientes` | 12 meses en línea + 4 años en archivo histórico (o anonimización tras baja ARCO) | Metadatos en esquema `auditoria` (`\d auditoria.cambios_clientes`) |
| CAT-03 | Registro de cambios | PostgreSQL 16 | `<servidor-pg> / comercial / gobierno.solicitudes_cambio` | Comité de cambios | DBA | Interna / Restringida | No (solo nombres de responsables/roles) | Control y evidencia de autorización de cambios en producción (POL-06) | 3 años para revisiones de auditoría interna y cumplimiento | Metadatos en esquema `gobierno` (`\d gobierno.solicitudes_cambio`) |
| CAT-04 | Clientes (tienda) | MongoDB 7 | `<servidor-mongo> / comercial / clientes` | Gerencia Comercial | DBA | Confidencial | Sí | Catálogo operativo de clientes en aplicación web/tienda | Mientras exista relación comercial activa (sincronizada con CAT-01) | Esquema JSON / validación de colección `clientes` |
| CAT-05 | Perfilado | MongoDB 7 | `<servidor-mongo> / comercial / system.profile` | Seguridad de la Información / Auditoría Interna | DBA | Restringida | Sí | Diagnóstico de rendimiento y auditoría de consultas lentas o indebidas | 7 a 30 días (colección *capped* rotativa) | Estructura nativa de `system.profile` (MongoDB 7) |
---

**1. ¿Por qué CAT-02 y CAT-05 contienen datos personales aunque su propósito sea la auditoría?**

Porque ambos registran el contenido real de las operaciones ejecutadas sobre las entidades de negocio.

CAT-02 (auditoria.cambios_clientes) almacena las filas completas antes y después de cada cambio en formato JSONB (valores_antes / valores_despues), incluyendo nombre, correo, teléfono y RFC; mientras que CAT-05 (system.profile) guarda los documentos de consulta, filtros y payloads enviados en operaciones find, update o insert sobre la colección de clientes.

**2. ¿Qué pasa si CAT-01 y CAT-04 tienen propietarios distintos y el RFC de un cliente difiere entre ambos motores?**

Se genera una inconsistencia de datos maestros sin autoridad única de resolución, ya que cada propietario puede considerar válido su propio registro, no existe una fuente única de verdad, los reportes y procesos de facturación entran en conflicto y se retrasa cualquier corrección al requerir negociación entre áreas sin un criterio único de gobierno.

**3. ¿Qué información del catálogo cambia con más frecuencia y quién debe actualizarla?**

Los metadatos operativos y de ciclo de vida (ubicación técnica, volumen/tamaño, controles de seguridad vigentes, estado de conservación y referencia al diccionario actualizado cuando se agregan columnas como canal_alta). Su actualización corresponde al Custodio (DBA) cada vez que se ejecuta un cambio aprobado en producción, con validación del Propietario del dato cuando cambian la finalidad, clasificación o reglas de retención.