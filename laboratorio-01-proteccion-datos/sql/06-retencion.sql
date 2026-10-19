SELECT * FROM clientes
WHERE fecha_alta < CURRENT_DATE - INTERVAL '1 day';