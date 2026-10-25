# ACTIVIDAD 14 - Escenario Integral

<table>
  <thead>
    <tr>
      <th style="text-align: center;">#</th>
      <th style="text-align: center;">Problema</th>
      <th style="text-align: center;">Principio afectado</th>
      <th style="text-align: center;">Riesgo</th>
      <th style="text-align: center;">Control propuesto</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="text-align: center;"><b>1</b></td>
      <td style="text-align: justify;"><b>Acceso directo de analítica a la tabla principal clientes</b></td>
      <td style="text-align: center;">Menor privilegio y Separación de funciones</td>
      <td style="text-align: justify;">Exposición masiva de la base de datos de producción; un analista comprometido podría extraer o alterar los 50,000 registros completos.</td>
      <td style="text-align: justify;">Revocar el acceso directo a public.clientes, aislar el entorno analítico en un esquema propio y controlar el acceso mediante roles (RBAC).</td>
    </tr>
    <tr>
      <td style="text-align: center;"><b>2</b></td>
      <td style="text-align: justify;"><b>Presencia de PII e identificadores directos en consultas de analítica</b></td>
      <td style="text-align: center;">Minimización de datos y Privacidad por defecto</td>
      <td style="text-align: justify;">Sobreexposición inútil de PII para un área que solo requiere métricas globales, aumentando la probabilidad de filtración o mal uso de identidad.</td>
      <td style="text-align: justify;">Seudonimizar o sustituir identificadores directos por tokens arbitrarios y exponer únicamente vistas o tablas analíticas sin PII.</td>
    </tr>
    <tr>
      <td style="text-align: center;"><b>3</b></td>
      <td style="text-align: justify;"><b>Uso de datos detallados cuando analítica solo requiere estadísticas mensuales</b></td>
      <td style="text-align: center;">Proporcionalidad y Necesidad</td>
      <td style="text-align: justify;">Posibilidad de rastrear o aislar a individuos específicos dentro de reportes internos sin una justificación operativa real.</td>
      <td style="text-align: justify;">Convertir los datos a agregados estadísticos (COUNT, GROUP BY) aplicando técnicas de anonimización y supresión de grupos pequeños (k-anonimato con k ≥ 5).</td>
    </tr>
    <tr>
      <td style="text-align: center;"><b>4</b></td>
      <td style="text-align: justify;"><b>Conservación de datos por 12 años sin justificación operativa o legal</b></td>
      <td style="text-align: center;">Limitación del plazo de conservación (Retención)</td>
      <td style="text-align: justify;">Exposición inútil de datos antiguos que incrementa el impacto legal, operativo y financiero en caso de sufrir una brecha de seguridad.</td>
      <td style="text-align: justify;">Definir un ciclo de vida de los datos y depurar/archivar en frío la información de clientes inactivos que supere el plazo legal de prescripción.</td>
    </tr>
    <tr>
      <td style="text-align: center;"><b>5</b></td>
      <td style="text-align: justify;"><b>Ausencia de una política documentada de retención de datos</b></td>
      <td style="text-align: center;">Gobierno de datos y Responsabilidad proactiva</td>
      <td style="text-align: justify;">Retención indefinida por defecto, incumplimiento de marcos regulatorios (LFPDPPP) e incapacidad de auditar el ciclo de vida de la información.</td>
      <td style="text-align: justify;">Redactar, aprobar y formalizar una Política de Retención y Destrucción de Datos con matrices claras de conservación por tipo de dato y responsable.</td>
    </tr>
    <tr>
      <td style="text-align: center;"><b>6</b></td>
      <td style="text-align: justify;"><b>Entrega de copias completas de la base de datos a desarrolladores</b></td>
      <td style="text-align: center;">Seguridad de los datos y Confidencialidad</td>
      <td style="text-align: justify;">Los entornos de desarrollo/pruebas suelen carecer de controles de seguridad estrictos, multiplicando las superficies de ataque y puntos de fuga.</td>
      <td style="text-align: justify;">Prohibir la entrega de volúmenes o respaldos completos de producción a entornos de desarrollo; entregar únicamente muestras acotadas y estructuradas.</td>
    </tr>
    <tr>
      <td style="text-align: center;"><b>7</b></td>
      <td style="text-align: justify;"><b>Uso de información real de clientes en entornos de pruebas y desarrollo</b></td>
      <td style="text-align: center;">Privacidad por diseño y Confidencialidad</td>
      <td style="text-align: justify;">Filtración accidental de PII a través de logs de prueba, repositorios de código o accesos de terceros/proveedores de software.</td>
      <td style="text-align: justify;">Implementar técnicas de enmascaramiento estático de datos (Static Data Masking) o utilizar generadores de datos sintéticos para dev/test.</td>
    </tr>
    <tr>
      <td style="text-align: center;"><b>8</b></td>
      <td style="text-align: justify;"><b>Uso de correos por Marketing para promociones sin verificar consentimiento</b></td>
      <td style="text-align: center;">Limitación de la finalidad y Consentimiento</td>
      <td style="text-align: justify;">Tratamiento no autorizado para finalidades secundarias, derivando en sanciones administrativas por el regulador (INAI) y daño reputacional.</td>
      <td style="text-align: justify;">Implementar un campo de consentimiento (Opt-in / Opt-out), condicionar la vista de marketing con WHERE acepta_promociones = TRUE y actualizar el Aviso de Privacidad.</td>
    </tr>
    <tr>
      <td style="text-align: center;"><b>9</b></td>
      <td style="text-align: justify;"><b>Falta de documentación e inventario sobre la finalidad de cada dato</b></td>
      <td style="text-align: center;">Transparencia y Gobierno de datos</td>
      <td style="text-align: justify;">Imposibilidad de auditar el uso legítimo de la información, confusión en la toma de decisiones e incapacidad para responder a solicitudes ARCO.</td>
      <td style="text-align: justify;">Crear un Catálogo e Inventario de Datos que documente la finalidad primaria/secundaria, la base jurídica, el Data Owner y el nivel de acceso autorizado.</td>
    </tr>
    <tr>
      <td style="text-align: center;"><b>10</b></td>
      <td style="text-align: justify;"><b>Exposición conjunta de cuasi-identificadores (edad, ciudad, código postal)</b></td>
      <td style="text-align: center;">Anonimización y Minimización</td>
      <td style="text-align: justify;">Ataque de reidentificación por vinculación: cruzar edad y código postal exacto con fuentes externas permite identificar unívocamente a los clientes.</td>
      <td style="text-align: justify;">Aplicar generalización de cuasi-identificadores (convertir edad a rangos y truncar el código postal a nivel macro-región LEFT(codigo_postal, 2)).</td>
    </tr>
  </tbody>
</table>