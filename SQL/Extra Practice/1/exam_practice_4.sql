use inmobiliaria_calciferhowl;

-- Ejercicio 1
/* Listar los garantes que han participado en solicitudes de contrato 'en alquiler'. Mostrar nombre, apellido y fecha de la solicitud. */
select
  per.nombre,
  per.apellido,
  sc.fecha_solicitud
from
  persona per
  inner join garantia g on per.id = g.id_garante
  inner join solicitud_contrato sc on g.id_solicitud = sc.id
where
  sc.estado = 'en alquiler';

-- Ejercicio 2
/* Listar los pagos realizados en 2024 para contratos de alquiler vigentes. Mostrar importe, fecha de pago, nombre y apellido del cliente y dirección de la propiedad. */
select
  p.importe,
  p.fecha_hora_pago,
  per.nombre,
  per.apellido,
  prop.direccion
from
  pago p
  inner join solicitud_contrato sc on p.id_solicitud = sc.id
  inner join persona per on sc.id_cliente = per.id
  inner join propiedad prop on sc.id_propiedad = prop.id
where
  p.fecha_hora_pago BETWEEN '2024-01-01'
  and '2024-12-31'
  and sc.estado = 'en alquiler';

select
  p.importe,
  p.fecha_hora_pago,
  per.nombre,
  per.apellido,
  prop.direccion
from
  pago p
  inner join solicitud_contrato sc on p.id_solicitud = sc.id
  inner join persona per on sc.id_cliente = per.id
  inner join propiedad prop on sc.id_propiedad = prop.id
where
  year(p.fecha_hora_pago) = 2024
  and sc.estado = 'en alquiler';

-- Ejercicio 3
/* Listar los propietarios y las propiedades que poseen. Mostrar nombre y apellido del propietario, dirección y zona de la propiedad. */
select
  p.nombre,
  p.apellido,
  prop.direccion,
  prop.zona
from
  persona p
  INNER JOIN propietario_propiedad pp ON p.id = pp.id_propietario
  INNER JOIN propiedad prop ON pp.id_propiedad = prop.id;

-- Ejercicio 4
/* Listar las propiedades que tienen al menos 3 baños. Mostrar id, dirección y cantidad de baños. */
select
  p.id,
  p.direccion,
  h.cantidad
from
  propiedad p
  inner join habitacion h on p.id = h.id_propiedad
  inner join tipo_habitacion th on h.id_tipo_habitacion = th.id
where
  th.nombre = 'baño'
  and h.cantidad >= 3;

-- Ejercicio 5
/* Listar los garantes que participaron en solicitudes de contrato rechazadas en 2023. Mostrar nombre, apellido y fecha de la solicitud. */
select
  p.nombre,
  p.apellido,
  sc.fecha_solicitud
from
  persona p
  inner join garantia g on p.id = g.id_garante
  inner join solicitud_contrato sc on g.id_solicitud = sc.id
where
  g.estado = 'rechazada'
  and year(sc.fecha_solicitud) = 2023;

-- Ejercicio 6
/* Listar los pagos realizados por concepto de 'pago alquiler' en propiedades de la zona 'Galaxia Muy Lejana'. Mostrar importe, fecha de pago y dirección de la propiedad. */
select
  pa.importe,
  pa.fecha_hora_pago,
  pr.direccion
from
  pago pa
  inner join solicitud_contrato sc on pa.id_solicitud = sc.id
  inner join propiedad pr on pr.id = sc.id_propiedad
where
  pr.zona = 'Galaxia Muy Lejana'
  and pa.concepto = 'pago alquiler';

-- Ejercicio 7
/* Listar las propiedades que tienen al menos una habitación de tipo 'dormitorio'. Mostrar id de la propiedad, dirección y cantidad de terrazas. */
select
  p.id,
  p.direccion,
  h.cantidad
from
  propiedad p
  inner join habitacion h on p.id = h.id_propiedad
  inner join tipo_habitacion th on h.id_tipo_habitacion = th.id
where
  th.nombre = 'dormitorio'
  and h.cantidad > 0;

-- Ejercicio 8
/* Listar los pagos realizados en 2023 por concepto de 'pago alquiler'. Mostrar importe, fecha de pago y dirección de la propiedad. */
select
  pa.importe,
  pa.fecha_hora_pago,
  pr.direccion
from
  pago pa
  inner join solicitud_contrato sc on pa.id_solicitud = sc.id
  inner join propiedad pr on pr.id = sc.id_propiedad
where
  pa.concepto = 'pago alquiler'
  and year(pa.fecha_hora_pago) = 2023;

-- Ejercicio 9
/* Listar todas las propiedades y, si tienen propietario, mostrar el nombre y apellido del propietario. Si no tienen propietario, mostrar 'Sin propietario'. */
select
  COALESCE(
    CONCAT(per.nombre, ', ', per.apellido),
    'Sin propietario'
  ) datos_propietario
from
  propiedad p
  left join propietario_propiedad pp on p.id = pp.id_propiedad
  left join persona per on pp.id_propietario = per.id;

