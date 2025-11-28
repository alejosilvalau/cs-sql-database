/*
A.AD03 - Registrar cambio en encargados. 

A menudo la empresa debe reasignar los encargados de un evento 
y luego es difícil saber quienes estuvieron a cargo de un evento 
y durante que período fueron desasignados o saber exactamente cuando 
y que rol usaron, también desea modificar las condiciones de los 
encargados ya que en los eventos más grandes y complejos está 
siendo difícil la gestión. 

Por este motivo la empresa necesita: 
1. Convertir el rol del encargado en una entidad rol con un 
id autoincremental y una descripción 

2. Migrar los roles actualmente registrados en encargado_evento a la 
endidad rol y reemplazar la columna rol por una CF al id de rol.

3. Registrar en encargado_evento la fecha de asignación obligatoria y 
fecha fin de asignación opcional. 

A los que se encuentran registrados actualmente asignarles la fecha 
del evento como fecha de asignación y sin fecha de fin. 

4. Ajustar la clave primaria según esta regla: 
	Un empleado puede ser asignado y desasignado a un evento una 
	o varias veces para desempeñar uno o más roles al mismo tiempo 
    o en momentos diferentes y varios empleados pueden desempeñar 
    el mismo rol simultáneamente. 
*/
-- 1.
CREATE TABLE `convenciones_underground_mod`.`rol` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `descripcion` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`));

-- 2.
start transaction;

insert into rol (descripcion)
select distinct rol from encargado_evento; 

commit;

ALTER TABLE `convenciones_underground_mod`.`encargado_evento` 
ADD COLUMN `id_rol` INT NULL AFTER `rol`,
ADD INDEX `fk_encargado_evento_rol_idx` (`id_rol` ASC) VISIBLE;
;
ALTER TABLE `convenciones_underground_mod`.`encargado_evento` 
ADD CONSTRAINT `fk_encargado_evento_rol`
  FOREIGN KEY (`id_rol`)
  REFERENCES `convenciones_underground_mod`.`rol` (`id`)
  ON DELETE RESTRICT
  ON UPDATE CASCADE;
  
start transaction;

update encargado_evento enc_eve
inner join rol on enc_eve.rol = rol.descripcion
set enc_eve.id_rol = rol.id;

commit;

ALTER TABLE `convenciones_underground_mod`.`encargado_evento` 
DROP FOREIGN KEY `fk_encargado_evento_rol`;
ALTER TABLE `convenciones_underground_mod`.`encargado_evento` 
DROP COLUMN `rol`,
CHANGE COLUMN `id_rol` `id_rol` INT NOT NULL ;
ALTER TABLE `convenciones_underground_mod`.`encargado_evento` 
ADD CONSTRAINT `fk_encargado_evento_rol`
  FOREIGN KEY (`id_rol`)
  REFERENCES `convenciones_underground_mod`.`rol` (`id`)
  ON DELETE RESTRICT
  ON UPDATE CASCADE;

-- 3.
ALTER TABLE `convenciones_underground_mod`.`encargado_evento` 
ADD COLUMN `fecha_asignacion_ini` DATE NULL AFTER `id_rol`,
ADD COLUMN `fecha_asignacion_fin` DATE NULL AFTER `fecha_asignacion_ini`;

start transaction;

update encargado_evento enc_eve
inner join evento eve on 
	enc_eve.id_evento = eve.id
set enc_eve.fecha_asignacion_ini = eve.fecha_desde;

commit;

ALTER TABLE `convenciones_underground_mod`.`encargado_evento` 
CHANGE COLUMN `fecha_asignacion_ini` `fecha_asignacion_ini` DATE NOT NULL ;

-- 4. 
ALTER TABLE `convenciones_underground_mod`.`encargado_evento` 
DROP PRIMARY KEY,
ADD PRIMARY KEY (`id_evento`, `cuil_encargado`, `id_rol`);
;
