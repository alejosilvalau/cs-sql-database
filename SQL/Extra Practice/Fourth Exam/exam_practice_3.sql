select
  *
from
  evaluaciones;

select
  *,
  cuadrado(nota),
  mejor_nota(nom_plan, nro_examen),
  nota
from
  evaluaciones;

-- Video de Meca
drop temporary table if exists mejores;

create temporary table mejores
select
  nom_plan,
  nro_examen,
  max(nota) max_nota
from
  evaluaciones
where
  fecha_evaluacion between '1990-01-01'
  and '2020-12-31'
group by
  nom_plan,
  nro_examen;

select
  ev.dni,
  alu.nombre,
  alu.apellido,
  ev.nom_plan,
  ev.nro_examen,
  ev.nota,
  me.max_nota,
  ev.nota - me.max_nota diferencia
from
  evaluaciones ev
  inner join alumnos alu on alu.dni = ev.dni
  inner join mejores me on me.nom_plan = ev.nom_plan
  and me.nro_examen = ev.nro_examen;

call compara_evaluaciones('1990-01-01', '2025-12-31');

select
  @ @transaction_isolation;

set
  @hola = 1;

set
  @hola2 := 2;

select
  3 into @hola3;

select
  @hola4 := 4;

select
  @hola,
  @hola2,
  @hola3,
  @hola4;

-- Practica 10: Store Procedures y Funciones
/* Crear un procedimiento almacenado llamado plan_lista_precios_actual
 que devuelva los planes de capacitación indicando: nom_plan, modalidad, valor_actual */
drop temporary table if exists valor_actual;

create temporary table valor_actual
select
  nom_plan,
  max(fecha_desde_plan) ult_fecha
from
  valores_plan
group by
  nom_plan;

select
  pc.nom_plan,
  pc.modalidad,
  vp.valor_plan
from
  plan_capacitacion pc
  inner join valor_actual va on pc.nom_plan = va.nom_plan
  inner join valores_plan vp on va.nom_plan = vp.nom_plan
  and va.ult_fecha = vp.fecha_desde_plan;

drop temporary table if exists valor_actual;

call plan_lista_precios_actual();

select
  current_date(),
  now(),
  curdate();

/* 6) Crear un procedimiento almacenado llamado alumnos_pagos_deudas_a_fecha
 que dada una fecha y un alumno indique cuanto ha pagado hasta
 esa fecha y cuantas cuotas adeudaba a dicha fecha (cuotas emitidas y no pagadas).
 Devolver los resultados en parámetros de salida.  */
select
  sum(importe_pagado)
from
  cuotas
where
  dni = 10101010
  and fecha_pago is not null
  and fecha_emision <= '2023-06-30';

select
  count(1)
from
  cuotas
where
  dni = 24242424
  and fecha_pago is null
  and fecha_emision <= '2023-06-30';

SET
  @pagado := 0;

SET
  @adeuda := 0;

call alumnos_pagos_deudas_a_fecha('2023-06-30', 24242424, @pagado, @adeuda);

select
  @pagado,
  @adeuda;

/* 7) Crear una función llamada alumnos_deudas_a_fecha
 que dado un alumno y una fecha indique cuantas cuotas adeuda
 a la fecha. */
-- Declaración de función
/* DELIMITER $ $ CREATE DEFINER = `root` @`localhost` FUNCTION `alumnos_deudas_a_fecha`(p_dni int, p_fecha date) RETURNS int READS SQL DATA BEGIN declare cant_ade int;

 select
 count(1) into cant_ade
 from
 cuotas
 where
 dni = p_dni
 and fecha_pago is null
 and fecha_emision <= p_fecha;

 RETURN cant_ade;

 END $ $ DELIMITER;

 -- Prueba de función
 select
 distinct dni,
 alumnos_deudas_a_fecha(dni, curdate()) deuda
 from
 cuotas;*/
/* 8) Crear un procedimiento almacenado llamado alumno_inscripción
 que dados los datos de un alumno y un curso lo inscriba en dicho curso
 el día de hoy y genere la primera cuota con fecha de emisión hoy para
 el mes próximo. */
select
  *
from
  cuotas;

call alumno_inscripcion(11111111, 'Reparacion PC', 2);

select
  *
from
  cursos;

select
  *
from
  inscripciones;

-- Prueba de procedimiento
start transaction;

insert into
  inscripciones
values
  ('Reparacion PC', 2, 11111111, curdate());

insert into
  cuotas
values
  (
    'Reparacion PC',
    2,
    11111111,
    year(adddate(curdate(), interval 1 month)),
    month(adddate(curdate(), interval 1 month)),
    curdate(),
    null, null
  );

rollback;

select
  *
from
  inscripciones;









