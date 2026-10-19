# Laboratorio 02 — Cifrado y credenciales


## Informe final: Protección de credenciales, datos sensibles y claves en PostgreSQL

### **1. Introducción**

Una base de datos con usuarios y roles bien configurados no está protegida. Los permisos controlan quién puede pedirle datos al motor, pero no protegen la información cuando se accede a ella por otras vías, una copia de seguridad robada, tráfico de red interceptado, una inyección SQL, un administrador con privilegios altos o un secreto publicado por error en un repositorio.

Este laboratorio aborda ese problema con cuatro capas complementarias:

- **Protección de credenciales:** almacenar contraseñas mediante hash con sal.
- **Protección de datos sensibles:** cifrar campos como el RFC.
- **Protección en tránsito:** verificar el estado de TLS en PostgreSQL.
- **Gestión de claves:** evitar que los secretos aparezcan en scripts y repositorios.


### **2. Protección de credenciales**

### Texto claro, hash y cifrado

| | Texto claro | Hash con sal | Cifrado simétrico |
|---|---|---|---|
| Ejemplo | `Password123` | `$2a$06$Hq3vYk0e...` | `\xc30d0407...` |
| ¿Reversible? | No hay nada que revertir | **No** | **Sí**, con la clave |
| ¿Usa clave? | No | No (usa sal) | Sí |
| Si se filtra la tabla | El atacante ve todo | Debe atacar cada hash por fuerza bruta | Descifra todo si obtiene la clave |
| Uso adecuado | Ninguno para datos sensibles | Contraseñas (solo se verifican) | Datos que luego hay que leer (RFC) |

### Implementación

Primero se mostró la tabla insegura (`usuarios_insegura`), donde un `SELECT *` revela las contraseñas directamente. Después se usó `pgcrypto`:

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE usuarios_segura (
    id BIGSERIAL PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL
);

INSERT INTO usuarios_segura (usuario, password_hash)
VALUES ('juan', crypt('Password123', gen_salt('bf', 12)));
```

Al ejecutar dos veces `crypt('Password123', gen_salt('bf'))` se obtuvieron resultados **distintos**, porque `gen_salt()` genera una sal aleatoria nueva en cada llamada. La sal queda incluida dentro del propio hash, por lo que no se necesita otra columna.

### Verificación

```sql
SELECT usuario,
       password_hash = crypt('Password123', password_hash) AS contraseña_correcta
FROM usuarios_segura
WHERE usuario = 'juan';
```

- Con la contraseña correcta el resultado fue `true`.
- Con una contraseña incorrecta (`OtraPassword`) el resultado fue `false`.

El sistema no necesita conocer la contraseña original, solo comprobar que quien la escribe la conoce.


### **3. Protección de datos sensibles**

Se eligió el **RFC** como ejemplo porque es un dato personal que permite identificar a una persona y cuya exposición facilita suplantación de identidad y fraude, además de generar obligaciones legales (LFPDPPP). A diferencia de una contraseña, el RFC debe poder leerse después (por ejemplo, para facturar), por lo que se utilizó cifrado simétrico y no hash.

```sql
CREATE TABLE clientes_protegidos (
    id BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    rfc_cifrado BYTEA NOT NULL
);

INSERT INTO clientes_protegidos (nombre, rfc_cifrado)
VALUES ('Ana López', pgp_sym_encrypt('LOPA900101ABC', 'CLAVE-DE-PRUEBA'));

SELECT id, nombre, pgp_sym_decrypt(rfc_cifrado, 'CLAVE-DE-PRUEBA') AS rfc
FROM clientes_protegidos;
```

Observaciones:

- Al consultar la tabla, el RFC aparece como bytes ilegibles (`BYTEA`).
- Repetir el cifrado del mismo valor produce resultados distintos, porque PGP incluye datos aleatorios.
- Con una clave incorrecta, PostgreSQL devuelve el error `Wrong key or corrupt data` y no entrega ningún dato.
- La clave está escrita en la consulta **solo con fines didácticos**. Esto es una mala práctica (ver sección 5).


### **4. TLS**

### Qué problema resuelve

Sin TLS, consultas, resultados y credenciales viajan en texto plano y pueden ser leídos o alterados por quien observe la red. Tampoco hay forma de comprobar que se habla con el servidor legítimo (riesgo de *man-in-the-middle*). TLS ofrece:

- **Confidencialidad:** el tráfico viaja cifrado.
- **Integridad:** cualquier alteración se detecta.
- **Autenticación del servidor:** mediante su certificado, siempre que el cliente lo valide (`sslmode=verify-full`).

TLS protege los datos **en tránsito**; no sustituye al cifrado de datos en reposo ni a la autorización.

### Qué se verificó en PostgreSQL

```sql
SHOW ssl;
SHOW ssl_min_protocol_version;
SHOW port;
SHOW listen_addresses;

