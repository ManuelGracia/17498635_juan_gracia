# Actividad 13 — Altas y bajas

**1. ¿Dónde queda evidencia de que existió y de sus datos?**

La evidencia completa queda almacenada en la tabla auditoria.cambios_clientes:

id_evento = 2 (INSERT): Registra el momento del alta y almacena todos los datos iniciales en la columna valores_despues dentro del documento JSONB ({"id": 6, "rfc": "RUPE950101AAA", "edad": 30, "nombre": "Pedro Ruiz", ...}).

id_evento = 3 (DELETE): Captura la baja y conserva el último estado conocido del cliente antes de su eliminación en la columna valores_antes.

Adicionalmente, si los niveles de bitácora registran sentencias DML o modificaciones, la bitácora física del motor (dba.bitacora) mantendrá la traza de la ejecución del comando.

**2. ¿Por qué ip_cliente está vacía en los eventos 2 y 3?**

Porque las sentencias fueron ejecutadas por el administrador (postgres) mediante una conexión local por socket de dominio Unix (conexión de tipo local en pg_hba.conf), sin pasar por la capa de red TCP/IP.

Al no existir un paquete de red ni una pila TCP/IP involucrada, la función nativa inet_client_addr() no detecta una dirección IP remota y devuelve NULL.

**3. El conflicto de políticas: Privacidad de Datos vs. Auditoría Forense**

El Conflicto (Derecho al olvido frente a No repudio e Inmutabilidad)
Existe una contradicción directa entre dos marcos regulatorios y de seguridad:

* Privacidad y Retención de Datos (PII / LFPDPPP / GDPR): Exige purgar, borrar o anonimizar los datos personales del titular cuando ya no son necesarios para la finalidad operativa o cuando el cliente ejerce su derecho de cancelación/olvido.

* Auditoría, Seguridad e Inmutabilidad (No Repudio / ISO 27001): Exige que los registros de auditoría no se alteren ni borren jamás para garantizar la trazabilidad forense de las operaciones del sistema.

Aunque la fila de "Pedro Ruiz" se eliminó de la tabla transaccional clientes, sus datos personales (nombre, correo, RFC) siguen existiendo en texto claro dentro de los objetos JSONB de la tabla de auditoría, lo que legalmente incumple el borrado definitivo si no se gestiona adecuadamente.

**¿Quién debe resolverlo y cómo?**

La decisión debe ser tomada conjuntamente por el Oficial de Protección de Datos (DPO) / Gobierno Corporativo / Área Legal y ejecutada técnicamente por el DBA / Dirección de TI:

* DPO / Área Legal: Establece los plazos de retención legal obligatoria (por ejemplo, conservar la auditoría durante 5 años para efectos fiscales o periciales) y determina la fecha exacta en que prevalece el borrado definitivo de los datos personales.

* DBA / Equipo de TI: Implementa la arquitectura técnica para conciliar ambas políticas, aplicando esquemas de:

* Seudonimización o enmascaramiento: Proceso automatizado que remueve o cifra los campos de datos personales (PII) en los documentos JSONB de auditoría una vez vencido el periodo de retención transaccional, conservando la metadata del evento (id_evento, momento, usuario_sesion, operacion).

* Particionamiento y Purgado Programado: Eliminación física de particiones históricas de la tabla de auditoría cuando cumplen el ciclo de vida dictado por la ley.