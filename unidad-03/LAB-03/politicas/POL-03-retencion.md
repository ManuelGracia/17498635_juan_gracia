POL-03 — Retención y Disposición Final de Datos y Bitácoras

Objetivo:        Reducir el riesgo de incumplimiento legal por conservar datos personales indefinidamente y evitar la pérdida prematura de evidencia necesaria para investigaciones de auditoría.

Alcance:         Aplica a todos los conjuntos de datos inventariados en el catálogo (`CAT-01` a `CAT-05`) y a las bitácoras de PostgreSQL 16 y MongoDB 7 en producción.

Regla:           Los datos operativos de clientes (`CAT-01`, `CAT-04`) se conservan mientras exista relación comercial activa más el plazo legal fiscal (a confirmar con el área jurídica respecto a obligaciones del SAT). Las bitácoras de cambios de privilegios (`dba.bitacora`) y `auditoria.cambios_clientes` (`CAT-02`) se conservan al menos 12 meses en línea (y hasta 2 años en archivo histórico) para garantizar la trazabilidad exigida por POL-05; al vencer el plazo o ejercerse un derecho de cancelación (ARCO), los datos personales en auditoría deben anonimizarse o purgarse de forma verificable.

Responsable:     Decide plazos y disposición: Propietario del dato (Gerencia Comercial / Auditoría Interna) con asesoría jurídica. Ejecuta: DBA.

Excepciones:     Suspensión temporal de purga o anonimización (*legal hold*) cuando exista una investigación de auditoría interna o requerimiento legal activo, autorizada por Auditoría Interna o el área jurídica.

Evidencia:       Tabla de criterios de conservación (LAB-03, Actividad 5) y catálogo mínimo de datos (LAB-03, Actividad 4). (Nota: hoy no existe un script automatizado de purga/anonimización ni acta de destrucción ejecutada).

Revisión:        Anual o ante reformas en materia de protección de datos personales y disposiciones fiscales.