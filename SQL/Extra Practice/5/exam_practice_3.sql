/*
AD.A2- Estado camas. 

La empresa ha decidido que necesita más información sobre el estado 
de las camas. Se decidió separar del estado la situación de uso en 
una nueva columna y mantener esta información actualizada por medio de triggers.

Se requiere:
[X] - Agregar en la tabla cama la columna en_uso (utilizar el tipo de dato apropiado).
[X] - Reflejar el valor de dicha columna según esta regla. 
[X] - Si tiene un contrato en embarcacion_cama sin fecha y hora de baja de contrato
	está en uso. Caso contrario no lo está.
[X] - A través del uso de triggers al registrar un nuevo contrato de una embarcación 
	sin fecha y hora de baja de contrato cambiar el valor de la columna 
    en_uso para reflejar que se encuentra utilizada y al registrar una fecha 
    y hora de baja de contrato reflejar que se encuentra libre.

[X] Usa los siguientes datos para probar
[X] - insert into embarcacion_cama values ('ESP010',2,8,now(),null);
[X] - update embarcacion_cama set fecha_hora_baja_contrato=now() where 
	hin='ESP010' and fecha_hora_baja_contrato is null;
*/

alter table cama add column en_uso bool;

start transaction;

-- Actualización en uso 
update cama c 
inner join embarcacion_cama ec on
	c.codigo_sector = ec.codigo_sector and
    c.numero = ec.numero_cama
set en_uso = true
where fecha_hora_baja_contrato is null;

-- Actualización libre
update cama 
set en_uso = false
where en_uso is null;

-- Cambio de tipo de dato de columna "en_uso"
ALTER TABLE `guarderia_gaghiel_mod`.`cama` 
CHANGE COLUMN `en_uso` `en_uso` TINYINT(1) NOT NULL ;

-- Trigger de actualización de uso
DROP TRIGGER IF EXISTS `guarderia_gaghiel_mod`.`embarcacion_cama_AFTER_INSERT`;

DELIMITER $$
USE `guarderia_gaghiel_mod`$$
CREATE DEFINER = CURRENT_USER TRIGGER `guarderia_gaghiel_mod`.`embarcacion_cama_AFTER_INSERT` 
AFTER INSERT ON `embarcacion_cama` FOR EACH ROW
BEGIN
update cama c 
inner join embarcacion_cama ec on
	c.codigo_sector = ec.codigo_sector and
    c.numero = ec.numero_cama
set en_uso = true
where 
	fecha_hora_baja_contrato is null and 
    ec.hin = new.hin and
    ec.codigo_sector = new.codigo_sector and
    ec.fecha_hora_contrato = new.fecha_hora_contrato;
END$$
DELIMITER ;

-- Trigger de actualización libre  
DROP TRIGGER IF EXISTS `guarderia_gaghiel_mod`.`embarcacion_cama_AFTER_UPDATE`;

DELIMITER $$
USE `guarderia_gaghiel_mod`$$
CREATE DEFINER = CURRENT_USER TRIGGER `guarderia_gaghiel_mod`.`embarcacion_cama_AFTER_UPDATE` AFTER UPDATE ON `embarcacion_cama` FOR EACH ROW
BEGIN
update cama c 
inner join embarcacion_cama ec on
	c.codigo_sector = ec.codigo_sector and
    c.numero = ec.numero_cama
set en_uso = false
where 
	fecha_hora_baja_contrato is not null and 
    ec.hin = new.hin and
    ec.codigo_sector = new.codigo_sector and
    ec.fecha_hora_contrato = new.fecha_hora_contrato;
END$$
DELIMITER ;

commit;

-- Prueba
start transaction;

insert into embarcacion_cama values ('ESP010',2,8,now(),null);

update embarcacion_cama set fecha_hora_baja_contrato=now() where 
	hin='ESP010' and fecha_hora_baja_contrato is null;

rollback;

-- Comprobar las modificaciones de los triggers
select * 
from cama c 
inner join embarcacion_cama ec on 
	c.numero = ec.numero_cama and 
    c.codigo_sector = ec.codigo_sector
where c.codigo_sector = 2 and c.numero = 8;