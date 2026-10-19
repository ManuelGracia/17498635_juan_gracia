# **_Laboratorio 01_**: Protección y privacidad de datos

## Actividad 1 - Clasificación de datos
<table>
  <thead>
    <tr>
      <th style="text-align: center;">Campo</th>
      <th style="text-align: center;">¿Identifica directamente?</th>
      <th style="text-align: center;">¿Puede contribuir a identificar?</th>
      <th style="text-align: center;">¿Requiere protección?</th>
      <th style="text-align: center;">Justificación</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="text-align: center;">id</td>
      <td style="text-align: center;">No</td>
      <td style="text-align: center;">Si</td>
      <td style="text-align: center;">Si</td>
      <td style="text-align: justify;">Conociendo el id de un usuario se pueden consultar directamente sus datos dentro de una tabla sin control de accesos.</td>
    </tr>
    <tr>
      <td style="text-align: center;">nombre</td>
      <td style="text-align: center;">Si</td>
      <td style="text-align: center;">Si</td>
      <td style="text-align: center;">Si</td>
      <td style="text-align: justify;">El nombre es de los datos más sensibles de una persona, ya que este lo identifica directamente.</td>
    </tr>
    <tr>
      <td style="text-align: center;">correo</td>
      <td style="text-align: center;">Si</td>
      <td style="text-align: center;">Si</td>
      <td style="text-align: center;">Si</td>
      <td style="text-align: justify;">Es un método de contacto único de la persona, normalmente contiene el nombre completo de la persona y sirve como credencial de acceso.</td>
    </tr>
    <tr>
      <td style="text-align: center;">telefono</td>
      <td style="text-align: center;">Si</td>
      <td style="text-align: center;">Si</td>
      <td style="text-align: center;">Si</td>
      <td style="text-align: justify;">Es una línea de comunicación directa con la persona.</td>
    </tr>
    <tr>
      <td style="text-align: center;">rfc</td>
      <td style="text-align: center;">Si</td>
      <td style="text-align: center;">Si</td>
      <td style="text-align: center;">Si</td>
      <td style="text-align: justify;">Es una clave única oficial que incluye iniciales, fecha de nacimiento y homoclave única de la persona..</td>
    </tr>
    <tr>
      <td style="text-align: center;">edad</td>
      <td style="text-align: center;">No</td>
      <td style="text-align: center;">Si</td>
      <td style="text-align: center;">Si</td>
      <td style="text-align: justify;">Si se junta con otro conjunto de datos puede utilizarse para identificar a una persona directamente.</td>
    </tr>
    <tr>
      <td style="text-align: center;">código postal</td>
      <td style="text-align: center;">No</td>
      <td style="text-align: center;">Si</td>
      <td style="text-align: center;">Si</td>
      <td style="text-align: justify;">Es casi un identificador de ubicación, combinado con la edad y otros datos demográficos puede aumentar el riesgo de reidentificación de una persona.</td>
    </tr>
    <tr>
      <td style="text-align: center;">fecha alta</td>
      <td style="text-align: center;">No</td>
      <td style="text-align: center;">Si</td>
      <td style="text-align: center;">No</td>
      <td style="text-align: justify;">No identifica directamente a la persona.</td>
    </tr>
  </tbody>
</table>

### Preguntas:
1. **¿Qué datos identifican directamente a una persona?**
El nombre, correo, teléfono, rfc. Son identificadores directos que señalan directamente a la persona sin necesidad de añadir información adicional.

2. **¿Qué campos no identifican por sí solos pero podrían contribuir a hacerlo?**
El id, edad, ciudad, código postal y fecha alta. Son identificadores indirectos, por separado son compartidos entre grandes volúmenes de personas, pero al combinarse permiten acortar la búsqueda.

3. **¿Qué combinación de campos podría incrementar el riesgo de reidentificación**
Si se combinan el código postal, edad, ciudad y fecha alta hay grandes posibilidades de identificar a una persona de X ciudad, de Y edad que se haya dado de alta el día Z.

4. **¿Todos los datos que deben protegerse son necesariamente datos personales sensibles desde el punto de vista jurídico?**
No, ya que existe una gran diferencia entre datos personales y datos personales sensibles, los datos personales como nombre, corre, teléfono, rfc, etc. deben protegerse por ley, los datos personales _sensibles_ son datos que pueden originar discriminación o un riesgo grave, como el estado de salud de la persona, ideoligía política, etnia, etc.

