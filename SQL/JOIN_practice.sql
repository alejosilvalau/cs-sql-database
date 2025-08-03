USE agencia_personal;

-- Exercise 3
/* Listado de las solicitudes consignando razón social, dirección y e_mail de la empresa, descripción del cargo solicitado y años de experiencia solicitados, ordenado por fecha d solicitud y descripción de cargo. */
SELECT e.razon_social, e.direccion, e.e_mail, c.desc_cargo, anios_experiencia FROM solicitudes_empresas se 
INNER JOIN cargos c ON se.cod_cargo = c.cod_cargo
INNER JOIN empresas e ON se.cuit = e.cuit
ORDER BY fecha_solicitud, c.desc_cargo;

-- Exercise 4
/* ¿Listar todos los candidatos con título de bachiller o un título de educación no formal.Mostrar nombre y apellido, descripción del título y DNI. */
SELECT p.dni, nombre, apellido, desc_titulo FROM personas p 
INNER JOIN personas_titulos pt ON p.dni = pt.dni
INNER JOIN titulos t ON pt.cod_titulo = t.cod_titulo
WHERE t.desc_titulo = 'Bachiller' OR t.tipo_titulo = 'Educacion no formal';

-- Exercise 5
/* Realizar el punto 4 sin mostrar el campo DNI pero para todos los títulos. */
SELECT nombre, apellido, desc_titulo FROM personas p 
INNER JOIN personas_titulos pt ON p.dni = pt.dni
INNER JOIN titulos t ON pt.cod_titulo = t.cod_titulo;

-- Exercise 8
/* Mostrar los antecedentes de cada postulante: */
SELECT 
  CONCAT(nombre, ' ', apellido) 'Postulante',  
  desc_cargo 'Cargo'
FROM antecedentes a
INNER JOIN personas p ON a.dni = p.dni
INNER JOIN cargos c ON a.cod_cargo = c.cod_cargo;

-- Exercise 9
/* Mostrar todas las evaluaciones realizadas para cada solicitud ordenar en forma ascendente por empresa y descendente por cargo: */
SELECT 
  emp.razon_social 'Empresa', 
  car.desc_cargo 'Cargo',
  eva.desc_evaluacion 'Desc_evaluacion',
  ent_eva.resultado 'Resultado'
FROM entrevistas ent
INNER JOIN empresas emp ON ent.cuit = emp.cuit
INNER JOIN cargos car ON ent.cod_cargo = car.cod_cargo
INNER JOIN entrevistas_evaluaciones ent_eva ON ent.nro_entrevista = ent_eva.nro_entrevista
INNER JOIN evaluaciones eva ON ent_eva.cod_evaluacion = eva.cod_evaluacion
ORDER BY emp.razon_social, car.desc_cargo DESC;

-- Exercise 13
/* Listar todos los cargos y para aquellos que hayan sido realizados (como antecedente) por alguna persona indicar nombre y apellido de la persona y empresa donde lo ocupó. */
SELECT 
  desc_cargo,
  IFNULL(p.dni, 'Sin antecedente') AS dni,
  IFNULL(p.apellido, 'Sin antecedente') AS apellido,
  e.razon_social
FROM cargos c
LEFT JOIN antecedentes a ON c.cod_cargo = a.cod_cargo
LEFT JOIN personas p ON a.dni = p.dni
LEFT JOIN empresas e ON a.cuit = e.cuit;
