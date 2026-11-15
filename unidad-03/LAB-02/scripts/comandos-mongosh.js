// - Preparación del entorno (Sección 6.3 y 6.4) -
use admin
db.createUser({ user: "admin", pwd: "Admin_Practica_2026", roles: ["root"] })
db.auth("admin", "Admin_Practica_2026")

use comercial
db.createUser({
  user: "app_ventas",
  pwd: "Ventas_Practica_2026",
  roles: [{ role: "readWrite", db: "comercial" }]
})

db.clientes.insertMany([
  { _id: 1, nombre: "Ana López", correo: "ana.lopez@example.test", telefono: "6671234567", rfc: "LOAA850315ABC", edad: 41, ciudad: "Culiacán", codigo_postal: "80000" },
  { _id: 2, nombre: "Carlos Pérez", correo: "carlos.perez@example.test", telefono: "6672345678", rfc: "PECA900720DEF", edad: 35, ciudad: "Culiacán", codigo_postal: "80100" },
  { _id: 3, nombre: "María García", correo: "maria.garcia@example.test", telefono: "6673456789", rfc: "GAMA780912GHI", edad: 47, ciudad: "Mazatlán", codigo_postal: "82000" },
  { _id: 4, nombre: "Luis Torres", correo: "luis.torres@example.test", telefono: "6674567890", rfc: "TOLU920201JKL", edad: 34, ciudad: "Los Mochis", codigo_postal: "81200" },
  { _id: 5, nombre: "Laura Sánchez", correo: "laura.sanchez@example.test", telefono: "6675678901", rfc: "SALA880525MNO", edad: 38, ciudad: "Culiacán", codigo_postal: "80200" }
])

// Función auxiliar para leer la bitácora en memoria (sesión DBA)
function bitacora() {
  return db.adminCommand({ getLog: "global" }).log.map(l => JSON.parse(l))
}


// - Actividad #1 - Lo que no existe en esta edición
db.version()
db.adminCommand({ buildInfo: 1 }).modules
db.serverCmdLineOpts().parsed


// - Actividad #2 - El incidente sin perfilado
// Sesión DBA: verificar estado del perfilador
db.getProfilingStatus()

// Sesión Aplicación (app_ventas): modificar RFC sin perfilado activo
db.clientes.updateOne({ _id: 3 }, { $set: { rfc: "GAMA780912XXX" } })

// Sesión DBA: buscar evidencia en system.profile y bitácora
db.system.profile.countDocuments()
bitacora().filter(e => JSON.stringify(e).includes("GAMA780912XXX")).length
bitacora().filter(e => JSON.stringify(e).includes("app-ventas-web")).map(e => ({ t: e.t, c: e.c, ctx: e.ctx, msg: e.msg }))


// - Actividad #3 - Activar el perfilador y registrar operaciones
// Sesión DBA: activar nivel 2
db.setProfilingLevel(2)
db.getProfilingStatus()

// Sesión Aplicación (app_ventas): ejecutar consulta, actualización y eliminación
db.clientes.find({ ciudad: "Culiacán" }, { nombre: 1, ciudad: 1 }).toArray()
db.clientes.updateOne({ _id: 3 }, { $set: { rfc: "GAMA780912XYZ" } })
db.clientes.deleteOne({ _id: 2 })

// Sesión DBA: consultar operaciones registradas en system.profile
db.system.profile.find(
  { ns: "comercial.clientes" },
  { op: 1, ns: 1, command: 1, user: 1, client: 1, appName: 1, ts: 1, millis: 1, nreturned: 1, docsExamined: 1, nModified: 1, ndeleted: 1 }
).sort({ ts: 1 })


// - Actividad #4 - Reducir el volumen con un filtro
// Sesión DBA: reiniciar system.profile y configurar filtro para escritura
db.setProfilingLevel(0)
db.system.profile.drop()
db.setProfilingLevel(1, { filter: { op: { $in: ["insert", "update", "remove"] } } })
db.getProfilingStatus()

// Sesión Aplicación (app_ventas): ejecutar una lectura y una actualización
db.clientes.find({ _id: 1 }).toArray()
db.clientes.updateOne({ _id: 1 }, { $set: { telefono: "6670000000" } })

