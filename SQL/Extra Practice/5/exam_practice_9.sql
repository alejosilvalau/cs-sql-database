SELECT @@transaction_isolation;

set transaction isolation level repeatable read;

SELECT 
    i.numero_curso, i.numero_socio
FROM
    inscripcion i
WHERE
    EXISTS( SELECT 
            1
        FROM
            socio s
        WHERE
            s.numero = i.numero_socio);

-- Todos los socios con alguna inscripcion
SELECT 
    s.numero, s.nombre
FROM
    socio s
WHERE
    EXISTS( SELECT 
            1
        FROM
            inscripcion i
        WHERE
            s.numero = i.numero_socio);

rollback;

create user 'hola'@'%' identified by '123';
grant select on guarderia_gaghiel.* to 'hola'@'%';

SELECT 
    *
FROM
    mysql.user;

SELECT 
    numero 'n', descripcion 'd'
FROM
    actividad;

SELECT @@sql_mode;

SELECT @@log_bin_trust_function_creators;

SELECT 
    numero, ADD_TEN(numero)
FROM
    actividad;

select * from actividad;
select * from actividad;



SELECT `embarcacion_cama`.`hin`,
    `embarcacion_cama`.`codigo_sector`,
    `embarcacion_cama`.`numero_cama`,
    `embarcacion_cama`.`fecha_hora_contrato`,
    `embarcacion_cama`.`fecha_hora_baja_contrato`
FROM `guarderia_gaghiel`.`embarcacion_cama`;

SELECT 
    hin,
    codigo_sector,
    numero_cama,
    fecha_hora_contrato,
    fecha_hora_baja_contrato
FROM
    embarcacion_cama;

UPDATE embarcacion_cama
SET
`hin` = <{hin: }>,
`codigo_sector` = <{codigo_sector: }>,
`numero_cama` = <{numero_cama: }>,
`fecha_hora_contrato` = <{fecha_hora_contrato: }>,
`fecha_hora_baja_contrato` = <{fecha_hora_baja_contrato: }>
WHERE `hin` = <{expr}> AND `fecha_hora_contrato` = <{expr}>;
Columns, hin, codigo_sector, numero_cama, fecha_hora_contrato, fecha_hora_baja_contrato

`embarcacion_cama`SET @hin_to_select = <{row_id}>;
SET @fecha_hora_contrato_to_select = <{dddf}>;
SELECT embarcacion_cama.*
    FROM embarcacion_cama
    WHERE embarcacion_cama.hin = @hin_to_select AND embarcacion_cama.fecha_hora_contrato = @fecha_hora_contrato_to_select;