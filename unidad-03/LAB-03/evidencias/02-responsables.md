# Actividad 2 — Propietarios, custodios y usuarios

| Conjunto de datos | Propietario | Custodio | Usuarios autorizados | Quién aprueba accesos | Quién aprueba correcciones |
|---|---|---|---|---|---|
| `comercial.public.clientes` (PostgreSQL) | Gerencia Comercial | DBA | Aplicación de ventas (`app_ventas`), Facturación, Soporte | Gerencia Comercial | Gerencia Comercial / Facturación |
| `auditoria.cambios_clientes` (PostgreSQL) | Auditoría Interna / Seguridad de la Información | DBA (solo operación técnica; sin permiso de modificación) | Auditoría Interna (solo lectura), Función disparadora (`SECURITY DEFINER`) | Auditoría Interna / Seguridad de la Información | No aplica (registro inmutable; no se corrige ni se borra) |
| Bitácora de PostgreSQL | Seguridad de la Información / Auditoría Interna | DBA / Administrador de Infraestructura | Auditoría Interna, Seguridad de la Información, DBA (diagnóstico operativo) | Seguridad de la Información / Auditoría Interna | No aplica (evidencia histórica de solo lectura) |
| `comercial.clientes` (MongoDB) | Gerencia Comercial | DBA | Aplicación de ventas / consultas operativas | Gerencia Comercial | Gerencia Comercial |
| `comercial.system.profile` (MongoDB) | Seguridad de la Información / Auditoría Interna | DBA | Auditoría Interna, DBA (optimización y revisión) | Seguridad de la Información / Auditoría Interna | No aplica (telemetría histórica de solo lectura) |
---

**1. ¿Por qué el propietario de auditoria.cambios_clientes no debería ser el mismo que opera clientes?**

Por el principio de separación de funciones. Si el mismo responsable de operar clientes (Gerencia Comercial o los usuarios de la aplicación) fuera dueño de la tabla de auditoría, tendría autoridad para decidir qué eventos se registran, modificar registros históricos o autorizar su borrado, destruyendo la independencia y validez legal de la evidencia ante un fraude o error operativo.

**2. ¿Quién debería poder leer las bitácoras y la vista dba.bitacora? Relaciónalo con lo observado en el LAB-01 (secretos en la bitácora).**

Únicamente personal estrictamente autorizado de Auditoría Interna, Seguridad de la Información y el DBA bajo el principio de mínimo privilegio. Como se observó en el LAB-01, las bitácoras registran sentencias SQL completas que pueden contener datos personales sensibles (RFC, teléfonos, correos) o credenciales en texto plano (como ALTER USER ... WITH PASSWORD), por lo que abrir su lectura a desarrolladores o usuarios generales expondría secretos del sistema.

**3. ¿Qué ocurre con la responsabilidad sobre un dato cuando nadie la tiene asignada? Relaciónalo con el problema inicial de la unidad.**

Se produce un vacío de gobernanza, ya que nadie valida la veracidad del dato, nadie autoriza cómo ni cuándo corregirlo y nadie asume las consecuencias de su alteración. En el problema inicial de la unidad (el cambio indebido del RFC de María García), sin un propietario asignado ni registros de auditoría del dato, el DBA no puede decidir qué RFC es el válido y Facturación queda paralizada sin saber quién debe autorizar ni respaldar documentalmente la restauración.