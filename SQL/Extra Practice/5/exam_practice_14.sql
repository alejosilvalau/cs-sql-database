/*
B.AD02 - Presentaciones a reprogramar. 

Indicar la presentación más popular de cada temática que haya finalizado. 

Listar temática, nombre y tipo de la presentación, cantidad de entradas vendidas 
y nombre del evento donde se realizó. Ordenar por cantidad de entradas vendidas 
descendente y fecha de inicio de la presentación descendente. 

Nota: La presentación más popular de una temática es la que más entradas 
vendidas tiene de todas las presentaciones de esa temática
*/
drop temporary table if exists presentacion_cant_entradas;
drop temporary table if exists presentacion_mas_popular;

create temporary table presentacion_cant_entradas
select
	pre.id_evento,
	pre.id_locacion,
	pre.nro_sala,
    pre.fecha_hora_ini,
    eve.tematica,
	count(pre_ent.id_evento) cant_ent_vend
from presentacion pre
inner join evento eve on
	pre.id_evento = eve.id
left join presentacion_entrada pre_ent on
	pre.id_evento = pre_ent.id_evento and
    pre.nro_sala = pre_ent.nro_sala and
    pre.fecha_hora_ini = pre_ent.fecha_hora_ini
where 
	pre.fecha_hora_fin < current_timestamp()
group by
	pre.id_evento,
	pre.id_locacion,
	pre.nro_sala,
    pre.fecha_hora_ini, 
    eve.tematica;

create temporary table presentacion_mas_popular
select 
    pre_ent.tematica,
	max(pre_ent.cant_ent_vend) cant_ent_vend
from presentacion_cant_entradas pre_ent
group by 
	pre_ent.tematica;

select 
	eve.tematica,
    pre.nombre pre_nombre,
    pre.tipo,
	pre_ent.cant_ent_vend,
    eve.nombre eve_nombre
from evento eve
inner join presentacion_cant_entradas pre_ent on
	eve.id = pre_ent.id_evento
inner join presentacion_mas_popular pre_pop on
	pre_ent.tematica = pre_pop.tematica and
    pre_ent.cant_ent_vend = pre_pop.cant_ent_vend 
inner join presentacion pre on
	pre_ent.id_locacion = pre_ent.id_locacion and
    pre_ent.nro_sala = pre.nro_sala and
    pre_ent.fecha_hora_ini = pre.fecha_hora_ini
where
    pre_ent.cant_ent_vend = pre_pop.cant_ent_vend
order by
	pre_ent.cant_ent_vend desc,
    pre.fecha_hora_ini desc;

drop temporary table if exists presentacion_cant_entradas;
drop temporary table if exists presentacion_mas_popular;