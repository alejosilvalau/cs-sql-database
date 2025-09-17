use agencia_personal;

/*
 * Exercise 1
 * ¿ Qué personas fueron contratadas por las mismas empresas que Stefanía Lopez ? 
 */
select
  distinct p.dni,
  p.apellido,
  p.nombre
from
  personas p
  inner join contratos c on p.dni = c.dni
where
  c.cuit in (
    select
      c2.cuit
    from
      contratos c2
      inner join personas p2 on c2.dni = p2.dni
    where
      p2.nombre = 'Stefanía'
      and p2.apellido = 'Lopez'
  );

/* 
 * Exercise 2 
 * Encontrar a aquellos empleados que ganan menos que el máximo sueldo de los empleados de Viejos Amigos.
 */
select
  max(con.sueldo) into @max_sueldo
from
  contratos con
  inner join empresas emp on emp.cuit = con.cuit
where
  emp.razon_social = 'Viejos Amigos';

select
  p.dni,
  concat(p.nombre, ' ', p.apellido),
  c.sueldo
from
  personas p
  inner join contratos c on p.dni = c.dni
where
  c.sueldo < @max_sueldo;

/*
 * Exercise 3
 * Mostrar empresas contratantes y sus promedios de comisiones pagadas o a pagar, 
 * pero sólo de aquellas cuyo promedio supere al promedio de Tráigame eso. 
 */
select
  avg(com.importe_comision) into @prom_traigame_eso
from
  contratos con
  inner join empresas emp on emp.cuit = con.cuit
  inner join comisiones com on com.nro_contrato = con.nro_contrato
where
  emp.razon_social = 'Traigame eso'
group by
  con.cuit;

select
  emp.cuit,
  emp.razon_social,
  avg(com.importe_comision) prom
from
  empresas emp
  inner join contratos con on emp.cuit = con.cuit
  inner join comisiones com on con.nro_contrato = com.nro_contrato
where
  emp.razon_social <> 'Tráigame eso'
group by
  emp.cuit,
  emp.razon_social
having
  prom > @prom_traigame_eso;

-- O con una subconsulta
select
emp.cuit,
emp.razon_social,
avg(com.importe_comision) prom
from
  empresas emp
  inner join contratos con on emp.cuit = con.cuit
  inner join comisiones com on con.nro_contrato = com.nro_contrato
where
  emp.razon_social <> 'Tráigame eso'
group by
  emp.cuit,
  emp.razon_social
having
  prom > (
    select
      avg(com.importe_comision)
    from
contratos con
inner join empresas emp on emp.cuit = con.cuit
inner join comisiones com on com.nro_contrato = con.nro_contrato
where
  emp.razon_social = 'Traigame eso'
group by
con.cuit
);

/*
 * Exercise 4
 * Seleccionar las comisiones pagadas que tengan un importe menor al promedio 
 * de todas las comisiones(pagas y no pagas), mostrando razón social de la 
 * empresa contratante, mes contrato, año contrato , nro. contrato, 
 * nombre y apellido del empleado. 
 */
select
  emp.razon_social,
  per.nombre,
  per.apellido,
  con.nro_contrato,
  com.mes_contrato,
  com.anio_contrato,
  com.importe_comision
from
  comisiones com
  inner join contratos con on con.nro_contrato = com.nro_contrato
  inner join empresas emp on emp.cuit = con.cuit
  inner join personas per on per.dni = con.dni
where
  com.fecha_pago is not null
  and com.importe_comision < (
select
  avg(importe_comision)
from
  comisiones
);

/*
 * Exercise 5
 * Determinar las empresas que pagaron en promedio la mayor de las comisiones.
 */
select
  max(importe_comision) into @max_com
from
  comisiones;

select
  emp.razon_social,
  avg(com.importe_comision) prom
from
  empresas emp
  inner join contratos con on con.cuit = emp.cuit
  inner join comisiones com on com.nro_contrato = con.nro_contrato
group by
  emp.razon_social
having
  prom = @max_com;

