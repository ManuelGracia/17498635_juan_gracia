# Actividad 2 - Cifrado de información sensible

**¿Qué diferencia existe entre crypt() y pgp_sym_encrypt()?**
Crypt() genera un hash con sal que es unidireccional no usa una clave, solo una sal, y devuelve un texto del cual no se puede recuperar el dato original. Pgp_sym_encrypt() realiza un cifrado simétrico, que es bidireccional y usa una clave secreta, devuelve un BYTEA y tiene su función inversa, pgp_sym_decrypt(). Por eso crypt() es adecuado para contraseñas, que solo se verifican, y pgp_sym_encrypt() para datos que luego hay que leer, como el RFC, la CURP o un teléfono.

**¿Cuál de los dos mecanismos permite recuperar el dato original?** Únicamente pgp_sym_encrypt() permite recuperar el dato original con la ayuda de la clave correcta.

**¿Cuál de los dos mecanismos permite recuperar el dato original?** PostreSQL devuelve un error.

**¿Qué problema de seguridad representa colocar la clave directamente en una consulta?**
Anula gran parte de la protección, porque la clave queda expuesta en varios lugares, en los logs del servidor, en el historial del cliente y en el código fuente y repositorios . Además, la clave viaja al servidor junto con los datos cifrados, de modo que quien comprometa la base de datos o sus logs obtiene ambos y el cifrado deja de servir. La protección solo funciona si la clave y los datos se guardan por separado.

