use guarderia_gaghiel;

/* 303.4 - Embarcaciones que no renovaron contrato.Listar embarcaciones que hayan estado almacenadas el año pasado (según la fecha de contrato) pero no tengan contratos activos actualmente.Indicar hin,
 nombre y descripción de la embarcación.Ordenar por nombre.*/
select
  distinct e.hin,
  e.nombre,
  e.descripcion
from
  embarcacion_cama ec
  inner join embarcacion e on e.hin = ec.hin
where
  year(ec.fecha_hora_contrato) = (year(now()) - 1)
  and ec.hin not in (
    select
      ec_sub.hin
    from
      embarcacion_cama ec_sub
    where
      (
        ec_sub.fecha_hora_baja_contrato >= now()
        or ec_sub.fecha_hora_baja_contrato is null
      )
      and ec.hin = ec_sub.hin
  )
order by
  e.nombre;

/* 
 * 303.5 - Sectores con muchas embarcaciones.
 * Listar los sectores que tienen más embarcaciones almacenadas actualmente que el promedio de la cantidad 
 * de embarcaciones actualmente almacenadas en cada sector.Se deben tener en cuenta para el promedio los 
 * sectores que podrían no tener embarcaciones actualmente almacenadas.Indicar código, nombre, cantidad de embarcaciones actualmente almacenadas. */
drop temporary table if exists cant_total_sector;

create temporary table if not exists cant_total_sector
select
  s.codigo,
  s.nombre,
  count(ec.hin) as cantidad_sector
from
  sector s
  left join embarcacion_cama ec on ec.codigo_sector = s.codigo
where
  ec.fecha_hora_baja_contrato is null
  or ec.fecha_hora_baja_contrato > now()
group by
  s.codigo,
  s.nombre;

select
  avg(cantidad_sector) into @promedio
from
  cant_total_sector;

select
  codigo,
  nombre,
  cantidad_sector
from
  cant_total_sector
where
  cantidad_sector > @promedio;

drop temporary table if exists cant_total_sector;
/* 301.4 - Actividades recientes para realizar.
 * Listar las actividades de las que se vayan a realizar cursos 
 * a futuro pero no se haya realizado ninguno antes de este año.
 * Indicar número y nombre de la actividad.Ordenar por número 
 * de actividad ascendente.*/
-- Se consideró el año actual como 2024 para tener data de la base de datos
select
  distinct a.numero,
  a.nombre
from
  curso c
  inner join actividad a on c.numero_actividad = a.numero
where
  c.fecha_inicio >= '2024-01-01'
  and a.numero not in (
    select
      c_sub.numero_actividad
    from
      curso c_sub
    where
      c_sub.fecha_inicio < '2024-01-01'
      and c_sub.numero_actividad = a.numero
  )
order by
  a.numero;

/* 301.5 - Socios con más cursos.
 * Listar los socios que se inscribieron a más cursos en 2024 que el promedio 
 * de la cantidad de cursos a la que se inscribió cada socio durante el 2024.
 * Se debe considerar los socios que no se inscribieron a ningún curso en 2024 
 * dentro del cálculo del promedio.Indicar número, nombre del socio y 
 * cantidad de cursos que realiza en 2024.
 * Ordenar por cantidad de cursos descendente. */
drop temporary table if exists cant_ins_socios;

create temporary table if not exists cant_ins_socios
select
  s.numero,
  s.nombre,
  count(s.numero) cant_ins
from
  socio s
  left join inscripcion i on s.numero = i.numero_socio
where
  year(i.fecha_hora_inscripcion) = 2024
group by
  s.numero;

select
  avg(cant_ins) into @prom_cant_ins
from
  cant_ins_socios;

select
  numero,
  nombre,
  cant_ins
from
  cant_ins_socios
where
  cant_ins > @prom_cant_ins
order by
  cant_ins desc;

drop temporary table if exists cant_ins_socios;