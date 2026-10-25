# Actividad 1 - **Inventario y finalidad de los datos**

<table>
  <thead>
    <tr>
      <th style="text-align: center;">Campo</th>
      <th style="text-align: center;">¿Es dato personal?</th>
      <th style="text-align: center;">Finalidad</th>
      <th style="text-align: center;">¿Es necesario?</th>
      <th style="text-align: center;">Nivel de acceso</th>
      <th style="text-align: center;">Retención</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="text-align: center;"><b>id</b></td>
      <td style="text-align: center;">No</td>
      <td style="text-align: justify;">Identificación técnica única del registro en la base de datos (clave primaria).</td>
      <td style="text-align: center;">Sí</td>
      <td style="text-align: center;">Técnico / General</td>
      <td style="text-align: justify;">Permanente mientras el registro exista en el sistema.</td>
    </tr>
    <tr>
      <td style="text-align: center;"><b>nombre</b></td>
      <td style="text-align: center;">Sí (Directo)</td>
      <td style="text-align: justify;">Identificar formalmente al cliente para atención, contratos y facturación.</td>
      <td style="text-align: center;">Sí</td>
      <td style="text-align: center;">Restringido (Soporte / Admón.)</td>
      <td style="text-align: justify;">5 años tras finalizar la relación comercial.</td>
    </tr>
    <tr>
      <td style="text-align: center;"><b>correo</b></td>
      <td style="text-align: center;">Sí (Directo)</td>
      <td style="text-align: justify;">Canal de comunicación, notificaciones de la cuenta y credencial de autenticación.</td>
      <td style="text-align: center;">Sí</td>
      <td style="text-align: center;">Restringido / Confidencial</td>
      <td style="text-align: justify;">5 años tras la cancelación de la cuenta.</td>
    </tr>
    <tr>
      <td style="text-align: center;"><b>telefono</b></td>
      <td style="text-align: center;">Sí (Directo)</td>
      <td style="text-align: justify;">Contacto directo para soporte, verificación de identidad y alertas.</td>
      <td style="text-align: center;">Sí</td>
      <td style="text-align: center;">Restringido</td>
      <td style="text-align: justify;">Durante la vigencia de la relación contractual.</td>
    </tr>
    <tr>
      <td style="text-align: center;"><b>rfc</b></td>
      <td style="text-align: center;">Sí (Directo)</td>
      <td style="text-align: justify;">Cumplimiento de obligaciones fiscales y emisión de comprobantes fiscales.</td>
      <td style="text-align: center;">Sí</td>
      <td style="text-align: center;">Altamente Restringido (Fiscal/Legal)</td>
      <td style="text-align: justify;">5 años (conforme a normativa fiscal aplicable).</td>
    </tr>
    <tr>
      <td style="text-align: center;"><b>edad</b></td>
      <td style="text-align: center;">Sí (Cuasi-identificador)</td>
      <td style="text-align: justify;">Validación de mayoría de edad legal y análisis demográfico de clientes.</td>
      <td style="text-align: center;">No</td>
      <td style="text-align: center;">Analítico / Seudonimizado</td>
      <td style="text-align: justify;">Se conserva en forma agregada/anonimizada.</td>
    </tr>
    <tr>
      <td style="text-align: center;"><b>ciudad</b></td>
      <td style="text-align: center;">Sí (Cuasi-identificador)</td>
      <td style="text-align: justify;">Análisis de cobertura de mercado, logística regional y estadísticas.</td>
      <td style="text-align: center;">No</td>
      <td style="text-align: center;">Analítico / General</td>
      <td style="text-align: justify;">Indefinida de forma agregada/anonimizada.</td>
    </tr>
    <tr>
      <td style="text-align: center;"><b>codigo_postal</b></td>
      <td style="text-align: center;">Sí (Cuasi-identificador)</td>
      <td style="text-align: justify;">Logística de entrega, validación de zona de servicio y cálculo de impuestos.</td>
      <td style="text-align: center;">Sí</td>
      <td style="text-align: center;">Restringido (Logística / Analítica)</td>
      <td style="text-align: justify;">5 años tras finalizar servicios.</td>
    </tr>
    <tr>
      <td style="text-align: center;"><b>fecha_alta</b></td>
      <td style="text-align: center;">No (Cuasi-identificador)</td>
      <td style="text-align: justify;">Auditoría del sistema, cálculo de antigüedad y control de políticas de retención.</td>
      <td style="text-align: center;">Sí</td>
      <td style="text-align: center;">Técnico / Interno</td>
      <td style="text-align: justify;">Durante el ciclo de vida del cliente + 5 años.</td>
    </tr>
  </tbody>
</table>