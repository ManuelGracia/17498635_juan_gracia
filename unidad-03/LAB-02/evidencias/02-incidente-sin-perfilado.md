# Actividad 2 — El incidente sin perfilado

**1. ¿Puedes demostrar qué cambió? ¿Y quién se conectó a esa hora?**

No hay evidencia con esta edición. Al estar el perfilador apagado (was: 0), system.profile contiene 0 registros y la bitácora del servidor no registra operaciones de lectura o escritura. Si bien el documento actual refleja el nuevo RFC, no existe registro de la operación que lo modificó ni del valor anterior que tenía el campo.

Los eventos de categorías NETWORK y ACCESS en la bitácora demuestran que a esa hora se conectó una aplicación identificada como app-ventas-web desde 127.0.0.1 y que se autenticó exitosamente el usuario app_ventas en la base comercial. Sin embargo, esto solo permite una correlación temporal circunstancial, no probar qué consulta ejecutó dicha sesión.

**2. ¿Por qué mongosh abre varias conexiones (conn8, conn9, …) para una sola instrucción? ¿Cuál es la que se autentica?**

mongosh utiliza el driver de Node.js de MongoDB, el cual separa el monitoreo del servidor de la ejecución de consultas mediante un pool de conexiones:

* Primera conexión (ej. conn8): Se utiliza para descubrimiento de topología y envío de metadatos iniciales, cerrándose sin autenticarse.

* Segunda conexión (ej. conn9): Pertenece al pool de operaciones de trabajo; esta es la conexión que se autentica y ejecuta la instrucción enviada en --eval.