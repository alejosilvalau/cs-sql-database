-- use afatse;
/* Alumnos que se inscribieron en 2014 pero no en 2015 */
select
  *
from
  inscripciones
where
  year(fecha_inscripcion) = 2015
order by
  dni;

select
  *
from
  inscripciones ins
where
  year(ins.fecha_inscripcion) = 2014
  and year(ins.fecha_inscripcion) <> 2015
order by
  ins.dni;

select
  distinct alu.*
from
  alumnos alu
  inner join inscripciones ins on alu.dni = ins.dni
where
  year(ins.fecha_inscripcion) = 2014
  and ins.dni not in (
    select
      ins_sub.dni
    from
      inscripciones ins_sub
    where
      year(ins_sub.fecha_inscripcion) = 2015
  );

-- Otra solución
drop temporary table if exists inscripciones_2015;

create temporary table inscripciones_2015
select
  ins_sub.dni
from
  inscripciones ins_sub
where
  year(ins_sub.fecha_inscripcion) = 2015;

select
  dni
from
  inscripciones_2015;

select
  distinct alu.*
from
  alumnos alu
  inner join inscripciones ins on alu.dni = ins.dni
where
  year(ins.fecha_inscripcion) = 2014
  and ins.dni not in (
    select
      dni
    from
      inscripciones_2015
  );

-- Solución con subconsulta dependiente
select
  distinct alu.*
from
  alumnos alu
  inner join inscripciones ins on alu.dni = ins.dni
where
  year(ins.fecha_inscripcion) = 2014
  and ins.dni not in (
    select
      ins_sub.dni
    from
      inscripciones ins_sub
    where
      year(ins_sub.fecha_inscripcion) = 2015
      and ins.dni = ins_sub.dni
  );

-- Solución con not exists
select
  distinct alu.*
from
  alumnos alu
  inner join inscripciones ins on alu.dni = ins.dni
where
  year(ins.fecha_inscripcion) = 2014
  and not exists (
    select
      1
    from
      inscripciones ins_sub
    where
      year(ins_sub.fecha_inscripcion) = 2015
      and ins.dni = ins_sub.dni
  );

-- Solución con LEFT JOIN
select
  DISTINCT alu.*
from
  alumnos alu
  inner join inscripciones ins_2014 on alu.dni = ins_2014.dni
  and year(ins_2014.fecha_inscripcion) = 2014
  left join inscripciones ins_2015 on alu.dni = ins_2015.dni
  and year(ins_2015.fecha_inscripcion) = 2015
where
  ins_2015.dni is null;