-- use afatse;
/* Identificar el valor de un plan a 01 febrero de 2015. 
 (Forma de obtener el último de los registros de un historial de valores)*/
drop temporary table if exists valores_feb_2015;

create temporary table valores_feb_2015
select
  nom_plan,
  max(fecha_desde_plan) as max_fecha_desde_plan
from
  valores_plan
where
  fecha_desde_plan <= '2015-02-01'
group by
  nom_plan;

select
  pc.*,
  vp.valor_plan valor_a_feb_2015
from
  valores_plan vp
  inner join valores_feb_2015 vf on vp.nom_plan = vf.nom_plan
  and vp.fecha_desde_plan = vf.max_fecha_desde_plan
  inner join plan_capacitacion pc on vp.nom_plan = pc.nom_plan;

/*
 Ejemplo de CTE
 
 WITH DepartmentSalaries AS (
 SELECT
 DepartmentID,
 SUM(Salary) AS TotalDepartmentSalary
 FROM
 Employees
 GROUP BY
 DepartmentID
 )
 SELECT
 e.EmployeeName,
 d.TotalDepartmentSalary
 FROM
 Employees e
 JOIN DepartmentSalaries d ON e.DepartmentID = d.DepartmentID;
 */
/* 
 Forma simplificada del CTE
 
 -- Select customer names and total revenue from their orders
 SELECT
 c.CustomerName,
 SUM(p.Price * o.Quantity) AS TotalRevenue
 FROM
 Orders o -- Join to get customer and products table
 JOIN Customers c ON o.CustomerID = c.CustomerID
 JOIN Products p ON o.ProductID = p.ProductID
 WHERE
 YEAR(o.OrderDate) = 2024
 GROUP BY
 c.CustomerName
 HAVING
 SUM(p.Price * o.Quantity) > 1000;
 */