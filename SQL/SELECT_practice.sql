USE agencia_personal;

-- Exercise 2
SELECT apellido, nombre, fecha_registro_agencia from personas;

-- Exercise 5
SELECT 
  CONCAT(nombre, ' ' , apellido) 'Apellido y Nombre', 
  fecha_nacimiento 'Fecha Nac.', 
  telefono 'Telefono', 
  direccion 'Direccion' 
FROM personas 
WHERE dni IN(27890765, 29345777, 31345778)
ORDER BY fecha_nacimiento;

-- Exercise 8
SELECT * FROM solicitudes_empresas ORDER BY fecha_solicitud;

-- Exercise 9
SELECT * FROM antecedentes WHERE fecha_hasta IS NULL ORDER BY fecha_desde;

-- Exercise 10
SELECT * FROM antecedentes WHERE fecha_hasta IS NOT NULL AND fecha_hasta NOT BETWEEN '2013-06-01' AND '2013-12-01' ORDER BY dni; 

-- Exercise 12
SELECT * FROM titulos WHERE desc_titulo LIKE 'Tecnico%';
