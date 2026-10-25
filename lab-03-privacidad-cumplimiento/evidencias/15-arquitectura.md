# ACTIVIDAD 15 - Propuesta de arquitectura de datos protegidos


```Plaintext
                               ┌───────────────────────────┐
                               │   BASE DE DATOS (PGSQL)   │
                               └─────────────┬─────────────┘
                                             │
      ┌────────────────────────┬─────────────┴─────────────┬────────────────────────┐
      │                        │                           │                        │
      ▼                        ▼                           ▼                        ▼
┌──────────────┐      ┌──────────────────┐        ┌──────────────────┐     ┌──────────────────┐
│  OPERACIÓN   │      │    PII VAULT     │        │    ANALÍTICA     │     │    AUDITORÍA     │
│ (esquema)    │      │ (esquema seguro) │        │ (esquema)        │     │ (esquema)        │
└──────┬───────┘      └────────┬─────────┘        └────────┬─────────┘     └────────┬─────────┘
       │                       │                           │                        │
       ▼                       ▼                           ▼                        ▼
  Datos reales           Mapa de tokens             Datos agregados        Logs de acceso e
  y enmascarados        (seudonimización)          y seudonimizados        historial inmutable

```
---

## Tradución de Principios de Privacidad a Controles Técnicos
**1. Control de Acceso (RBAC y Aislamiento por Esquemas)**

Decisión técnica: Creación de roles de base de datos dedicados (rol_operacion, rol_analitica, rol_auditoria, rol_dpo) sin privilegios sobre el esquema public.

* Implementación:

```SQL
GRANT USAGE ON SCHEMA operacion TO rol_operacion;

GRANT SELECT ON analitica.vista_estadisticas TO rol_analitica;
```
Se deniega explícitamente todo acceso del rol analítico hacia las tablas de operacion.

**2. Minimización de Datos**

Decisión técnica: Generación de canalizaciones ETL/ELT internas que transforman los datos de producción antes de volcarlos al esquema analítico.

* Implementación:

    
    + Filtrado de columnas no requeridas para análisis (se eliminan nombre, correo, telefono, rfc).

    * Transformación de datos continuos a valores categóricos (ej. convertir fecha_nacimiento a rango_edad).

**3. Protección de Información Sensible**

Decisión técnica: Aislamiento del mapa de reidentificación en un esquema restringido y uso de vistas de enmascaramiento dinámico para el personal operativo.

Implementación:

Uso de la extensión pgcrypto para cifrar columnas sensibles en reposo (ej. salarios o datos fiscales).

+ Vistas enmascaradas para soporte con funciones SQL:

```SQL
CREATE VIEW operacion.v_clientes_soporte AS
SELECT id, nombre, 
       regexp_replace(correo, '(^.)[^@]*', '\1***') AS correo_mascarado
FROM operacion.clientes;
```

**4. Retención**

Decisión técnica: Implementación de tareas programadas de mantenimiento para evaluar el ciclo de vida del dato.

Implementación:

* Definición de plazos diferenciados por esquema:

    * Operación: Conservación durante la relación comercial activa + 5 años de archivo.

    * Analítica: Retención indefinida solo si los datos están totalmente anonimizados (agregados).

    * Auditoría: Retención de logs por 10 años conforme a requerimientos regulatorios.

**5. Trazabilidad**

Decisión técnica: Creación de un esquema auditoria de solo lectura e inserción.

* Implementación:

    * Registro automático de eventos DDL y DML sensibles (quién consultó, desde qué IP, a qué hora y cuántas filas fueron retornadas).

    * Desactivación de permisos UPDATE o DELETE sobre las tablas del esquema auditoria para todos los roles ordinarios.

**6. Eliminación**

Decisión técnica: Protocolo en dos fases: Bloqueo Lógico seguido de Purga Física Cifrada.

* Implementación:

    Cuando se autoriza la cancelación, el registro pasa a estado CANCELADO_BLOQUEADO y se reasigna a un esquema temporal restringido.

    Una vez cumplido el plazo de conservación obligatoria (fiscal/mercantil), se ejecuta un procedimiento almacenado (sp_purga_definitiva()) que ejecuta el DELETE físico y limpia las referencias temporales.

**7. Atención de Solicitudes (Derechos ARCO)**

Decisión técnica: Automatización de flujos técnicos para responder a las solicitudes de los titulares mediante procedimientos almacenados seguros.

* Implementación:

    * Acceso: Procedimiento sp_exportar_datos_titular(p_id) que genera un archivo estructurado (JSON/CSV) con toda la información vinculada al cliente.

    * Rectificación: Procedimiento auditado que actualiza la PII en el esquema de operación y propaga las correcciones a los sistemas integrados.

    * Oposición: Flag acepta_promociones = FALSE que excluye automáticamente al cliente de las vistas utilizadas por el área de marketing.