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

start transaction;

-- Insert común
-- Insert select
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
-- Update select
rollback;