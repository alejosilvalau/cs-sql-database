select
  @ @autocommit;

start transaction;

insert into
  alumnos (dni, nombre, apellido, tel, email, direccion) value (
    16817618,
    'Clotilde',
    'Diez',
    11111111,
    'cloti@yahoo.com',
    'Rioja 2030'
  );

insert into
  inscripciones (
    nom_plan,
    nro_curso,
    dni,
    fecha_inscripcion
  ) value ('Marketing 3', 1, 16817618, current_date());

delete from inscripciones where dni = 16817618 and nom_plan = 'Marketing 3';

delete from alumnos where dni = 16817618;

select * from
  inscripciones
where
  dni = 16817618;

select * from
  alumnos
where
  dni = 16817618;

rollback;
commit;

set @@autocommit = 1;
select @@autocommit;
start transaction;



