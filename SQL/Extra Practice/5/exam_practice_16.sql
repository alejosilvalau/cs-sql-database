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
-- Mi solución
with cant_sol_2024 as (
	select p.id,
		count(sc.id_propiedad) cant
	from propiedad p
		left join solicitud_contrato sc on p.id = sc.id_propiedad
		and year(sc.fecha_solicitud) = 2024
	group by p.id
),
prom_sol_2023 as (
	select p.tipo,
		coalesce (avg(sc.id_propiedad), 0) prom
	from propiedad p
		left join solicitud_contrato sc on p.id = sc.id_propiedad
		and year(sc.fecha_solicitud) = 2023
	group by p.tipo
)
select p.id,
	p.zona,
	p.tipo,
	p.situacion,
	cs24.cant,
	ps23.prom
from propiedad p
	left join cant_sol_2024 cs24 on cs24.id = p.id
	left join prom_sol_2023 ps23 on ps23.tipo = p.tipo
where cs24.cant > ps23.prom;


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
