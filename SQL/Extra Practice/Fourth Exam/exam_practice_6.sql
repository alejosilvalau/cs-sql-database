use inmobiliaria_calciferhowl_mod;

-- Repaso práctica 8, 9, 10 y 11
select
  *
from
  proveedores;

select
  *
from
  cursos_horarios
where
  nom_plan = 'Marketing 3';

select
  *
from
  cursos;

select
  *
from
  tipo_habitacion;

select
  *
from
  habitacion;

select
  *
from
  valor_propiedad;

select
  *
from
  propiedad;

start transaction;

-- Insert común
insert into
  valor_propiedad (id_propiedad, fecha_hora_desde, valor)
values
  (12001, CURRENT_TIMESTAMP, 3000000);

-- Insert select
insert into
  valor_propiedad (id_propiedad, fecha_hora_desde, valor)
select
  id,
  CURRENT_TIMESTAMP,
  10
from
  propiedad;

-- Delete común
delete from
  habitacion
where
  id_tipo_habitacion = 13001;

delete from
  tipo_habitacion
where
  id = 13001;

-- Delete join
delete h
from
  habitacion h
  inner join tipo_habitacion th on h.id_tipo_habitacion = th.id
where
  th.nombre = 'Dormitorio';

-- Update común
update
  valor_propiedad
set
  valor = 2000000
where
  id_propiedad = 12001;

-- Update join
update
  propiedad p
  inner join valor_propiedad vp on p.id = vp.id_propiedad
set
  p.direccion = 'Calle Falsa 123'
where
  vp.valor < 500000;

rollback;