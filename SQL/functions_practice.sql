USE agencia_personal;

-- Exercise 1
/* Para aquellos contratos que no hayan terminado calcular la fecha de caducidad como la fecha de solicitud más 30 días (no actualizar la base de datos).Función ADDDATE */
SELECT
  nro_contrato,
  fecha_incorporacion,
  fecha_finalizacion_contrato,
  ADDDATE (fecha_solicitud, 30)
FROM
  contratos
WHERE
  fecha_caducidad IS NULL;

-- Exercise 2
/* Mostrar los contratos.Indicar nombre y apellido de la persona,
 razón social de la empresa fecha de inicio del contrato y fecha de caducidad del contrato.Si la fecha no ha terminado mostrar “ Contrato Vigente ”.Función IFNULL */
SELECT
  nro_contrato,
  e.razon_social,
  p.apellido,
  p.nombre,
  fecha_incorporacion,
  IFNULL (fecha_caducidad, 'Contrato Vigente') AS fin_contrato
FROM
  contratos c
  LEFT JOIN personas p ON c.dni = p.dni
  LEFT JOIN empresas e ON c.cuit = e.cuit;

-- Exercise 3
/* Para aquellos contratos que terminaron antes de la fecha de finalización, indicar la cantidad de días que finalizaron antes de tiempo.Función DATEDIFF */
SELECT
  *,
  DATEDIFF(fecha_finalizacion_contrato, fecha_caducidad) AS dias_antes
from
  contratos
WHERE
  fecha_caducidad < fecha_finalizacion_contrato;

-- Exercise 4
/* Emitir un listado de comisiones impagas para cobrar.Indicar cuit, razón social de la empresa y dirección, año y mes de la comisión, importe y la fecha de vencimiento que se calcula como la fecha actual más dos meses.Función ADDDATE con INTERVAL */
SELECT
  con.cuit,
  emp.razon_social,
  emp.direccion,
  com.anio_contrato,
  com.mes_contrato,
  com.importe_comision,
  ADDDATE(CURDATE(), INTERVAL 2 MONTH) AS fecha_vencimiento
FROM
  contratos con
  LEFT JOIN comisiones com ON con.nro_contrato = com.nro_contrato
  LEFT JOIN empresas emp ON con.cuit = emp.cuit
WHERE
  com.fecha_pago IS NULL;

-- Exercise 5
/* Mostrar en qué día mes y año nacieron las personas (mostrarlos en columnas separadas) y sus nombres y apellidos concatenados.Funciones DAY, YEAR, MONTH y CONCAT */
SELECT
  CONCAT(nombre, ' ', apellido) AS 'Nombre y apellido',
  fecha_nacimiento,
  DAY(fecha_nacimiento) as 'Dia',
  MONTH(fecha_nacimiento) as 'Mes',
  YEAR(fecha_nacimiento) as 'Año'
FROM personas;