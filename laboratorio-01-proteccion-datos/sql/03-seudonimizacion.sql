-- CREAR LOS ESQUEMAS
CREATE SCHEMA pii;
CREATE SCHEMA analitica;

-- CREAR LA TABLA DE CORRESPONDENCIA
CREATE TABLE pii.mapa_cliente (
    token UUID PRIMARY KEY,
    cliente_id BIGINT UNIQUE
        REFERENCES public.clientes(id)
);

--GENERAR LOS TOKENS
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- GENERAR UN TOKEN PARA CADA CLIENTE
INSERT INTO pii.mapa_cliente
(token, cliente_id)
SELECT
    gen_random_uuid(),
    id
FROM clientes;

-- VERIFICAR
SELECT * FROM pii.mapa_cliente;

-- CREAR CONJUNTO DE DATOS PARA ANALÍTICA
CREATE TABLE analitica.clientes AS
SELECT
    m.token AS cliente_token,
    c.edad,
    c.ciudad,
    c.codigo_postal,
    c.fecha_alta
FROM pii.mapa_cliente m
JOIN clientes c
    ON c.id = m.cliente_id;

-- VERIFICAR
SELECT * FROM analitica.clientes;