-- Ejercicio 10
/* Listar todas las propiedades y, si tienen alguna habitación de tipo 'mazmorra', mostrar la cantidad. Si no tienen, mostrar 0. */
select
  p.id,
  p.direccion,
  isnull(th.nombre) mazmorra,
  ifnull(th.nombre, 'No hay') mazmorra2
from
  propiedad p
  left join habitacion h on p.id = h.id_propiedad
  left join tipo_habitacion th on h.id_tipo_habitacion = th.id
  and th.nombre = 'mazmorra';

-- Ejercicio 11
/* Listar todas las visitas realizadas en 2024, mostrando fecha, dirección de la propiedad y nombre y apellido del cliente que realizó la visita. */
select
  p.direccion,
  per.nombre,
  per.apellido
from
  visita v
  inner join propiedad p on v.id_propiedad = p.id
  inner join persona per on v.id_cliente = per.id
where
  year(v.fecha_hora_visita) = 2024;

select
  p.direccion,
  per.nombre,
  per.apellido
from
  visita v
  inner join propiedad p on v.id_propiedad = p.id
  inner join persona per on v.id_cliente = per.id
where
  v.fecha_hora_visita between '2024-01-01'
  and '2024-12-31';

-- Respuestas Sugeridas
-- Ejercicio 1
SELECT
  per.nombre,
  per.apellido,
  sc.fecha_solicitud
FROM
  garantia g
  INNER JOIN persona per ON g.id_garante = per.id
  INNER JOIN solicitud_contrato sc ON g.id_solicitud = sc.id
WHERE
  g.estado = 'aprobada';

-- Ejercicio 2
SELECT
  pago.importe,
  pago.fecha_hora_pago,
  per.nombre,
  per.apellido,
  p.direccion
FROM
  pago
  INNER JOIN solicitud_contrato sc ON pago.id_solicitud = sc.id
  INNER JOIN persona per ON sc.id_cliente = per.id
  INNER JOIN propiedad p ON sc.id_propiedad = p.id
WHERE
  sc.estado = 'en alquiler'
  AND YEAR (pago.fecha_hora_pago) = 2024;

-- Ejercicio 3
SELECT
  per.nombre,
  per.apellido,
  p.direccion,
  p.zona
FROM
  propietario_propiedad pp
  INNER JOIN persona per ON pp.id_propietario = per.id
  INNER JOIN propiedad p ON pp.id_propiedad = p.id;

-- Ejercicio 4
SELECT
  p.id,
  p.direccion,
  h.cantidad AS baños
FROM
  propiedad p
  INNER JOIN habitacion h ON p.id = h.id_propiedad
WHERE
  h.id_tipo_habitacion = 13004
  AND h.cantidad >= 3;

-- Ejercicio 5
SELECT
  per.nombre,
  per.apellido,
  sc.fecha_solicitud
FROM
  garantia g
  INNER JOIN persona per ON g.id_garante = per.id
  INNER JOIN solicitud_contrato sc ON g.id_solicitud = sc.id
WHERE
  g.estado = 'rechazada'
  AND YEAR (sc.fecha_solicitud) = 2023;

-- Ejercicio 6
SELECT
  pago.importe,
  pago.fecha_hora_pago,
  p.direccion
FROM
  pago
  INNER JOIN solicitud_contrato sc ON pago.id_solicitud = sc.id
  INNER JOIN propiedad p ON sc.id_propiedad = p.id
WHERE
  pago.concepto = 'expensas'
  AND p.zona = 'Centro';

-- Ejercicio 7
SELECT
  p.id,
  p.direccion,
  h.cantidad AS terrazas
FROM
  propiedad p
  INNER JOIN habitacion h ON p.id = h.id_propiedad
WHERE
  h.id_tipo_habitacion = 13005
  AND h.cantidad > 0;

-- Ejercicio 8
SELECT
  pago.importe,
  pago.fecha_hora_pago,
  p.direccion
FROM
  pago
  INNER JOIN solicitud_contrato sc ON pago.id_solicitud = sc.id
  INNER JOIN propiedad p ON sc.id_propiedad = p.id
WHERE
  pago.concepto = 'depósito'
  AND YEAR (pago.fecha_hora_pago) = 2023;

-- Ejercicio 9
SELECT
  p.id,
  p.direccion,
  COALESCE(per.nombre, 'Sin propietario') AS nombre_propietario,
  COALESCE(per.apellido, '') AS apellido_propietario
FROM
  propiedad p
  LEFT JOIN propietario_propiedad pp ON p.id = pp.id_propiedad
  LEFT JOIN persona per ON pp.id_propietario = per.id;

-- Ejercicio 10
SELECT
  p.id,
  p.direccion,
  COALESCE(h.cantidad, 0) AS baños
FROM
  propiedad p
  LEFT JOIN habitacion h ON p.id = h.id_propiedad
  AND h.id_tipo_habitacion = 13004;

-- Ejercicio 11
SELECT
  v.fecha_visita,
  p.direccion,
  per.nombre,
  per.apellido
FROM
  visita v
  INNER JOIN propiedad p ON v.id_propiedad = p.id
  INNER JOIN persona per ON v.id_cliente = per.id
WHERE
  YEAR (v.fecha_visita) = 2024;