// Sesión DBA: verificar que solo se registró la operación update
db.system.profile.find({}, { op: 1, ns: 1, user: 1, appName: 1, "command.q": 1, "command.u": 1, ts: 1 })


// - Actividad #5 - Accesos en la bitácora de mongod
// Intentos de acceso fallidos (ejecutados vía --eval con credenciales inválidas)
db.clientes.countDocuments()

// Sesión DBA: filtrar intentos de autenticación fallidos y último acceso exitoso
bitacora()
  .filter(e => e.c === "ACCESS" && e.msg === "Failed to authenticate")
  .map(e => ({ t: e.t, id: e.id, ctx: e.ctx, user: e.attr.user, client: e.attr.client, error: e.attr.error, result: e.attr.result, app: e.attr.doc?.application?.name }))

bitacora()
  .filter(e => e.msg === "Successfully authenticated" && e.attr.user === "app_ventas")
  .slice(-1)
  .map(e => ({ t: e.t, id: e.id, ctx: e.ctx, client: e.attr.client, result: e.attr.result, app: e.attr.doc?.application?.name }))


// - Actividad #6 - Correlacionar un cambio de configuración con su autor
// Sesión DBA: localizar cambio en el perfilador y correlacionar con su conexión (ctx)
bitacora()
  .filter(e => e.msg === "Profiler settings changed")
  .map(e => ({ t: e.t, ctx: e.ctx, msg: e.msg, attr: e.attr }))

// Sustituir "conn31" por el valor de ctx observado
bitacora()
  .filter(e => e.ctx === "conn31" && e.msg === "Successfully authenticated")
  .map(e => ({ t: e.t, ctx: e.ctx, user: e.attr.user, db: e.attr.db, client: e.attr.client }))


// - Actividad #7 - Cambios de privilegios: el límite más importante
// Sesión DBA: tomar primera instantánea de privilegios
db.getSiblingDB("auditoria").instantaneas_privilegios.insertOne({
  momento: new Date(),
  tomada_por: db.runCommand({ connectionStatus: 1 }).authInfo.authenticatedUsers,
  usuarios: (db.getUsers().users ?? db.getUsers()).map(u => ({ user: u.user, db: u.db, roles: u.roles }))
})

// Activar nivel 2 y otorgar rol adicional
db.setProfilingLevel(2)
db.grantRolesToUser("app_ventas", [{ role: "dbAdmin", db: "comercial" }])

// Verificar ausencia de evidencia nativa en system.profile y bitácora
db.system.profile.countDocuments({ "command.grantRolesToUser": { $exists: true } })
bitacora().filter(e => JSON.stringify(e).includes("grantRoles")).length

// Tomar segunda instantánea y comparar ambas
db.getSiblingDB("auditoria").instantaneas_privilegios.insertOne({
  momento: new Date(),
  tomada_por: db.runCommand({ connectionStatus: 1 }).authInfo.authenticatedUsers,
  usuarios: (db.getUsers().users ?? db.getUsers()).map(u => ({ user: u.user, db: u.db, roles: u.roles }))
})

db.getSiblingDB("auditoria").instantaneas_privilegios.find({}, { _id: 0 }).sort({ momento: 1 })

// Revocar rol adicional y restablecer filtro de la Actividad 4
db.revokeRolesFromUser("app_ventas", [{ role: "dbAdmin", db: "comercial" }])
db.setProfilingLevel(1, { filter: { op: { $in: ["insert", "update", "remove"] } } })


// - Actividad #8 - Conservación: exportar antes de perder
// Exportar system.profile y bitácora desde mongosh usando Node fs
const fs = require("fs");

fs.writeFileSync(
  "C:/Users/graci/Documents/unidad-03/LAB-02/evidencias/system-profile.json",
  EJSON.stringify(
    db.system.profile.find({}, { op: 1, ns: 1, user: 1, client: 1, appName: 1, ts: 1, "command.q": 1, "command.u": 1 }).toArray(),
    null,
    2
  )
);

fs.writeFileSync(
  "C:/Users/graci/Documents/unidad-03/LAB-02/evidencias/bitacora-mongod.log",
  db.adminCommand({ getLog: "global" }).log.join("
")
);

// Verificación posterior al reinicio del servicio MongoDB
db.getProfilingStatus()
db.system.profile.countDocuments()
bitacora().length