## ACTIVIDAD 2 - ENMASCARAMIENTO

1. **¿Qué información continúa existiendo en la tabla original?** La tabla continúa existiendo intacta, lo que se creó fue una vista, o sea que no se alteraron los datos originales.

2. **¿Qué información puede visualizar el usuario soporte?** El usuario soporte pueder ver el id y el nombre de los clientes.

3. **¿Por qué no es suficiente ocultar los datos únicamente en la aplicación?** Porque la aplicación puede acceder a los datos crudos mediante un SELECT y mostrarlos utilizando un enmascaramiento, lo cual en conocimiento de un usuario malicioso puede llevar a que se filtren los datos originales.

4. **¿Qué ocurriría si soporte tuviera acceso directo a clientes?** Si fuera una persona maliciosa, podría vender la información de los clientes a la competencia o alterar los datos de la tabla.

## ACTIVIDAD 4 - SEPARACIÓN DE FUNCIONES

1. **¿Qué ocurriría si analista pudiera consultar también pii.mapa_cliente?** La seudonimización perdería su efectividad, ya que el usuario analista podría cruzar los datos seudonimizados de analitica.clientes con el mapa de correspondencia pii.mapa_cliente, logrando reidentificar a las personas y anulando la protección de la identidad.

2. **¿Qué principio de seguridad se está aplicando al separar ambos accesos?** El principio de Separación de funciones (segregación de funciones), soportado además por el principio de menor privilegio (least privilege), el cual limita los permisos de cada rol estrictamente a los recursos necesarios para su trabajo.


3. **¿Por qué la seudonimización no equivale a anonimización?** Porque la seudonimización es un proceso reversible que reemplaza los datos identificativos por seudónimos o tokens, conservando la posibilidad de reidentificar al individuo mediante información adicional. La anonimización es un proceso irreversible mediante el cual es imposible volver a asociar los datos con la persona.


4. **¿Qué información permite volver a relacionar el token con una persona?** El mapa de correspondencia, el cual contiene la relación explícita entre el token/seudónimo analítico y los datos de identidad real.

## ACTIVIDAD 6 - ANÁLISIS DEL RIESGO DE REIDENTIFICACIÓN
1. **¿Qué identificadores directos fueron eliminados?** Se eliminaron identificadores directos como el nombre, teléfono, dirección de correo electrónico, RFC, código postal, etc.


2. **¿Qué cuasi-identificadores permanecen?** La edad, que ahora está dentro de un rango y la región.


3. **¿Qué combinaciones de atributos podrían reducir el anonimato?** Al combinar el rango de edad y la región junto con otros cuasi-identificacdores podrían reducir el tamaño de la búsqueda.


4. **¿Qué sucede cuando un grupo contiene pocos registros?** Aumentan el riesgo de reidentificación al aislar a los individuos dentro del conjunto.


5. **¿Qué atributos deberían generalizarse?** Los cuasi-identificadores precisos o continuos, como la edad exacta (convertida a rangos) y el código postal completo (reducido a nivel regional).


6. **¿Qué información debería suprimirse?** Los identificadores directos y las combinaciones atípicas o grupos reducidos que no superen el umbral establecido de registros (k < 5).


7. **¿Es correcto afirmar que el conjunto de datos es “100 % anónimo”? ¿Por qué?**
No, porque cumplir con un umbral k = 5 reduce el riesgo pero no garantiza un anonimato absoluto, ya que siempre pueden existir atributos adicionales o fuentes de datos externas que permitan reidentificar a una persona.


RETO

```SQL
    SELECT

    CASE
        WHEN edad BETWEEN 18 AND 40 THEN '18-40'
        WHEN edad BETWEEN 41 AND 65 THEN '41-65'
        ELSE '65+'
    END AS rango_edad,
    
    LEFT(codigo_postal, 2) AS region,
    
    COUNT(*) AS total

    FROM clientes

    GROUP BY 1, 2

    HAVING COUNT(*) >= 10;
```

**Motivo**: Aumentar el grado de abstracción de los cuasi-identificadores y elevar la exigencia de agrupación para evitar que combinaciones poco comunes de edad y ubicación permitan aislar a un individuo dentro de la muestra estadística.

