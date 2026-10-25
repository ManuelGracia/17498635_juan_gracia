# ACTIVIDAD 10 - Política de retención

**1. ¿Es compatible con el principio de minimización?**
No, es totalmente incompatible. El principio de minimización de datos exige que los datos tratados sean únicamente los estrictamente adecuados, relevantes y necesarios para cumplir con una finalidad determinada e informada.

Conservar datos “por si acaso” o de forma indefinida para hipotéticos usos futuros viola tanto la minimización como el principio de limitación del plazo de conservación, el cual obliga a suprimir o anonimizar la información una vez que ha concluido la finalidad operativa o la obligación legal que justificó su recolección.

**2. ¿Qué riesgos genera conservar información innecesaria?**

Conservar información innecesaria o fuera de su ciclo de vida genera los siguientes riesgos:

**Mayor impacto ante brechas de seguridad (Data Breach):** Incrementa la superficie de ataque. Si ocurre una exfiltración de datos, el volumen y la antigüedad de la información comprometida aumentan desproporcionadamente las consecuencias financieras y operativas.

**Sanciones legales y regulatorias:** Expone a la organización a multas severas por parte de las autoridades de supervisión (como el INAI bajo la LFPDPPP) al incumplir los plazos legales de conservación y los principios de privacidad.

**Daño reputacional:** Pérdida de confianza del mercado y de los titulares al revelarse que la empresa mantiene información personal antigua sin justificación legítima ni consentimiento.

**Incapacidad para atender Derechos ARCO:** Dificulta el cumplimiento eficiente de solicitudes de cancelación o acceso, al tener que buscar y procesar grandes volúmenes de datos dispersos u obsoletos.

**Costos e ineficiencia operativa:** Genera costos innecesarios en almacenamiento, procesamiento, infraestructura de respaldos y complejidad en la administración de las bases de datos.

**3. ¿Qué debería determinar la organización antes de establecer un periodo de retención?**

Antes de establecer un periodo de retención, la organización debe determinar:

* La finalidad primaria y secundaria: Definir el tiempo exacto que requiere el dato para cumplir el propósito por el cual fue recolectado.

* Obligaciones legales y regulatorias: Identificar las leyes aplicables que exigen plazos mínimos de conservación (por ejemplo, leyes fiscales, mercantiles o de prevención de lavado de dinero, que suelen fijar plazos de 5 a 10 años).

* Plazos de prescripción de responsabilidades: Evaluar el periodo en el que podrían presentarse reclamaciones contractuales, disputas comerciales o requerimientos judiciales.

* Viabilidad de anonimización: Determinar si los análisis futuros pueden realizarse sobre datos agregados o anónimos, eliminando la necesidad de conservar PII cruda.

**4. ¿Qué información debería documentarse para justificar el periodo seleccionado?**

* Matriz de Retención de Datos: Documento formal que asocie cada categoría de dato con su plazo de conservación específico.

* Fundamento legal o base jurídica: La norma, código o análisis de riesgo que respalda explícitamente la duración del plazo fijado.

* Acción al vencimiento: El destino final del registro al cumplir el plazo (eliminación definitiva cifrada, desintegración de respaldos o proceso de anonimización irreversible).

* Mecanismos de suspensión (Legal Hold): El protocolo para congelar temporalmente la eliminación de registros en caso de litigios, auditorías o investigaciones activas.

* Roles responsables: Identificación explícita del Propietario de datos que autoriza la regla y del DBA que ejecuta el procedimiento técnico de purga.