/*
B.AD01 - Salas alternativas. 

Cuando una sala tiene un inconveniente cerca de una presentación 
la empresa debe de forma urgente organizar la presentación en 
otra sala alternativa. 

Para ello se debe crear el procedimiento almacenado salas_alternativas 
que reciba como parámetro el id de locación y número de sala y rango 
de fechas donde no podrá utilizarse la sala y por cada presentación 
ya organizada en dichas fechas devuelva todas las salas que: 
[X] 1. Sean de la misma locación que la sala a reemplazar 

[X] 2. Tengan una capacidad superior a la cantidad de entradas vendidas para la presentación 

[X] 3. La sala tenga estado habilitada 
Nota: no es necesario tener en cuenta si la nueva sala ya tiene agendadas presentaciones. 

Indicar id y nombre de la locación, número, nombre y capacidad de la sala. 

Probar el procedimiento con la sala 1 de la locación 11001, 
la misma estará en matenimiento desde el 20 de noviembre de 
2023 al 30 de noviembre de 2023.
*/
USE `convenciones_underground_mod`;
DROP procedure IF EXISTS `salas_alternativas3`;

DELIMITER $$
USE `convenciones_underground_mod`$$
CREATE PROCEDURE `salas_alternativas3` (IN p_id_locacion INT, 
    IN p_nro_sala INT, 
    IN p_fecha_hora_ini DATETIME, 
    IN p_fecha_hora_hasta DATETIME)
BEGIN
-- 1. Limpieza previa
    DROP TEMPORARY TABLE IF EXISTS presentacion_cant_vendidas;

    -- 2. Creamos la tabla temporal con las presentaciones AFECTADAS y sus ventas
    CREATE TEMPORARY TABLE presentacion_cant_vendidas
    SELECT 
        pre.id_locacion,
        pre.nro_sala, -- Esta es la sala "rota"
        pre.fecha_hora_ini,
        COUNT(pre_ent.id_evento) AS cant_ent_vend
    FROM presentacion pre
    LEFT JOIN presentacion_entrada pre_ent ON
        pre.id_locacion = pre_ent.id_locacion AND
        pre.nro_sala = pre_ent.nro_sala AND
        pre.fecha_hora_ini = pre_ent.fecha_hora_ini
    WHERE 
        pre.id_locacion = p_id_locacion AND
        pre.nro_sala = p_nro_sala AND
        -- Lógica de superposición de fechas (Evento empieza antes de que termine mant. y termina después de que empiece mant.)
        pre.fecha_hora_ini < p_fecha_hora_hasta AND
        pre.fecha_hora_fin > p_fecha_hora_ini
    GROUP BY 
        pre.id_locacion,
        pre.nro_sala,
        pre.fecha_hora_ini;
    
    -- 3. Consulta Final: Cruzamos las afectadas con las CANDIDATAS
    SELECT 
        loc.id AS id_locacion,
        loc.nombre AS nombre_locacion,
        sal.nro AS nro_sala_alternativa,
        sal.nombre AS nombre_sala_alternativa,
        sal.capacidad_maxima,
        pre_ven.fecha_hora_ini AS fecha_presentacion_original -- Importante para distinguir eventos
    FROM sala sal
    INNER JOIN locacion loc ON
        sal.id_locacion = loc.id
    -- Aquí hacemos el cruce: Traemos las presentaciones afectadas de la tabla temporal
    INNER JOIN presentacion_cant_vendidas pre_ven ON
        sal.id_locacion = pre_ven.id_locacion -- Misma locación
    WHERE 
        sal.estado = 'habilitada' AND
        sal.nro <> p_nro_sala AND -- IMPORTANTE: Que NO sea la sala rota
        sal.capacidad_maxima > pre_ven.cant_ent_vend; -- Que quepan los invitados

    -- 4. Limpieza final
    DROP TEMPORARY TABLE IF EXISTS presentacion_cant_vendidas;
END$$

DELIMITER ;

-- Prueba:
call salas_alternativas(11001, 1, '2023-11-20', '2023-11-30'); 
call salas_alternativas2(11001, 1, '2023-11-20', '2023-11-30'); 
call salas_alternativas3(11001, 1, '2023-11-20', '2023-11-30'); 
call salas_alternativas4(11001, 1, '2023-11-20', '2023-11-30'); 
