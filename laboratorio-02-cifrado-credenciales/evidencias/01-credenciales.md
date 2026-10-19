# **Actividad 1** — Protección de credenciales

## 7.1 El problema
**¿Qué ocurriría si una persona obtiene acceso de lectura a esta tabla?** Un usuario malicioso podría suplantar la identidad de los usuarios registrados en esa tabla.

## 7.3 Generar una representación no reversible
**¿Son iguales?** No.


**Si no son iguales, ¿Por qué?** Porque Aunque la contraseña de entrada sea la misma, cada ejecución genera una distinta.

**¿Qué función cumple gen_salt()?** Genera una cadena aleatoria (la sal) junto con la configuración del algoritmo.

**¿Qué función cumple crypt()?** Calcula el hash de la contraseña usando la sal (y el algoritmo y costo indicados en ella).

**¿Esto es un cifrado reversible?** No. Es una función de hash (unidireccional), no un cifrado. No existe una operación “descifrar” para recuperar Password123 desde el hash. La única forma de averiguarla es probar candidatos (fuerza bruta o diccionario) y comparar, y bcrypt está diseñado para que cada intento sea deliberadamente lento.

## 7.5 Verificar una contraseña
**¿Qué resultado obtuviste con la contraseña correcta?**
true. Al ejecutar crypt('Password123', password_hash), la función toma la sal y el costo que están dentro del hash almacenado, recalcula el hash con la contraseña recibida y obtiene exactamente el mismo valor que ya estaba guardado.

**¿Qué resultado obtuviste con la contraseña incorrecta?** false. Usando la misma sal pero una contraseña distinta, bcrypt produce un hash completamente diferente, por lo que la comparación falla.


**¿Por qué no es necesario recuperar la contraseña original?** Porque el sistema no necesita conocer la contraseña, solo comprobar que quien la escribe conoce la correcta.


**¿Por qué un hash no debe confundirse con cifrado?** Confundirlos lleva a errores graves. Si se cifran las contraseñas en lugar de aplicar hash, la seguridad depende por completo de proteger la clave: quien la obtenga (junto con la tabla) descifra todas las contraseñas de golpe. Con un hash bien diseñado, aun si el atacante roba la base de datos completa, debe atacar cada contraseña por separado con fuerza bruta, y bcrypt hace que cada intento sea lento.


