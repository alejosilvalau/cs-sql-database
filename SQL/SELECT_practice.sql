USE agencia_personal;

-- Exercise 2
/* Mostrar la estructura de la tabla Personas.Mostrar el apellido y nombre y la fecha de registro en la agencia. */
SELECT apellido, nombre, fecha_registro_agencia from personas;

-- Exercise 5
/* Mostrar los datos de ej.Anterior, pero para las personas 27890765, 29345777 y 31345778.Ordenadas por fecha de Nacimiento */
SELECT 
  CONCAT(nombre, ' ' , apellido) 'Apellido y Nombre', 
  fecha_nacimiento 'Fecha Nac.', 
  telefono 'Telefono', 
  direccion 'Direccion' 
FROM personas 
WHERE dni IN(27890765, 29345777, 31345778)
ORDER BY fecha_nacimiento;

-- Exercise 8
/* Mostrar las solicitudes que hayan sido hechas alguna vez ordenados en forma ascendente por fecha de solicitud. */
SELECT * FROM solicitudes_empresas ORDER BY fecha_solicitud;

-- Exercise 9
/* Mostrar los antecedentes laborales que aún no hayan terminado su relación laboral ordenados por fecha desde. */
SELECT * FROM antecedentes WHERE fecha_hasta IS NULL ORDER BY fecha_desde;

-- Exercise 10
/* Mostrar aquellos antecedentes laborales que finalizaron y cuya fecha hasta no esté entre junio del 2013 a diciembre de 2013,
 ordenados por número de DNI del empleado. */
SELECT * FROM antecedentes WHERE fecha_hasta IS NOT NULL AND fecha_hasta NOT BETWEEN '2013-06-01' AND '2013-12-01' ORDER BY dni; 

-- Exercise 12
/* Mostrar los títulos técnicos. */
SELECT * FROM titulos WHERE desc_titulo LIKE 'Tecnico%';
