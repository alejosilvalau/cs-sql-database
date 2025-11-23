/*
REC.1- Contratos y salidas. 

Para obtener información de forma rápida y concisa sobre los 
contratos y salidas de embarcaciones se requiere crear una rutina 
llamada contratos_salidas que reciba como parámetro "el código de 
tipo de embarcación" e indique para las embarcaciones de dicho 
tipo: 
- cuantas salidas en total ha realizado, 
- la fecha de su última salida, 
- la mayor cantidad de días que ha salido en una salida y 
- para cada uno de sus contratos 
- -	la cantidad de salidas durante la duración de dicho contrato y 
- - que proporción son sobre el total de salidas de dicha embarcación. 

Si no realizó salidas debe mostrar la cantidad de salidas en 0. 

Indicar:
- hin y nombre de la embarcación; 
- nombre del tipo de embarcación; 
- nombre del propietario; 
- cantidad total de salidas; 
- fecha de la última salida, 
- máxima cantidad de días que duró una salida realmente y 
- para cada contrato, la fecha y hora de contrato, 
- - fecha y hora de baja de contrato, 
- - cantidad de salidas en dicho contrato y 
- - que proporción representan del total.

Invocar la rutina para con el código de tipo de embarcación 8
(incluirlo en la resolución).
*/
USE `guarderia_gaghiel_mod`;
DROP procedure IF EXISTS `contratos_salidas5`;

USE `guarderia_gaghiel_mod`;
DROP procedure IF EXISTS `guarderia_gaghiel_mod`.`contratos_salidas5`;
;

DELIMITER $$
USE `guarderia_gaghiel_mod`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `contratos_salidas5`(in p_cod_te int unsigned)
BEGIN
drop temporary table if exists salidas_filtradas;
drop temporary table if exists salidas_por_embarcacion;
drop temporary table if exists cant_sal_cont;

-- 1. Pre-filtrar salidas válidas (con regreso real)
create temporary table salidas_filtradas
select
	s.hin,
    s.fecha_hora_salida,
    s.fecha_hora_regreso_real,
    timestampdiff(day, s.fecha_hora_salida, s.fecha_hora_regreso_real) cant_dias
from salida s
inner join embarcacion e on
	s.hin = e.hin
where 
	fecha_hora_regreso_real is not null and
    e.codigo_tipo_embarcacion = p_cod_te;

-- 2. Calcular salidas totales POR EMBARCACIÓN del tipo
create temporary table salidas_por_embarcacion
select
	e.hin,
    count(sf.hin) cant_tot_sal,
    max(sf.fecha_hora_salida) ult_sal,
    max(sf.cant_dias) max_cant_dias
from embarcacion e
inner join tipo_embarcacion te on 
	e.codigo_tipo_embarcacion = te.codigo
left join salidas_filtradas sf on
	e.hin = sf.hin
where 
	te.codigo = p_cod_te
group by e.hin;

-- 3. Cantidad de salidas por contrato
create temporary table cant_sal_cont 
select
	e.hin,
    ec.fecha_hora_contrato,
    count(sf.hin) cant_sal
from embarcacion e
inner join tipo_embarcacion te on
	e.codigo_tipo_embarcacion = te.codigo
inner join embarcacion_cama ec on
	e.hin = ec.hin
left join salidas_filtradas sf on
	e.hin = sf.hin
where 
	te.codigo = p_cod_te and 
    (
		sf.fecha_hora_salida is null
        or (
			sf.fecha_hora_salida >= ec.fecha_hora_contrato and 
            sf.fecha_hora_regreso_real <= coalesce(ec.fecha_hora_baja_contrato, now())
		)
	)
group by e.hin,
    ec.fecha_hora_contrato; 

-- 4. Consulta final
select
	e.hin e_hin,
	e.nombre e_nombre,
	te.nombre te_nombre,
	s.nombre s_nombre,
	coalesce(spe.cant_tot_sal, 0) te_cant_total_salidas,
	spe.ult_sal te_ultima_salida,
	spe.max_cant_dias te_max_cant_dias,
	ec.fecha_hora_contrato contrato_fecha_hora,
	ec.fecha_hora_baja_contrato contrato_fecha_hora_baja,
	coalesce(csc.cant_sal, 0) contrato_cant_sal,
	coalesce((csc.cant_sal * 100.0) / spe.cant_tot_sal, 0) proporcion_del_total
from embarcacion e
inner join tipo_embarcacion te on 
	e.codigo_tipo_embarcacion = te.codigo
inner join socio s on 
	e.numero_socio = s.numero
left join salidas_por_embarcacion spe on
	e.hin = spe.hin
left join embarcacion_cama ec on 
	e.hin = ec.hin
left join cant_sal_cont csc on
	ec.hin = csc.hin 
	and ec.fecha_hora_contrato = csc.fecha_hora_contrato
where te.codigo = p_cod_te;

drop temporary table if exists salidas_filtradas;
drop temporary table if exists salidas_por_embarcacion;
drop temporary table if exists cant_sal_cont;

END$$

DELIMITER ;
;



call contratos_salidas5(8);
-- Solucion propuesta:
call contratos_salidas3(8);

