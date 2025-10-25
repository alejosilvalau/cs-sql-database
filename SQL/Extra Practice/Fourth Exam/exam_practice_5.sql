-- Practica 11: triggers
use afatse_mod;

/* Ejercicio 1 */
-- Prueba de código de trigger antes de crearlo
start transaction;

insert into
  alumnos_historico(
    dni,
    fecha_hora_cambio,
    nombre,
    apellido,
    tel,
    direccion,
    usuario_modificacion
  )
values
  (
    10101010,
    CURRENT_TIMESTAMP,
    'Juan',
    'Perez',
    '123456789',
    'Calle Falsa 123',
    '123456789'
  );

insert into
  alumnos_historico(
    dni,
    fecha_hora_cambio,
    nombre,
    apellido,
    tel,
    direccion,
    usuario_modificacion
  )
values
  (
    43644910,
    CURRENT_TIMESTAMP,
    'Juan',
    'Perez',
    '123456789',
    'Calle Falsa 123',
    '123456789'
  );

rollback;

select
  *
from
  alumnos;

select
  *
from
  alumnos_historico;

-- Código del trigger de inserción
DROP TRIGGER IF EXISTS `afatse_mod`.`alumnos_after_ins_tr`;

DELIMITER $ $ USE `afatse_mod` $ $ CREATE DEFINER = CURRENT_USER TRIGGER `afatse_mod`.`alumnos_after_ins_tr`
AFTER
INSERT
  ON `alumnos` FOR EACH ROW BEGIN
insert into
  alumnos_historico(
    dni,
    fecha_hora_cambio,
    nombre,
    apellido,
    tel,
    direccion,
    usuario_modificacion
  )
values
  (
    new.dni,
    current_timestamp,
    new.nombre,
    new.apellido,
    new.tel,
    new.direccion,
    current_user
  );

END $ $ DELIMITER;

-- Código de trigger de actualización
DROP TRIGGER IF EXISTS `afatse_mod`.`alumnos_before_upd_tr`;

DELIMITER $ $ USE `afatse_mod` $ $ CREATE DEFINER = CURRENT_USER TRIGGER `afatse_mod`.`alumnos_before_upd_tr` BEFORE
UPDATE
  ON `alumnos` FOR EACH ROW BEGIN
insert into
  alumnos_historico(
    dni,
    fecha_hora_cambio,
    nombre,
    apellido,
    tel,
    direccion,
    usuario_modificacion
  )
values
  (
    new.dni,
    current_timestamp,
    new.nombre,
    new.apellido,
    new.tel,
    new.direccion,
    current_user
  );

END $ $ DELIMITER;

-- Prueba de método
call todos_los_alumnos();

-- Para ver los triggers creados en el information_schema
select
  *
from
  information_schema.triggers;

show triggers;

show triggers
from
  afatse_mod;

-- Prueba de trigger de inserción
start transaction;

insert into
  alumnos (dni, nombre, apellido, tel, email, direccion) value (
    17817615,
    'Beatriz',
    'Repetti',
    '0314-444444',
    'berep@hotmail.com',
    'Rioja 1212'
  );

select
  *
from
  alumnos;

select
  *
from
  alumnos_historico;

rollback;

commit;

-- Prueba de trigger de actualización
start transaction;

update
  alumnos
set
  direccion = 'Rioja 1111'
where
  dni = 17817615;

/* primero pruebo rollback */
rollback;

/* luego pruebo commit*/
commit;