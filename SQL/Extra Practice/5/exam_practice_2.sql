/* AD.A1- Embarcación de mayor almacenamiento por tipo de
embarcación. 

[X] La empresa desea identificar a las embarcaciones que
[X] llevan más tiempo total almacenadas para cada tipo de
[X] embarcación. 

[X] El total de horas de almacenamiento de cada
[X] embarcación se calcula como la sumatoria de las diferencia en
[X] horas entre la fecha y hora de fin de contrato y la fecha y hora
[X] de contrato (atención: en los contratos que no tienen aún fecha y
[X] hora de fin deberá usarse la actual). 

[X] La embarcación con mayor hs totales será considerada como la de mayor almacenamiento

[X] Se requiere listar para cada tipo de embarcación la embarcación
[X] con más horas totales almacenadas, indicando: 
[X] - código y nombre del tipo de embarcación; 
[X] - hin y nombre de la embarcación; 
[X] - número y nombre del propietario, 
[X] - fecha de la primera vez que almacenó la embarcación, 
[X] - cantidad de horas totales de almacenamiento, 
[X] - y de las salidas con dicha embarcación la última fecha de salida en
[X] 	2024 y la cantidad de salidas durante 2024.

Si una embarcación no tiene tiempo de almacenamiento indicar 0 en
las horas totales. 
[X] - Se deberán listar todos los tipos de embarcación y aún 
	si no tienen ningún almacenamiento indicando 0. 
[X] - Se deberá mostrar la embarcación con más tiempo de almacenamiento 
	aún si no tuvo salidas indicando 0 en la cantidad de salidas.

[X] Ordenar los datos por horas totales de almacenamiento
[X] descendente, fecha del primer almacenamiento ascendente y
[X] cantidad de salidas descendente. */ 

drop temporary table if exists max_horas_embarcacion;
drop temporary table if exists max_horas_tipo;
drop temporary table if exists min_fecha_contrato;
drop temporary table if exists max_fecha_salida_2024;
drop temporary table if exists cant_fecha_salida_2024;

create temporary table max_horas_embarcacion
select emb.hin, emb.codigo_tipo_embarcacion, max(coalesce(
		emb_cam.fecha_hora_baja_contrato, 
        current_timestamp()
	) - emb_cam.fecha_hora_contrato) max_horas_alm
from embarcacion emb 
inner join embarcacion_cama emb_cam 
	on emb.hin = emb_cam.hin
group by emb.hin, emb.codigo_tipo_embarcacion;

-- create temporary table max_horas_tipo
select codigo_tipo_embarcacion, 
	max(max_horas_alm) max_horas_alm_tipo
from max_horas_embarcacion
group by codigo_tipo_embarcacion;

create temporary table min_fecha_contrato
select hin, min(fecha_hora_contrato) min_fecha_hora_contrato
from embarcacion_cama group by hin;

create temporary table max_fecha_salida_2024
select mhe.hin, max(fecha_hora_salida) max_fecha_hora_salida 
from salida s
inner join max_horas_embarcacion mhe on
	s.hin = mhe.hin
where year(fecha_hora_salida) = 2024
group by mhe.hin;

create temporary table cant_fecha_salida_2024
select mhe.hin, count(fecha_hora_salida) cant_fecha_hora_salida 
from salida s
inner join max_horas_embarcacion mhe on
	s.hin = mhe.hin
where year(fecha_hora_salida) = 2024
group by mhe.hin;

select 
	te.codigo, te.nombre nombre_tipo_embarcacion,
    e.hin, e.nombre nombre_embarcacion,
    s.numero, s.nombre nombre_socio,
    mfc.min_fecha_hora_contrato,
    coalesce(mhe.max_horas_alm, 0) tiempo_alm,
    mfs.max_fecha_hora_salida ultima_salida_2024,
    coalesce(cfs.cant_fecha_hora_salida, 0) cant_salidas
from tipo_embarcacion te 
left join embarcacion e on
	e.codigo_tipo_embarcacion = te.codigo
