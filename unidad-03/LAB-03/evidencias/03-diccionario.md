# Actividad 3 — Diccionario de datos operativo dentro del motor

| Columna | Clasificación (Unidad II) | Finalidad | Control aplicado | ¿Cambios auditados? | Regla de calidad |
|---|---|---|---|---|---|
| `id` | Interna / Técnica | Identificador único del cliente | Llave primaria (`PRIMARY KEY`), secuencia automática | Sí (tabla completa en `auditoria.cambios_clientes`) | Unicidad, no nulo (`NOT NULL`) |
| `nombre` | Dato personal | Identificación directa y facturación | Permisos de acceso restringidos por rol | Sí (`auditoria.cambios_clientes`) | No nulo (`NOT NULL`), longitud válida |
| `correo` | Dato personal | Notificaciones y contacto con el cliente | Vista enmascarada para soporte (U2) | Sí (`auditoria.cambios_clientes`) | Unicidad normalizada, formato de email válido |
| `telefono` | Dato personal | Soporte y seguimiento comercial | Vista enmascarada para soporte (U2) | Sí (`auditoria.cambios_clientes`) | Longitud de 10 dígitos numéricos |
| `rfc` | Dato personal (fiscal) | Emisión de comprobantes fiscales (CFDI) | Vista enmascarada para soporte (U2) | Sí, LAB-01 Parte B (`auditoria.cambios_clientes`) | Formato oficial RFC (12 o 13 caracteres) |
| `edad` | Dato personal | Analítica demográfica agregada | Acceso restringido | Sí (`auditoria.cambios_clientes`) | Rango válido (18 a 120 años) |
| `ciudad` | Pública / Demográfica | Logística y segmentación regional | Control de escritura por aplicación | Sí (`auditoria.cambios_clientes`) | Catálogo o texto estandarizado |
| `codigo_postal` | Dato personal / Fiscal | Facturación (domicilio fiscal) y cobertura | Control de escritura por aplicación | Sí (`auditoria.cambios_clientes`) | Exactamente 5 dígitos numéricos |
| `fecha_alta` | Interna / Operativa | Control de antigüedad y trazabilidad | Valor por defecto del sistema (`DEFAULT now()`) | Sí (`auditoria.cambios_clientes`) | Fecha válida, no nula |
| `segmento` | Interna / Comercial | Asignación de políticas de precios y atención | Acceso limitado a roles comerciales | Sí (`auditoria.cambios_clientes`) | Dominio cerrado de categorías permitidas |
---

**1. ¿Qué ventaja tiene guardar el significado en COMMENT en lugar de solo en un documento aparte?**

Mantiene la documentación acoplada directamente a los objetos reales dentro del catálogo del sistema. Esto evita que el diccionario quede desactualizado o extraviado en archivos externos, permite consultarlo mediante SQL estándar junto con los metadatos técnicos y lo hace visible automáticamente en herramientas de administración como psql (\d+) o pgAdmin.

**2. ¿Quedaron registrados los COMMENT en la bitácora? ¿Con qué nivel de log_statement?**

No quedaron registrados con la configuración actual del laboratorio, ya que mod únicamente registra sentencias de modificación de datos. En PostgreSQL, COMMENT ON es una sentencia DDL, por lo que requiere log_statement = 'ddl' o 'all' para aparecer en la bitácora del servidor.

**3. ¿Qué información del diccionario debe mantenerse fuera del motor? ¿Por qué?**

Deben mantenerse fuera del motor los detalles sensibles de arquitectura de seguridad, reglas específicas de detección de fraude, ubicaciones de respaldos, credenciales o excepciones de control aceptadas, así como la justificación legal y el análisis de riesgos asociados a cada dato. Exponer esa información dentro de los metadatos del SGBD facilitaría el reconocimiento a un atacante que logre acceso de lectura a la base de datos.
