SELECT vp.nom_plan, max(vp.valor_plan) max_valor_plan
FROM valores_plan vp group by vp.nom_plan;

select vp.nom_plan, max(vp.valor_plan) max_valor_plan
from valores_plan vp 
where vp.fecha_desde_plan <= current_date()
group by vp.nom_plan;

select * from valores_plan vp 
where vp.fecha_desde_plan = (
	select max(sub_vp.fecha_desde_plan) max_fecha_desde_plan
	from valores_plan sub_vp 
	where sub_vp.fecha_desde_plan <= current_date() 
		and sub_vp.nom_plan = vp.nom_plan
	group by sub_vp.nom_plan
);

select * from valores_plan, materiales mat where mat.cod_material = 'UT-004';

select * from materiales where cod_material = 'UT-004';

select * from valores_plan;

-- LEFT JOIN
select * from alumnos alu
left join cuotas cuo 
on alu.dni = cuo.dni
where cuo.nom_plan is null;

-- INNER JOIN
select * from alumnos alu
inner join cuotas cuo 
on  alu.dni = cuo.dni
where cuo.nom_plan is null;



