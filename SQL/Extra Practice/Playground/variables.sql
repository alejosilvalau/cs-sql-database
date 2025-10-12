use afatse;

set
  @a := 10;

set
  @b := 20;

set
  @c := 'esto es tipo char en mysql';

select
  @a,
  @c;

/* Buscar el mínimo y máximo de las notas del curso de Marketing 1 y del segundo examen */
select
  @min := min(nota),
  @max := max(nota)
from
  evaluaciones
where
  nom_plan = 'Marketing 1'
  and nro_examen = 2;

select
  ev.dni,
  alu.nombre,
  alu.apellido,
  ev.nota
from
  evaluaciones ev
  inner join alumnos alu on ev.dni = alu.dni
where
  ev.nota in (@min, @max)
  and nom_plan = 'Marketing 1'
  and nro_examen = 2;

select
  min(nota),
  max(nota) into @min,
  @max
from
  evaluaciones
where
  nom_plan = 'Marketing 1'
  and nro_examen = 2;

/* Cual es la ventaja de usar into? */
select
  nro_examen,
  @min := min(nota),
  @max := max(nota)
from
  evaluaciones
where
  nom_plan = 'Marketing 1'
group by
  nom_plan,
  nro_examen;

-- Las variables solo guardan el resultado de la última asignación
select
  @min,
  @max;

-- Esto da error porque la query devuelve más de un registro, lo cual es una ventaja sobre la asignación en select
select
  min(nota),
  max(nota) into @min,
  @max
from
  evaluaciones
where
  nom_plan = 'Marketing 1'
group by
  nom_plan,
  nro_examen;

/* Ordenar los alumnos de Marketing 1 por nota y
 fecha de evolución descendientes y numerarlos según ese orden */
set
  @i := 0;

select
  @i := @i + 1 as posicion,
  -- antes de mostrar el valor, se calcula la expresión y se asigna
  alu.*,
  ev.nota
from
  evaluaciones ev
  inner join alumnos alu on ev.dni = alu.dni
where
  nom_plan = 'Marketing 1'
order by
  ev.nota desc,
  ev.fecha_evaluacion desc;