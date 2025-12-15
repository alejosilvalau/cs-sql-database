/*
 * AD.A1 -  Reforma de solicitudes de contrato.
 * La empresa  ha detectado que algunas solicitudes de contratos se
 * deberían hacer a nombre de dos clientes o más, sin embargo el
 * sistema actual solo permite registrar 1. Por este motivo debemos
 * modificar la estructura de la base de datos para permitir que las
 * solicitudes sean de muchos clientes y los clientes puedan hacer muchas
 * solicitudes. Modificar la estructura de la base de datos para el nuevo
 * modelo, migrar el único cliente actual al nuevo modelo en una transacción
 * y borrar la estructura anterior.
 */
create table inmobiliaria_calciferhowl_mod3.cliente_contrato (
	id_cliente int unsigned not null,
	id_solicitud int unsigned not null,
	constraint fk_cliente_contrato_solicitud_contrato foreign key (id_solicitud) references inmobiliaria_calciferhowl_mod3.solicitud_contrato(id) on
delete restrict on
	update cascade,
	constraint fk_cliente_contrato_persona foreign key (id_cliente) references inmobiliaria_calciferhowl_mod3.persona(id) on
		delete restrict on
			update cascade
) engine = InnoDB default CHARSET = utf8mb4 collate = utf8mb4_0900_ai_ci;
start transaction;
insert into cliente_contrato (id_cliente, id_solicitud)
select id_cliente,
	id
from solicitud_contrato;
commit;
alter table inmobiliaria_calciferhowl_mod3.solicitud_contrato drop foreign key fk_solicitud_contrato_persona;
alter table inmobiliaria_calciferhowl_mod3.solicitud_contrato drop column id_cliente;

/*
 * AD.A2 -  Oportunidades perdidas. Listar las solicitudes con estado rechazada cuyo
 * importe mensual pactado sea mayor o igual al 70% del valor de la propiedad a la fecha
 * de dicha solicitud de contrato (fecha_solicitud) y que a pesar de haber sido rechazada
 * la solicitud no tengan ninguna garantía rechazada. Indicar id y fecha de solicitud;
 * id, nombre y apellido del agente y proporción entre el importe mensual y el valor
 * a esa fecha. Nota: Los estados de solicitudes de contrato pueden ser “en proceso”,
 * “en alquiler” o “rechazada”.
 */
select sc.id solicitud_contrato_id,
	sc.fecha_solicitud,
	a.id agente_id,
	a.nombre,
	a.apellido,
	sc.importe_mensual / vp.valor proporcion
from solicitud_contrato sc
	inner join valor_propiedad vp on vp.id_propiedad = sc.id_propiedad
	and vp.fecha_hora_desde = (
		select max(sub_vp.fecha_hora_desde)
		from valor_propiedad sub_vp
		where sc.id_propiedad = sub_vp.id_propiedad
			and sub_vp.fecha_hora_desde <= sc.fecha_solicitud
	)
	inner join persona a on a.id = sc.id_agente
	left join garantia g on g.id_solicitud = sc.id
	and g.estado = 'rechazada'
where sc.estado = 'rechazada'
	and sc.importe_mensual / vp.valor >= 0.7
	and g.id_solicitud is null;

/*
 * AD.A3 - Trending props. En base a las visitas de 2025, listar la propiedad más popular de cada mes.
 * se considera la propiedad más popular de cada mes a la que tenga mayor cantidad de visitas el
 * mismo mes en base a la fecha de visita. En cada mes de 2025 se debe indicar la propiedad
 * más popular (o la más populares si tuvieran la misma cantidad de visitas) y para dicho
 * mes indicar los datos de la última visita de las propiedad más popular. Indicar mes; id,
 * zona y tipo de propiedad, cantidad total de visitas; fecha de la última visita (para dicho
 * mes y propiedad) y del agente de dicha visita indicar su id, nombre y apellido. Si en un mes
 * de 2025 no hubiera visitas no debe mostrarse. Nota: la función month devuelve el mes de una
 * fecha
 */
-- Contar la cantidad de visitas por propiedad
drop temporary table if exists cant_vis_prop_2025;
create temporary table if not exists cant_vis_prop_2025
select v.id_propiedad,
	month(v.fecha_hora_visita) mes,
	count(v.fecha_hora_visita) cant_vis
