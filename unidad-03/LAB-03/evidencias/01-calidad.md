# Actividad 1 — Calidad de datos desde la operación

| # | Hallazgo | Registros | Regla de calidad | ¿Quién decide la corrección? | Acción propuesta |
|---|---|---|---|---|---|
| C1 | Posible cliente duplicado | 1, 7 | Unicidad del correo | Gerencia Comercial (Propietario del dato) | Confirmar con el cliente si es la misma persona, fusionar historial y eliminar el duplicado (id 7). |
| C2 | RFC incompleto o ausente | 7, 8 | Formato y completitud del RFC | Gerencia Comercial / Facturación | Solicitar la constancia fiscal al cliente para completar el carácter faltante (id 7) y capturar el RFC faltante (id 8). |
| C3 | Correo electrónico con formato inválido (`sin-correo`) | 8 | Validez de formato | Gerencia Comercial / Soporte | Contactar al cliente vía telefónica para recabar un correo electrónico real y válido. |
| C4 | Edad fuera de rango lógico (`-3`) | 8 | Validez de dominio / rango | Gerencia Comercial | Validar la fecha de nacimiento real del cliente con una identificación oficial y corregir el valor. |

---

**1. ¿Por qué el DBA no debe corregir por su cuenta el RFC del registro 7?**

Porque el DBA es custodio del dato (encargado de su operación, integridad y resguardo técnico), no su propietario (data owner). El DBA no conoce la realidad comercial ni fiscal del cliente; adivinar o inventar el carácter faltante alteraría información legal y financiera cuya veracidad y corrección corresponden exclusivamente a la Gerencia Comercial o Facturación.

**2.¿Qué restricción (CHECK, UNIQUE) habría evitado cada hallazgo? ¿Quién debería aprobar agregarla?**

* C1 (Duplicado por correo): Un índice único funcional CREATE UNIQUE INDEX ON clientes (lower(correo)); (o restricción UNIQUE sobre correo normalizado).

* C2 (RFC inválido/nulo): Restricciones NOT NULL y CHECK (rfc ~ '^[A-ZÑ&]{3,4}[0-9]{6}[A-Z0-9]{3}$').

* C3 (Correo inválido): Restricción CHECK (correo ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$').

* C4 (Edad fuera de rango): Restricción CHECK (edad BETWEEN 18 AND 120).

* ¿Quién aprueba agregarla? El Propietario del dato (Gerencia Comercial) en coordinación con los responsables de las aplicaciones consumidoras, ya que imponer restricciones estrictas puede rechazar transacciones en la operación diaria (por ejemplo, si el negocio sí permite registrar clientes sin RFC inicialmente).

**3. Si el DBA corrige un dato, ¿qué mecanismo del LAB-01 (Parte B) dejará evidencia del cambio?**

El disparador (trigger) de auditoría del dato asociado a la tabla clientes, el cual registrará automáticamente en la tabla auditoria.cambios_clientes el UPDATE con los valores exactos antes (valores_antes) y después (valores_despues), la marca de tiempo (momento), y el usuario de sesión (usuario_sesion) que ejecutó la corrección.