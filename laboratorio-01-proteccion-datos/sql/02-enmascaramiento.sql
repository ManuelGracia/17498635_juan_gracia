CREATE ROLE soporte NOLOGIN;

ALTER ROLE soporte LOGIN PASSWORD 'Seguridad2026';

-- VISTA DE ACCESO RESTRINGIDO
CREATE VIEW v_clientes_soporte AS
SELECT
    id,
    nombre,

    CONCAT(
        LEFT(correo, 2),
        '*****',
        SUBSTRING(correo FROM POSITION('@' IN correo))
    ) AS correo,

    CONCAT(
        '******',
        RIGHT(telefono, 4)
    ) AS telefono,

    CONCAT(
        '*********',
        RIGHT(rfc, 4)
    ) AS rfc

FROM clientes;

-- CONSULTAR VISTA (COMO ADMIN)
SELECT * FROM v_clientes_soporte;

-- CONCEDER ACCESO A LA VISTA
GRANT USAGE
ON SCHEMA public
TO soporte;

GRANT SELECT
ON v_clientes_soporte
TO soporte;

-- REVOCAR EL ACCESO DIRECTO A LA TABLA
REVOKE ALL
ON clientes
FROM soporte;

