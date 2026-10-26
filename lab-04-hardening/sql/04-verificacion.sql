-- REVISAR EXTENSIONES
SELECT
    extname,
    extversion
FROM pg_extension
ORDER BY extname;

-- VERIFICAR EL USO DE TLS EN LA SESIÓN ACTIVA
SELECT
    s.pid,
    a.usename,
    a.client_addr,
    s.ssl,
    s.version,
    s.cipher
FROM pg_stat_ssl s
JOIN pg_stat_activity a ON s.pid = a.pid
WHERE s.pid = pg_backend_pid();

-- PERMISOS DEL ROL APP
-- CONSULTAR PRIVILEGIOS DEL CATÁLOGO DEL SISTEMA
SELECT
    grantee,
    table_schema,
    table_name,
    privilege_type
FROM information_schema.role_table_grants
WHERE grantee = 'app_comercializadora';

-- VERIFICACIÓN FINAL DE PARÁMETROS DE SEGURIDAD ACTIVOS
SELECT name, setting, unit, context
FROM pg_settings
WHERE name IN (
    'listen_addresses',
    'ssl',
    'ssl_min_protocol_version',
    'password_encryption',
    'statement_timeout',
    'idle_in_transaction_session_timeout'
);