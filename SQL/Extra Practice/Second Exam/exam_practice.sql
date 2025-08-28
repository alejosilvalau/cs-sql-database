use agencia_personal;

-- Ejercicio 1
select
  emp.razon_social,
  sum(com.importe_comision)
from
  comisiones com
  inner join contratos con on con.nro_contrato = com.nro_contrato
  inner join empresas emp on con.cuit
where
  com.fecha_pago is not null
  and emp.razon_social like '%Traigame eso%'
group by
  emp.razon_social;

-- Ejercicio 2
select
  emp.razon_social,
  sum(com.importe_comision)
from
  comisiones com
  inner join contratos con on con.nro_contrato = com.nro_contrato
  inner join empresas emp on con.cuit
where
  com.fecha_pago is not null
group by
  emp.razon_social;

-- Ejercicio 5
select
  nombre_entrevistador,
  count(nombre_entrevistador)
from
  entrevistas
where
  month (fecha_entrevista) = 10
  and year (fecha_entrevista) = 2014
group by
  nombre_entrevistador;

-- Ejercicio 8
select
  com.nro_contrato,
  count(com.nro_contrato) total,
  count(com.fecha_pago) pagadas,
  count(com.nro_contrato) - count(com.fecha_pago) impagas
from
  comisiones com
  inner join contratos con on com.nro_contrato = con.nro_contrato
group by
  com.nro_contrato;

-- Ejercicio 9
select
  com.nro_contrato,
  count(com.nro_contrato) total,
  ((count(com.fecha_pago) * 100) / count(1)) pagadas,
  (((count(1) - count(fecha_pago)) * 100) / count(1)) impagas
from
  comisiones com
  inner join contratos con on com.nro_contrato = con.nro_contrato
group by
  com.nro_contrato;

-- Ejercicio 13
select
  emp.cuit,
  emp.razon_social,
  count(distinct ant.dni) cantidad_de_personas
from
  empresas emp
  left join antecedentes ant on ant.cuit = emp.cuit
group by
  emp.cuit,
  emp.razon_social;

-- Ejercicio 14
select
  car.cod_cargo,
  car.desc_cargo,
  count(sol.cuit) cantidad_de_solicitudes
from
  cargos car
  left join solicitudes_empresas sol on sol.cod_cargo = car.cod_cargo
group by
  car.cod_cargo,
  car.desc_cargo
order by
  cantidad_de_solicitudes desc;

-- Ejercicio 15
select
  car.cod_cargo,
  car.desc_cargo,
  count(sol.cuit) cantidad_de_solicitudes
from
  cargos car
  left join solicitudes_empresas sol on sol.cod_cargo = car.cod_cargo
group by
  car.cod_cargo,
  car.desc_cargo
having
  cantidad_de_solicitudes >= 2;

select
  car.cod_cargo,
  car.desc_cargo,
  count(sol.cuit) cantidad_de_solicitudes
from
  cargos car
  left join solicitudes_empresas sol on sol.cod_cargo = car.cod_cargo
group by
  car.cod_cargo,
  car.desc_cargo
having
  cantidad_de_solicitudes < 2;