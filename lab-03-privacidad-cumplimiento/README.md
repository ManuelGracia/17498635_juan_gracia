# **LAB-03 — Privacidad, cumplimiento y gobierno de los datos**

### 1. Introducción
El informe aborda la diferencia crítica entre la seguridad de la infraestructura y el cumplimiento del principio de privacidad. Una base de datos técnicamente segura puede seguir violando leyes de privacidad si almacena información excesiva, la conserva indefinidamente o permite su uso para finalidades no informadas al titular.

### 2. Inventario de datos
Los datos capturados en la tabla `clientes` se clasificaron entre identificadores directos (`nombre`, `correo`, `telefono`, `rfc`), cuasi-identificadores (`edad`, `ciudad`, `codigo_postal`) e identificadores sintéticos (`id`).

### 3. Finalidades
Las finalidades se dividen en primarias operativas (soporte y facturación) y secundarias (analítica y marketing). Cada consulta debe limitarse a la finalidad autorizada.

### 4. Minimización
Se demostró la necesidad de eliminar atributos redundantes (`edad`), suprimir datos no justificados (`salario`, `estado_civil`) y generalizar cuasi-identificadores en esquemas secundarios.

### 5. Control de acceso
Mediante un esquema RBAC, los permisos se otorgaron estrictamente según la función del rol, evitando que los usuarios accedan a tablas crudas sin enmascarar.

### 6. Derechos ARCO
Se identificaron los retos técnicos de atender el derecho de Cancelación, subrayando que un `DELETE` no elimina copias en respaldos, réplicas ni logs.

### 7. Retención
El periodo de retención debe basarse en la vida útil operativa más el plazo legal de prescripción (fiscal/mercantil), requiriendo purga automatizada al vencimiento.

### 8. Gobierno de datos
Se formalizó la Matriz de Gobierno definiendo *Data Owners* y *Data Custodians* para cada campo de la base de datos.

### 9. Evaluación integral
Se detallaron 10 problemas operativos y sus soluciones técnicas mediante enmascaramiento, seudonimización y aislamiento de entornos.

### 10. Conclusiones
Se comprendió que el DBA opera como el ejecutor técnico (*Custodio*) de las decisiones del negocio y normativas de privacidad.

## **10. Preguntas de Reflexión**

### 1. ¿Una base de datos técnicamente segura necesariamente cumple con todos los requisitos de privacidad?
No. La seguridad protege los datos contra accesos no autorizados, mientras que la privacidad determina la legitimidad de su tratamiento. Una base de datos sin brechas técnicas puede violar la privacidad si recolecta datos innecesarios o los conserva sin consentimiento.

### 2. ¿Por qué el principio de mínimo privilegio también contribuye a la privacidad?
Porque restringe la visibilidad de los datos personales exclusivamente a quienes los necesitan para su función, disminuyendo la superficie de exposición y el riesgo de fugas internas.

### 3. ¿Por qué el DBA no debería decidir por sí solo la finalidad del tratamiento de los datos?
Porque la finalidad es una decisión estratégica y jurídica que corresponde al Propietario de los Datos y al área de Cumplimiento/Privacidad. El DBA actúa únicamente como custodio técnico.

### 4. ¿Por qué los desarrolladores no deberían recibir automáticamente copias completas de bases de datos productivas?
Porque los entornos de prueba carecen de los mismos niveles de protección que producción, exponiendo datos reales en sistemas con menor seguridad.

### 5. ¿Por qué una copia utilizada para desarrollo también puede representar un riesgo de privacidad?
Porque los datos reales en entornos de desarrollo pueden filtrarse a través de repositorios, archivos de logs o equipos portátiles de trabajo.

### 6. ¿Por qué la retención debe formar parte del ciclo de vida de los datos?
Porque conservar datos indefinidamente incrementa los riesgos de seguridad y viola los principios legales de proporcionalidad y limitación de la conservación.

### 7. ¿Qué relación existe entre privacidad por diseño y diseño de bases de datos?
Implica proyectar el modelo de datos, los esquemas y las políticas de acceso considerando la minimización y la protección desde la arquitectura inicial.

### 8. ¿Qué controles técnicos implementarías para reducir el riesgo de exposición de datos personales?
* Control de Acceso por Roles (RBAC).
* Vistas de Enmascaramiento Dinámico.
* Seudonimización y Cifrado (`pgcrypto`).
* Auditoría con `pgaudit`.

### 9. ¿Qué información debería conocer un DBA para responder técnicamente a una solicitud ARCO?
* La ubicación de la PII en todas las tablas y esquemas.
* La red de dependencias e integridad referencial.
* Los flujos de sincronización con réplicas y *Data Warehouses*.
* El ciclo de vida de los respaldos.

### 10. ¿Qué responsabilidades deberían corresponder al DBA, al responsable de privacidad, al área jurídica y al propietario de los datos?
* **Área Jurídica:** Define el marco legal y revisa los Avisos de Privacidad.
* **Responsable de Privacidad:** Supervisa el cumplimiento de derechos ARCO y evalúa riesgos de privacidad.
* **Propietario de los Datos:** Define la finalidad comercial y autoriza accesos por rol.
* **DBA:** Implementa técnicamente las restricciones, esquemas, permisos y procedimientos de purga en la base de datos.