/*
 * Exercise 6
 * Seleccionar los empleados que no tengan educación no formal o terciario. 
 */
select
  per.apellido,
  per.nombre
from
  personas per
where
  per.dni not in (
    select
      per.dni
    from
      personas per
      inner join personas_titulos pt on per.dni = pt.dni
      inner join titulos ti on pt.cod_titulo = ti.cod_titulo
    where
      ti.tipo_titulo = 'Educacion no formal'
      or ti.tipo_titulo = 'Terciario'
  );
/*
 * Exercise 7
 * Mostrar los empleados cuyo salario supere al promedio de sueldo de la empresa que los contrató.
 */
drop temporary table if exists promedios;

create temporary table promedios
select
  con.cuit,
  avg(con.sueldo) avg_sueldo
from
  contratos con
group by
  con.cuit;

select
  con.cuit,
  con.dni,
  con.sueldo,
  prom.avg_sueldo
from
  contratos con
  inner join promedios prom on con.cuit = prom.cuit
where
  con.sueldo > prom.avg_sueldo;

/*
 * Exercise 8
 * Determinar las empresas que pagaron en promedio la mayor o menor de las comisiones
 */
select
  min(importe_comision),
  max(importe_comision) into @min_com,
  @max_com
from
  comisiones;

select
  emp.razon_social,
  avg(com.importe_comision) promedio
from
  contratos con
  inner join empresas emp on con.cuit = emp.cuit
  inner join comisiones com on con.nro_contrato = com.nro_contrato
where
  com.fecha_pago is not null
group by
  emp.cuit
having
  promedio = @min_com
  or promedio = @max_com;

use afatse;

/*
 * Exercise 9
 * Alumnos que se  hayan inscripto a más cursos que Antoine de Saint-Exupery. 
 * Mostrar todos los datos de los alumnos, la cantidad de cursos a la que se inscribió y 
 * cuantas veces más que Antoine de Saint-Exupery.
 */
select
  count(1) into @min_cant_ins
from
  alumnos alu
  inner join inscripciones ins on alu.dni = ins.dni
where
  alu.nombre = 'Antoine de'
  and alu.apellido = 'Saint-Exupery'
group by
  ins.dni;

select
  alu.*,
  count(1) cant,
  count(1) - @min_cant_ins
from
  alumnos alu
  inner join inscripciones ins on alu.dni = ins.dni
group by
  alu.dni,
  alu.nombre,
  alu.apellido,
  alu.tel,
  alu.email,
  alu.direccion
having
  cant > @min_cant_ins;
/*
 * Exercise 10
 * En el año 2014, qué cantidad de alumnos se han inscripto a los Planes de Capacitación 
 * indicando para cada Plan de Capacitación la cantidad de alumnos inscriptos y 
 * el porcentaje que representa respecto del total de inscriptos a los Planes de Capacitación 
 * dictados en el año.
 */
select
  count(1) into @cant_ins
from
  inscripciones
where
  year(fecha_inscripcion) = 2014;

select
  pc.nom_plan,
  count(1) cant,
  ((count(1) * 100) / @cant_ins) as '% Total'
from
  inscripciones ins
  inner join plan_capacitacion pc on ins.nom_plan = pc.nom_plan
where
  year(ins.fecha_inscripcion) = 2014
group by
  pc.nom_plan;
/*
 * Exercise 11
 * Indicar el valor actual de los planes de Capacitación  
 */
drop temporary table if exists fecha_valores_plan;

create temporary table fecha_valores_plan
select
  nom_plan,
  max(fecha_desde_plan) as fecha_valor_actual
from
  valores_plan
where
  fecha_desde_plan <= NOW()
group by
  nom_plan;

select
  vp.*
from
  valores_plan vp
  inner join fecha_valores_plan fvp on fvp.nom_plan = vp.nom_plan
  and fvp.fecha_valor_actual = vp.fecha_desde_plan;