from visita v
where year(v.fecha_hora_visita) = 2025
group by v.id_propiedad,
	mes;
-- Obtener la más popular por mes
drop temporary table if exists prop_mas_pop_2025;
create temporary table if not exists prop_mas_pop_2025
select mes,
	max(cant_vis) max_cant_vis
from cant_vis_prop_2025
group by mes;
-- ultima visita por propiedad y mes
drop temporary table if exists ult_vis_prop_mas_pop_2025;
create temporary table if not exists ult_vis_prop_mas_pop_2025
select mprop.mes,
	v.id_propiedad,
	max(v.fecha_hora_visita) ult_vis
from visita v
	inner join cant_vis_prop_2025 cvprop on cvprop.id_propiedad = v.id_propiedad
	and cvprop.mes = month(v.fecha_hora_visita)
	inner join prop_mas_pop_2025 mprop on mprop.mes = month(v.fecha_hora_visita)
	and mprop.max_cant_vis = cvprop.cant_vis
where year(v.fecha_hora_visita) = 2025
group by mprop.mes,
	v.id_propiedad;
-- Consulta final
select uvprop.mes,
	p.id,
	p.zona,
	p.tipo,
	cvprop.cant_vis,
	uvprop.ult_vis,
	a.id age_id,
	a.nombre,
	a.apellido
from visita v
	inner join cant_vis_prop_2025 cvprop on cvprop.id_propiedad = v.id_propiedad
	and cvprop.mes = month(v.fecha_hora_visita)
	inner join ult_vis_prop_mas_pop_2025 uvprop on uvprop.id_propiedad = v.id_propiedad
	and uvprop.ult_vis = v.fecha_hora_visita
	inner join propiedad p on p.id = uvprop.id_propiedad
	inner join persona a on a.id = v.id_agente;

-- Solución propuesta por cátedra
with visitas_mes as (
	select month(v.fecha_hora_visita) mes,
		v.id_propiedad,
		p.tipo,
		p.zona,
		count(*) cant_visitas,
		max(v.fecha_hora_visita) ult_visita
	from visita v
		inner join propiedad p on v.id_propiedad = p.id
	where year(fecha_hora_visita) = 2025
	group by month(v.fecha_hora_visita),
		v.id_propiedad,
		p.tipo,
		p.zona
),
max_vis as (
	select mes,
		max(cant_visitas) max_vis
	from visitas_mes
	group by mes
)
select vmes.mes,
	vmes.id_propiedad,
	vmes.zona,
	vmes.tipo,
	vmes.cant_visitas,
	vmes.ult_visita,
	age.id id_agente,
	age.nombre nombre_agente,
	age.apellido apellido_agente
from visitas_mes vmes
	inner join max_vis maxv on vmes.mes = maxv.mes
	and vmes.cant_visitas = maxv.max_vis
	inner join visita vi on vmes.id_propiedad = vi.id_propiedad
	and vmes.ult_visita = vi.fecha_hora_visita
	inner join persona age on vi.id_agente = age.id
where year(vi.fecha_hora_visita) = 2025;

/*
 * AD.A4 -  Mejoras en las ofertas. La empresa requiere un listado de
 * las propiedades cuya cantidad de solicitudes de contrato en 2024
 * haya aumentado con respecto al promedio de cantidad de solicitudes
 * de contrato de las propiedades del mismo tipo en 2023. Si una
 * propiedad no tuvo solicitudes debería tenerse en cuenta como 0
 * para el promedio. Indicar id, tipo, zona, situación de la propiedad,
 * cantidad de solicitudes en 2024 y promedio de solicitudes del tipo en 2023.
 */

drop temporary table if exists cantidad_2023;
create temporary table cantidad_2023
select
	pro.id,
	pro.tipo,
	count(sc.id_propiedad) cant_solicitudes
from
	propiedad pro
left join solicitud_contrato sc on
	pro.id = sc.id_propiedad
	and year(sc.fecha_solicitud)= 2023
group by
	pro.id,
	pro.tipo;

