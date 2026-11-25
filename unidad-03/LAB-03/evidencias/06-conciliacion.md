# Actividad 7 — Registro de cambios y conciliación

| Momento (bitácora) | Usuario | Sentencia | Folio que lo autoriza | ¿Autorizado? | Hallazgo |
|---|---|---|---|---|---|
| 2026-10-25 22:54:26.533 | `postgres` | `ALTER TABLE clientes ADD COLUMN canal_alta VARCHAR(20);` | `CAM-2026-014` | Sí | — (Cambio ejecutado dentro de la ventana autorizada por el Comité de cambios). |
| 2026-10-25 22:50:53.549 | `postgres` | `ALTER TABLE clientes DISABLE TRIGGER trg_auditoria_clientes` | Ninguno | No | **Hallazgo crítico:** Evasión deliberada del control de auditoría del dato por el superusuario (DBA) seguida de modificación sin rastro en `auditoria.cambios_clientes`. |
| 2026-10-25 22:50:53.554 | `postgres` | `ALTER TABLE clientes ENABLE TRIGGER trg_auditoria_clientes` | Ninguno | No | **Hallazgo crítico:** Reactivación del disparador tras ocultar una modificación no autorizada del RFC. |
| 2026-10-25 22:50:53.460 | `app_ventas` | `ALTER TABLE clientes DISABLE TRIGGER trg_auditoria_clientes` | Ninguno | No | **Hallazgo alto:** Intento de evasión de controles por cuenta de aplicación (rechazado por falta de propiedad sobre la tabla). |
| 2026-10-25 22:50:09.367 | `postgres` | `GRANT UPDATE ON clientes TO app_ventas` | Ninguno | No (Sin folio registrado) | **Hallazgo medio (Incumplimiento de POL-01 / POL-06):** Cambio de privilegios ejecutado sin solicitud formal aprobada en `gobierno.solicitudes_cambio` (origen: configuración previa del LAB-01). |
| 2026-10-25 22:50:09.341 | `postgres` | `REVOKE UPDATE ON clientes FROM soporte_ana` | Ninguno | No (Sin folio registrado) | **Hallazgo medio (Incumplimiento de POL-01):** Revocación de permisos sin folio de autorización documentado (origen: configuración previa del LAB-01). |
| 2026-10-25 22:50:09.372 | `postgres` | `ALTER TABLE clientes ADD COLUMN segmento VARCHAR(20)` | Ninguno | No (Sin folio registrado) | **Hallazgo medio (Incumplimiento de POL-06):** Alteración de esquema en producción sin folio de aprobación previo (origen: configuración previa del LAB-01). |
| 2026-10-25 22:50:09.375 | `postgres` | `CREATE ROLE rol_temporal LOGIN PASSWORD '[CENSURADO]'` | Ninguno | No | **Hallazgo alto (POL-01 / POL-05):** Creación de cuenta temporal sin solicitud aprobada, sin fecha de revocación registrada y con contraseña expuesta en texto plano en la bitácora. |
---

**1. ¿Qué cambios de la bitácora no tienen folio? Clasifícalos: ¿son de preparación del laboratorio o representan hallazgos?**

Todos los cambios anteriores a CAM-2026-014 (líneas 34, 35, 36, 37, 163, 169 y 171) carecen de folio en gobierno.solicitudes_cambio. En una auditoría real, todos representan hallazgos, aunque de distinta naturaleza:

* De configuración/preparación previa (líneas 34–36): REVOKE UPDATE, GRANT UPDATE y ALTER TABLE ... ADD COLUMN segmento provienen del despliegue técnico del LAB-01 antes de existir el registro de gobierno; son hallazgos administrativos por falta de regularización retroactiva.

* De seguridad y evasión activa (líneas 37, 163, 169, 171): La creación de rol_temporal con contraseña visible y la desactivación/reactivación del disparador trg_auditoria_clientes son hallazgos graves de seguridad, pues evidencian intentos de eludir controles y crear accesos no gobernados.

**2. La desactivación del disparador del LAB-01 (Actividad 14), ¿qué tan grave es como hallazgo? ¿Por qué? ¿Qué distingue la línea 163 de la 169?**

* Gravedad: Es un hallazgo crítico (máxima severidad).

* ¿Por qué? Porque neutraliza intencionalmente el control compensatorio de integridad y trazabilidad (auditoria.cambios_clientes), permitiendo alterar datos sensibles (como el RFC) sin dejar registro de valores antes y después, lo que compromete la confiabilidad de toda la evidencia de la base de datos.

* Diferencia entre línea 163 y línea 169: En la línea 163, el usuario app_ventas intentó desactivar el disparador y el motor rechazó la orden por falta de privilegios (must be owner of table clientes), registrando el intento fallido. En la línea 169, el superusuario postgres ejecutó exactamente la misma sentencia con éxito efectivo, deshabilitando el control real.

**3. ¿Qué limitación tiene esta conciliación si log_statement estuvo en none durante algún periodo?**

Se produce un punto ciego (hueco de evidencia) en la línea de tiempo: cualquier sentencia DDL (CREATE, ALTER, DROP) o DCL (GRANT, REVOKE) ejecutada mientras log_statement = 'none' (como ocurrió al crear la vista dba.bitacora) simplemente no existe en los logs. La conciliación solo puede verificar lo que el colector registró; si la bitácora estuvo apagada, un atacante o administrador pudo crear roles ocultos o modificar estructuras sin dejar rastro conciliable.

**4. ¿Quién debería realizar la conciliación: el DBA que hizo los cambios u otra persona?**

Debe realizarla otra persona independiente (específicamente Auditoría Interna o Seguridad de la Información), aplicando el principio de separación de funciones. Si el mismo DBA que ejecutó los cambios realiza la conciliación, se convierte en juez y parte, pudiendo omitir sus propias acciones no autorizadas (como desactivar disparadores) o falsificar el reporte de cumplimiento.