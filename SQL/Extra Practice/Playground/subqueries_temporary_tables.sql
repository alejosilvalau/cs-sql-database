use afatse;

/* Las sub-consultas pueden reemplazar el uso de variables */
/* Buscar los alumnos de Marketing 1 que tuvieron una nota mayor al promedio de las evaluaciones */
-- Usando variables
select
  avg(nota) into @promedio
from
  evaluaciones
where
  nom_plan = 'Marketing 1';

select
  alu.*,
  ev.nota
from
  evaluaciones ev
  inner join alumnos alu on ev.dni = alu.dni
where
  nom_plan = 'Marketing 1'
  and ev.nota > @promedio;

-- Usando sub-consulta
select
  alu.*,
  ev.nota
from
  evaluaciones ev
  inner join alumnos alu on ev.dni = alu.dni
where
  nom_plan = 'Marketing 1'
  and ev.nota > (
    select
      avg(nota)
    from
      evaluaciones
    where
      nom_plan = 'Marketing 1'
  );

select
  alu.*,
  ev.nota,
  (
    select
      avg(nota)
    from
      evaluaciones
    where
      nom_plan = 'Marketing 1'
  ) promedio
from
  evaluaciones ev
  inner join alumnos alu on ev.dni = alu.dni
where
  nom_plan = 'Marketing 1'
  and ev.nota > (
    select
      avg(nota)
    from
      evaluaciones
    where
      nom_plan = 'Marketing 1'
  );

/* Mostrar los alumnos de Marketing 1 cuya nota es mayor al promedio de las evaluciones del plan de dicha nota */
/* Ejemplo de subconsulta dependiente */
select
  alu.dni,
  alu.nombre,
  alu.apellido,
  ev.nom_plan,
  ev.nota,
  (
    select
      avg(nota)
    from
      evaluaciones ev_subc
    where
      ev_subc.nom_plan = ev.nom_plan
  ) promedio
from
  evaluaciones ev
  inner join alumnos alu on ev.dni = alu.dni
where
  ev.nota > (
    select
      avg(nota)
    from
      evaluaciones ev_subc
    where
      ev_subc.nom_plan = ev.nom_plan
  );

select
  alu.dni,
  alu.nombre,
  alu.apellido,
  ev.nom_plan,
  ev.nota,
  proms.prom promedio
from
  evaluaciones ev
  inner join alumnos alu on ev.dni = alu.dni
  inner join () proms on ev.nom_plan = proms.nom_plan
where
  ev.nota > proms.prom;

-- Usando tabla temporal
drop temporary table if exists promedios;

create temporary table promedios
select
  nom_plan,
  avg(nota) prom
from
  evaluaciones ev_subc
group by
  nom_plan;

select
  alu.dni,
  alu.nombre,
  alu.apellido,
  ev.nom_plan,
  ev.nota,
  proms.prom promedio
from
  evaluaciones ev
  inner join alumnos alu on ev.dni = alu.dni
  inner join promedios proms on ev.nom_plan = proms.nom_plan
where
  ev.nota > proms.prom;

-- Forma alternativa de crear tabla temporal
create temporary table if not exists promedios
select
  nom_plan,
  avg(nota) prom
from
  evaluaciones ev_subc
group by
  nom_plan;

/* Planes con mejor promedios de notas que Marketing 1 */
drop temporary table if exists promedios;

create temporary table promedios
select
  nom_plan,
  avg(nota) prom
from
  evaluaciones
group by
  nom_plan;

select
  prom into @prom_mkt1
from
  promedios proms
where
  nom_plan = 'Marketing 1';

select
  pc.*,
  proms.prom
from
  promedios proms
  inner join plan_capacitacion pc on proms.nom_plan = pc.nom_plan
where
  proms.prom > @prom_mkt1;

drop temporary table if exists promedios;