drop temporary table if exists promedioxtipo;
create temporary table promedioxtipo
select
	c23.tipo,
	avg(c23.cant_solicitudes) promedio
from
	cantidad_2023 c23
group by
	c23.tipo;

drop temporary table if exists cantidad_2024;
create temporary table cantidad_2024
select
	pro.id,
	pro.tipo,
	pro.zona,
	pro.situacion,
	count(sc.id_propiedad) cant_solicitudes
from
	propiedad pro
left join solicitud_contrato sc on
	pro.id = sc.id_propiedad
	and year(sc.fecha_solicitud)= 2024
group by
	pro.id,
	pro.tipo,
	pro.zona,
	pro.situacion;

select
	c24.id,
	c24.tipo,
	c24.zona,
	c24.situacion,
	c24.cant_solicitudes,
	prot.promedio
from
	cantidad_2024 c24
inner join promedioxtipo prot on
	c24.tipo = prot.tipo
where
	c24.cant_solicitudes > prot.promedio;

-- Otra solución (Mejor)
with sc_prop_tipo_anio as (
select
	p.id id_propiedad,
	p.tipo,
	p.zona,
	p.situacion ,
	year(sc.fecha_solicitud) anio ,
	count(sc.fecha_solicitud) cant_sol
from
	propiedad p
left join solicitud_contrato sc on
	sc.id_propiedad = p.id
group by
	p.id,
	p.tipo,
	p.zona,
	p.situacion ,
	year(sc.fecha_solicitud) ),
sctipo_2023 as (
select
	scpro.tipo,
	avg(cant_sol) prom_sol
from
	sc_prop_tipo_anio scpro
where
	scpro.anio = 2023
group by
	scpro.tipo )
select
	scpta.id_propiedad,
	scpta.tipo,
	scpta.zona,
	scpta.situacion ,
	scpta.cant_sol cant_sol_2024 ,
	coalesce(sctipo_2023.prom_sol, 0) prom_sol_2023
from
	sc_prop_tipo_anio scpta
left join sctipo_2023 on
	scpta.tipo = sctipo_2023.tipo
where
	scpta.anio = 2024
	and scpta.cant_sol > coalesce(sctipo_2023.prom_sol, 0);

/*
 * AD.B1 - La inmobiliaria nos informa que en algunas solicitudes de
 * contratos se necesita registrar varios agentes que cooperaron durante
 * un contrato. Una solicitud de contrato puede involucrar a varios agentes
 * asignados y un agente asignado puede participar en muchas solicitudes.
 * Se requiere modificar la estructura de la base de datos para soportar este
 * cambio en el modelo, migrar el agente asignado registrado en las solicitudes
 * existentes al nuevo modelo en una transacción y eliminar la estructura anterior.
 */

create table agente_solicitud (
	id_solicitud int unsigned not null,
	id_agente int unsigned not null,
	id_propiedad int unsigned not null,
	fecha_hora_desde datetime not null,
	primary key (
		id_solicitud,
		id_agente,
		id_propiedad,
		fecha_hora_desde
	),
	constraint fk_agente_solicitud_solicitud_contrato foreign key (id_solicitud) references solicitud_contrato(id) on delete restrict on update cascade,
	constraint fk_agente_solicitud_agente_asignado foreign key (id_agente, id_propiedad, fecha_hora_desde) references agente_asignado(id_agente, id_propiedad, fecha_hora_desde) on delete restrict on update cascade
) engine = InnoDB;
begin;
insert into agente_solicitud
select id,
	id_agente,
	id_propiedad,
	fecha_hora_desde
from solicitud_contrato;
commit;
alter table solicitud_contrato drop constraint fk_solicitud_contrato_agente_asignado,
	drop column id_agente,
	drop column id_propiedad,
	drop column fecha_hora_desde;

/*
 * AD.B2 -  Los clavos. La inmobiliaria quiere identificar las propiedades que pagan
 * alquileres bajos pero no están siendo mostradas. Se requiere listar los pagos en
 * concepto de alquiler cuyo importe sea menor al 70% del valor de la propiedad a
 * la fecha de pago del alquiler y no tengan visitas posteriores a la fecha de contrato
 * de la solicitud correspondiente. Indicando id y fecha de contrato de la solicitud;
 * importe y fecha y hora de pago, proporción entre importe pagado y valor de la
 * propiedad a la fecha de pago; id, tipo, zona y dirección de la propiedad.
 * Nota: Los conceptos de pago pueden ser
 * “comision”, “deposito”, “sellado” o “pago alquiler”.
 */

