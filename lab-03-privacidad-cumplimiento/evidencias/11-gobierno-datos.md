# ACTIVIDAD 11 - Diseñar una matriz de gobierno de datos

<table>
  <thead>
    <tr>
      <th style="text-align: center;">Dato</th>
      <th style="text-align: center;">Finalidad</th>
      <th style="text-align: center;">Responsable</th>
      <th style="text-align: center;">Usuarios autorizados</th>
      <th style="text-align: center;">Protección</th>
      <th style="text-align: center;">Retención</th>
      <th style="text-align: center;">Acción al finalizar</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="text-align: center;"><b>nombre</b></td>
      <td style="text-align: justify;">Identificación del titular para atención operacional y emisión de comprobantes fiscales.</td>
      <td style="text-align: center;">Gerente de Atención a Clientes / Finanzas</td>
      <td style="text-align: center;">Atención al cliente, Facturación, DBA</td>
      <td style="text-align: justify;">Control de acceso basado en roles (RBAC), Vistas restringidas sin acceso directo a la tabla principal.</td>
      <td style="text-align: justify;">Durante la relación comercial activa + 5 años por prescripción legal.</td>
      <td style="text-align: justify;">Eliminación física cifrada / Cancelación con bloqueo.</td>
    </tr>
    <tr>
      <td style="text-align: center;"><b>correo</b></td>
      <td style="text-align: justify;">Canal de contacto directo, notificaciones del servicio y recuperación de credenciales.</td>
      <td style="text-align: center;">Gerente de Servicio al Cliente</td>
      <td style="text-align: center;">Atención al cliente, DBA</td>
      <td style="text-align: justify;">Enmascaramiento dinámico (u***@domain.com), RBAC. Excluido del esquema analítico.</td>
      <td style="text-align: justify;">Durante la relación comercial activa + 5 años.</td>
      <td style="text-align: justify;">Eliminación física.</td>
    </tr>
    <tr>
      <td style="text-align: center;"><b>telefono</b></td>
      <td style="text-align: justify;">Contacto telefónico operativo directo y autenticación/seguridad.</td>
      <td style="text-align: center;">Gerente de Servicio al Cliente</td>
      <td style="text-align: center;">Atención al cliente, DBA</td>
      <td style="text-align: justify;">Enmascaramiento parcial (******1234), RBAC.</td>
      <td style="text-align: justify;">Durante la relación comercial activa.</td>
      <td style="text-align: justify;">Eliminación física.</td>
    </tr>
    <tr>
      <td style="text-align: center;"><b>rfc</b></td>
      <td style="text-align: justify;">Cumplimiento de obligaciones fiscales y facturación electrónica.</td>
      <td style="text-align: center;">Gerente de Finanzas / Contabilidad</td>
      <td style="text-align: center;">Facturación, DBA</td>
      <td style="text-align: justify;">Restricción estricta por esquema, cifrado/enmascaramiento. Acceso denegado a soporte y analítica.</td>
      <td style="text-align: justify;">5 a 10 años conforme a la legislación fiscal aplicable.</td>
      <td style="text-align: justify;">Depuración y eliminación física segura.</td>
    </tr>
    <tr>
      <td style="text-align: center;"><b>edad</b></td>
      <td style="text-align: justify;">Análisis demográfico y segmentación de clientes para estudios de mercado.</td>
      <td style="text-align: center;">Gerente de Analítica / Marketing</td>
      <td style="text-align: center;">Analítica, Dirección, DBA</td>
      <td style="text-align: justify;">Generalización en rangos de edad (18-30, 31-45), Seudonimización en esquemas analíticos.</td>
      <td style="text-align: justify;">5 años a nivel individual; indefinido si se convierte en dato anonimizado agregando k-anonimato.</td>
      <td style="text-align: justify;">Anonimización irreversible / Agregación estadística.</td>
    </tr>
    <tr>
      <td style="text-align: center;"><b>ciudad</b></td>
      <td style="text-align: justify;">Logística, segmentación geográfica operativa y estudios regionales.</td>
      <td style="text-align: center;">Gerente de Operaciones</td>
      <td style="text-align: center;">Atención al cliente, Analítica, Dirección, DBA</td>
      <td style="text-align: justify;">RBAC, Agregación regional.</td>
      <td style="text-align: justify;">Durante la relación comercial activa + 5 años.</td>
      <td style="text-align: justify;">Anonimización (agregación a nivel provincia/macro-región).</td>
    </tr>
    <tr>
      <td style="text-align: center;"><b>codigo_postal</b></td>
      <td style="text-align: justify;">Validación logística de envíos y determinación de zona geográfica.</td>
      <td style="text-align: center;">Gerente de Logística</td>
      <td style="text-align: center;">Atención al cliente, Facturación, Analítica (truncado), DBA</td>
      <td style="text-align: justify;">Truncamiento de precisión (LEFT(codigo_postal, 2)) para analítica, k-anonimato (k ≥ 5).</td>
      <td style="text-align: justify;">Durante la relación comercial activa + 5 años.</td>
      <td style="text-align: justify;">Eliminación del dato exacto / Supresión de grupos reducidos.</td>
    </tr>
  </tbody>
</table>