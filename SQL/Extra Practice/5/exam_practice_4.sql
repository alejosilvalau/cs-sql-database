/*
AD.B2- Cursos más exitosos. 

La empresa desea conocer para cada tipo de embarcación información 
de los cursos más exitosos. 

[X] Se considera que el curso más exitoso para cada tipo de embarcación
es el que [X] tiene mayor cantidad de socios inscriptos dentro de los
cursos de dicho tipo de embarcación (que se relaciona según la
actividad realizada en el curso). 

Se requiere listar para cada tipo de embarcación el curso más exitoso indicando: 
- código y nombre del tipo de embarcación; 
- número, nombre y descripción de la actividad del curso, 
- número de curso, 
- cuántos días pasaron desde que se comenzó a dictar dicho curso, 
- cantidad de inscriptos que tuvo y 
- la cantidad de embarcaciones del tipo de embarcación que están 
	actualmente almacenadas en la guardería.

Si para un tipo de embarcación no se dictó ningún curso debe
mostrarse igualmente con 0 inscriptos y sin datos de la actividad
o curso y si no hay embarcaciones almacenadas actualmente de
dicho tipo debe mostrarse con 0.

Ordenar por cantidad de embarcaciones almacenadas descendente,
cantidad de inscriptos ascendente y días desde que comenzó el
curso ascendente.
*/
drop temporary table if exists cant_ins_curso;
drop temporary table if exists max_ins_te;
drop temporary table if exists curso_mas_exitoso;
drop temporary table if exists emb_alm;

create temporary table cant_ins_curso
select 
	c.numero,
	count(i.numero_socio) as cant_ins
from curso c
left join inscripcion i on
	c.numero = i.numero_curso
group by c.numero;

create temporary table max_ins_te
select
	te.codigo as cod_te,
    max(coalesce(cic.cant_ins, 0)) as max_cant_ins
from tipo_embarcacion te
left join actividad a on a.codigo_tipo_embarcacion = te.codigo
left join curso c on c.numero_actividad = a.numero
left join cant_ins_curso cic on cic.numero = c.numero
group by te.codigo;

create temporary table curso_mas_exitoso 
select
	te.codigo cod_te,
    c.numero num_curso,
    cic.cant_ins
from tipo_embarcacion te
inner join max_ins_te mit on 
	te.codigo = mit.cod_te
left join actividad a on 
	a.codigo_tipo_embarcacion = te.codigo
left join curso c on 
	c.numero_actividad = a.numero
left join cant_ins_curso cic on 
	cic.numero = c.numero
where coalesce(cic.cant_ins, 0) = mit.max_cant_ins;

create temporary table emb_alm
select 
	e.codigo_tipo_embarcacion,
    count(e.hin) cant_alm
from embarcacion e
inner join embarcacion_cama ec on e.hin = ec.hin
where ec.fecha_hora_baja_contrato is null
group by e.codigo_tipo_embarcacion;

select 
	te.codigo te_cod,
    te.nombre te_nom,
    a.numero a_numero,
    a.nombre a_nombre,
    a.descripcion a_descripcion,
    c.numero c_num,
    coalesce(datediff(now(), c.fecha_inicio), null) c_cant_dias,
    coalesce(cme.cant_ins, 0) c_cant_ins,
    coalesce(ea.cant_alm, 0) te_cant_alm
from tipo_embarcacion te
left join curso_mas_exitoso cme on
	te.codigo = cme.cod_te
left join curso c on
	c.numero = cme.num_curso
left join actividad a on
	c.numero_actividad = a.numero
left join emb_alm ea on
	ea.codigo_tipo_embarcacion = te.codigo
order by
	te_cant_alm desc,
    c_cant_ins,
    c_cant_dias;

drop temporary table if exists cant_ins_curso;
drop temporary table if exists max_ins_te;
drop temporary table if exists curso_mas_exitoso;
drop temporary table if exists emb_alm;