**Resultado obtenido**:
Se obtienen segmentos analíticos más amplios y uniformes. Aunque se pierde granularidad detallada en la segmentación de edad y zona geográfica, el conjunto de datos final solo muestra tendencias macroeconómicas o regionales consolidadas con un mínimo de 10 personas por categoría.

**Riesgo que se pretende reducir**: 
*   **Ataque por vinculación de datos**: Dificulta que un tercero con información parcial externa (por ejemplo, conocer la edad exacta y el código postal de un vecino) pueda cruzar los datos para identificar a esa persona en el reporte.
*   **Ataque de inferencia por homogeneidad**: Al obligar a que cada grupo tenga al menos 10 integrantes (k = 10) y pertenezca a zonas geográficas más extensas, disminuye drásticamente la probabilidad de inferir información confidencial por simple exclusión.

## ACTIVIDAD 7 - RETENCIÓN DE DATOS

**1. Registros afectados**:
Aquellos clientes cuya fecha de alta (fecha_alta) tenga una antigüedad estrictamente mayor a 5 años respecto a la fecha de ejecución (CURRENT_DATE - INTERVAL '5 years'). Se trata de datos de usuarios que han superado el ciclo de vida operacional y de retención estándar definido por la organización.

**2. Justificación del periodo de conservación**:
* Cumplimiento legal y normativo: Principio de limitación del plazo de conservación (exigido por marcos como el RGPD o leyes locales de protección de datos), que prohíbe mantener datos personales de forma indefinida cuando la finalidad original ha expirado.

* Prescripción de responsabilidades: El plazo de 5 años suele corresponder con el periodo marco legal para atender prescripciones de obligaciones contractuales, reclamos comerciales o auditorías fiscales.

* Minimización del riesgo de seguridad: Reducir la cantidad de datos almacenados disminuye el impacto potencial ante una brecha de seguridad (data breach).

**3. Aprobaciones requeridas previa eliminación**:
Antes de ejecutar la purga, se requiere la autorización explícita mediante un flujo formal de control de cambios:

* Oficial de Protección de Datos (DPO): Garantiza que no existan litigios activos o requerimientos legales que obliguen a congelar los datos.

* Propietario de los datos (Data Owner): Confirma que los clientes identificados no mantienen cuentas activas ni operaciones pendientes.

* Administrador de Base de Datos (DBA): Revisa y aprueba el impacto técnico de la consulta en el rendimiento del sistema.

**4. Respaldo previo requerido**:
* Snapshot o Backup de seguridad previo: Respaldo completo (Full Backup) o exportación (dump) de las tablas afectadas justo antes de la transacción.

* Almacenamiento frío cifrado (Cold Storage): Transferencia temporal de los datos purgados a una tabla intermedia de archivo o a un contenedor seguro offline con acceso restringido únicamente a personal de auditoría.

**5. Evidencia a conservar (Log de auditoría)**:
No deben conservarse los datos personales eliminados, sino un registro inmutable del proceso (Audit Log) que contenga:

* ID del ticket de aprobación y responsable que autorizó la purga.

* Identidad del usuario/rol técnico que ejecutó la instrucción.

* Fecha y hora exacta de la ejecución.

* Filtro SQL exacto aplicado y cantidad total de filas afectadas.

* Hash de confirmación de la operación.

**6. Procedimiento de recuperación ante eliminación accidental**:

* Restauración en punto en el tiempo: Uso de los registros de transacciones de la base de datos para rearmar el estado del sistema hasta el segundo previo a la ejecución del borrado.

* Restauración aislada desde Snapshot: Montar el respaldo previo en un entorno de pruebas o esquema temporal, aislar únicamente los registros eliminados por error y reinsertarlos mediante un script de actualización (`INSERT INTO clientes SELECT ... FROM respaldo.clientes`).

* Protocolo de reversión (Rollback Plan): Definición de una ventana de tiempo estricta (ej. 24 a 48 horas) para auditar la eliminación antes de destruir el respaldo temporal de seguridad.

## 19 Informe

