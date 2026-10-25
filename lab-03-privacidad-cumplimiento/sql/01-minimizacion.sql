-- PRINCIPIOS DE MINIMIZACIÓN
-- CREAR TABLA
-- DISEÑAR UNA ESTRUCTURA MÍNIMA
CREATE TABLE clientes_soporte (
    id BIGINT PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    correo VARCHAR(150) NOT NULL,
    telefono VARCHAR(20)
);

-- CARGAR INFORMACIÓN A PARTIR DE CLIENTES
INSERT INTO clientes_soporte (
    id,
    nombre,
    correo,
    telefono
)
SELECT
    id,
    nombre,
    correo,
    telefono
FROM clientes;

--CONSULTA
SELECT * FROM clientes_soporte;

