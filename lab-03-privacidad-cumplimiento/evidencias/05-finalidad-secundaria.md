# ACTIVIDAD 5 - Analizar una finalidad secundaria

**1. ¿El hecho de que la organización ya tenga los datos significa automáticamente que puede utilizarlos para cualquier finalidad?**

No. De acuerdo con el principio de limitación de finalidad (purpose limitation), el tratamiento de datos personales debe sujetarse estrictamente a los propósitos informados al titular en el Aviso de Privacidad.

Haber recopilado legalmente información de clientes para finalidades primarias (como facturación o atención al cliente) no faculta a Comercializadora Norte S.A. de C.V. a reutilizarla automáticamente para finalidades secundarias o incompatibles sin contar con una base jurídica adecuada, que generalmente exige ofrecer un mecanismo claro de consentimiento o de oposición (opt-out).


**2. ¿Qué preguntas debería realizar la organización antes de implementar este tratamiento?**
* ¿La finalidad secundaria de “envío de promociones y perfilamiento” está explícitamente informada en el Aviso de Privacidad vigente?

* ¿Se requiere el consentimiento expreso/tácito del titular o existe la opción de que este ejerza su derecho ARCO de Oposición antes de incluirlo en las campañas?

* *¿Son los atributos solicitados (edad, ciudad, historial de compra) adecuados, relevantes y estrictamente necesarios para cumplir el objetivo publicitario?

* ¿El Propietario de Datos (Data Owner) del área comercial autorizó el tratamiento y se validó con Compliance/Oficial de Privacidad?

* ¿Qué impacto tiene sobre la privacidad del cliente combinar su ubicación geográfica con su comportamiento de compra?

**3. ¿Qué datos serían realmente necesarios?**

* Para análisis y segmentación:

    * Rango de edad (generalización de la edad exacta a rangos como 18-30, 31-45).

    * Ciudad (para agrupamiento geográfico).

    * Categoría/Patrón de compra agregado (en lugar de transacciones detalladas o datos financieros).

* Para el envío de la promoción:

    * Únicamente el correo electrónico (o canal de contacto autorizado).

* Datos innecesarios que deben ser excluidos:

    * RFC, teléfono, código postal completo e id original de la tabla base.

**4. ¿Necesitaría el área de marketing acceso directo a public.clientes?**

No. Otorgar acceso a public.clientes violaría el principio de menor privilegio e incrementaría el riesgo de accesos no autorizados a datos fiscales y de contacto sensible.

Marketing opera únicamente como un usuario consumidor de información segmentada. Por lo tanto, no requiere acceso a la tabla operacional original, sino a vistas o conjuntos de datos derivados diseñados para su finalidad específica.

**5. ¿Qué controles técnicos podrían limitar la información entregada?**

Como DBA, se deben aplicar los siguientes controles en el gestor:

* Vistas restrictivas por esquema: Crear una vista dentro de un esquema dedicado (ej. marketing.audiencia_promociones) que exponga únicamente el correo, la ciudad y el rango_edad.

* Filtro de consentimiento/Oposición obligatorio: Incluir en la definición SQL de la vista un filtro que excluya automáticamente a los titulares que hayan rechazado mercadotecnia o ejercido su derecho de cancelación/oposición:

```SQL
WHERE acepta_publicidad = TRUE AND estatus_cliente = 'ACTIVO'
```
* Control de Acceso Basado en Roles (RBAC): Conceder al rol de marketing permisos exclusivamente sobre las vistas de su esquema, revocando todo acceso de consulta directa sobre la tabla base public.clientes.

* Seudonimización en análisis: Reemplazar el id real del cliente por un token arbitrario cuando Marketing analice patrones de comportamiento de compra previa al envío.