-- Conseguir el valor de la propiedad a la fecha de pago del alquiler
select
	sc.id,
	sc.fecha_contrato,
	p.importe,
	p.fecha_hora_pago,
	(p.importe / vp.valor) proporcion,
	prop.id prop_id,
	prop.tipo,
	prop.zona,
	prop.direccion
from
	pago p
inner join solicitud_contrato sc on
	sc.id = p.id_solicitud
inner join valor_propiedad vp on
	vp.id_propiedad = sc.id_propiedad
	and vp.fecha_hora_desde = (
	select max(sub_vp.fecha_hora_desde)
	from valor_propiedad sub_vp
	where
		sub_vp.id_propiedad = sc.id_propiedad
		and sub_vp.fecha_hora_desde <= p.fecha_hora_pago
	)
inner join propiedad prop on
	prop.id = sc.id_propiedad
where
	p.concepto = 'pago alquiler'
	and sc.id_propiedad not in (
	select
		sub_v.id_propiedad
	from
		visita sub_v
	where
		sub_v.fecha_hora_visita >= sc.fecha_contrato
		)
	and (p.importe / vp.valor) < 0.7;

-- Solución de la cátedra
with sol_ult_val as (
select
	p.id_solicitud,
	p.fecha_hora_pago,
	p.importe ,
	sc.id_propiedad,
	sc.fecha_contrato ,
	p.concepto ,
	max(vp.fecha_hora_desde) ult_fec
from
	pago p
inner join solicitud_contrato sc on
	p.id_solicitud = sc.id
inner join valor_propiedad vp on
	vp.id_propiedad = sc.id_propiedad
	and vp.fecha_hora_desde <= p.fecha_hora_pago
where
	concepto = 'pago alquiler'
group by
	p.id_solicitud,
	p.fecha_hora_pago,
	p.importe,
	sc.id_propiedad )
select
	suv.id_solicitud,
	suv.fecha_contrato,
	suv.fecha_hora_pago ,
	suv.ult_fec,
	suv.importe / vp.valor ,
	prop.id id_propiedad,
	prop.tipo,
	prop.zona,
	prop.direccion
from
	sol_ult_val suv
inner join valor_propiedad vp on
	suv.id_propiedad = vp.id_propiedad
	and suv.ult_fec = vp.fecha_hora_desde
inner join propiedad prop on
	suv.id_propiedad = prop.id
where
	suv.importe / vp.valor < 0.7
	and suv.id_propiedad not in (
	select
		v.id_propiedad
	from
		visita v
	where
		v.fecha_hora_visita >= suv.fecha_contrato );

/*
 * AD.B3 -  Agente del año. En base a las solicitudes con contrato,
 * listar para cada año quien fue el mejor agente. El mejor agente
 * de un año es aquel cuya, suma de importes mensuales de todas las
 * solicitudes que gestionó y se hayan contratado ese año, sea la más
 * alta (en base a la fecha de contrato de la solicitud de contrato).
 * En cada año se debe indicar el mejor agente (o los mejores si vendieran
 * la misma cantidad) y para ese año indicar los datos de la mejor de las
 * solicitudes de dicho agente (la que tenga importe más alto). Indicar año;
 * id, nombre y apellido del agente, total de importes mensuales; id, fecha
 * de solicitud, importe mensual y fecha de contrato de la mejor solicitud;
 * id, nombre y apellido del cliente de dicha solicitud. Si un año no hubiera
 * solicitudes con contrato no debe mostrarse Nota: la función year devuelve
 * el año de una fecha
 */

