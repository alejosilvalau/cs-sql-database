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