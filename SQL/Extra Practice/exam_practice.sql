use guarderia_gaghiel;
/* Listar las embarcaciones con contratos activos (sin fecha de baja) que se estén guardando
en camas de sectores de tipo de operación manual. Indicar hin y nombre de la embarcación,
fecha y hora del contrato, número de cama, código y nombre del sector donde se
almacenan, código y nombre del tipo de embarcación. Ordenar los registros por fecha y
hora de contrato descendente y nombre ascendente. */
select
  em.hin,
  em.nombre,
  ec.fecha_hora_contrato,
  ec.numero_cama,
  se.codigo,
  se.nombre
from
  embarcacion em
  inner join embarcacion_cama ec on em.hin = ec.hin
  inner join tipo_embarcacion te on em.codigo_tipo_embarcacion = te.codigo
  inner join sector se on ec.codigo_sector = se.codigo
where
  te.operacion_requerida = 'manual'
order by
  ec.fecha_hora_contrato desc,
  em.nombre asc;

/* Listar los socios que son personas físicas (con tipo de documento dni) y sus embarcaciones
y, en caso que en alguna de las salidas hayan regresado tarde, listar dichas salidas. Indicar,
número y nombre del socio; hin, nombre y descripción de la embarcación; fechas y horas de
salida, regreso real y tentativo. */
select
  s.numero,
  s.nombre,
  em.hin,
  em.nombre,
  em.descripcion,
  sa.fecha_hora_salida,
  sa.fecha_hora_regreso_real,
  sa.fecha_hora_regreso_tentativo
from
  socio s
  inner join embarcacion em on s.numero = em.numero_socio
  left join salida sa on em.hin = sa.hin
  and sa.fecha_hora_regreso_real > sa.fecha_hora_regreso_tentativo
where
  s.tipo_doc = 'dni';

use convenciones_underground;
/* Listar los empleados con categoría supervisor y, solo para los que hayan ocupado el rol de
“coordinador” para algún evento, mostrar el/los eventos para el que lo ocuparon, el resto
mostrar null. Indicar cuil, nombre y apellido del empleado; id, nombre y tipo del evento. */
select
  emp.cuil,
  emp.nombre,
  emp.apellido,
  eve.id,
  eve.nombre,
  eve.tipo
from
  empleado emp
  left join encargado_evento enc_eve on emp.cuil = enc_eve.cuil_encargado
  and enc_eve.rol = 'coordinador'
  left join evento eve on enc_eve.id_evento = eve.id
where
  emp.categoria = 'supervisor';

/* Listar los presentadores de alguna presentación realizada en locaciones de zona de "Orth".
Indicar el id, nombre, apellido y denominación del presentador; nombre, tipo de
presentación y fecha y hora de inicio. Ordenar ascendente por cuit del presentador y fecha
de inicio de la presentación descendente. */
select
  pre.id,
  pre.nombre,
  pre.apellido,
  pre.denominacion,
  pres.nombre as presentacion_nombre,
  pres.tipo as presentacion_tipo,
  pre_pres.fecha_hora_ini
from
  presentador pre
  inner join presentador_presentacion pre_pres on pre.id = pre_pres.id_presentador
  inner join locacion loc on pre_pres.id_locacion = loc.id
  inner join presentacion pres on pre_pres.id_locacion = pres.id_locacion
  and pre_pres.nro_sala = pres.nro_sala
  and pre_pres.fecha_hora_ini = pres.fecha_hora_ini
where
  loc.zona = 'Orth'
order by
  pre.cuit,
  pre_pres.fecha_hora_ini desc;

use cooperativa_sustentable;
/* Listar los miembros y, si lo hubiera hecho, los lotes donde participó en la producción hace 2
meses atrás (julio). Indicando: cuil, nombre y apellido del miembro y de los lotes producidos,
código de producto, número de lote, fecha de producción y cantidad de horas. */
select
  mie.cuil,
  mie.nombre,
  mie.apellido,
  lot.codigo_producto,
  lot.numero,
  lot.fecha_produccion,
  lot.cantidad_producida
from
  miembro mie
  left join produce pro on mie.cuil = pro.cuil_miembro
  left join lote lot on pro.codigo_producto = lot.codigo_producto
  and pro.numero_lote = lot.numero
  and lot.fecha_produccion between '20250701' and '20250731';

/* Listar productos que tengan algún material con stock menor a la cantidad utilizada para
componer dicho producto. Indicar código y nombre del producto y de él/los materiales con
bajo stock, código, nombre, unidad de medida, stock y cantidad que componen. Ordenar por
nombre de material alfabéticamente y stock en forma descendente. */
select
  p.codigo as producto_codigo,
  p.nombre as producto_nombre,
  m.codigo as material_codigo,
  m.nombre as material_nombre,
  m.unidad_medida,
  m.stock,
  c.cantidad
from
  producto p
  inner join composicion c on p.codigo = c.codigo_producto
  inner join material m on c.codigo_material = m.codigo
