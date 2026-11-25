POL-05 — Protección y Uso de Datos Sensibles y Personales

Objetivo:        Reducir el riesgo de exposición, filtración o uso indebido de datos personales identificadores y fiscales (RFC, correo, teléfono, nombre) y credenciales del sistema.

Alcance:         Aplica a las columnas clasificadas como dato personal o confidencial en `public.clientes` (`CAT-01`), `auditoria.cambios_clientes` (`CAT-02`), `comercial.clientes` (`CAT-04`) y a los archivos de bitácora en cualquier ambiente.

Regla:           El acceso directo a datos personales sin enmascarar en producción está restringido exclusivamente a roles operativos autorizados por la Gerencia Comercial (como Facturación), mientras que áreas de soporte deben consultar vistas enmascaradas y los ambientes de desarrollo o pruebas no pueden usar datos personales reales sin anonimizar. Toda modificación sobre datos personales en `clientes` queda registrada automáticamente con valores antes/después, y toda lectura masiva o exportación de bitácoras debe revisarse para evitar fuga de secretos.

Responsable:     Decide finalidad y accesos: Gerencia Comercial (Propietario). Implementa controles y supervisa: DBA y Seguridad de la Información.

Excepciones:     Extracción temporal de datos reales para diagnóstico de incidentes críticos, autorizada por Seguridad de la Información y el Propietario del dato, con eliminación segura inmediata al concluir el análisis.

Evidencia:       Disparador `trg_auditoria_clientes` y registros en `auditoria.cambios_clientes` (LAB-01 Parte B), comentarios de clasificación en `information_schema` / `diccionario-clientes.csv` (LAB-03, Actividad 3), vista enmascarada de soporte (Unidad II) y `system.profile` en MongoDB (LAB-02). (Nota: hoy no existe registro de lecturas `SELECT` en PostgreSQL por ausencia de `pgaudit`).

Revisión:        Semestral o cuando se agreguen nuevas columnas con datos personales al diccionario.