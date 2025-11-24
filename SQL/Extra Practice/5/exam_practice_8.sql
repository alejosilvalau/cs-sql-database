/*
REC.3- Consistencia de datos. 

Se detectó una redundancia entre los campos sector.tipo_operacion 
con valores: “Manual” y “Automático” y tipo_embarcacion.operacion_requerida 
con valores: “Manual” y “Automática”. 

Ambos significan lo mismo pero al utilizarlos con una descripción 
los datos fueron cargados inconsistentes, se desea resolver esto y 
evitar que vuelva a suceder creando una entidad tipo_operacion con 
un código numérico autoincremental y una descripción. 

A tal efecto se requiere:
- Crear una nueva tabla operatoria con CP código autoincremental 
	y una descripción de texto.
- Corregir la inconsistencia entre los valores.
- Insertar los valores ya consistentes en la nueva tabla.
- Reemplazar las columnas descriptivas por una FK a la tabla 
	operatoria con los códigos adecuados
- Eliminar las columnas preexistentes.

Ayuda: 
- utilizar character set utf8mb4 y 
- collate utf8_unicode_ci para evitar errores;
*/

CREATE TABLE `guarderia_gaghiel_mod`.`tipo_operacion` (
  `codigo` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `descripcion` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`codigo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;

ALTER TABLE `guarderia_gaghiel_mod`.`sector` 
ADD COLUMN `codigo_tipo_operacion` INT UNSIGNED NULL AFTER `sectorcol`,
ADD INDEX `fk_sector_tipo_operacion_idx` (`codigo_tipo_operacion` ASC) VISIBLE;
;

ALTER TABLE `guarderia_gaghiel_mod`.`sector` 
ADD CONSTRAINT `fk_sector_tipo_operacion`
  FOREIGN KEY (`codigo_tipo_operacion`)
  REFERENCES `guarderia_gaghiel_mod`.`tipo_operacion` (`codigo`)
  ON DELETE RESTRICT
  ON UPDATE CASCADE;

ALTER TABLE `guarderia_gaghiel_mod`.`tipo_embarcacion` 
ADD COLUMN `codigo_tipo_operacion` INT UNSIGNED NULL AFTER `operacion_requerida`,
ADD INDEX `fk_tipo_embarcacion_tipo_operacion_idx` (`codigo_tipo_operacion` ASC) VISIBLE;
;

ALTER TABLE `guarderia_gaghiel_mod`.`tipo_embarcacion` 
ADD CONSTRAINT `fk_tipo_embarcacion_tipo_operacion`
  FOREIGN KEY (`codigo_tipo_operacion`)
  REFERENCES `guarderia_gaghiel_mod`.`tipo_operacion` (`codigo`)
  ON DELETE RESTRICT
  ON UPDATE CASCADE;

start transaction;

update tipo_embarcacion set operacion_requerida = 'Automático'
where operacion_requerida = 'Automática';

insert into tipo_operacion(descripcion)
select distinct operacion_requerida from tipo_embarcacion;

update sector s
inner join tipo_operacion tio on
	s.tipo_operacion = tio.descripcion
set s.codigo_tipo_operacion = tio.codigo;

update tipo_embarcacion te
inner join tipo_operacion tio on
	te.operacion_requerida = tio.descripcion
set te.codigo_tipo_operacion = tio.codigo;

commit;

ALTER TABLE `guarderia_gaghiel_mod`.`sector` 
DROP FOREIGN KEY `fk_sector_tipo_operacion`;
ALTER TABLE `guarderia_gaghiel_mod`.`sector` 
DROP COLUMN `tipo_operacion`,
CHANGE COLUMN `codigo_tipo_operacion` `codigo_tipo_operacion` INT UNSIGNED NOT NULL ;
ALTER TABLE `guarderia_gaghiel_mod`.`sector` 
ADD CONSTRAINT `fk_sector_tipo_operacion`
  FOREIGN KEY (`codigo_tipo_operacion`)
  REFERENCES `guarderia_gaghiel_mod`.`tipo_operacion` (`codigo`)
  ON DELETE RESTRICT
  ON UPDATE CASCADE;

ALTER TABLE `guarderia_gaghiel_mod`.`tipo_embarcacion` 
DROP FOREIGN KEY `fk_tipo_embarcacion_tipo_operacion`;
ALTER TABLE `guarderia_gaghiel_mod`.`tipo_embarcacion` 
DROP COLUMN `operacion_requerida`,
CHANGE COLUMN `codigo_tipo_operacion` `codigo_tipo_operacion` INT UNSIGNED NOT NULL ;
ALTER TABLE `guarderia_gaghiel_mod`.`tipo_embarcacion` 
ADD CONSTRAINT `fk_tipo_embarcacion_tipo_operacion`
  FOREIGN KEY (`codigo_tipo_operacion`)
  REFERENCES `guarderia_gaghiel_mod`.`tipo_operacion` (`codigo`)
  ON DELETE RESTRICT
  ON UPDATE CASCADE;