drop temporary table if exists fecha_valores_plan;
/*
 * Exercise 12
 * Plan de capacitacion mas barato. Indicar los datos del plan de capacitacion y el valor actual 
 */
drop temporary table if exists fecha_actual;

drop temporary table if exists valor_actual;

create temporary table if not exists fecha_actual
select
  nom_plan,
  max(fecha_desde_plan) as fecha_valor_actual
from
  valores_plan
where
  fecha_desde_plan <= NOW()
group by
  nom_plan;

create temporary table if not exists valor_actual
select
  vp.*
from
  valores_plan vp
  inner join fecha_actual fa on fa.nom_plan = vp.nom_plan
  and fa.fecha_valor_actual = vp.fecha_desde_plan;

select
  min(valor_plan) into @min_valor_actual
from
  valor_actual;

select
  pc.*,
  vp.valor_plan
from
  valores_plan vp
  inner join fecha_actual fa on fa.nom_plan = vp.nom_plan
  and fa.fecha_valor_actual = vp.fecha_desde_plan
  inner join plan_capacitacion pc on vp.nom_plan = pc.nom_plan
where
  vp.valor_plan = @min_valor_actual;

drop temporary table if exists fecha_actual;

drop temporary table if exists valor_actual;
/*
 * Exercise 13
 * ¿Qué instructores que han dictado algún curso del Plan de Capacitación 
 * “Marketing 1” el año 2014 y no vayan a dictarlo este año? (año 2015) 
 */
drop temporary table if exists instr_2015;

create temporary table if not exists instr_2015
select
  ins.cuil
from
  instructores ins
  inner join cursos_instructores ci on ins.cuil = ci.cuil
  inner join cursos cur on cur.nom_plan = ci.nom_plan
  and cur.nro_curso = ci.nro_curso
where
  ci.nom_plan = 'Marketing 1'
  and year(cur.fecha_ini) = 2015;

select
  ins.cuil
from
  instructores ins
  inner join cursos_instructores ci on ins.cuil = ci.cuil
  inner join cursos cur on cur.nom_plan = ci.nom_plan
  and cur.nro_curso = ci.nro_curso
where
  ci.nom_plan = 'Marketing 1'
  and year(cur.fecha_ini) = 2014
  and ins.cuil not in (
    select
      cuil
    from
      instr_2015
  );

drop temporary table if exists instr_2015;

-- Si fuese "and year(cur.fecha_ini) = 2014 and year(cur.fecha_ini) <> 2015", 
-- solo filtraría los cursos que se hicieron en 2014.
--
-- Segunda solución
select
  ins.cuil
from
  instructores ins
  inner join cursos_instructores ci on ins.cuil = ci.cuil
  inner join cursos cur on cur.nom_plan = ci.nom_plan
  and cur.nro_curso = ci.nro_curso
where
  ci.nom_plan = 'Marketing 1'
  and year(cur.fecha_ini) = 2014
  and ins.cuil not in (
    select
      ci_sub.cuil
    from
      cursos_instructores ci_sub
      inner join cursos cur_sub on ci_sub.nom_plan = cur_sub.nom_plan
      and ci_sub.nro_curso = cur_sub.nro_curso
    where
      cur_sub.nom_plan = 'Marketing 1'
      and year(cur_sub.fecha_ini) = 2015
      and ci_sub.cuil = ins.cuil
  );
/*
 * Exercise 14
 * Alumnos que tengan todas sus cuotas pagas hasta la fecha. 
 */
select
  distinct alu.dni,
  alu.nombre,
  alu.apellido,
  alu.tel,
  alu.email,
  alu.direccion
from
  alumnos alu
  inner join cuotas cu on cu.dni = alu.dni
where
  alu.dni not in (
    select
      distinct dni
    from
      cuotas
    where
      fecha_pago is null
      and fecha_pago <= now()
  );

-- Solución con subquery dependiente
select
  distinct alu.dni,
  alu.nombre,
  alu.apellido,
  alu.tel,
  alu.email,
  alu.direccion
