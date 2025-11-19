USE agencia_personal;

-- Shows all the companies that have made requests for employees for a specific position
-- and the contracts associated with those requests, if they exist.
SELECT
  emp.cuit,
  emp.razon_social,
  se.fecha_solicitud,
  car.desc_cargo,
  con.nro_contrato,
  con.sueldo,
  con.fecha_incorporacion
FROM
  empresas emp
  INNER JOIN solicitudes_empresas se ON emp.cuit = se.cuit
  INNER JOIN cargos car ON se.cod_cargo = car.cod_cargo
  INNER JOIN contratos con ON se.cuit = con.cuit
  AND se.cod_cargo = con.cod_cargo
  AND se.fecha_solicitud = con.fecha_solicitud
WHERE
  se.fecha_solicitud < ADDDATE (NOW (), INTERVAL -5 YEAR)
ORDER BY
  se.fecha_solicitud;

-- Shows all the companies that have made requests for employees for a specific position
-- but, if there are no contracts associated with those requests, it still shows the request details.
SELECT
  emp.cuit,
  emp.razon_social,
  se.fecha_solicitud,
  car.desc_cargo,
  con.nro_contrato,
  con.sueldo,
  con.fecha_incorporacion
FROM
  empresas emp
  INNER JOIN solicitudes_empresas se ON emp.cuit = se.cuit
  INNER JOIN cargos car ON se.cod_cargo = car.cod_cargo
  LEFT JOIN contratos con ON se.cuit = con.cuit
  AND se.cod_cargo = con.cod_cargo
  AND se.fecha_solicitud = con.fecha_solicitud
WHERE
  se.fecha_solicitud < ADDDATE (NOW (), INTERVAL -5 YEAR)
ORDER BY
  se.fecha_solicitud;

-- As we use INNER JOIN after the LEFT JOIN, it will eliminate any rows where there is no match in the contratos table (where con.dni IS NULL).
SELECT
  emp.cuit,
  emp.razon_social,
  se.fecha_solicitud,
  car.desc_cargo,
  con.nro_contrato,
  con.sueldo,
  con.fecha_incorporacion,
  per.nombre
FROM
  empresas emp
  INNER JOIN solicitudes_empresas se ON emp.cuit = se.cuit
  INNER JOIN cargos car ON se.cod_cargo = car.cod_cargo
  LEFT JOIN contratos con ON se.cuit = con.cuit
  AND se.cod_cargo = con.cod_cargo
  AND se.fecha_solicitud = con.fecha_solicitud
  INNER JOIN personas per ON con.dni = per.dni
WHERE
  se.fecha_solicitud < ADDDATE (NOW (), INTERVAL -5 YEAR)
ORDER BY
  se.fecha_solicitud;

SELECT
  emp.cuit,
  emp.razon_social,
  se.fecha_solicitud,
  car.desc_cargo,
  con.nro_contrato,
  con.sueldo,
  con.fecha_incorporacion,
  per.nombre
FROM
  empresas emp
  INNER JOIN solicitudes_empresas se ON emp.cuit = se.cuit
  INNER JOIN cargos car ON se.cod_cargo = car.cod_cargo
  LEFT JOIN contratos con ON se.cuit = con.cuit
  AND se.cod_cargo = con.cod_cargo
  AND se.fecha_solicitud = con.fecha_solicitud
  LEFT JOIN personas per ON con.dni = per.dni
WHERE
  se.fecha_solicitud < ADDDATE (NOW (), INTERVAL -5 YEAR)
ORDER BY
  se.fecha_solicitud;

SELECT
  emp.cuit,
  emp.razon_social,
  se.fecha_solicitud,
  car.desc_cargo,
  con.nro_contrato,
  con.sueldo,
  con.fecha_incorporacion,
  per.nombre
FROM
  empresas emp
  INNER JOIN solicitudes_empresas se ON emp.cuit = se.cuit
  INNER JOIN cargos car ON se.cod_cargo = car.cod_cargo
  LEFT JOIN contratos con ON se.cuit = con.cuit
  AND se.cod_cargo = con.cod_cargo
  AND se.fecha_solicitud = con.fecha_solicitud
  LEFT JOIN personas per ON con.dni = per.dni
