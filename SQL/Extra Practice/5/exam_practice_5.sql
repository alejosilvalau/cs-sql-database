/*
AD.B2- Embarcaciones almacenadas. 

La empresa ha detectado dificultad para identificar si las 
embarcaciones se encuentran almacenadas o no a la hora de cierre. 

Por este motivo se ha decidido agregar una columna “almacenada” 
en la tabla embarcación que refleje la situación y automatizar 
con triggers el estado de dicha columna.

Se requiere:

[X] - Crear una columna almacenada para reflejar el estado (utilizar el
tipo de dato que crea apropiado).

[X] - Cargar el valor inicial de la columna. Las embarcaciones que no
tengan una salida con fecha y hora de regreso real en null está
almacenadas.

- A través del uso de triggers al registrar una nueva salida de una
embarcación cambiar el valor de la columna almacenada para
reflejar que salió y al registrar una fecha y hora de regreso
real reflejar que se encuentra almacenada.

- Puede usar los siguientes datos para probar:
- - insert into salida values ('can002',now(),'20241202T200000',null);
- - update salida set fecha_hora_regreso_real=now() where fecha_hora_regreso_real is null;
*/

-- A mano
alter table embarcacion add column almacenada boolean;

-- Con MySQL Workbench 
ALTER TABLE `guarderia_gaghiel_mod`.`embarcacion` 
ADD COLUMN `almacenada` TINYINT NULL AFTER `numero_socio`;

start transaction;

-- Cargar el valor inicial de la columna
update embarcacion e
set almacenada = true
where not exists (
    select 1
    from salida s
    where s.hin = e.hin
    and s.fecha_hora_regreso_real is null
);

-- Actualización de las demás filas    
update embarcacion e 
set almacenada = false
where almacenada is null; 

commit;

alter table embarcacion modify column almacenada bool not null;

-- Trigger al crear nueva salida
DROP TRIGGER IF EXISTS `guarderia_gaghiel_mod`.`salida_AFTER_INSERT`;

DELIMITER $$
USE `guarderia_gaghiel_mod`$$
CREATE DEFINER = CURRENT_USER TRIGGER `guarderia_gaghiel_mod`.`salida_AFTER_INSERT` AFTER INSERT ON `salida` FOR EACH ROW
BEGIN
update embarcacion e
set almacenada = false
where 
	new.hin = e.hin and
    new.fecha_hora_regreso_real is null;
END$$
DELIMITER ; 

-- Trigger al actualizar salida
DROP TRIGGER IF EXISTS `guarderia_gaghiel_mod`.`salida_AFTER_UPDATE`;

DELIMITER $$
USE `guarderia_gaghiel_mod`$$
CREATE DEFINER = CURRENT_USER TRIGGER `guarderia_gaghiel_mod`.`salida_AFTER_UPDATE` AFTER UPDATE ON `salida` FOR EACH ROW
BEGIN
update embarcacion e
set almacenada = true
where 
	new.hin = e.hin and
    new.fecha_hora_regreso_real is not null;
END$$
DELIMITER ;

-- Pruebas
start transaction;

insert into salida values ('can002',now(),'20241202T200000',null);

update salida set fecha_hora_regreso_real=now() where fecha_hora_regreso_real is null;

select * from embarcacion;

commit;
