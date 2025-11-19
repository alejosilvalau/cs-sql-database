-- Practica 9
/*Ejercicio 1 Crear una nueva lista de precios para todos los planes
 de capacitación, a partir del 01/06/2009 con un 20 por
 ciento más que su último valor. Eliminar las filas agregadas.*/
select
  *
from
  valores_plan
order by
  fecha_desde_plan;

select
  val.nom_plan,
  max(val.fecha_desde_plan) ult_fecha
from
  valores_plan val
group by
  val.nom_plan;

drop table if exists ult_val_plan;

create temporary table if not exists ult_val_plan
select
  val.nom_plan,
  max(val.fecha_desde_plan) ult_fecha
from
  valores_plan val
group by
  val.nom_plan;

start transaction;

insert into
  valores_plan(nom_plan, fecha_desde_plan, valor_plan)
select
  val.nom_plan,
  '20160601',
  val.valor_plan * 1.2
from
  valores_plan val
  inner join ult_val_plan ult on val.nom_plan = ult.nom_plan
  and val.fecha_desde_plan = ult.ult_fecha;

commit;

start transaction;

delete from
  valores_plan
where
  fecha_desde_plan = '20160601';

commit;

/* #eje3 Crear un nuevo plan: Marketing 1 Presen. Con los mismos
 datos que el plan Marketing 1 pero con modalidad presencial.
 Este plan tendrá los mismos temas, exámenes y materiales que
 Marketing 1 pero con un costo un 50% superior, para todos los
 períodos de este año (2014)que ya estén definidos costos del plan. */
start transaction;

insert into
  plan_capacitacion
select
  'Marketing 1 Presen.',
  desc_plan,
  hs,
  'presencial'
from
  plan_capacitacion
where
  nom_plan = 'Marketing 1';

insert into
  plan_temas
select
  'Marketing 1 Presen.',
  titulo,
  detalle
from
  plan_temas
where
  nom_plan = 'Marketing 1';

insert into
  examenes
select
  'Marketing 1 Presen.',
  nro_examen
from
  examenes
where
  nom_plan = 'Marketing 1';

insert into
  examenes_temas
select
  'Marketing 1 Presen.',
  titulo,
  nro_examen
from
  examenes_temas
where
  nom_plan = 'Marketing 1';

insert into
  valores_plan
select
  'Marketing 1 Presen.',
  fecha_desde_plan,
  valor_plan * 1.5
from
  valores_plan
where
  nom_plan = 'Marketing 1';

commit;

SELECT
  i.cuil,
  i.cuil_supervisor,
  ci.nom_plan,
  ci.nro_curso,
  c.nom_plan,
  c.nro_curso,
  c.fecha_ini,
  h.nom_plan,
  h.nro_curso,
  h.hora_inicio
FROM
  instructores i
  INNER JOIN cursos_instructores ci ON ci.`cuil` = i.`cuil`
  INNER JOIN cursos c ON c.nom_plan = ci.nom_plan
  and c.nro_curso = ci.nro_curso
  INNER JOIN cursos_horarios h on c.nom_plan = h.nom_plan
  and c.nro_curso = h.nro_curso
WHERE
  i.apellido = 'Kafka'
  and i.nombre = 'Franz'
  and YEAR(c.fecha_ini) = 2015;

start transaction;

update
  cursos_horarios ch
  inner join cursos_instructores ci on h.nom_plan = ci.nom_plan
  and ch.nro_curso = ci.nro_curso
  inner join cursos c on ci.nom_plan = c.nom_plan
  and ci.nro_curso = c.nro_curso
set
  ch.hora_inicio = ADDTIME(ch.hora_inicio, -010000),
  ch.hora_fin = ADDTIME(ch.hora_fin, -010000)
where
  ci.cuil = '66-66666666-6'
  and ch.`hora_inicio` = '160000'
  and year(c.fecha_ini) = 2015;

commit;

/* 6) Eliminar los exámenes donde el promedio general de las evaluaciones
 sea menor a 5.5. Eliminar también los temas que sólo se evalúan en esos
 exámenes. Ayuda: Usar una tabla temporal para determinar el/los exámenes
 que cumplan en las condiciones y utilizar dichas tabla para los joins.
 Tener en cuenta las CF para poder eliminarlos.  */
drop temporary table if exists exa_elim;

create temporary table if not exists exa_elim (
  select
    nom_plan,
    nro_examen,
    avg(nota) prom
  from
    evaluaciones
  group by
    nom_plan,
    nro_examen
  having
    avg(nota) < 5.5
);

start transaction;

delete ev,
et
from
  evaluaciones ev
  inner join exa_elim on ev.nom_plan = exa_elim.nom_plan
  and ev.nro_examen = exa_elim.nro_examen
  inner join examenes_temas et on ev.nom_plan = et.nom_plan
  and ev.nro_examen = et.nro_examen;

select
  *
from
  evaluaciones
  inner join exa_elim on evaluaciones.nom_plan = exa_elim.nom_plan
  and evaluaciones.nro_examen = exa_elim.nro_examen;

select
  *
from
  examenes_temas
  inner join exa_elim on examenes_temas.nom_plan = exa_elim.nom_plan
  and examenes_temas.nro_examen = exa_elim.nro_examen;

rollback;