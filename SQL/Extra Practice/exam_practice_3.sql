-- Ejercicio 1
/* Listar todas las propiedades en alquiler, mostrando id, dirección, zona y situación. Ordenar por zona alfabéticamente. */
select
  id,
  direccion,
  zona,
  situacion
from
  propiedad
where
  situacion = 'alquilada'
order by
  zona;

-- Ejercicio 2
/* Listar los agentes y las propiedades que tienen asignadas actualmente. Mostrar nombre y apellido del agente, id y dirección de la propiedad. */
select
  p.nombre,
  p.apellido,
  prop.id,
  prop.direccion
from
  agente_asignado aa
  inner join persona p on aa.id_agente = p.id
  inner join propiedad prop on aa.id_propiedad = prop.id
where
  aa.fecha_hora_hasta is null;

-- Ejercicio 3
/* Listar todas las propiedades que tienen más de 2 dormitorios. Mostrar id, dirección, zona y cantidad de dormitorios. */
select
  p.id,
  p.direccion,
  p.zona,
  h.cantidad
from
  propiedad p
  inner join habitacion h on p.id = h.id_propiedad
  inner join tipo_habitacion th on h.id_tipo_habitacion = th.id
where
  th.nombre = 'dormitorio'
  and h.cantidad > 2;

-- Ejercicio 4
/* Listar los clientes que han solicitado un contrato en 2024. Mostrar nombre, apellido y fecha de solicitud. */
-- Ejercicio 5
/* Listar las propiedades que tienen jardín. Mostrar id, dirección y zona. */
-- Ejercicio 6
/* Listar todas las propiedades que hayan estado alquiladas en algún momento de 2023, mostrando dirección, zona, fecha de inicio y fin del contrato, y nombre y apellido del cliente. Ordenar por fecha de inicio descendente. */
-- Ejercicio 7
/* Listar los agentes que actualmente tienen asignadas propiedades en la zona 'Centro', mostrando nombre, apellido y dirección de la propiedad. */
-- Ejercicio 8
/* Listar los clientes que hayan solicitado contratos para propiedades en la zona 'Norte' y que el importe mensual sea mayor a $100000. Mostrar nombre, apellido, dirección de la propiedad e importe mensual. */
-- Ejercicio 9
/* Listar todas las propiedades que están disponibles para alquiler y que fueron construidas antes de 2010. Mostrar id, dirección, zona y año de construcción. Ordenar por año de construcción ascendente. */
-- Ejercicio 10
/* Listar las propiedades que tienen al menos una característica cuyo contenido sea 'no'. Mostrar dirección, zona y nombre de la característica. */
-- Ejercicio 11
/* Listar los clientes que han solicitado contratos para propiedades en la zona 'Sur' y que el estado de la solicitud sea 'rechazada'. Mostrar nombre, apellido, dirección de la propiedad y fecha de solicitud. */
-- Resoluciones
-- Ejercicio 1
SELECT
  id,
  direccion,
  zona,
  situacion
FROM
  propiedad
WHERE
  situacion = 'alquilada'
ORDER BY
  zona;

-- Ejercicio 2
SELECT
  per.nombre,
  per.apellido,
  p.id,
  p.direccion
FROM
  agente_asignado aa
  INNER JOIN persona per ON aa.id_agente = per.id
  INNER JOIN propiedad p ON aa.id_propiedad = p.id
WHERE
  aa.fecha_hora_hasta IS NULL;

-- Ejercicio 3
SELECT
  p.id,
  p.direccion,
  p.zona,
  h.cantidad AS dormitorios
FROM
  propiedad p
  INNER JOIN habitacion h ON p.id = h.id_propiedad
WHERE
  h.id_tipo_habitacion = 13001
  AND h.cantidad > 2;

-- Ejercicio 4
SELECT
  per.nombre,
  per.apellido,
  sc.fecha_solicitud
FROM
  solicitud_contrato sc
  INNER JOIN persona per ON sc.id_cliente = per.id
WHERE
  YEAR (sc.fecha_solicitud) = 2024;

-- Ejercicio 5
SELECT
  p.id,
  p.direccion,
  p.zona
FROM
  propiedad p
  INNER JOIN caracteristica_propiedad cp ON p.id = cp.id_propiedad
WHERE
  cp.id_caracteristica = 14002
  AND cp.contenido = 'si';

-- Ejercicio 6
SELECT
  p.direccion,
  p.zona,
  sc.fecha_contrato,
  sc.fecha_fin,
  per.nombre,
  per.apellido
FROM
  propiedad p
  INNER JOIN solicitud_contrato sc ON p.id = sc.id_propiedad
  INNER JOIN persona per ON sc.id_cliente = per.id
WHERE
  sc.estado = 'en alquiler'
  AND sc.fecha_contrato BETWEEN '2023-01-01' AND '2023-12-31'
ORDER BY
  sc.fecha_contrato DESC;

-- Ejercicio 7
SELECT
  per.nombre,
  per.apellido,
  p.direccion
FROM
  agente_asignado aa
  INNER JOIN persona per ON aa.id_agente = per.id
  INNER JOIN propiedad p ON aa.id_propiedad = p.id
WHERE
  aa.fecha_hora_hasta IS NULL
  AND p.zona = 'Centro';

-- Ejercicio 8
SELECT
  per.nombre,
  per.apellido,
  p.direccion,
  sc.importe_mensual
FROM
  solicitud_contrato sc
  INNER JOIN persona per ON sc.id_cliente = per.id
  INNER JOIN propiedad p ON sc.id_propiedad = p.id
WHERE
  p.zona = 'Norte'
  AND sc.importe_mensual > 100000;

-- Ejercicio 9
SELECT
  id,
  direccion,
  zona,
  anio_const
FROM
  propiedad
WHERE
  situacion = 'disponible'
  AND anio_const < 2010
ORDER BY
  anio_const ASC;

-- Ejercicio 10
SELECT
  p.direccion,
  p.zona,
  c.nombre AS caracteristica
FROM
  propiedad p
  INNER JOIN caracteristica_propiedad cp ON p.id = cp.id_propiedad
  INNER JOIN caracteristica c ON cp.id_caracteristica = c.id
WHERE
  cp.contenido = 'no';

-- Ejercicio 11
SELECT
  per.nombre,
  per.apellido,
  p.direccion,
  sc.fecha_solicitud
FROM
  solicitud_contrato sc
  INNER JOIN persona per ON sc.id_cliente = per.id
  INNER JOIN propiedad p ON sc.id_propiedad = p.id
WHERE
  p.zona = 'Sur'
  AND sc.estado = 'rechazada';