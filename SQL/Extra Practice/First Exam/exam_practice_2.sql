use inmobiliaria_calciferhowl;

-- Ejercicio 1
/* Listar todas las propiedades alquiladas junto con sus agentes asignados actualmente. Indicar id y dirección de la propiedad, zona, nombre y apellido del agente, y fecha desde la que está asignado. Ordenar por zona alfabéticamente y fecha de asignación descendente. */
select
  p.id,
  p.direccion,
  p.zona,
  per.nombre,
  per.apellido,
  aa.fecha_hora_desde
from
  propiedad p
  inner join agente_asignado aa on p.id = aa.id_propiedad
  inner join persona per on aa.id_agente = per.id
where
  p.situacion = 'alquilada'
  and aa.fecha_hora_hasta is null
order by
  p.zona,
  aa.fecha_hora_desde desc;

-- Ejercicio 2
/* Listar todas las propiedades que tengan pileta y jardín. Mostrar dirección, zona, año de construcción. Ordenar por zona descendente. */
select
  p.direccion,
  p.zona,
  p.anio_const
from
  propiedad p
  inner join caracteristica_propiedad cp on p.id = cp.id_propiedad
  inner join caracteristica c on cp.id_caracteristica = c.id
where
  c.nombre in ('pileta', 'jardín')
order by
  p.zona desc;

-- Ejercicio 3
/* Listar todas las solicitudes de contrato que tienen al menos 2 garantías aprobadas. Mostrar id de la solicitud, fecha, importe mensual, nombre y apellido del cliente, dirección de la propiedad y cantidad de garantías aprobadas. Ordenar por fecha de solicitud descendente. */
-- Ejercicio 4
/* Listar todos los agentes que han atendido solicitudes de contrato en 2024 y que hayan finalizado en alquiler. Mostrar nombre y apellido del agente, cantidad de solicitudes convertidas en alquiler, y promedio de importe mensual. Ordenar por cantidad de alquileres descendente. */
select
  *
from
  persona p
  inner join solicitud_contrato sc on p.id = sc.id_agente;

-- Ejercicio 5
/* Listar todas las propiedades y sus propietarios, junto con los pagos recibidos en caso de estar alquiladas durante 2023. Mostrar dirección de la propiedad, nombre y apellido de los propietarios, estado de la propiedad. Ordenar por pagos descendiente y nombre alfabéticamente. */
select
  p.direccion,
  per.nombre,
  per.apellido,
  p.situacion,
  sc.importe_mensual
from
  propiedad p
  left join propietario_propiedad pp on p.id = pp.id_propiedad
  left join persona per on pp.id_propietario = per.id
  left join solicitud_contrato sc on p.id = sc.id_propiedad
  and fecha_contrato between '2023-01-01' and '2023-12-31'
order by
  sc.importe_mensual desc,
  per.nombre;

-- Ejercicio 6
/* Listar todos los clientes que tienen contratos de alquiler vigentes y si han tenido algún retraso en sus pagos (más de 5 días desde el día 10 del mes). Mostrar nombre y apellido del cliente, dirección de la propiedad, fecha de inicio del contrato y cantidad de pagos retrasados. Ordenar por cantidad de pagos retrasados descendente. */
select
  *
from
  persona
  inner join solicitud_contrato sc on persona.id = sc.id_cliente
where
  sc.estado = 'en alquiler';

-- Ejercicio 7
/* Listar todas las características disponibles y cuántas propiedades tienen cada una. Mostrar nombre de la característica, tipo y cantidad de propiedades. Ordenar por cantidad de propiedades descendente. */
-- Ejercicio 8
/* Listar los garantes que han participado en más de una solicitud de contrato, indicando su nombre y apellido, cantidad de solicitudes en las que participó, y cuántas fueron aprobadas y rechazadas. Ordenar por cantidad total de solicitudes descendente. */
-- Resoluciones
-- Ejercicio 1
SELECT
  p.id,
  p.direccion,
  p.zona,
  per.nombre,
  per.apellido,
  aa.fecha_hora_desde
FROM
  propiedad p
  INNER JOIN agente_asignado aa ON p.id = aa.id_propiedad
  AND aa.fecha_hora_hasta IS NULL
  INNER JOIN persona per ON aa.id_agente = per.id
WHERE
  p.situacion = 'alquilada'
ORDER BY
  p.zona ASC,
  aa.fecha_hora_desde DESC;

-- Ejercicio 2
SELECT
  p.direccion,
  p.zona,
  p.anio_const,
  (
    SELECT
      cantidad
    FROM
      habitacion h
    WHERE
      h.id_propiedad = p.id
      AND h.id_tipo_habitacion = 13001
  ) AS dormitorios,
  (
    SELECT
      cantidad
    FROM
      habitacion h
    WHERE
      h.id_propiedad = p.id
      AND h.id_tipo_habitacion = 13004
  ) AS baños
