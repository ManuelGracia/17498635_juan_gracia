-- 7.1
-- Implementación incorrecta
CREATE TABLE usuarios_insegura (
    id BIGSERIAL PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL,
    password VARCHAR(100) NOT NULL
);

-- Inserción de datos de prueba
INSERT INTO usuarios_insegura (usuario, password)
VALUES ('juan', 'Password123');

-- Visualizar la tabla
SELECT * FROM usuarios_insegura;

-- 7.3
-- Generar una representación no reversible
SELECT crypt(
    'Password123',
    gen_salt('bf')
);

-- 7.4
-- Crear tabla con credenciales protegidas
CREATE TABLE usuarios_segura (
    id BIGSERIAL PRIMARY KEY,
    usuario VARCHAR(50) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL
);

-- Insertar un usuario
INSERT INTO usuarios_segura (usuario, password_hash)
VALUES (
    'juan',
    crypt('Password123', gen_salt('bf'))
);

-- Consulta
SELECT * FROM usuarios_segura;

-- 7.5
-- Verificar una contraseña
SELECT
    usuario,
    password_hash = crypt('Password123', password_hash)
        AS contraseña_correcta
FROM usuarios_segura
WHERE usuario = 'juan';

-- Verificar contraseña incorrecta
SELECT
    usuario,
    password_hash = crypt('OtraPassword', password_hash)
        AS contraseña_correcta
FROM usuarios_segura
WHERE usuario = 'juan';

