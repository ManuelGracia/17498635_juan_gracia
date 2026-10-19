# Actividad 10 - Crear una política mínima de protección de claves

1. *__Generación__*:
Las claves se generan con un generador criptográficamente seguro, con la longitud y el algoritmo aprobados. Nunca se derivan de frases predecibles, nombres, fechas ni valores como CLAVE-DE-PRUEBA, y cada ambiente (desarrollo, pruebas, producción) tiene claves distintas.

2. *__Almacenamiento__*:
Las claves se guardan únicamente en un gestor de secretos o KMS, separadas físicamente de los datos que protegen. Está prohibido escribirlas en código, scripts SQL, archivos de configuración versionados, documentación, correos, mensajes o capturas de pantalla.

3. *__Acceso__*:
El acceso a cada clave se concede bajo el principio de mínimo privilegio, a identidades concretas (personas o servicios) con una necesidad justificada. Ninguna persona debe poder acceder a la vez a la clave y a los datos cifrados sin autorización registrada, y el uso de claves se audita mediante registros que no contengan el valor de la clave.

4. *__Uso__*:
Las aplicaciones obtienen la clave en tiempo de ejecución desde el gestor de secretos y la pasan como parámetro, nunca como literal dentro de consultas SQL. Una misma clave se utiliza para un solo propósito (por ejemplo, no se reutiliza la clave del RFC para cifrar respaldos).

5. *__Rotación__*:
Las claves se rotan en un plazo definido (por ejemplo, cada 12 meses) y de inmediato ante cualquier sospecha de compromiso o cuando alguien con acceso deja la organización. Tras la rotación, los datos se recifran con la clave nueva y se verifica que puedan descifrarse antes de retirar la anterior.

6. *__Respaldo de claves__*:
Existe una copia de recuperación de cada clave, cifrada y almacenada en un lugar distinto al de la clave original y al de los respaldos de datos. Su restauración se prueba periódicamente, porque perder la clave equivale a perder los datos cifrados de forma permanente.

7. *__Revocación__*:
Cuando una clave se considera comprometida o deja de ser necesaria, se revoca de inmediato: se bloquea su uso en el gestor, se genera una sustituta y se documenta quién la solicitó, cuándo y por qué. Los datos protegidos con la clave revocada se recifran antes de retirarla definitivamente.