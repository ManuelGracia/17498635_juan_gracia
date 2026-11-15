# Actividad 4 — Reducir el volumen con un filtro

**1. ¿Qué perdiste de evidencia al aplicar el filtro? ¿Qué ganaste?**

* Evidencia perdida: Se perdió la visibilidad sobre las operaciones de lectura, impidiendo auditar accesos indebidos o exfiltración de datos. Además, al establecer un filter, MongoDB ignora slowms y sampleRate, dejando de registrar consultas lentas y comandos administrativos fuera de la lista filtrada.

* Beneficios ganados: Se redujo significativamente el volumen de registros generados y la sobrecarga de rendimiento respecto al nivel 2. Al evitar que las lecturas saturen el límite de 1 MB de la colección limitada system.profile, se extiende el tiempo que permanecen almacenadas las operaciones de escritura antes de sobrescribirse.

**2. ¿Qué filtro usarías si solo interesaran operaciones sobre la colección clientes?**

Se utiliza el campo ns indicando la base de datos y la colección:

```JavaScript
db.setProfilingLevel(1, { filter: { ns: "comercial.clientes" } })
```