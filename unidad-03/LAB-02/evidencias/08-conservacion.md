# Actividad 8 — Conservación: exportar antes de perder

**1. Menciona tres formas en que la evidencia del perfilador o de la bitácora puede perderse sin que nadie la borre deliberadamente.**

* Sobrescritura circular en system.profile: Al ser una colección limitada de 1 MB por defecto, al llenarse sobrescribe automáticamente los documentos más antiguos con las operaciones nuevas.

* Reinicio del servicio mongod: Vacía la memoria volátil de getLog, restablece el nivel del perfilador a 0 si no se configuró en mongod.cfg (dejando de registrar eventos posteriores) y, si se ejecuta sin archivo persistente o con logAppend: false, descarta o reemplaza la bitácora previa.

* Rotación del búfer de getLog por volumen de eventos: Al almacenar únicamente los últimos 1,024 eventos en memoria, cualquier ráfaga de conexiones o actividad expulsa los registros anteriores.

**2. ¿Por qué el tamaño de 1 MB de system.profile es un problema de conservación y no solo de espacio?**

Porque al ser una colección limitada, ese límite de 1 MB define la ventana de retención de la evidencia, no solo el almacenamiento en disco. En cuanto se llena, los registros antiguos son sobrescritos automáticamente por los nuevos, provocando la pérdida irreversible de evidencia histórica antes de que pueda investigarse un incidente.

**3. ¿Por qué getLog sirve para interpretar pero no para conservar?**

* Para interpretar: Permite consultar desde mongosh, de forma independiente al sistema operativo o despliegue, los eventos recientes en JSON estructurado para filtrarlos y correlacionarlos durante un diagnóstico.

* No para conservar: Es un búfer volátil en RAM restringido a los últimos 1,024 eventos; se pierde por completo al reiniciar el servidor, rota rápidamente bajo carga y no ofrece almacenamiento persistente ni inmutable.