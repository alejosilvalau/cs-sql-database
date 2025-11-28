/*
A.AD01 - Posibles presentadores. 

Varias veces la empresa se encuentra ante el inconveniente de 
que un presentador cancele cerca de la fecha de un evento y 
deben reemplazarlo rápidamente. 

A tal fin se necesita una lista de presentadores posibles 
para reemplazarlo. 

Para ello crear un procedimiento almacenado posibles_presentadores 
que reciba una temática, y un rango de fechas y liste los posibles 
presentadores que: 
1. Hayan participado o vayan a participar en el futuro de una 
presentación en un evento de la temática ingresada 
2. No estén participando de ninguna presentación en ese mismo 
horario 

Indicar id, nombre, apellido, denominación y especialidad del presentador y del evento 
y presentación de las que participó o participará id y nombre del evento y nombre de 
la presentación Probar el procedimiento con la temática "Ciencia Ficcion" para un evento 
que se organizaría entre 10 de diciembre de 2023 y 21 de diciembre de 2023.
*/
USE `convenciones_underground_mod`;
DROP procedure IF EXISTS `posibles_presentadores`;

DELIMITER $$
USE `convenciones_underground_mod`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `posibles_presentadores`(in p_tematica varchar(255), in p_fecha_desde date, p_fecha_hasta date)
BEGIN
select
	dor.id presentador_id,
    dor.nombre presentador_nombre,
    dor.apellido presentador_apellido,
    dor.denominacion presentador_denominacion,
    dor.especialidad presentador_especialidad,
    eve.id evento_id,
    eve.nombre evento_nombre,
    pre.nombre presentacion_nombre
from evento eve
inner join presentacion pre on
	eve.id = pre.id_evento
inner join presentador_presentacion pre_dor on
	pre.id_locacion = pre_dor.id_locacion and
    pre.nro_sala = pre_dor.nro_sala
inner join presentador dor on
	pre_dor.id_presentador = dor.id
where 
	eve.tematica = p_tematica
    and dor.id not in (
		select pre_dor.id_presentador
			from presentacion sub_pre 
		inner join presentador_presentacion sub_pre_dor on
			sub_pre.id_locacion = sub_pre_dor.id_locacion and
			sub_pre.nro_sala = sub_pre_dor.nro_sala and
            sub_pre.fecha_hora_ini = sub_pre_dor.fecha_hora_ini
		where 
			sub_pre.fecha_hora_ini < p_fecha_hasta and 
            # Esto incluye todo el intervalo, aunque un evento solape con la p_fecha_desde 
            # y p_fecha_hasta, pero no sea exactamente la fecha de inicio y fecha de 
            # fin pasada por parametro
			sub_pre.fecha_hora_fin > p_fecha_desde and
            sub_pre_dor.id_presentador = dor.id
    )
    
;
END$$

DELIMITER ;
;

-- Solución propuesta:
USE `convenciones_underground_mod`;
DROP procedure IF EXISTS `posibles_presentadores2`;

DELIMITER $$
USE `convenciones_underground_mod`$$
CREATE PROCEDURE `posibles_presentadores2` (in tematica varchar(255),in f_desde date,in f_hasta date)
BEGIN
select 
	distinct pre.id, 
	pre.nombre, 
    pre.apellido, 
    pre.especialidad, 
    pre.denominacion, 
	e.id, 
    e.nombre, 
    p.nombre 
from evento e 
inner join presentacion p on 
	e.id = p.id_evento 
inner join presentador_presentacion pe on 
	pe.id_locacion = p.id_locacion and 
	pe.nro_sala = p.nro_sala and 
	pe.fecha_hora_ini = p.fecha_hora_ini 
inner join presentador pre on 
	pe.id_presentador = pre.id 
where 
	e.tematica = tematica and 
    pe.id_presentador not in ( 
		select pps.id_presentador 
		from presentador_presentacion pps 
		inner join presentacion p1 on 
			pps.id_locacion = p1.id_locacion and 
			pps.nro_sala = p1.nro_sala and 
			pps.fecha_hora_ini = p1.fecha_hora_ini 
		where 
			p1.fecha_hora_ini between f_desde and f_hasta or 
			p1.fecha_hora_fin between f_desde and f_hasta 
	);
END$$

DELIMITER ;

-- Prueba
call posibles_presentadores('Ciencia Ficcion', '2023-12-10', '2023-10-21'); # Mí solución maneja los rangos de fecha mejor!
call posibles_presentadores2('Ciencia Ficcion', '2023-12-10', '2023-10-21');