-- Mi Solución
with count_agente_anio as (
select
	sc.id_agente,
	year(sc.fecha_contrato) anio,
	sum(sc.importe_mensual) importe_agregado,
	max(sc.importe_mensual) importe_max
from
	solicitud_contrato sc
where
	fecha_contrato is not null
group by
	sc.id_agente,
	year(sc.fecha_contrato)
),
max_agente_anio as (
select
	anio,
	max(importe_agregado) max_importe_agregado
from
	count_agente_anio
group by
	anio
)
select
	maa.anio,
	a.id agente_id,
	a.nombre agente_nom,
	a.apellido agente_ape,
	sc.id solicitud_id,
	sc.fecha_solicitud,
	sc.importe_mensual,
	sc.fecha_contrato,
	c.id cliente_id,
	c.nombre cliente_nom,
	c.apellido cliente_ape
from
	count_agente_anio caa
inner join max_agente_anio maa on
	maa.anio = caa.anio
	and
	maa.max_importe_agregado = caa.importe_agregado
inner join persona a on
	a.id = caa.id_agente
inner join solicitud_contrato sc on
	year(sc.fecha_solicitud) = caa.anio
	and
	sc.id_agente = caa.id_agente
	and
	sc.importe_mensual = caa.importe_max
inner join persona c on
	sc.id_cliente = c.id
where
	sc.fecha_contrato is not null;

-- Solución de la cátedra
with tot_ag as (
select
	year(sc.fecha_contrato) anio,
	sc.id_agente ,
	ag.nombre nombre_agente,
	ag.apellido apellido_agente ,
	sum(sc.importe_mensual) total_importes ,
	max(sc.importe_mensual) mejor_imp
from
	solicitud_contrato sc
inner join persona ag on
	sc.id_agente = ag.id
where
	sc.fecha_contrato is not null
group by
	year(sc.fecha_contrato) ,
	sc.id_agente,
	ag.nombre,
	ag.apellido ),
max_anio as (
select
	anio,
	max(total_importes) max_anio
from
	tot_ag
group by
	anio )
select
	ta.anio,
	ta.id_agente,
	ta.nombre_agente,
	ta.apellido_agente ,
	ta.total_importes ,
	sc.id,
	sc.fecha_solicitud,
	sc.importe_mensual,
	sc.fecha_contrato ,
	cli.id id_cliente,
	cli.nombre nombre_cliente,
	cli.apellido apellido_cliente
from
	tot_ag ta
inner join max_anio ma on
	ta.anio = ma.anio
	and ta.total_importes = ma.max_anio
inner join solicitud_contrato sc on
	ta.id_agente = sc.id_agente
	and year(sc.fecha_contrato)= ta.anio
	and sc.importe_mensual = ta.mejor_imp
inner join persona cli on
	sc.id_cliente = cli.id
where
	sc.fecha_contrato is not null;

	/*
 * AD.B4 -  Tendencia de busqueda. La empresa requiere un listado de las
 * propiedades cuya cantidad de visitas en 2025 supere al promedio de
 * cantidad de visitas de cada propiedad del mismo tipo durante 2024.
 * Si una propiedad no tiene visitas debería tenerse en cuenta como 0 para
 * el promedio. Indicar id, tipo, zona y situación de la propiedad, cantidad
 * de visitas en 2025 y promedio de visitas del tipo de propiedad en 2024.
 */


with cant_vis_prop as (
select
	p.id,
	p.tipo,
	p.zona,
	p.situacion,
	year(v.fecha_hora_visita) anio,
	count(v.id_propiedad) cant_vis
from
	propiedad p
left join visita v on
	v.id_propiedad = p.id
where
	year(v.fecha_hora_visita)
	between 2024
	and 2025
group by
	p.id,
	p.tipo,
	p.zona,
	p.situacion,
	year(v.fecha_hora_visita)
),
prom_tipo_prop as (
select
	cvp.tipo,
	avg(cvp.cant_vis) prom_vis
from
	cant_vis_prop cvp
where
	anio = 2024
group by
	cvp.tipo
)
select
	cvp.id,
	cvp.tipo,
	cvp.zona,
	cvp.situacion,
	cvp.cant_vis,
	coalesce(ptp.prom_vis, 0) promedio_vis
from
	cant_vis_prop cvp
left join prom_tipo_prop ptp on
	ptp.tipo = cvp.tipo
where
	cvp.cant_vis > coalesce(ptp.prom_vis, 0);