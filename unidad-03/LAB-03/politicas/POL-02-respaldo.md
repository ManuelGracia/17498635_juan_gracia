POL-02 — Respaldo de Bases de Datos y Evidencias

Objetivo:        Reducir el riesgo de pérdida irreversible de información operativa, metadatos de gobierno o registros históricos de auditoría ante fallas técnicas, corrupción o incidentes de seguridad.

Alcance:         Aplica a las bases de datos `comercial` (esquemas `public`, `auditoria`, `gobierno` y `dba` en PostgreSQL 16; colecciones operativas en MongoDB 7) y a las bitácoras exportadas en el ambiente de producción.

Regla:           Se debe realizar un respaldo completo diario de la base operativa y de las tablas de auditoría y gobierno, almacenando una copia fuera del servidor de producción con verificación de integridad (hash). El DBA ejecuta mensualmente una prueba de integridad y legibilidad sobre una muestra de respaldos para confirmar que son recuperables. (El procedimiento técnico se definirá en la Unidad V).

Responsable:     Decide: Gerencia Comercial y Seguridad de la Información. Ejecuta y verifica: DBA.

Excepciones:     Postergación temporal de ventana de respaldo por mantenimiento mayor en producción, autorizada previamente por el Comité de cambios y documentada en el registro de cambios.

Evidencia:       Hoy no existe evidencia técnica de respaldos ejecutados ni bitácora de pruebas de verificación (se implementará y documentará en la Unidad V; las bitácoras exportadas cuentan con `evidencias/bitacora-lab01.log` y `evidencias/diccionario-clientes.csv` como exportaciones puntuales).

Revisión:        Anual o cada vez que se incorpore un nuevo motor o conjunto de datos crítico al catálogo.