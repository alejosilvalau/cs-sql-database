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