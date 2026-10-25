# ACTIVIDAD 12 - Privacidad por Diseño

**1. ¿Qué problemas identificas?**

* Recolección excesiva de datos ("Data Hoarding"): Almacenar información de forma masiva "por si acaso" viola las regulaciones de privacidad y aumenta desproporcionadamente la superficie de ataque e impacto ante una brecha de seguridad (data breach).

* Redundancia e inconsistencia de datos: Almacenar edad y fecha_nacimiento de forma simultánea crea duplicidad de información. La edad es un dato dinámico que se desactualiza y debe ser derivado/calculado a partir de la fecha de nacimiento únicamente cuando sea necesario.

* Captura de datos patrimoniales y de perfil socioeconómico: La inclusión de campos como salario, estado_civil y ocupacion en un registro general sin un propósito financiero/crediticio justificado expone a la organización a mayores cargas legales de protección.

* Inexistencia de vinculación con la finalidad: No hay congruencia entre los datos solicitados y un objetivo operativo claro informado al cliente.

**2. ¿Qué principio de privacidad se está ignorando?**

* Principio de Minimización de Datos: Establece que una organización solo debe recopilar y tratar los datos que sean adecuados, relevantes y estrictamente necesarios para cumplir con la finalidad informada.

* Principio de Limitación de la Finalidad: Exige que los datos se recaben para fines determinados, explícitos y legítimos, prohibiendo su recolección para usos futuros hipotéticos o no definidos.

* Enfoque de Privacidad por Diseño y por Defecto (Privacy by Design & Default): Se ignoró al diseñar la estructura pensando en la máxima acumulación de datos en lugar de la máxima protección por defecto.

**3. ¿Qué preguntas realizarías antes de aprobar el diseño?**

* ¿Cuál es el core business de la aplicación y qué finalidad operativa específica cumple cada uno de los campos solicitados?

* ¿Qué campos son indispensables para completar el registro básico de un cliente?

* ¿El cliente requiere factura o entregas físicas en su domicilio desde el momento del registro?

* ¿Existe una justificación legal o de evaluación de riesgo financiero para solicitar salario, ocupacion y estado_civil?

* ¿Estos campos están contemplados y clasificados en el Aviso de Privacidad vigente?

**4. ¿Qué datos eliminarías?**

* edad: Debe eliminarse de la estructura física de la tabla por ser redundante con fecha_nacimiento. Si se requiere para reglas de negocio, se calcula en tiempo de ejecución o mediante un campo generado.

* salario: Debe eliminarse a menos que la aplicación sea un sistema bancario, de préstamos o evaluación crediticia.

* estado_civil y ocupacion: Deben eliminarse de la tabla principal de registro de clientes generales, ya que no son necesarios para la relación comercial estándar.

**5. ¿Qué datos requerirían una justificación adicional?**

* salario: Clasificado como dato patrimonial/financiero. Requiere un nivel de protección reforzado, consentimiento explícito del titular y justificación de evaluación crediticia.

* rfc: Solo se justifica si el cliente solicita explícitamente facturación electrónica o si existe una obligación legal de retención fiscal.

* direccion (dirección exacta): Solo se justifica si la aplicación involucra logística, envíos físicos o servicios a domicilio. Si solo se requiere segmentación geográfica, basta con la ciudad o codigo_postal.

* fecha_nacimiento: Requiere justificar si se necesita la fecha exacta (ej. requerimiento legal de mayoría de edad) o si basta con solicitar una confirmación booleana (es_mayor_de_edad = TRUE).

**6. ¿Cómo aplicarías privacidad por defecto?**

* Registro progresivo (Progressive Profiling): Diseñar la tabla base únicamente con los datos mínimos obligatorios para crear la cuenta (id, nombre, correo y credenciales). Los demás datos se solicitan opcionalmente en el momento preciso en que el cliente requiere una función específica (ej. pedir la dirección solo cuando va a realizar una compra física).

* Campos no obligatorios por defecto: Evitar la restricción NOT NULL en atributos secundarios o de perfilamiento.

* Segmentación mediante esquemas y vistas: Aislar los datos sensibles/fiscales en tablas complementarias (ej. clientes_datos_fiscales) con controles de acceso restringidos, evitando colocarlos en la tabla clientes de acceso general.

* Desactivación de recolección opcional (Opt-in): Garantizar que cualquier campo utilizado para mercadotecnia o análisis demográfico requiera la casilla desmarcada por defecto, exigiendo la acción afirmativa del cliente.