use dsi_turnos;

-- Paso 2
SELECT
  *
FROM
  profesionales p
WHERE
  p.id_especialidad = '1';

SELECT
  *
FROM
  profesionales p
  inner join especialidades e on p.id_especialidad = e.id
WHERE
  e.denominacion = 'Cardiología';

-- Paso 3
SELECT
  *
FROM
  turnos t
WHERE
  t.id_profesional = '2'
  AND YEAR(t.fecha_hora_turno) = 2025
  AND MONTH(t.fecha_hora_turno) = 8;

SELECT
  *
FROM
  turnos t
  inner join profesionales p on t.id_profesional = p.id
WHERE
  p.apellido_nombre = 'Dra. Fernández, María Elena'
  AND YEAR(t.fecha_hora_turno) = 2025
  AND MONTH(t.fecha_hora_turno) = 8;