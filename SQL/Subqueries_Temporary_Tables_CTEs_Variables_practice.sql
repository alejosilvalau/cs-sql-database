-- use agencia_personal;
-- Exercise 7
/* Mostrar los empleados cuyo salario supere al promedio de sueldo de la empresa que los contrató.  */
drop table if exists emp_prom;

create TEMPORARY table emp_prom (
  select
    cuit,
    avg(sueldo)
  from
    contratos
  group by
    cuit
);

select
  *
from
  emp_prom;