FROM
  propiedad p
  INNER JOIN caracteristica_propiedad cp1 ON p.id = cp1.id_propiedad
  AND cp1.id_caracteristica = 14001
  AND cp1.contenido = 'si'
  INNER JOIN caracteristica_propiedad cp2 ON p.id = cp2.id_propiedad
  AND cp2.id_caracteristica = 14002
  AND cp2.contenido = 'si'
ORDER BY
  p.zona,
  dormitorios DESC;

-- Ejercicio 3
SELECT
  sc.id,
  sc.fecha_solicitud,
  sc.importe_mensual,
  p_cliente.nombre,
  p_cliente.apellido,
  prop.direccion,
  COUNT(g.id_garante) AS cantidad_garantias
FROM
  solicitud_contrato sc
  INNER JOIN persona p_cliente ON sc.id_cliente = p_cliente.id
  INNER JOIN propiedad prop ON sc.id_propiedad = prop.id
  INNER JOIN garantia g ON sc.id = g.id_solicitud
  AND g.estado = 'aprobada'
GROUP BY
  sc.id,
  sc.fecha_solicitud,
  sc.importe_mensual,
  p_cliente.nombre,
  p_cliente.apellido,
  prop.direccion
HAVING
  COUNT(g.id_garante) >= 2
ORDER BY
  sc.fecha_solicitud DESC;

-- Ejercicio 4
SELECT
  p.nombre,
  p.apellido,
  COUNT(sc.id) AS cantidad_alquileres,
  AVG(sc.importe_mensual) AS promedio_alquiler
FROM
  persona p
  INNER JOIN solicitud_contrato sc ON p.id = sc.id_agente
WHERE
  YEAR (sc.fecha_solicitud) = 2024
  AND sc.estado = 'en alquiler'
GROUP BY
  p.id,
  p.nombre,
  p.apellido
ORDER BY
  cantidad_alquileres DESC;

-- Ejercicio 5
SELECT
  p.direccion,
  STRING_AGG (CONCAT (per.nombre, ' ', per.apellido), ', ') AS propietarios,
  p.situacion,
  COALESCE(SUM(pago.importe), 0) AS total_pagos_2023
FROM
  propiedad p
  INNER JOIN propietario_propiedad pp ON p.id = pp.id_propiedad
  INNER JOIN persona per ON pp.id_propietario = per.id
  LEFT JOIN solicitud_contrato sc ON p.id = sc.id_propiedad
  AND sc.estado = 'en alquiler'
  LEFT JOIN pago ON sc.id = pago.id_solicitud
  AND YEAR (pago.fecha_hora_pago) = 2023
GROUP BY
  p.id,
  p.direccion,
  p.situacion
ORDER BY
  total_pagos_2023 DESC;

-- Ejercicio 6
SELECT
  per.nombre,
  per.apellido,
  p.direccion,
  sc.fecha_contrato,
  COUNT(
    CASE
      WHEN DAY (pago.fecha_hora_pago) > 15 THEN 1
    END
  ) AS pagos_retrasados
FROM
  persona per
  INNER JOIN solicitud_contrato sc ON per.id = sc.id_cliente
  INNER JOIN propiedad p ON sc.id_propiedad = p.id
  LEFT JOIN pago ON sc.id = pago.id_solicitud
  AND pago.concepto = 'pago alquiler'
WHERE
  sc.estado = 'en alquiler'
GROUP BY
  per.id,
  per.nombre,
  per.apellido,
  p.direccion,
  sc.fecha_contrato
ORDER BY
  pagos_retrasados DESC;

-- Ejercicio 7
SELECT
  c.nombre,
  c.tipo,
  COUNT(cp.id_propiedad) AS cantidad_propiedades
FROM
  caracteristica c
  LEFT JOIN caracteristica_propiedad cp ON c.id = cp.id_caracteristica
GROUP BY
  c.id,
  c.nombre,
  c.tipo
ORDER BY
  cantidad_propiedades DESC;

-- Ejercicio 8
SELECT
  per.nombre,
  per.apellido,
  COUNT(g.id_solicitud) AS total_solicitudes,
  SUM(
    CASE
      WHEN g.estado = 'aprobada' THEN 1
      ELSE 0
    END
  ) AS solicitudes_aprobadas,
  SUM(
    CASE
      WHEN g.estado = 'rechazada' THEN 1
      ELSE 0
    END
  ) AS solicitudes_rechazadas
FROM
  persona per
  INNER JOIN garantia g ON per.id = g.id_garante
GROUP BY
  per.id,
  per.nombre,
  per.apellido
HAVING
  COUNT(g.id_solicitud) > 1
ORDER BY
  total_solicitudes DESC;