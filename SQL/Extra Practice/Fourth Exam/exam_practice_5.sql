-- Practica 11: triggers
use afatse_mod;

/* Ejercicio 1 */
-- Prueba de código de trigger antes de crearlo
CREATE TABLE `alumnos_historico` (
  `dni` int NOT NULL,
  `fecha_hora_cambio` datetime NOT NULL,
  `nombre` varchar(20) DEFAULT NULL,
  `apellido` varchar(20) DEFAULT NULL,
  `tel` varchar(20) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `direccion` varchar(50) DEFAULT NULL,
  `usuario_modificacion` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`dni`, `fecha_hora_cambio`),
  CONSTRAINT `alumnos_historico_alumnos_fk` FOREIGN KEY (`dni`) REFERENCES `alumnos` (`dni`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb3;

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

-------------------------------------------------------------------
-- Ejercicio 2
USE `afatse_mod`;

CREATE TABLE `stock_movimientos` (
  `cod_material` char(6) NOT NULL,
  `fecha_movimiento` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `cantidad_movida` int(11) NOT NULL,
  `cantidad_restante` int(11) NOT NULL,
  `usuario_movimiento` varchar(50) NOT NULL,
  PRIMARY KEY (`cod_material`, `fecha_movimiento`),
  CONSTRAINT `stock_movimientos_fk` FOREIGN KEY (`cod_material`) REFERENCES `materiales` (`cod_material`) ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

-- Trigger de inserción
DROP TRIGGER IF EXISTS `afatse_mod`.`materiales_after_ins_tr2`;

DELIMITER $ $ USE `afatse_mod` $ $ CREATE DEFINER = `root` @`localhost` TRIGGER `materiales_after_ins_tr2`
AFTER
INSERT
  ON `materiales` FOR EACH ROW BEGIN if new.cant_disponible is not null then
insert into
  stock_movimientos (
    cod_material,
    cant_movida,
    cantidad_restante,
    usuario_movimiento
  )
values
  (
    new.cod_material,
    new.cant_disponible,
    new.cant_disponible,
    current_user
  );

end if;

END $ $ DELIMITER;

-- Trigger de actualización
DROP TRIGGER IF EXISTS `afatse_mod`.`materiales_before_upd_tr`;

DELIMITER $ $ USE `afatse_mod` $ $ CREATE DEFINER = CURRENT_USER TRIGGER `afatse_mod`.`materiales_before_upd_tr` BEFORE
UPDATE
  ON `materiales` FOR EACH ROW BEGIN if new.cant_disponible is not null then if old.cant_disponible <> new.cant_disponible then
insert into
  stock_movimientos(
    cod_material,
    cantidad_movida,
    cantidad_restante,
    usuario_movimiento
  )
values
  (
    new.cod_material,
    new.cant_disponibleold.cant_disponible,
    new.cant_disponible,
    CURRENT_USER
  );

end if;

end if;

END $ $ DELIMITER;

-- Prueba de triggers
-- Verificación de tablas
select
  *
from
  materiales;

select
  *
from
  stock_movimientos;

-- Verificación de primer trigger (inserción)
start transaction;

INSERT INTO
  materiales (
    cod_material,
    desc_material,
    url_descarga,
    autores,
    tamanio,
    fecha_creacion,
    cant_disponible,
    punto_pedido,
    cantidad_a_pedir
  )
VALUES
  (
    'UT-005',
    'Lapiz',
    NULL,
    NULL,
    NULL,
    NULL,
    100,
    30,
    1000
  );

commit;
rollback;

-- Verificación de primer trigger (inserción)
start transaction;

update
  materiales
set
  desc_material = 'lapiz negro',
  cant_disponible = 0
where
  cod_material = 'UT-005';

commit;

-- Ejercicio 3