SELECT ssl, version, cipher
FROM pg_stat_ssl
WHERE pid = pg_backend_pid();
```

| Parámetro | Resultado obtenido |
|---|---|
| `ssl` | `off` |
| `ssl_min_protocol_version` | `TLSv1.2` |
| `port` | 5432 |
| `listen_addresses` | * |
| `pg_stat_ssl` (`ssl`, `version`, `cipher`) | `ssl = off`, `NULL`, `NULL` |

**Interpretación:** `ssl = off` indica que el servidor no tiene TLS habilitado, por lo que la sesión no está cifrada. El valor `TLSv1.2` en `ssl_min_protocol_version` solo sería la versión mínima aceptada si TLS estuviera activo; mientras `ssl` esté en `off`, no tiene efecto práctico. Esta configuración es insegura para un entorno real.

### **5. Gestión de claves**

Las claves no deben almacenarse junto con los scripts porque:

1. **Quien accede al script obtiene la clave.** Basta combinarla con cualquier copia de los datos cifrados (respaldo, filtración, inyección SQL) para descifrar todo.
2. **Git conserva el historial.** Borrar el archivo en un commit posterior no elimina la clave de commits anteriores, ramas, forks ni clones.
3. **Se propaga sin control.** Termina en logs, historiales, respaldos, capturas de pantalla, herramientas de CI/CD y equipos de desarrollo.
4. **Anula la separación entre clave y datos.** El cifrado solo protege si ambos se guardan por separado.

En el laboratorio se creó sql/ejemplo-mala-practica.sql con la clave ficticia CLAVE-DE-PRUEBA únicamente para identificar el error y se eliminó antes de la entrega.

### **Política mínima de protección de claves**

1. **Generación:** con CSPRNG, KMS o HSM, con algoritmo y longitud aprobados; nunca derivadas de frases predecibles; claves distintas por ambiente.
2. **Almacenamiento:** solo en un gestor de secretos, separado de los datos y del código; prohibido en scripts, repositorios, documentación, mensajes y capturas.
3. **Acceso:** mínimo privilegio, identidades concretas y uso auditado sin registrar el valor de la clave.
4. **Uso:** la aplicación obtiene la clave en tiempo de ejecución y la pasa como parámetro; cada clave tiene un solo propósito.
5. **Rotación:** periódica (por ejemplo, anual) y de inmediato ante sospecha de compromiso; los datos se recifran y se verifica el descifrado antes de retirar la clave anterior.
6. **Respaldo:** copia de recuperación cifrada, en lugar distinto al de la clave original y al de los respaldos de datos, con pruebas periódicas de restauración.
7. **Revocación:** bloqueo inmediato de claves comprometidas o innecesarias, con registro de quién, cuándo y por qué.
8. **Exposición accidental:** toda clave que aparezca fuera de su almacén se considera comprometida aunque se borre; se reporta, se rota, se revisan accesos y se limpia el historial. Se usan herramientas de detección de secretos.
9. **Eliminación:** destrucción segura al final de su vida útil, solo después de confirmar que ningún dato depende de ella.
10. **Responsabilidad:** cada clave tiene un responsable y un inventario con propósito, fecha de creación y próxima rotación; la política se revisa anualmente.

### **6. Resultados**

- Se demostró que una tabla con contraseñas en texto claro expone todas las credenciales ante cualquier acceso de lectura.
- Se generaron hashes bcrypt con sal aleatoria: la misma contraseña produce hashes distintos, y la verificación con `crypt()` devolvió `true` para la contraseña correcta y `false` para la incorrecta.
- Se cifró el RFC con `pgp_sym_encrypt()` y se recuperó con `pgp_sym_decrypt()`; una clave incorrecta produjo error y no devolvió datos.
- Se verificó que el servidor tiene `ssl = off`, por lo que la sesión no usa TLS, y que `ssl_min_protocol_version` es `TLSv1.2`.
- Se identificó la clave dentro de un script SQL como mala práctica y se analizó el impacto de publicarla en Git.
- Se completó la tabla comparativa de protección en reposo y en tránsito y se analizó un escenario empresarial, concluyendo que el problema más crítico es la exposición de claves en archivos SQL porque invalida las demás protecciones.
- Se redactó una política de 10 reglas para la gestión de claves.


### **7. Problemas encontrados**

- **TLS deshabilitado:** `SHOW ssl` devolvió `off`, por lo que no fue posible observar versión ni cipher en `pg_stat_ssl` (los campos quedan en `NULL`). Se documentó el estado y se describió cómo habilitarlo, sin modificar el servidor.
- **Confusión entre `SHOW ssl` y `pg_stat_ssl`:** el primero indica si el **servidor** admite TLS; el segundo, si **la sesión concreta** lo usa.
- **Confusión entre `ssl_min_protocol_version` y TLS activo:** un valor `TLSv1.2` no implica que haya cifrado si `ssl = off`.
- **Clave en la consulta:** para que `pgp_sym_decrypt()` funcione en el laboratorio fue necesario escribir la clave en el SQL, lo que se documentó como mala práctica y solo se hizo con un valor ficticio.

### **8. Conclusiones**

**Qué aprendí**

- Cada dato requiere un mecanismo distinto según cómo se use: hash si solo se verifica, cifrado si debe leerse, TLS si viaja por la red.
- Usuarios y roles son necesarios pero no suficientes; la seguridad se logra con varias capas complementarias (defensa en profundidad).
- La seguridad de un cifrado depende de la protección de la clave, no solo del algoritmo.

**Medidas que aplicaría en producción**

- Contraseñas con bcrypt (costo de al menos 12), idealmente calculadas en la aplicación.
- Cifrado de datos sensibles (RFC, información financiera) con claves en un KMS, fuera de la base de datos.
- TLS 1.2 o superior en el servidor y `sslmode=verify-full` en todos los clientes.
- Gestor de secretos, rotación de claves, detección de secretos en commits y en CI/CD.
- Respaldos cifrados, con acceso restringido y pruebas periódicas de restauración.
- Mínimo privilegio, auditoría de accesos y revisión periódica de configuración.

### **9. Preguntas de reflexión**

**1. ¿Por qué una contraseña no debe almacenarse como texto claro?**
Porque cualquiera con acceso de lectura a la tabla obtiene las contraseñas listas para usar, sin necesidad de descifrar nada. Permite suplantar a cualquier usuario y por la reutilización de contraseñas, comprometer cuentas en otros servicios.

**2. ¿Por qué un hash no es equivalente a un cifrado?**
El cifrado es bidireccional, con la clave se recupera el dato original. El hash es unidireccional, no existe operación inversa ni clave y solo permite comprobar si un candidato produce el mismo resultado. El cifrado sirve para datos que hay que volver a leer, el hash para datos que solo hay que verificar.

**3. ¿Por qué el cifrado de una columna no sustituye al control de acceso?**
Porque resuelven problemas distintos. El control de acceso decide quién puede consultar o modificar los datos, el cifrado protege el contenido si ese control se evade. Además, quien tenga permiso de lectura y acceso a la clave verá el dato descifrado y el cifrado no impide modificar, borrar ni sobrescribir registros.

**4. ¿Por qué TLS no sustituye a los mecanismos de autorización de PostgreSQL?**
TLS protege el canal (confidencialidad, integridad y autenticación del servidor), pero no decide qué puede hacer un usuario una vez conectado. Un usuario legítimo o un atacante con credenciales robadas puede conectarse por un canal perfectamente cifrado y sin roles ni permisos adecuados, acceder a todo. Además, TLS no protege los datos en reposo.

**5. ¿Qué ocurriría si una organización pierde una clave utilizada para cifrar información?**
Los datos cifrados quedarían irrecuperables de forma permanente, porque no existe forma práctica de descifrarlos sin la clave. Se produciría pérdida de información, interrupción de operaciones y posibles incumplimientos legales. Por eso se requieren respaldos seguros de las claves y pruebas de restauración.

**6. ¿Qué ocurriría si una clave criptográfica se publica accidentalmente en GitLab?**
Debe considerarse comprometida de inmediato, ya que  cualquiera con acceso al repositorio y a una copia de los datos cifrados podría descifrarlos. Borrar el archivo no basta, porque la clave permanece en el historial, ramas, forks, clones y servicios integrados (CI/CD). Hay que rotar la clave, recifrar los datos, revocar la clave expuesta, revisar accesos durante la exposición, limpiar el historial y tratar el hecho como un incidente de seguridad, con notificación si hay datos personales involucrados.

**7. ¿Por qué un repositorio privado no debe considerarse un almacén de secretos?**
Porque "privado" solo limita quién puede verlo, no elimina el riesgo, además los secretos quedan al alcance de todo el equipo, de colaboradores externos y de integraciones, se copian a clones locales, respaldos y pipelines, y el historial los conserva indefinidamente. Si una cuenta con acceso se compromete o el repositorio se hace público por error, todos los secretos quedan expuestos. Además, un repositorio no ofrece rotación, auditoría de uso por secreto ni control de acceso granular, que sí brinda un gestor de secretos.

**8. ¿Qué diferencia existe entre proteger información almacenada y proteger información durante su transmisión?**
Proteger la información almacenada busca que los datos sean ilegibles si se roban discos, respaldos o tablas y se logra con hash, cifrado de columnas o de disco y control de acceso. Proteger la información en tránsito busca que no pueda ser interceptada ni alterada mientras viaja por la red, y se logra con TLS. Son medidas complementarias: usar solo una deja la otra puerta abierta.

**9. ¿Por qué la gestión de claves es tan importante como el algoritmo criptográfico?**
Porque la seguridad de un cifrado robusto depende por completo del secreto de la clave. Si la clave se genera mal, se guarda junto con los datos, se publica o nunca se rota, el algoritmo deja de proteger. En la práctica, la mayoría de las brechas ocurren por mala gestión de claves y no por romper el algoritmo.

**10. ¿Qué mecanismo adicional implementarías en una organización para proteger los respaldos de las bases de datos?**
Cifrado de los respaldos con claves gestionadas en un KMS y guardadas por separado, complementado con almacenamiento de acceso restringido y auditado, copias inmutables o fuera de línea, transmisión por canales cifrados, retención definida y pruebas periódicas de restauración. La clave que protege el respaldo debe ser distinta de la que protege los datos en producción.
