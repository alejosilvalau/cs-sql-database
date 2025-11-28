/*
 A.AD02 - Salas más pequeñas.

 La empresa desea ahorrar en el costo de las salas que alquila.

 Para ello se debe identificar para las presentaciones futuras si existe
 otra sala en la misma locación con menor capacidad pero suficiente para
 las entradas vendidas.

 Listar para todas las presentaciones futuras, la capacidad máxima de la
 sala y calcular la cantidad de entradas vendidas.

 En función de ello determinar si existe una sala diferente
 en la misma locación, que tenga menos capacidad que la sala
 ya asignada pero suficiente para las entradas vendidas.

 Indicar id y nombre de la locación, número, nombre y capacidad
 máxima de la sala actual, cantidad de entradas vendidas y de las
 salas potenciales número, nombre y capacidad máxima.
 */
drop temporary table if exists presentacion_futuras;

# Uso variables para trabajar con tablas no vacías
set @current_timestamp = '2021-11-22 20:00:00';

create temporary table presentacion_futuras
select pre.id_locacion,
  pre.nro_sala,
  sal.capacidad_maxima,
  count(1) cant_ent_vend
from presentacion pre
  inner join presentacion_entrada pre_ent on pre.id_locacion = pre_ent.id_locacion
  and pre.nro_sala = pre_ent.nro_sala
  and pre.fecha_hora_ini = pre_ent.fecha_hora_ini
  inner join entrada ent on pre_ent.id_evento = ent.id_evento
  and pre_ent.nro_entrada = ent.nro
  inner join sala sal on pre.id_locacion = sal.id_locacion
  and pre.nro_sala = sal.nro
where pre.fecha_hora_ini > @current_timestamp
group by pre.id_locacion,
  pre.nro_sala,
  sal.capacidad_maxima;

select loc.id loc_id,
  loc.nombre loc_nombre,
  sal.nro sal_act_nro,
  sal.nombre sal_act_nombre,
  pre_fut.capacidad_maxima sal_act_capacidad_maxima,
  pre_fut.cant_ent_vend,
  sal.nro sal_pot_nro,
  sal.nombre sal_pot_nombre,
  sal.capacidad_maxima sal_pot_capacidad_maxima
from sala sal
  inner join locacion loc on sal.id_locacion = loc.id
  left join presentacion_futuras pre_fut on sal.id_locacion = pre_fut.id_locacion
  and sal.nro = pre_fut.nro_sala
where sal.capacidad_maxima < pre_fut.capacidad_maxima
  and sal.capacidad_maxima >= pre_fut.cant_ent_vend
  and sal.estado = 'habilitada';
  
drop temporary table if exists salas_mas_grandes;

-- Solucion propuesta 
create temporary table if not exists salas_mas_grandes
select l.id as id_locacion,
  l.nombre as locacion_nombre,
  s.nro,
  s.nombre as sala_nombre,
  s.capacidad_maxima,
  count(*) as entradas_vendidas
from presentacion p
  inner join sala s on s.nro = p.nro_sala
  and s.id_locacion = p.id_locacion
  inner join locacion l on l.id = s.id_locacion
  inner join presentacion_entrada pe on p.id_locacion = pe.id_locacion
  and p.nro_sala = pe.nro_sala
  and p.fecha_hora_ini = pe.fecha_hora_ini
  inner join entrada e on e.id_evento = pe.id_evento
  and e.nro = pe.nro_entrada
where p.fecha_hora_ini > now()
  and e.id_comprador is not null
group by id_locacion,
  l.nombre,
  s.nro,
  s.nombre,
  s.capacidad_maxima;

select smg.*,
  sl.nombre,
  sl.nro,
  sl.capacidad_maxima
from salas_mas_grandes smg
  left join sala sl on smg.nro = sl.nro
  and smg.id_locacion = sl.id_locacion
  and sl.capacidad_maxima < smg.capacidad_maxima
  and sl.capacidad_maxima > smg.entradas_vendidas;