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