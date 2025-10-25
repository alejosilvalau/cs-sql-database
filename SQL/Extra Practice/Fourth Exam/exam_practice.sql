-- Practica 8
/* 1) Agregar el nuevo instructor Daniel Tapia con cuil: 44-44444444-4,
 teléfono: 444444444, email: dotapia@gmail.com, dirección
 Ayacucho 4444 y sin supervisor. */
start transaction;

insert into
  instructores
values
  (
    "44-44444444-4",
    "Daniel",
    "Tapia",
    "444-444444",
    "dotapia@gmail.com",
    "Ayacucho 4444",
    null
  );

select
  *
from
  instructores;

commit;

/* 3) Como resultado de una mudanza a otro edificio más grande se ha incrementado la
 capacidad de los salones, además la experiencia que han adquirido los instructores
 permite ampliar el cupo de los cursos.

 Para todos los curso con modalidad presencial y semipresencial aumentar
 el cupo de la siguiente forma:
 ● 50% para los cursos con cupo menor a 20
 ● 25% para los cursos con cupo mayor o igual a 20*/
select
  cur.nom_plan,
  cur.nro_curso,
  pla.modalidad,
  cur.cupo
from
  plan_capacitacion pla
  inner join cursos cur on pla.nom_plan = cur.nom_plan
where
  pla.modalidad in ('Presencial', 'Semipresencial');

start transaction;

update
  cursos cur
set
  cur.cupo = cur.cupo * 1.25
where
  cur.cupo >= 20
  and cur.nom_plan in (
    select
      nom_plan
    from
      plan_capacitacion
    where
      modalidad in ('Presencial', 'Semipresencial')
  );

update
  cursos cur
set
  cur.cupo = cur.cupo * 1.50
where
  cur.cupo < 20
  and cur.nom_plan in (
    select
      nom_plan
    from
      plan_capacitacion
    where
      modalidad in ('Presencial', 'Semipresencial')
  );

rollback;

commit;

/* 6) El alumno Victor Hugo se ha mudado. Actualizar su dirección
 a Italia 2323 y su teléfono nuevo es 3232323. */
select
  dni into @dni_v
from
  alumnos
where
  nombre = 'Victor'
  and apellido = 'Hugo';

start transaction;

update
  alumnos
set
  direccion = 'Italia 2323',
  tel = '3232323'
where
  dni = @dni_v;

commit;

select
  *
from
  alumnos
where
  dni = @dni_v;

/* 8)  Eliminar los nuevos apuntes AP-008 y AP-009.  Ayuda: Tener en cuenta las CF para poder eliminarlo. */
select
  *
from
  materiales_plan
where
  cod_material in ('AP-008', 'AP-009');

select
  *
from
  proveedores_materiales
where
  cod_material in ('AP-008', 'AP-009');

select
  *
from
  materiales
where
  cod_material in ('AP-008', 'AP-009');

start transaction;

delete from
  materiales
where
  cod_material in ('AP-008', 'AP-009');

rollback;

commit;

/* Cosas Random */
start transaction;

delete from
  instructores
where
  cuil = '30-30303030-3';

delete from
  instructores
where
  cuil = '99-99999999-9';

select
  *
from
  instructores;

rollback;

/* 10) Eliminar los inscriptos al curso de
 Marketing 3 curso numero 1. */
select
  *
from
  inscripciones
where
  nro_curso = 1
  and nom_plan = 'Marketing 3';

start transaction;

delete from
  inscripciones
where
  nro_curso = 1
  and nom_plan = 'Marketing 3';

rollback;

/*
 11) Eliminar los instructores que tienen de supervisor a Elias Yanes (CUIL 99-99999999-9)

 12) Ídem 11) pero usar una variable para obtener el CUIL de Elias Yanes.
 */
select
  cuil into @cuil_ey
from
  instructores
where
  cuil = '99-99999999-9';

select
  @cuil_ey;

select
  *
from
  instructores
where
  cuil_supervisor = @cuil_ey;

start transaction;

delete from
  instructores
where
  cuil_supervisor = @cuil_ey;

rollback;

/* 13) Eliminar todos los apuntes que tengan
 como autora o coautora a Erica de Forifregoro  */
select
  *
from
  materiales
where
  autores like '%Erica de Forifregoro%';

select
  *
from
  materiales_plan
where
  cod_material = 'AP-006';

select
  *
from
  proveedores_materiales
where
  cod_material = 'AP-006';

start transaction;

delete from
  materiales_plan
where
  cod_material = 'AP-006';

delete from
  materiales
where
  autores like '%Erica de Forifregoro%';

rollback;