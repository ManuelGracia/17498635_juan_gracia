# **Actividad 7** — Modificaciones de datos: ddl frente a mod

**1. ¿Qué nivel habría registrado la lectura del RFC? ¿Qué costo tendría en un servidor con miles de consultas por minuto?**

* Nivel requerido: log_statement = 'all'. Este nivel es el único que registra todas las sentencias enviadas al servidor, incluyendo las consultas de lectura (SELECT).

Costo en rendimiento y almacenamiento:

* Degradación drástica del I/O (Rendimiento): Generar una escritura en disco por cada SELECT crea un cuello de botella masivo en el subsistema de almacenamiento, incrementando la latencia de todas las transacciones de la base de datos.

* Consumo desmedido de disco: En un servidor con miles de consultas por minuto, la bitácora generaría gigabytes o terabytes de archivos en cuestión de horas, saturando rápidamente la partición de almacenamiento (Disk Full) y provocando la caída del servicio.

* Riesgo de privacidad y fuga de datos: Registrar cada SELECT implica escribir en texto plano dentro del archivo de bitácora todos los datos consultados o filtrados en las cláusulas WHERE (nombres, correos, RFCs, salarios, tokens), violando el principio de minimización y sobreexponiendo PII.

**2. ¿Qué le falta a esta bitácora para revertir el cambio con certeza?**

A la bitácora a nivel de sentencia le faltan los valores anteriores de los registros modificados (el estado OLD).

Aunque log_statement = 'mod' registra la sentencia SQL exacta (UPDATE clientes SET telefono = '6679990000' WHERE id = 3), no registra qué valor tenía el campo telefono antes de ejecutar la instrucción.

Sin conocer el valor original, es imposible restaurar o revertir el registro a su estado correcto con certeza sin depender de un point-in-time recovery (PITR) o una copia de respaldo. Para solucionar esta limitación, se requiere un mecanismo de auditoría a nivel de dato (como un disparador AFTER UPDATE con una tabla de auditoría dedicada que guarde los valores OLD y NEW).