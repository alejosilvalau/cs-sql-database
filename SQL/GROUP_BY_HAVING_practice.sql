use agencia_personal;

-- Exercise 3
/* Mostrar el promedio, desviación estándar y varianza del puntaje de las evaluaciones de entrevistas,
 por tipo de evaluación y entrevistador.Ordenar por promedio en forma ascendente y luego por desviación estándar en forma descendente. */
select
  e.nombre_entrevistador,
  ee.cod_evaluacion,
  avg(ee.resultado) as promedio,
  std(ee.resultado) as desviacion_estandar,
  variance(ee.resultado) as varianza
from
  entrevistas_evaluaciones ee
  inner join entrevistas e on ee.nro_entrevista = e.nro_entrevista
group by
  e.nombre_entrevistador,
  ee.cod_evaluacion
order by
  promedio,
  desviacion_estandar desc;

-- Exercise 4
/* Ídem 3) pero para Angélica Doria,con promedio mayor a 71.Ordenar por código de evaluación. */
select
  e.nombre_entrevistador,
  ee.cod_evaluacion,
  avg(ee.resultado) as promedio,
  std(ee.resultado) desviacion_estandar,
  var_pop(ee.resultado) varianza
from
  entrevistas_evaluaciones ee
  inner join entrevistas e on ee.nro_entrevista = e.nro_entrevista
where
  e.nombre_entrevistador = 'Angelica Doria'
group by
  nombre_entrevistador,
  cod_evaluacion
having
  promedio > 71
order by
  cod_evaluacion;

-- Exercise 5
/* Cuantas entrevistas fueron hechas por cada entrevistador en octubre de 2014. */
select
  nombre_entrevistador,
  count(*) cantidad_entrevistas
from
  entrevistas
where
  fecha_entrevista between '2014-10-01'
  and '2014-10-31'
group by
  nombre_entrevistador;

-- Exercise 6
/* Ídem 4) pero para todos los entrevistadores.Mostrar nombre y cantidad.Ordenado por cantidad de entrevistas. */
select
  e.nombre_entrevistador,
  ee.cod_evaluacion,
  count(*) cantidad_entrevistas,
  avg(ee.resultado) promedio,
  std(ee.resultado) desviacion_estandar,
  var_pop(ee.resultado) varianza
from
  entrevistas_evaluaciones ee
  inner join entrevistas e on ee.nro_entrevista = e.nro_entrevista
group by
  nombre_entrevistador,
  cod_evaluacion
having
  promedio > 71
order by
  cantidad_entrevistas;

-- Exercise 7
/* Ídem 6) para aquellos cuya cantidad de entrevistas por codigo de evaluacion sea myor mayor que 1.Ordenado por nombre en forma descendente y por codigo de evalucacion en forma ascendente */
select
  e.nombre_entrevistador,
  ee.cod_evaluacion,
  count(*) cantidad_entrevistas,
  avg(ee.resultado) promedio,
  std(ee.resultado) desviacion_estandar,
  var_pop(ee.resultado) varianza
from
  entrevistas_evaluaciones ee
  inner join entrevistas e on ee.nro_entrevista = e.nro_entrevista
group by
  nombre_entrevistador,
  cod_evaluacion
having
  promedio > 71
  and cantidad_entrevistas > 1
order by
  e.nombre_entrevistador desc,
  ee.cod_evaluacion asc;

-- Exercise 10
/* Mostrar la cantidad de empresas diferentes que han realizado solicitudes y la diferencia respecto al total de solicitudes. */
select
  count(distinct cuit) cantidad,
  count(cuit) - count(distinct cuit) diferencia
from
  solicitudes_empresas;

-- Exercise 11
/* Cantidad de solicitudes por empresas. */
select
  e.cuit,
  e.razon_social,
  count(*) cantidad_solicitudes
from
  solicitudes_empresas se
  inner join empresas e on se.cuit = e.cuit
group by
  e.cuit,
  e.razon_social
order by
  cantidad_solicitudes desc;

-- Exercise 12
/* Cantidad de solicitudes por empresas y cargos. */
select
  e.cuit,
  e.razon_social,
  c.desc_cargo,
  count(*) cantidad_solicitudes
from
  solicitudes_empresas se
  inner join empresas e on se.cuit = e.cuit
  inner join cargos c on se.cod_cargo = c.cod_cargo
group by
  e.cuit,
  e.razon_social,
  c.desc_cargo;