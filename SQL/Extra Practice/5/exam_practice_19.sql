/*
 * AD.E1 - Historial de Cambios de Precio (DDL + Migración).
 * La inmobiliaria necesita llevar un registro histórico de los cambios en los importes
 * mensuales de los contratos. Actualmente, cuando el importe mensual de un contrato cambia,
 * se pierde el historial del valor anterior.
 *
 * Se requiere:
 * 1. Crear una tabla `historial_precio_contrato` que registre cada cambio de importe con fecha.
 * 2. Migrar el importe actual de todas las solicitudes con contrato como primer registro en el histórico.
 *    Usar la fecha_contrato como fecha_cambio y el importe_anterior como 0.
 * 3. Realizar todo en una transacción.
 *
 * Luego, listar los contratos que tienen al menos 2 cambios de precio registrados, mostrando:
 * ID de solicitud, ID de propiedad, dirección de la propiedad, cantidad de cambios de precio,
 * primer importe registrado, último importe registrado y variación porcentual calculada como:
 * ((importe_ultimo - importe_primero) / importe_primero) * 100
 */

CREATE TABLE inmobiliaria_calciferhowl_mod4.historial_precio_contrato (
	fecha_hora_desde DATETIME NOT NULL,
	id_solicitud int unsigned NOT NULL,
	importe_mensual decimal(12, 3) NOT NULL,
	CONSTRAINT pk_historial_precio_contrato PRIMARY KEY (fecha_hora_desde,id_solicitud),
	CONSTRAINT fk_historial_precio_contrato_solicitud_contrato FOREIGN KEY (id_solicitud) REFERENCES inmobiliaria_calciferhowl_mod4.solicitud_contrato(id) ON DELETE RESTRICT ON UPDATE CASCADE
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;

start transaction;

insert
	into
	historial_precio_contrato (
	fecha_hora_desde,
	id_solicitud,
	importe_mensual)
select
	sc.fecha_contrato,
	sc.id,
	sc.importe_mensual
from
	solicitud_contrato sc
where
	sc.fecha_contrato is not null;

commit;

with cant_cambio_importe as (
select
	sc.id,
	count(1) cant_cambio,
	min(hpc.fecha_hora_desde) fec_pri_imp,
	max(hpc.fecha_hora_desde) fec_ult_imp
from
	historial_precio_contrato hpc
inner join solicitud_contrato sc on
	hpc.id_solicitud = sc.id
group by
	sc.id
),
val_pri_ult_imp as (
select
	cci.id,
	pri_hpc.importe_mensual pri_importe,
	ult_hpc.importe_mensual ult_importe
from
	cant_cambio_importe cci
inner join historial_precio_contrato pri_hpc on
	pri_hpc.id_solicitud = cci.id
	and pri_hpc.fecha_hora_desde = cci.fec_pri_imp
inner join historial_precio_contrato ult_hpc on
	ult_hpc.id_solicitud = cci.id
	and ult_hpc.fecha_hora_desde = cci.fec_ult_imp
)
select
	sc.id,
	sc.id_propiedad,
	p.direccion,
	cci.cant_cambio,
	vpui.pri_importe,
	vpui.ult_importe,
	((vpui.ult_importe - vpui.pri_importe) / vpui.pri_importe) * 100 variacion_porc,
from
	solicitud_contrato sc
inner join cant_cambio_importe cci on
	sc.id = cci.id
inner join propiedad p on
	sc.id_propiedad = p.id
inner join val_pri_ult_imp vpui on
	sc.id = vpui.id
where
	cci.cant_cambio >= 2;

/*
 * AD.E2 - Zonas en Declive.
 * La empresa necesita identificar zonas que tienen bajo rendimiento en la conversión
 * de visitas a solicitudes de contrato.
 *
 * Listar las zonas que cumplan TODAS estas condiciones simultáneamente:
 * - Tienen más de 20 visitas registradas durante el año 2025
 * - La tasa de conversión (total solicitudes / total visitas) es inferior al 15%
 * - No tienen ninguna propiedad actualmente alquilada con importe mensual superior a $50,000
 *
 * Mostrar: Zona, total de visitas en 2025, total de solicitudes en 2025, tasa de conversión (%),
 * cantidad de propiedades disponibles en la zona, valor promedio de las propiedades de la zona
 * (usar el valor más reciente de cada propiedad).
 *
 * Ordenar por tasa de conversión ascendente.
 */
--  AD.E2 - Zonas en Declive.

with cant_vis_zona as (
select
	p.zona,
	count(1) cant_vis
from
	visita v
inner join propiedad p on
	v.id_propiedad = p.id
where
	year(v.fecha_hora_visita) = 2025
group by
	p.zona
),
cant_sc_zona as (
select
	p.zona,
	count(1) cant_sol
from
	solicitud_contrato sc
inner join propiedad p on
	sc.id_propiedad = p.id
where
	year(sc.fecha_solicitud) = 2025
group by
	p.zona
),
cant_prop_disp as (
select
	p.zona,
	count(distinct p.id) cant_prop
from
	solicitud_contrato sc
inner join propiedad p on
	p.id = sc.id_propiedad
where
	p.situacion != 'alquilada'
group by
	p.zona
),
ult_val_fec_prop as (
select
	vp.id_propiedad,
	max(vp.fecha_hora_desde) fec_val_act
from
	valor_propiedad vp
where
	vp.fecha_hora_desde <= current_timestamp()
group by
	vp.id_propiedad
),
ult_val_prop as (
select
	vp.id_propiedad,
	vp.fecha_hora_desde,
	vp.valor
from
	ult_val_fec_prop uvfp
inner join valor_propiedad vp on
	uvfp.id_propiedad = vp.id_propiedad
	and uvfp.fec_val_act = vp.fecha_hora_desde
),
val_prom_zona as (
select
	p.zona,
	avg(uvp.valor) valor_prom
from
	propiedad p
inner join ult_val_prop uvp on
	p.id = uvp.id_propiedad
group by
	p.zona
)
select
	cvz.zona,
	cvz.cant_vis,
	csz.cant_sol,
	(csz.cant_sol / cvz.cant_vis) * 100 tasa_conv,
	cpd.cant_prop cant_prop_disp,
	vpz.valor_prom
from
	cant_vis_zona cvz
inner join cant_sc_zona csz on
	cvz.zona = csz.zona
inner join cant_prop_disp cpd on
	cvz.zona = cpd.zona
inner join val_prom_zona vpz on
	cvz.zona = vpz.zona
where
	(csz.cant_sol / cvz.cant_vis) < 0.15
	and cvz.cant_vis > 20
	and csz.zona not in (
	select
			sub_p.zona
	from
			solicitud_contrato sub_sc
	inner join propiedad sub_p on
			sub_sc.id_propiedad = sub_p.id
	where
			sub_sc.estado = 'en alquiler'
		and sub_sc.importe_mensual > 50000
		and sub_p.zona = cvz.zona
)
order by
	tasa_conv;

/*
 * AD.E3 - Agentes Multi-Zona.
 * La empresa quiere identificar agentes que tienen un desempeño efectivo en múltiples zonas.
 *
 * Listar los agentes que cumplan TODAS estas condiciones:
 * - Han gestionado solicitudes en al menos 3 zonas diferentes durante el año 2024
 * - En cada una de esas zonas tienen una tasa de éxito (contratos cerrados / solicitudes) superior al 50%
 * - El valor total de contratos cerrados por zona supera los $100,000
 *
 * Para cada agente mostrar: ID del agente, nombre, apellido, cantidad de zonas donde opera,
 * la zona con mayor cantidad de contratos cerrados, valor total de contratos en esa zona principal,
 * y el valor total general sumando todas las zonas.
 *
 * Ordenar por cantidad de zonas descendente y luego por valor total general descendente.
 */
with cant_tot_zona as (
-- Cantidad total de zonas gestionandas en 2024 por agente
select
	sc.id_agente,
	count(distinct p.zona) cant_zonas
from
	solicitud_contrato sc
inner join propiedad p on
	sc.id_propiedad = p.id
where
	year(sc.fecha_solicitud) = 2024
group by
	sc.id_agente
having cant_zonas >= 3
),
cant_sol as (
-- Cant sol. tot. por agente y zona en 2024
select
	sc.id_agente,
	p.zona,
	count(1) cant_sol
from
	solicitud_contrato sc
inner join propiedad p on
	sc.id_propiedad = p.id
where
	year(sc.fecha_solicitud) = 2024
group by
	sc.id_agente,
	p.zona
),
cant_con as (
-- Cant sol. cerrado. por agente y zona en 2024 y suma de el importe
select
	sc.id_agente,
	p.zona,
	count(1) cant_con,
	sum(sc.importe_mensual) valor_tot
from
	solicitud_contrato sc
inner join propiedad p on
	sc.id_propiedad = p.id
where
	year(sc.fecha_solicitud) = 2024
		and sc.fecha_contrato is not null
group by
	sc.id_agente,
	p.zona
having valor_tot > 100000
),
max_cant_con as (
select
	cc.id_agente,
	max(cc.cant_con) max_con_cerr,
	sum(cc.valor_tot) valor_tot_age
from
	cant_con cc
group by
	cc.id_agente
)
select
	age.id,
	age.nombre,
	age.apellido,
	ctz.cant_zonas,
	cc.zona zona_mayor_cont_cerr,
	cc.valor_tot,
	mcc.valor_tot_age
from
	persona age
inner join cant_tot_zona ctz on
	ctz.id_agente = age.id
inner join max_cant_con mcc on
	age.id = mcc.id_agente
inner join cant_con cc on
	age.id = cc.id_agente
	and mcc.max_con_cerr = cc.cant_con
inner join cant_sol cs on
	age.id = cs.id_agente
	and cc.zona = cs.zona
where
(cc.cant_con / cs.cant_sol) > 0.5
order by ctz.cant_zonas desc, cc.valor_tot desc

/*
 * AD.E4 - Propiedades "Fantasma" (DDL + Query).
 * La empresa necesita detectar propiedades sospechosas que generan mucho interés
 * pero nunca logran concretar contratos.
 *
 * Parte DDL:
 * 1. Crear una tabla `alerta_propiedad` con: id_propiedad, fecha_alerta, tipo_alerta, descripcion
 * 2. Insertar alertas con tipo_alerta = 'BAJA_CONVERSION' para todas las propiedades que cumplan:
 *    - Tienen más de 10 visitas durante el año 2025
 *    - No tienen ninguna solicitud de contrato generada en 2025
 *    - Su valor de propiedad (más reciente) es superior al promedio de su zona
 * 3. Realizar todo en una transacción.
 *
 * Parte Query:
 * Listar todas las propiedades que tienen alertas registradas, mostrando:
 * ID de propiedad, dirección, zona, tipo de propiedad, total de visitas en 2025,
 * fecha de la última visita en 2025, valor actual de la propiedad, promedio de valor
 * en la zona, ID y nombre completo del agente asignado más recientemente a la propiedad,
 * y la cantidad total de propiedades que ese agente tiene actualmente en estado 'en alquiler'.
 *
 * Ordenar por total de visitas descendente.
 */


/*
 * AD.E5 - Análisis Comparativo de Garantías.
 * La empresa desea evaluar si la cantidad de garantías asociadas a una solicitud
 * influye en la probabilidad de que el contrato se concrete.
 *
 * Agrupar las solicitudes de contrato de los años 2024 y 2025 según la cantidad
 * de garantías asociadas (clasificar en: 0 garantías, 1 garantía, 2 garantías, 3 o más garantías).
 *
 * Para cada grupo calcular:
 * - Total de solicitudes en ese grupo
 * - Cantidad de solicitudes con estado 'en alquiler' (contratos exitosos)
 * - Tasa de éxito calculada como: (exitosas / total) * 100
 * - Tiempo promedio en días desde fecha_solicitud hasta fecha_contrato (solo de las exitosas)
 * - Importe mensual promedio de los contratos exitosos
 *
 * Mostrar solo los grupos que tengan al menos 10 solicitudes.
 * Ordenar por tasa de éxito descendente.
 *
 * Nota: Para clasificar en "3 o más garantías" usar CASE WHEN al contar.
 */


/*
 * AD.E6 - Clientes Morosos con Historial.
 * La empresa necesita identificar clientes que tienen un patrón de comportamiento
 * irregular en sus pagos y además tienen antecedentes negativos con garantías.
 *
 * Listar los clientes que cumplan TODAS estas condiciones simultáneamente:
 * - Tienen al menos 2 contratos (activos o finalizados) durante los años 2024-2025
 * - En al menos uno de esos contratos, el último pago de alquiler fue hace más de 90 días
 * - En ese mismo contrato con atraso, el total pagado es menor al 60% del total esperado
 *   (calculado como: meses transcurridos × importe_mensual)
 * - El cliente tiene al menos una garantía con estado 'rechazada' en cualquier momento
 *
 * Mostrar: ID del cliente, nombre, apellido, cantidad total de contratos del cliente,
 * cantidad de contratos con atrasos mayores a 90 días, suma total de deuda pendiente
 * (calculada como: total_esperado - total_pagado) sumando todos sus contratos activos,
 * y la peor proporción de pago (el mínimo entre todas las proporciones pagado/esperado
 * de sus contratos).
 *
 * Ordenar por suma total de deuda pendiente descendente.
 *
 * Nota: usar TIMESTAMPDIFF(MONTH,...) para calcular meses transcurridos y
 * DATEDIFF para calcular diferencias en días.
 */