left join max_horas_embarcacion mhe on
	mhe.hin = e.hin and
    mhe.codigo_tipo_embarcacion = te.codigo
left join max_horas_tipo mht on 
	mhe.codigo_tipo_embarcacion = mht.codigo_tipo_embarcacion and
    mhe.max_horas_alm = mht.max_horas_alm_tipo
left join socio s on
	e.numero_socio = s.numero
left join min_fecha_contrato mfc on
	e.hin = mfc.hin
left join max_fecha_salida_2024 mfs on 
	mfs.hin = e.hin
left join cant_fecha_salida_2024 cfs on
	cfs.hin = e.hin
order by 
	mhe.max_horas_alm desc, 
	mfc.min_fecha_hora_contrato, 
    cfs.cant_fecha_hora_salida desc;

drop temporary table if exists max_horas_embarcacion;
drop temporary table if exists max_horas_tipo;
drop temporary table if exists min_fecha_contrato;
drop temporary table if exists max_fecha_salida_2024;
drop temporary table if exists cant_fecha_salida_2024;

-- Resolucion corregida
-- Limpieza de tablas temporales
DROP TEMPORARY TABLE IF EXISTS te_alm;
DROP TEMPORARY TABLE IF EXISTS max_alm;
DROP TEMPORARY TABLE IF EXISTS salidas_2024;

-- 1. Calcular horas totales de almacenamiento por tipo y embarcación
CREATE TEMPORARY TABLE te_alm AS
SELECT 
    te.codigo AS cod_tipo,
    te.nombre AS tipo,
    e.hin,
    e.nombre AS emb,
    e.numero_socio,
    s.nombre AS propietario,
    MIN(ec.fecha_hora_contrato) AS desde,
    SUM(COALESCE(
        TIMESTAMPDIFF(HOUR, 
            fecha_hora_contrato,
            COALESCE(fecha_hora_baja_contrato, NOW())
        ), 
        0
    )) AS hs_tot
FROM tipo_embarcacion te
LEFT JOIN embarcacion e ON te.codigo = e.codigo_tipo_embarcacion
LEFT JOIN embarcacion_cama ec ON e.hin = ec.hin
LEFT JOIN socio s ON e.numero_socio = s.numero
GROUP BY te.codigo, e.hin;

-- 2. Identificar el máximo de horas por tipo de embarcación
CREATE TEMPORARY TABLE max_alm AS
SELECT 
    cod_tipo,
    MAX(hs_tot) AS max_hs
FROM te_alm
GROUP BY cod_tipo;

-- 3. Obtener información de salidas en 2024 por embarcación
CREATE TEMPORARY TABLE salidas_2024 AS
SELECT 
    hin,
    MAX(fecha_hora_salida) AS ult_salida,
    COUNT(fecha_hora_salida) AS salidas
FROM salida
WHERE fecha_hora_salida BETWEEN '2024-01-01' AND '2024-12-01'
GROUP BY hin;

-- 4. Consulta final: embarcaciones con máximo almacenamiento por tipo
SELECT 
    te_alm.cod_tipo,
    te_alm.tipo,
    te_alm.hin,
    te_alm.emb,
    te_alm.numero_socio,
    te_alm.propietario,
    te_alm.desde,
    te_alm.hs_tot,
    s24.ult_salida,
    COALESCE(s24.salidas, 0) AS salidas
FROM te_alm
INNER JOIN max_alm 
    ON te_alm.cod_tipo = max_alm.cod_tipo
    AND te_alm.hs_tot = max_alm.max_hs
LEFT JOIN salidas_2024 s24 
    ON te_alm.hin = s24.hin
ORDER BY 
    te_alm.hs_tot DESC,
    te_alm.desde ASC,
    salidas DESC;

-- Limpieza final
DROP TEMPORARY TABLE IF EXISTS te_alm;
DROP TEMPORARY TABLE IF EXISTS max_alm;
DROP TEMPORARY TABLE IF EXISTS salidas_2024;