/*
REC.2- Mejoras al modelo. 

Tras haber utilizado nuestro sistema algún tiempo se ha 
detectado una nueva necesidad de la empresa.

Las actividades deben poder asociarse a más de un tipo de
embarcación. Actualmente es una relación 1aN y debe ser
modificada a una NaM.

Para ello se requiere realizar los siguientes cambios al modelo:
- Implementar los cambios necesarios en el modelo para este cambio.
- Migrar los datos de la relación actual a la nueva.
- Eliminar la relación 1aN existente.
*/

CREATE TABLE `guarderia_gaghiel_mod`.`actividad_tipo_embarcacion` (
  `codigo_tipo_embarcacion` INT UNSIGNED NOT NULL,
  `numero_actividad` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`codigo_tipo_embarcacion`, `numero_actividad`),
  INDEX `fk_actividad_tipo_embarcacion_actividad_idx` (`numero_actividad` ASC) VISIBLE,
  CONSTRAINT `fk_actividad_tipo_embarcacion_actividad`
    FOREIGN KEY (`numero_actividad`)
    REFERENCES `guarderia_gaghiel_mod`.`actividad` (`numero`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_actividad_tipo_embarcacion_tipo_embarcacion`
    FOREIGN KEY (`codigo_tipo_embarcacion`)
    REFERENCES `guarderia_gaghiel_mod`.`tipo_embarcacion` (`codigo`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE);
    
start transaction;

insert into actividad_tipo_embarcacion
select codigo_tipo_embarcacion, numero
from actividad;

commit;

ALTER TABLE `guarderia_gaghiel_mod`.`actividad` 
DROP FOREIGN KEY `fk_actividad_tipo_embarcacion`;
ALTER TABLE `guarderia_gaghiel_mod`.`actividad` 
DROP COLUMN `codigo_tipo_embarcacion`,
DROP INDEX `fk_actividad_tipo_embarcacion_idx` ;
;

-- Prueba
select * from actividad_tipo_embarcacion;

insert into actividad_tipo_embarcacion values (5, 1);

select * 
from actividad_tipo_embarcacion ate
inner join actividad a on
	ate.numero_actividad = a.numero
inner join tipo_embarcacion te on
	ate.codigo_tipo_embarcacion = te.codigo
where a.numero = 1;