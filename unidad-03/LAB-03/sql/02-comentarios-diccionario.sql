-- Documenta el significado de la tabla y de sus columnas con COMMENT (REF-U3-14):
COMMENT ON TABLE clientes IS 'Clientes de Comercializadora Norte. Propietario: Gerencia Comercial. Custodio: DBA. Clasificación: confidencial (contiene datos personales).';
COMMENT ON COLUMN clientes.id IS 'Identificador interno del cliente. Generado por el sistema.';
COMMENT ON COLUMN clientes.nombre IS 'Nombre completo. Dato personal identificador directo.';
COMMENT ON COLUMN clientes.correo IS 'Correo de contacto. Dato personal. Uso: notificaciones al cliente.';
COMMENT ON COLUMN clientes.rfc IS 'RFC del cliente. Dato personal. Uso: facturación. Cambios auditados en auditoria.cambios_clientes.';
COMMENT ON COLUMN clientes.edad IS 'Edad en años cumplidos. Dato personal. Uso: analítica agregada.';

-- Completa los comentarios de telefono, ciudad, codigo_postal, fecha_alta y segmento.
COMMENT ON COLUMN clientes.telefono IS 'Número telefónico de contacto (10 dígitos). Dato personal. Uso: soporte y seguimiento comercial.';
COMMENT ON COLUMN clientes.ciudad IS 'Ciudad o localidad de residencia o domicilio fiscal. Dato demográfico. Uso: logística y segmentación regional.';
COMMENT ON COLUMN clientes.codigo_postal IS 'Código postal del domicilio (5 dígitos). Dato personal y fiscal. Uso: facturación (CFDI) y cobertura de envíos.';
COMMENT ON COLUMN clientes.fecha_alta IS 'Fecha de registro del cliente en el sistema. Metadato operativo. Uso: control de antigüedad y auditoría.';
COMMENT ON COLUMN clientes.segmento IS 'Clasificación comercial asignada al cliente (ej. minorista, mayorista, VIP). Dato interno. Uso: políticas de precios y atención.';

-- Consulta el diccionario combinando metadatos estructurales (information_schema.columns, REF-U3-15) y comentarios (col_description, REF-U3-14):
SELECT c.ordinal_position          AS pos,
       c.column_name               AS columna,
       c.data_type                 AS tipo,
       c.character_maximum_length  AS longitud,
       c.is_nullable               AS acepta_nulos,
       c.column_default            AS valor_por_defecto,
       col_description('public.clientes'::regclass, c.ordinal_position) AS descripcion
FROM information_schema.columns c
WHERE c.table_schema = 'public'
  AND c.table_name = 'clientes'
ORDER BY c.ordinal_position;

-- Exporta el diccionario en CSV:
SELECT c.column_name AS columna,
       c.data_type AS tipo,
       c.character_maximum_length AS longitud,
       c.is_nullable AS acepta_nulos,
       col_description('public.clientes'::regclass, c.ordinal_position) AS descripcion
FROM information_schema.columns c
WHERE c.table_schema = 'public'
  AND c.table_name = 'clientes'
ORDER BY c.ordinal_position;