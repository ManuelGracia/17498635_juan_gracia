# Actividad 5 — Verificar el estado de TLS en PostgreSQL

**¿La conexión actual utiliza TLS?** No, SSL = OFF.

**¿Qué versión de TLS se está utilizando?** NULL, porque no se está utilizando TLS.

**¿Qué algoritmo de cifrado aparece?** NULL, porque no se está utilizando TLS.

**¿Qué diferencia existe entre una conexión protegida con TLS y una conexión sin TLS?** La diferencia es si los datos que viajan entre el cliente y el servidor de base de datos están protegidos mientras atraviesan la red.

Sin TLS, la comunicación se transmite en texto plano. Cualquiera que pueda observar el tráfico puede leer las consultas SQL, los resultados con datos sensibles e incluso material de la contraseña.

Con TLS, antes de intercambiar datos, cliente y servidor negocian una versión del protocolo y un conjunto de algoritmos, y establecen claves de sesión temporales.