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

-- Store procedures y functions
-- Práctica 10, ejercicio 7
/* Crear una función llamada alumnos_deudas_a_fecha que dado un alumno y
 una fecha indique cuantas cuotas adeuda a la fecha. */
USE `afatse_mod`;

DROP function IF EXISTS `alumnos_deudas_a_fecha`;

DELIMITER $ $ USE `afatse_mod` $ $ CREATE FUNCTION `alumnos_deudas_a_fecha` (p_dni int, p_fecha date) RETURNS INTEGER reads sql data BEGIN declare v_cuotas_adeudadas int;

select
  count(1) into v_cuotas_adeudadas
from
  cuotas
where
  dni = p_dni
  and fecha_emision <= p_fecha
  and fecha_pago is null;

return v_cuotas_adeudadas;

END $ $ DELIMITER;

-- Prueba de función
select
  alumnos_deudas_a_fecha(24242424, '2023-06-30') as cuotas_adeudadas;

select
  nombre,
  dni,
  alumnos_deudas_a_fecha(dni, current_timestamp) as cuotas_adeudadas
from
  alumnos;

-- Práctica 10, ejercicio 11
USE `afatse_mod`;

DROP procedure IF EXISTS `stock_movimiento`;

DELIMITER $ $ USE `afatse_mod` $ $ CREATE PROCEDURE `stock_movimiento` (
  in cod_mat char(6),
  in cant_movida integer(11),
  out stock integer(11)
) BEGIN declare url varchar(50);

start transaction;

select
  url_descarga into url
from
  materiales
where
  cod_material = cod_mat;

if url is null then
update
  materiales
set
  cant_disponible = cant_disponible + cant_movida
where
  cod_material = cod_mat;

end if;

SELECT
  cant_disponible INTO stock
FROM
  materiales
WHERE
  cod_material = cod_mat;

if stock >= 0 then commit;

else rollback;

select
  cant_disponible into stock
from
  materiales
where
  cod_material = cod_mat;

end if;

END $ $ DELIMITER;

USE `afatse_mod`;

DROP procedure IF EXISTS `stock_ingreso`;

DELIMITER $ $ USE `afatse_mod` $ $ CREATE PROCEDURE `stock_ingreso` (
  in p_cod_mat char(6),
  in p_cant_movida integer(11),
  out p_stock integer(11)
) BEGIN call stock_movimiento(p_cod_mat, p_cant_movida, p_stock);

END $ $ DELIMITER;

USE `afatse_mod`;

DROP procedure IF EXISTS `afatse_mod`.`stock_egreso`;

;

DELIMITER $ $ USE `afatse_mod` $ $ CREATE DEFINER = `root` @`localhost` PROCEDURE `stock_egreso`(
  in p_cod_mat char(6),
  in p_cant_movida integer(11),
  out p_stock integer(11)
) BEGIN call stock_movimiento(p_cod_mat, (-1) * p_cant_movida, p_stock);

END $ $ DELIMITER;

;

-- Prueba de procedimientos
select
  *
from
  materiales;

SET
  @stock_final = 0;

call stock_ingreso('ut-001', 10, @stock_final);

select
  @stock_final as stock_final;

call stock_egreso('ut-001', 5, @stock_final);

select
  @stock_final as stock_final;