start transaction;

create table tematica (
	id int unsigned not null auto_increment,
    descripcion varchar(255) not null,
    primary key(id)
);

rollback;

select current_timestamp();


select
  min(nota),
  max(nota) into @min,
  @max
from
  evaluaciones
where
  nom_plan = 'Marketing 1'
group by
  nom_plan,
  nro_examen;
