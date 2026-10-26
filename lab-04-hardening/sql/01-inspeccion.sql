-- SUPERFICIE DE ATAQUE
-- VERSIÓN DE SQL
SELECT version();

SHOW port;
SHOW listen_addresses;
SHOW ssl;
SHOW password_encryption;

-- CONEXIONES ACTIVAS
SELECT
    pid,
    usename,
    datname,
    client_addr,
    client_port,
    application_name
FROM pg_stat_activity;

-- ARCHIVOS DE CONFIGURACIÓN
-- RUTAS DE ARCHIVOS DE CONFIGURACIÓN
SHOW config_file;
SHOW hba_file;
SHOW ident_file;

-- RUTAS DE ALMACENAMIENTO Y REGISTROS
SHOW data_directory;
SHOW log_directory;
SHOW log_connections;
SHOW log_disconnections;

-- REVISAR pg_hba.conf
-- REGLAS ACTIVAS DE AUTENTICACIÓN BASADAS EN HOST
SELECT
    line_number,
    type,
    database,
    user_name,
    address,
    auth_method
FROM pg_hba_file_rules;