WHERE
  se.fecha_solicitud < ADDDATE (NOW (), INTERVAL -5 YEAR)
  AND (
    con.fecha_incorporacion IS NULL
    OR con.fecha_incorporacion > '20140101'
  )
ORDER BY
  se.fecha_solicitud;

SELECT
  emp.cuit,
  emp.razon_social,
  se.fecha_solicitud,
  car.desc_cargo,
  con.nro_contrato,
  con.sueldo,
  con.fecha_incorporacion,
  per.nombre
FROM
  empresas emp
  INNER JOIN solicitudes_empresas se ON emp.cuit = se.cuit
  INNER JOIN cargos car ON se.cod_cargo = car.cod_cargo
  LEFT JOIN contratos con ON se.cuit = con.cuit
  AND se.cod_cargo = con.cod_cargo
  AND se.fecha_solicitud = con.fecha_solicitud
  AND con.fecha_incorporacion > '20140101'
  LEFT JOIN personas per ON con.dni = per.dni
WHERE
  se.fecha_solicitud < ADDDATE (NOW (), INTERVAL -5 YEAR)
ORDER BY
  se.fecha_solicitud;

-- LEFT JOIN vs RIGHT JOIN
SELECT
  emp.cuit,
  emp.razon_social,
  car.cod_cargo,
  car.desc_cargo
FROM
  empresas emp
  LEFT JOIN antecedentes ant ON emp.cuit = ant.cuit
  LEFT JOIN cargos car ON ant.cod_cargo = car.cod_cargo;

SELECT
  emp.cuit,
  emp.razon_social,
  car.cod_cargo,
  car.desc_cargo
FROM
  empresas emp
  RIGHT JOIN antecedentes ant ON emp.cuit = ant.cuit
  RIGHT JOIN cargos car ON ant.cod_cargo = car.cod_cargo;

SELECT
  emp.cuit,
  emp.razon_social,
  car.cod_cargo,
  car.desc_cargo
FROM
  cargos car
  LEFT JOIN antecedentes ant ON car.cod_cargo = ant.cod_cargo
  LEFT JOIN empresas emp ON ant.cuit = emp.cuit;

-- All companies that have requested for employees from 2014-09-21 onwards
SELECT
  emp.cuit,
  emp.razon_social,
  se.fecha_solicitud,
  se.cod_cargo,
  car.desc_cargo
FROM
  empresas emp
  LEFT JOIN solicitudes_empresas se ON emp.cuit = se.cuit
  AND se.fecha_solicitud > '2014-09-21'
  LEFT JOIN cargos car ON se.cod_cargo = car.cod_cargo;

SELECT
  emp.cuit,
  emp.razon_social,
  se.fecha_solicitud,
  se.cod_cargo,
  car.desc_cargo
FROM
  empresas emp
  LEFT JOIN solicitudes_empresas se ON emp.cuit = se.cuit
  LEFT JOIN cargos car ON se.cod_cargo = car.cod_cargo
WHERE
  se.fecha_solicitud > '2014-09-21';

USE afatse;

SELECT
  al.dni,
  al.apellido,
  al.nombre,
  in1.fecha_inscripcion,
  in1.nro_curso
FROM
  alumnos al
  INNER JOIN inscripciones in1 ON al.dni = in1.dni
  AND YEAR (in1.fecha_inscripcion) < YEAR (CURDATE ())
  LEFT JOIN inscripciones in2 ON al.dni = in2.dni
  AND YEAR (in2.fecha_inscripcion) = YEAR (CURDATE ())
WHERE
  in2.dni IS NULL;

-- Shows all students who have enrolled in courses before the current year
-- and have not enrolled in any course in the current year.
SELECT
  al.dni,
  al.apellido,
  al.nombre,
  in1.fecha_inscripcion,
  in1.nro_curso
FROM
  alumnos al
  INNER JOIN inscripciones in1 ON al.dni = in1.dni
  AND YEAR (in1.fecha_inscripcion) < YEAR (CURDATE ())
  LEFT JOIN inscripciones in2 ON al.dni = in2.dni
  AND YEAR (in2.fecha_inscripcion) = YEAR (CURDATE ())
  AND in2.dni IS NULL;