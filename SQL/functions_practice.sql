USE agencia_personal;

-- Exercise 1
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
SELECT
  *,
  DATEDIFF (fecha_finalizacion_contrato, fecha_caducidad) AS dias_antes
from
  contratos
WHERE
  fecha_caducidad < fecha_finalizacion_contrato;

-- Exercise 4
SELECT
  con.cuit,
  emp.razon_social,
  emp.direccion,
  com.anio_contrato,
  com.mes_contrato,
  com.importe_comision,
  ADDDATE (CURDATE (), INTERVAL 2 MONTH) AS fecha_vencimiento
FROM
  contratos con
  LEFT JOIN comisiones com ON con.nro_contrato = com.nro_contrato
  LEFT JOIN empresas emp ON con.cuit = emp.cuit
WHERE
  com.fecha_pago IS NULL;

-- Exercise 5
SELECT
  CONCAT(nombre, ' ', apellido) AS 'Nombre y apellido',
  fecha_nacimiento,
  DAY(fecha_nacimiento) as 'Dia',
  MONTH(fecha_nacimiento) as 'Mes',
  YEAR(fecha_nacimiento) as 'Año'
FROM personas;