where
  m.stock < c.cantidad
order by
  m.nombre,
  m.stock desc;

use role_play_events;
/* Listar para cada tour contratado entre enero y julio de 2022 (inclusive) los clientes que lo
contrataron. Indicar número y temática del tour, fecha y hora de contratación y cuil, tipo y
denominación del cliente. No se deberán mostrar registros repetidos y deberá ordenarse
alfabéticamente por denominación del cliente. */
select distinct
  t.nro,
  t.tematica,
  c.fecha_hora,
  cl.cuil,
  cl.tipo,
  cl.denom
from
  tour t
  inner join contrata c on t.nro = c.nro_tour
  inner join cliente cl on c.cuil_cliente = cl.cuil
where
  c.fecha_hora between '20220101' and '20220731'
order by
  cl.denom;

/* Listar los idiomas y, para aquellos que hayan sido solicitados en contrataciones de julio de
2022, mostrar en qué tours fueron solicitados. Indicar código y nombre del idioma, número
de tour y temática del tour. Ordenar por nombre del idioma alfabéticamente. */
select
  i.codigo,
  i.nombre,
  t.nro,
  t.tematica
from
  idioma i
  left join contrata c on i.codigo = c.codigo_idioma
  and c.fecha_hora between '20220701' and '20220731'
  left join tour t on c.nro_tour = t.nro
order by
  i.nombre;

/* Listar las temáticas de los tours y todas las actividades que se han realizado en las escalas
de los tours de dicha temática que comenzaron durante el 2021. Indicar, temática, código y
nombre de la locación, número, descripción y equipamiento de la actividad. Ordenar por
temática alfabéticamente. No se deben repetir registros. */
select distinct
  t.tematica,
  l.codigo,
  l.nombre,
  a.nro,
  a.descripcion,
  a.equipamiento
from
  tour t
  inner join escala e on t.nro = e.nro_tour
  inner join actividad a on e.codigo_locacion = a.codigo_locacion
  and e.nro_actividad = a.nro
  inner join locacion l on a.codigo_locacion = l.codigo
where
  t.fecha_hora_salida between '20210101' and '20211231T235959'
order by
  t.tematica;

/* Indicar todas las locaciones con ambientación SNK y si fueron visitadas durante un tour en
agosto de 2022 indicar los datos del mismo, la escala y actividad por la cual la visitaron.
Indicar código y nombre de la locación, número, fecha de salida y temática del tour, número
de la actividad y fecha y horas de la escala. */
select
  l.codigo,
  l.nombre,
  t.nro,
  t.fecha_hora_salida,
  t.tematica,
  e.nro_actividad,
  e.fecha_hora_ini,
  e.fecha_hora_fin
from
  locacion l
  left join escala e on l.codigo = e.codigo_locacion
  and e.fecha_hora_ini between '20220801' and '20220831'
  left join tour t on e.nro_tour = t.nro
where
  l.ambientacion = 'SNK';

/* Listar todos los guías de la empresa y si han guiado algún tour con temática “Hunter X” la
información de contratos. Indicar cuil, nombre y apellido del guía y si hay número de tour,
año y mes de salida, importe y cantidad de entradas del contrato, cuil y denominación del
cliente y si se solicitó algún idioma código y nombre del mismo. */
select
  e.cuil cuil_guia,
  e.nombre nombre_guia,
  e.apellido,
  t.nro nro_tour,
  year (t.fecha_hora_salida) anio,
  month (t.fecha_hora_salida) mes,
  c.importe,
  c.cant_entradas,
  cl.cuil cuil_cliente,
  cl.denom,
  i.codigo codigo_idioma,
  i.nombre nombre_idioma
from
  empleado e
  left join tour t on e.cuil = t.cuil_guia
  and t.tematica = 'Hunter X'
  left join contrata c on t.nro = c.nro_tour
  left join cliente cl on c.cuil_cliente = cl.cuil
  left join idioma i on c.codigo_idioma = i.codigo
where
  e.tipo = 'guia';

/* Listar todos los empleados que trabajaron en algún tour con temática SNK ya sea como
guías o como encargados de alguna de sus escalas. Indicar cuil, nombre y apellido del
empleado, número, fecha de salida del tour. Ordenar por apellido y nombre alfabéticamente,
fecha y hora de salida ascendente y no repetir registros. */
select distinct
  e.cuil,
  e.nombre,
  e.apellido,
  coalesce(t1.nro, t2.nro) nro_tour,
  coalesce(t1.fecha_hora_salida, t2.fecha_hora_salida) fecha_salida
from
  empleado e
  left join tour t1 on e.cuil = t1.cuil_guia
  and t1.tematica = 'SNK'
  left join escala s on s.cuil_encargado = e.cuil
  left join tour t2 on s.nro_tour = t2.nro
  and t2.tematica = 'SNK'
where
  t1.nro is not null
  or t2.nro is not null
order by
  e.apellido,
  e.nombre,
  fecha_salida;