### 19.1 Clasificación
* **Datos que requieren protección:** Identificadores directos (nombre, correo electrónico, teléfono, RFC) y cuasi-identificadores / identificadores indirectos (ID de usuario, edad, código postal, fecha de alta).
* **Justificación:** Los identificadores directos señalan de manera única e inmediata a una persona física, por lo que su exposición compromete directamente su privacidad y facilita delitos como la suplantación de identidad. Por su parte, los cuasi-identificadores, aunque individualmente parecen seguros, permiten recortar el universo de búsqueda hasta reidentificar al sujeto cuando se combinan entre sí o con fuentes de datos externas. La protección de ambos grupos es obligatoria para dar cumplimiento a los principios de minimización y confidencialidad exigidos por las regulaciones de protección de datos personales.

### 19.2 Enmascaramiento
* **Qué se ocultó:** Se restringieron las columnas sensibles completas (correo, teléfono, RFC, código postal) mostrando únicamente los datos mínimos indispensables (como el ID y el nombre del cliente).
* **Para quién:** Para el rol operativo de soporte (`soporte`).
* **Por qué:** El personal de soporte requiere atender solicitudes de clientes específicos, pero no necesita visualizar la totalidad de sus datos personales ni de contacto en claro para validar peticiones operativas básicas. Limitar los campos expuestos reduce la superficie de riesgo ante fuga o venta no autorizada de información.
* **Mecanismo utilizado:** Creación de una vista SQL (`CREATE VIEW`) que selecciona exclusivamente los campos autorizados, complementada con la asignación selectiva de permisos (`GRANT SELECT ON vista TO soporte`) y la revocación del acceso directo a la tabla principal (`public.clientes`).

### 19.3 Seudonimización
* **Generación de tokens:** Se reemplazaron los identificadores directos por valores alfanuméricos arbitrarios o claves sintéticas (tokens) que no guardan relación algorítmica ni deducible con los datos personales originales.
* **Ubicación del mapa de correspondencia:** En un esquema aislado y protegido de la base de datos denominado `pii.mapa_cliente`.
* **Acceso autorizado:** Únicamente los administradores del sistema de seguridad de datos, el Oficial de Protección de Datos (DPO) o procesos automatizados con privilegios elevados de reidentificación.
* **Separación de permisos:** Se implementó para garantizar que los analistas de datos puedan realizar estudios sobre la tabla `analitica.clientes` sin posibilidad de realizar un cruce (`JOIN`) con `pii.mapa_cliente`, asegurando la efectividad técnica del tokenizado.

### 19.4 Anonimización
* **Identificadores eliminados:** Nombre, teléfono, correo electrónico, RFC, ID de cliente y código postal completo.
* **Atributos generalizados:** La edad exacta fue agrupada en rangos o intervalos (ej. `18-40`, `41-65`, `65+`), y la ubicación fue abstraída a nivel regional o macro-regional reduciendo la precisión del código postal (`LEFT(codigo_postal, 2)` o `LEFT(codigo_postal, 1)`).
* **Grupos suprimidos:** Aquellas combinaciones de atributos cuyos conteos agregados no alcanzaron el umbral mínimo de seguridad (k-anonimato), utilizando la cláusula `HAVING COUNT(*) >= 5` (o `>= 10` en el reto propuesto).
* **Riesgo remanente:** Persiste el riesgo de ataques por vinculación de datos si un tercero cruza estos resultados con bases de datos externas públicas o privadas, así como el riesgo de inferencia por homogeneidad si un grupo resultante comparte atributos confidenciales idénticos.

### 19.5 Retención
* **Criterio utilizado:** Registros con una antigüedad superior a 5 años desde la fecha de alta (`fecha_alta < CURRENT_DATE - INTERVAL '5 years'`).
* **Información a conservar:** Datos de clientes con relación contractual activa, transacciones vigentes, aquellos bajo investigación judicial o congelación legal, así como las evidencias/logs de auditoría inmutables del proceso de purga.
* **Información a eliminar:** Datos personales de usuarios inactivos cuyo periodo de conservación obligatorio (fiscal, mercantil o administrativo) haya expirado.
* **Controles previos a la eliminación:**
  1. Aprobación formal del Oficial de Protección de Datos (DPO), Propietario de los Datos y Administrador de Base de Datos (DBA).
  2. Verificación de ausencia de bloqueos legales sobre los registros identificados.
  3. Generación de un respaldo inalterable (*Snapshot/Full Backup*) antes de la ejecución.
  4. Registro estricto en la bitácora de auditoría (usuario, fecha, filtro ejecutado y volumen de filas afectadas).

