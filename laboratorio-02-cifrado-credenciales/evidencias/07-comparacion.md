# Actividad 7 - Comparar protección en reposo y protección en tránsito

<table>
  <thead>
    <tr>
      <th style="text-align: center;">Situación</th>
      <th style="text-align: center;">Mecanismo apropiado</th>
      <th style="text-align: center;">¿Qué protege?</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="text-align: center;">Contraseña de usuario</td>
      <td style="text-align: center;">Hash con sal y factor de costo (bcrypt, scrypt o Argon2; en PostgreSQL, crypt() con gen_salt('bf', 12))</td>
      <td style="text-align: center;">La confidencialidad de la contraseña en reposo. No es reversible, solo permite verificar y si la tabla se filtra el atacante debe hacer fuerza bruta contra cada hash.</td>
    </tr>
    <tr>
      <td style="text-align: center;">RFC almacenado en una tabla</td>
      <td style="text-align: center;">Cifrado simétrico (pgp_sym_encrypt() / pgp_sym_decrypt(), o AES-256 desde la aplicación), con la clave fuera de la base de datos</td>
      <td style="text-align: center;">La confidencialidad del dato personal en reposo. Es reversible, porque el sistema necesita volver a leer el RFC. Complementar con permisos (GRANT/REVOKE).</td>
    </tr>
    <tr>
      <td style="text-align: center;">Consulta enviada desde un cliente al servidor</td>
      <td style="text-align: center;">TLS (ssl = on, versión mínima TLS 1.2 y cliente con sslmode=verify-full)</td>
      <td style="text-align: center;">La confidencialidad, la integridad y la autenticación del servidor en tránsito, consultas, resultados y credenciales no pueden ser leídos ni modificados en la red.</td>
    </tr>
    <tr>
      <td style="text-align: center;">Respaldo de una base de datos</td>
      <td style="text-align: center;">Cifrado del archivo de respaldo, almacenamiento con cifrado en reposo y control de acceso, claves guardadas por separado</td>
      <td style="text-align: center;">La confidencialidad de toda la información contenida en el respaldo (en reposo) si el archivo se pierde, se roba o se copia. Si el respaldo viaja por la red, también se protege con TLS o SSH.</td>
    </tr>
    <tr>
      <td style="text-align: center;">Clave criptográfica</td>
      <td style="text-align: center;">Gestor de secretos o KMS (HashiCorp Vault, AWS KMS), variables de entorno con acceso restringido, nunca en el código ni en el repositorio; rotación periódica y control de acceso</td>
      <td style="text-align: center;">La confidencialidad de la clave misma, de la que depende la seguridad de todos los datos cifrados. Si se expone, el cifrado deja de servir.</td>
    </tr>
  </tbody>
</table>