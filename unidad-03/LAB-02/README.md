# LAB-02 — Trazabilidad en MongoDB Community

Repositorio de prácticas, evidencias e informe técnico correspondiente al laboratorio **LAB-02** de la Unidad III (*Gestión de Seguridad y Desempeño de Bases de Datos*).

## 1. Versión y despliegue del servidor (Anexo A)

* **Motor y edición:** MongoDB **9.0.8** Community Edition.
* **Sistema operativo y método de despliegue:** Instalación local nativa como servicio de Windows, administrada mediante PowerShell, la consola integrada `>_ MONGOSH` de MongoDB Compass y `mongosh` desde terminal.
* **Parámetros principales de configuración (`mongod.cfg`):**
  * **Autorización:** `security.authorization: enabled` (autenticación SCRAM obligatoria).
  * **Bitácora del servidor:** `systemLog.destination: file` con salida JSON estructurada en `C:\Program Files\MongoDB\Server\9.0\log\mongod.log` y `logAppend: true`.
  * **Red:** Enlace local en `127.0.0.1:27017`.


### Actores configurados en el entorno

| Perfil | Usuario | Base de autenticación (`authSource`) | Rol asignado | Identificador de aplicación (`appName`) |
| :--- | :--- | :--- | :--- | :--- |
| **DBA** | `admin` | `admin` | `root` | `MongoDB Compass` / `mongosh` |
| **Aplicación** | `app_ventas` | `comercial` | `readWrite` en `comercial` | `app-ventas-web` |

---

## 2. Estructura del repositorio

```text
LAB-02/
├── README.md                                       # Descripción del despliegue, versión y estructura del laboratorio
├── informe.md                                      # Informe técnico y preguntas de reflexión (Secciones 19 y 20)
├── scripts/
│   └── comandos-mongosh.js                         # Comandos ejecutados en mongosh organizados por actividad
└── evidencias/
    ├── 01-edicion-y-limitacion.md                  # Verificación de versión 9.0.8 Community y módulos activos
    ├── 02-incidente-sin-perfilado.md               # Modificación sin perfilador activo (was: 0)
    ├── 03-perfilador.md                            # Activación de perfilador nivel 2 e interpretación de system.profile
    ├── 04-filtro.md                                # Reducción de volumen con filtro de escritura (insert, update, remove)
    ├── 05-accesos-mongod.md                        # Análisis de accesos exitosos y fallidos en mongod.log
    ├── 06-correlacion.md                           # Correlación de cambios de configuración del perfilador vía ctx
    ├── 07-privilegios-control-compensatorio.md     # Limitación en cambios de privilegios e instantáneas compensatorias
    ├── 08-conservacion.md                          # Persistencia tras reinicio, exportación e integridad SHA-256
    ├── 09-comparacion.md                           # Matriz comparativa: PostgreSQL, MongoDB Community y Enterprise/Atlas
    ├── 10-respuesta-direccion.md                   # Dictamen ejecutivo para Dirección basado en evidencia verificada
    ├── system-profile.json                         # Exportación EJSON de comercial.system.profile
    ├── bitacora-mongod.log                         # Exportación de eventos recientes desde getLog
    └── hashes.sha256                               # Resúmenes criptográficos SHA-256 de los archivos exportados
```