from
  alumnos alu
  inner join cuotas cu on cu.dni = alu.dni
where
  alu.dni not in (
    select
      distinct dni
    from
      cuotas cu_sub
    where
      alu.dni = cu_sub.dni
      and fecha_pago is null
      and fecha_pago <= now()
  );
/*
 * Exercise 15
 * Alumnos cuyo promedio supere al del curso que realizan. 
 * Mostrar dni, nombre y apellido, promedio y promedio del curso. 
 */
-- Mi solución
select
  alu.dni,
  alu.nombre,
  alu.apellido,
  AVG(eva.nota) as prom,
  (
    select
      AVG(eva_sub.nota)
    from
      evaluaciones eva_sub
    where
      eva_sub.nom_plan = eva.nom_plan
      and eva_sub.nro_curso = eva.nro_curso
  ) as prom_curso
from
  evaluaciones eva
  inner join alumnos alu on eva.dni = alu.dni
group by
  alu.dni,
  alu.nombre,
  alu.apellido,
  eva.nom_plan,
  eva.nro_curso
having
  prom > prom_curso;

-- Solución de la cátedra
drop temporary table if exists promedios;

create temporary table promedios
select
  nom_plan,
  nro_curso,
  avg(nota) prome
from
  evaluaciones
group by
  nom_plan,
  nro_curso;

select
  distinct ev.dni,
  alu.nombre,
  alu.apellido,
  avg(ev.nota) prom,
  p.prome prom_curso
from
  evaluaciones ev
  inner join alumnos alu on ev.dni = alu.dni
  inner join promedios p on ev.nom_plan = p.nom_plan
  and ev.nro_curso = p.nro_curso
group by
  ev.dni,
  alu.nombre,
  alu.apellido,
  p.prome
having
  avg(ev.nota) > p.prome;

drop temporary table promedio;
/*
 * Exercise 16
 * Para conocer la disponibilidad de lugar en los cursos que empiezan 
 * en abril para lanzar una campaña  se desea conocer la cantidad de 
 * alumnos inscriptos a los cursos que comienzan a partir del 1/04/2014 
 * indicando: Plan de Capacitación, curso, fecha de inicio, salón, cantidad 
 * de alumnos inscriptos y diferencia con el cupo de alumnos registrado para el 
 * curso que tengan al más del 80% de lugares disponibles respecto del cupo.
 */
-- Mi solución
drop temporary table if exists cant_alumnos_cursos;

create temporary table if not exists cant_alumnos_cursos
select
  cur.nom_plan,
  cur.nro_curso,
  count(1) cant_alu
from
  alumnos alu
  inner join inscripciones ins on alu.dni = ins.dni
  inner join cursos cur on cur.nom_plan = ins.nom_plan
  and cur.nro_curso = ins.nro_curso
where
  cur.fecha_ini >= '2014-04-01'
group by
  cur.nom_plan,
  cur.nro_curso;

select
  cur.nom_plan,
  cur.nro_curso,
  cur.fecha_ini,
  cur.salon,
  cur.cupo,
  cac.cant_alu,
  (cur.cupo - cac.cant_alu) lugares_libres
from
  cursos cur
  inner join cant_alumnos_cursos cac on cur.nom_plan = cac.nom_plan
  and cur.nro_curso = cac.nro_curso
where
  cur.fecha_ini >= '2014-04-01'
having
  lugares_libres > (cur.cupo * 0.8);

drop temporary table if exists cant_alumnos_cursos;

-- Solución de la cátedra
select
  cur.nro_curso,
  fecha_ini,
  salon,
  cupo,
  count(dni) Cantidad,
  (cupo - count(dni)) as "Diferencia con Cupo"
from
  cursos cur
  inner join inscripciones ins on cur.nro_curso = ins.nro_curso
  and cur.nom_plan = ins.nom_plan
where
  fecha_ini >= "20140401"
group by
  cur.nro_curso,
  fecha_ini,
  salon,
  cupo
having
  (cupo - count(dni)) > (cupo * 0.80);