### 19.6 Conclusiones
* **Área de soporte:** **Enmascaramiento dinámico o Vistas restrictivas**, ya que permite atender casos puntuales identificables limitando la visualización a los datos estrictamente necesarios para la atención.
* **Área de analítica:** **Seudonimización**, debido a que permite realizar análisis del comportamiento individual a lo largo del tiempo utilizando un token unívoco, sin exponer la PII directa.
* **Publicación de estadísticas:** **Anonimización** (agregación, generalización y supresión con k-anonimato), para impedir irreversiblemente la reidentificación de cualquier individuo en reportes públicos.
* **Sustitución del control de acceso:** Ninguna de estas técnicas sustituye al control de acceso porque transforman o presentan la información, pero no gestionan la autenticación ni las autorizaciones del sistema. Sin un control de acceso robusto, un usuario podría eludir las vistas, acceder a los datos crudos en la tabla principal, consultar los mapas de correspondencia o alterar las reglas del sistema.


## 20. Preguntas de reflexión

1. **¿Cuál es la diferencia entre enmascaramiento y seudonimización?**  
   El enmascaramiento modifica la presentación visual del dato (ocultando caracteres parcialmente) para restringir su lectura en pantalla manteniendo el formato original. La seudonimización reemplaza el identificador por un token sintético en la base de datos, manteniendo la capacidad de revertir el proceso mediante un mapa de correspondencia almacenado por separado.

2. **¿Por qué la seudonimización no significa anonimización?**  
   Porque la seudonimización es un proceso reversible que conserva la posibilidad de reidentificar al individuo mediante información adicional (el mapa de correspondencia). La anonimización es un proceso irreversible donde los datos no pueden volver a asociarse a una persona por ningún medio razonable.

3. **¿Por qué eliminar nombre y RFC no garantiza que un conjunto de datos sea anónimo?**  
   Porque los datos restantes pueden actuar como cuasi-identificadores (edad, código postal, fecha de registro). Si estos atributos se combinan entre sí o se cruzan con bases de datos externas, la combinación puede resultar única e identificar unívocamente a una persona.

4. **¿Qué función tienen los cuasi-identificadores?**  
   Son atributos que por sí solos no identifican a un individuo, pero que al combinarse reducen de forma drástica el grupo de búsqueda, permitiendo la reidentificación de sujetos en un conjunto de datos.

5. **¿Por qué es importante separar el mapa de seudonimización?**  
   Porque si el mapa reside en el mismo esquema o está al alcance de los mismos usuarios que consultan los datos seudonimizados, la técnica pierde toda su efectividad, ya que una simple consulta de unión (`JOIN`) revelaría la identidad real inmediatamente.

6. **¿Qué principio de seguridad se aplica al impedir que el analista acceda al mapa?**  
   El principio de **Separación de Funciones** (*Segregation of Duties*), respaldado por el principio de **Menor Privilegio** (*Least Privilege*).

7. **¿Por qué una vista puede ser preferible a entregar acceso directo a la tabla?**  
   Porque la vista actúa como una capa de abstracción y control, ya que  permite filtrar columnas sensibles, aplicar transformaciones de enmascaramiento y restringir filas sin modificar la tabla física subyacente ni conceder permisos de lectura o modificación sobre los datos originales.

8. **¿Qué diferencia existe entre proteger un dato para visualización y protegerlo contra acceso no autorizado?**  
   Proteger para visualización condiciona el formato en que un usuario autorizado observa la información en una interfaz o consulta restringida (evita miradas indiscretas). Proteger contra acceso no autorizado bloquea el canal de consulta a nivel del motor de base de datos o almacenamiento, impidiendo que usuarios sin privilegios lean, extraigan o manipulen los datos crudos.

9. **¿Por qué la retención forma parte de la protección de datos?**  
   Porque responde al principio de limitación del plazo de conservación. Conservar únicamente los datos necesarios durante el tiempo estrictamente justificado garantiza los derechos de privacidad de los titulares y reduce la cantidad de datos expuestos en la organización.

10. **¿Qué riesgo existe si una organización conserva información indefinidamente?**  
    Aumenta el impacto económico, legal y reputacional ante brechas de seguridad, expone a la organización a severas sanciones por incumplimiento normativo de privacidad, e incrementa los costos operativos de almacenamiento y mantenimiento de datos obsoletos.