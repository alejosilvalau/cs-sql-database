/*
 * AD.C1 - Reforma de Visitas (DDL + Migración).
 * Actualmente, la tabla `visita` identifica cada visita por la clave primaria compuesta
 * (id_cliente, fecha_hora_visita). Esto impide registrar que una misma visita (mismo agente,
 * propiedad y horario) fue realizada por un grupo de personas (ej. una pareja).
 *
 * Se requiere modificar el modelo para soportar "Eventos de Visita" con múltiples asistentes:
 * 1. Crear una tabla `evento_visita` que represente el hecho de la visita (agente, propiedad, fecha).
 *    Debe tener un ID autoincremental como PK.
 * 2. Crear una tabla `asistente_visita` que relacione el evento con los clientes (N:M).
 * 3. Migrar los datos: Agrupar las visitas existentes que coincidan en agente, propiedad y fecha
 *    en un único evento, y mover los clientes a la tabla de asistentes.
 * 4. Eliminar la tabla `visita` original.
 * Realizar todo en una transacción.
 */

CREATE TABLE evento_visita (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_agente INT UNSIGNED NOT NULL,
    id_propiedad INT UNSIGNED NOT NULL,
    fecha_hora_desde DATETIME NOT NULL,
    fecha_hora_visita DATETIME NOT NULL,
    CONSTRAINT fk_ev_agente_asignado FOREIGN KEY (id_agente, id_propiedad, fecha_hora_desde)
        REFERENCES agente_asignado (id_agente, id_propiedad, fecha_hora_desde)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE asistente_visita (
    id_evento INT UNSIGNED NOT NULL,
    id_cliente INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_evento, id_cliente),
    CONSTRAINT fk_av_evento FOREIGN KEY (id_evento) REFERENCES evento_visita (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_av_cliente FOREIGN KEY (id_cliente) REFERENCES persona (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

START TRANSACTION;

-- Insertar eventos únicos basados en las visitas existentes
INSERT INTO evento_visita (id_agente, id_propiedad, fecha_hora_desde, fecha_hora_visita)
SELECT DISTINCT id_agente, id_propiedad, fecha_hora_desde, fecha_hora_visita
FROM visita;

-- Insertar los asistentes vinculando la tabla vieja con la nueva
INSERT INTO asistente_visita (id_evento, id_cliente)
SELECT ev.id, v.id_cliente
FROM visita v
INNER JOIN evento_visita ev ON v.id_agente = ev.id_agente
    AND v.id_propiedad = ev.id_propiedad
    AND v.fecha_hora_visita = ev.fecha_hora_visita;

COMMIT;

-- Eliminar estructura anterior
DROP TABLE visita;

-- Mi solución
create table inmobiliaria_calciferhowl_mod4.evento_visita (
	id int unsigned auto_increment not null,
	id_agente int unsigned not null,
	id_propiedad int unsigned not null,
	fecha_hora_desde datetime not null,
	fecha_hora_visita datetime not null,
	constraint pk_evento_visita primary key (id),
	constraint fk_evento_visita_agente_asignado foreign key (id_agente,
id_propiedad,
fecha_hora_desde) references inmobiliaria_calciferhowl_mod4.agente_asignado(id_agente,
id_propiedad,
fecha_hora_desde) on
delete
	restrict on
	update
		cascade
)
engine = InnoDB
default CHARSET = utf8mb4
collate = utf8mb4_0900_ai_ci;

CREATE TABLE inmobiliaria_calciferhowl_mod4.asistente_visita (
	id_visita int unsigned NOT NULL,
	id_cliente int unsigned NOT NULL,
	CONSTRAINT pk_asistente_visita PRIMARY KEY (id_visita,id_cliente),
	CONSTRAINT fk_asistente_visita_evento_visita FOREIGN KEY (id_visita) REFERENCES inmobiliaria_calciferhowl_mod4.evento_visita(id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT fk_asistente_visita_persona FOREIGN KEY (id_cliente) REFERENCES inmobiliaria_calciferhowl_mod4.persona(id) ON DELETE RESTRICT ON UPDATE CASCADE
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;

start transaction;

-- El inner join lo usé acá para evitar errores de integridad
insert
	into
	evento_visita (id_agente,
	id_propiedad,
	fecha_hora_desde,
	fecha_hora_visita)
select
	v.id_agente,
	v.id_propiedad,
	v.fecha_hora_desde,
	v.fecha_hora_visita
from
	visita v
inner join agente_asignado aa on
	v.id_agente = aa.id_agente
	and v.id_propiedad = aa.id_propiedad
	and v.fecha_hora_desde = aa.fecha_hora_desde;

insert
	into
	asistente_visita
select
	ev.id,
	v.id_cliente
from
	visita v
inner join evento_visita ev on
	v.id_agente = ev.id_agente
	and v.id_propiedad = ev.id_propiedad
	and v.fecha_hora_desde = ev.fecha_hora_desde;

commit;

DROP TABLE inmobiliaria_calciferhowl_mod4.visita;

select
	v.id_agente v_id_agente,
	v.id_propiedad v_id_propiedad,
	v.fecha_hora_desde v_fecha_hora_desde,
	aa.id_agente aa_id_agente,
	aa.id_propiedad aa_id_propiedad,
	aa.fecha_hora_desde aa_fecha_hora_desde
from
	visita v
left join agente_asignado aa on
	v.id_agente = aa.id_agente
	and v.id_propiedad = aa.id_propiedad
	and v.fecha_hora_desde = aa.fecha_hora_desde;

/*
 * AD.C2 - Propiedades "Vidriera".
 * La empresa quiere identificar propiedades que generan mucho interés pero no se alquilan.
 * Listar las propiedades que tuvieron 5 o más visitas durante el año 2025, pero que NO
 * tienen ninguna solicitud de contrato con estado 'en alquiler' o 'en proceso' generada en 2025.
 *
 * Mostrar: id de propiedad, dirección, zona, cantidad de visitas en 2025 y el valor de tasación
 * (valor_propiedad) vigente a la fecha de la última visita registrada en 2025.
 */

WITH visitas_2025 AS (
    SELECT
        id_propiedad,
        COUNT(*) as cant_visitas,
        MAX(fecha_hora_visita) as ultima_visita
    FROM visita
    WHERE YEAR(fecha_hora_visita) = 2025
    GROUP BY id_propiedad
    HAVING COUNT(*) >= 5
),
props_con_contrato_2025 AS (
    SELECT DISTINCT id_propiedad
    FROM solicitud_contrato
    WHERE YEAR(fecha_solicitud) = 2025
      AND estado IN ('en alquiler', 'en proceso')
)
SELECT
    p.id,
    p.direccion,
    p.zona,
    v25.cant_visitas,
    vp.valor as valor_al_momento_visita
FROM visitas_2025 v25
INNER JOIN propiedad p ON v25.id_propiedad = p.id
LEFT JOIN props_con_contrato_2025 pcc ON v25.id_propiedad = pcc.id_propiedad
INNER JOIN valor_propiedad vp ON vp.id_propiedad = v25.id_propiedad
    AND vp.fecha_hora_desde = (
        SELECT MAX(sub_vp.fecha_hora_desde)
        FROM valor_propiedad sub_vp
        WHERE sub_vp.id_propiedad = v25.id_propiedad
          AND sub_vp.fecha_hora_desde <= v25.ultima_visita
    )
WHERE pcc.id_propiedad IS NULL;

-- Mi solución
with cant_vis_prop as (
select
	p.id,
	count(1) cant_vis,
	max(v.fecha_hora_visita) ult_vis
from
	visita v
inner join propiedad p on
	p.id = v.id_propiedad
where
	year(v.fecha_hora_visita) = 2025
	and p.id not in (
	select
		distinct sub_sc.id_propiedad
	from
		solicitud_contrato sub_sc
	where
		sub_sc.estado in ('en alquiler', 'en proceso')
		and year(sub_sc.fecha_solicitud) = 2025
		and sub_sc.id_propiedad = p.id )
group by
	p.id
having
	cant_vis >= 5 ),
cot_prop_vis as (
select
	cvp.id,
	vp.valor val_prop
from
	valor_propiedad vp
inner join cant_vis_prop cvp on
	vp.id_propiedad = cvp.id
	and
	vp.fecha_hora_desde = (
	select
		max(sub_vp.fecha_hora_desde)
	from
		valor_propiedad sub_vp
	where
		sub_vp.id_propiedad = cvp.id
		and
	sub_vp.fecha_hora_desde <= cvp.ult_vis ))
select
	p.id,
	p.zona,
	p.direccion,
	cvp.cant_vis,
	cpv.val_prop
from
	cant_vis_prop cvp
inner join cot_prop_vis cpv on
	cvp.id = cpv.id
inner join propiedad p on
	p.id = cvp.id;

/*
 * AD.C3 - Cliente del Año (Ranking por Grupos).
 * Para cada año (basado en la fecha de pago), encontrar al cliente que más dinero ha pagado
 * a la inmobiliaria (suma de importes de todos sus pagos).
 *
 * El reporte debe mostrar: Año, ID del Cliente, Nombre, Apellido y el Total Pagado.
 * Si en un año hay empate en el monto máximo, mostrar a todos los clientes empatados.
 */

WITH pagos_por_cliente_anio AS (
    SELECT
        YEAR(p.fecha_hora_pago) as anio,
        sc.id_cliente,
        SUM(p.importe) as total_pagado
    FROM pago p
    INNER JOIN solicitud_contrato sc ON p.id_solicitud = sc.id
    GROUP BY YEAR(p.fecha_hora_pago), sc.id_cliente
),
max_pago_por_anio AS (
    SELECT
        anio,
        MAX(total_pagado) as max_total
    FROM pagos_por_cliente_anio
    GROUP BY anio
)
SELECT
    pca.anio,
    pca.id_cliente,
    per.nombre,
    per.apellido,
    pca.total_pagado
FROM pagos_por_cliente_anio pca
INNER JOIN max_pago_por_anio mpa ON pca.anio = mpa.anio
    AND pca.total_pagado = mpa.max_total
INNER JOIN persona per ON pca.id_cliente = per.id
ORDER BY pca.anio DESC;


/*
 * AD.C4 - Rendimiento Superior (Comparativo).
 * Listar las propiedades actualmente alquiladas (solicitud con estado 'en alquiler') cuyo
 * "Rendimiento Mensual" sea superior al promedio de rendimiento mensual de las propiedades
 * de su misma zona.
 *
 * El Rendimiento Mensual se calcula como: (Importe Mensual del Contrato / Valor de la Propiedad a la fecha del contrato).
 * Mostrar: ID Propiedad, Zona, Importe Mensual, Valor a fecha contrato, Rendimiento Propiedad y Promedio Rendimiento Zona.
 */

WITH rendimiento_propiedad AS (
    SELECT
        sc.id_propiedad,
        p.zona,
        sc.importe_mensual,
        vp.valor as valor_contrato,
        (sc.importe_mensual / vp.valor) as rendimiento
    FROM solicitud_contrato sc
    INNER JOIN propiedad p ON sc.id_propiedad = p.id
    INNER JOIN valor_propiedad vp ON vp.id_propiedad = sc.id_propiedad
        AND vp.fecha_hora_desde = (
            SELECT MAX(sub_vp.fecha_hora_desde)
            FROM valor_propiedad sub_vp
            WHERE sub_vp.id_propiedad = sc.id_propiedad
              AND sub_vp.fecha_hora_desde <= sc.fecha_contrato
        )
    WHERE sc.estado = 'en alquiler'
      AND sc.fecha_contrato IS NOT NULL
),
promedio_zona AS (
    SELECT
        zona,
        AVG(rendimiento) as prom_rendimiento_zona
    FROM rendimiento_propiedad
    GROUP BY zona
)
SELECT
    rp.id_propiedad,
    rp.zona,
    rp.importe_mensual,
    rp.valor_contrato,
    rp.rendimiento,
    pz.prom_rendimiento_zona
FROM rendimiento_propiedad rp
INNER JOIN promedio_zona pz ON rp.zona = pz.zona
WHERE rp.rend/*
 * AD.C1 - Reforma de Visitas (DDL + Migración).
 * Actualmente, la tabla `visita` identifica cada visita por la clave primaria compuesta
 * (id_cliente, fecha_hora_visita). Esto impide registrar que una misma visita (mismo agente,
 * propiedad y horario) fue realizada por un grupo de personas (ej. una pareja).
 *
 * Se requiere modificar el modelo para soportar "Eventos de Visita" con múltiples asistentes:
 * 1. Crear una tabla `evento_visita` que represente el hecho de la visita (agente, propiedad, fecha).
 *    Debe tener un ID autoincremental como PK.
 * 2. Crear una tabla `asistente_visita` que relacione el evento con los clientes (N:M).
 * 3. Migrar los datos: Agrupar las visitas existentes que coincidan en agente, propiedad y fecha
 *    en un único evento, y mover los clientes a la tabla de asistentes.
 * 4. Eliminar la tabla `visita` original.
 * Realizar todo en una transacción.
 */

CREATE TABLE evento_visita (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_agente INT UNSIGNED NOT NULL,
    id_propiedad INT UNSIGNED NOT NULL,
    fecha_hora_desde DATETIME NOT NULL,
    fecha_hora_visita DATETIME NOT NULL,
    CONSTRAINT fk_ev_agente_asignado FOREIGN KEY (id_agente, id_propiedad, fecha_hora_desde)
        REFERENCES agente_asignado (id_agente, id_propiedad, fecha_hora_desde)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE asistente_visita (
    id_evento INT UNSIGNED NOT NULL,
    id_cliente INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_evento, id_cliente),
    CONSTRAINT fk_av_evento FOREIGN KEY (id_evento) REFERENCES evento_visita (id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_av_cliente FOREIGN KEY (id_cliente) REFERENCES persona (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

START TRANSACTION;

-- Insertar eventos únicos basados en las visitas existentes
INSERT INTO evento_visita (id_agente, id_propiedad, fecha_hora_desde, fecha_hora_visita)
SELECT DISTINCT id_agente, id_propiedad, fecha_hora_desde, fecha_hora_visita
FROM visita;

-- Insertar los asistentes vinculando la tabla vieja con la nueva
INSERT INTO asistente_visita (id_evento, id_cliente)
SELECT ev.id, v.id_cliente
FROM visita v
INNER JOIN evento_visita ev ON v.id_agente = ev.id_agente
    AND v.id_propiedad = ev.id_propiedad
    AND v.fecha_hora_visita = ev.fecha_hora_visita;

COMMIT;

-- Eliminar estructura anterior
DROP TABLE visita;


/*
 * AD.C2 - Propiedades "Vidriera".
 * La empresa quiere identificar propiedades que generan mucho interés pero no se alquilan.
 * Listar las propiedades que tuvieron 5 o más visitas durante el año 2025, pero que NO
 * tienen ninguna solicitud de contrato con estado 'en alquiler' o 'en proceso' generada en 2025.
 *
 * Mostrar: id de propiedad, dirección, zona, cantidad de visitas en 2025 y el valor de tasación
 * (valor_propiedad) vigente a la fecha de la última visita registrada en 2025.
 */

WITH visitas_2025 AS (
    SELECT
        id_propiedad,
        COUNT(*) as cant_visitas,
        MAX(fecha_hora_visita) as ultima_visita
    FROM visita
    WHERE YEAR(fecha_hora_visita) = 2025
    GROUP BY id_propiedad
    HAVING COUNT(*) >= 5
),
props_con_contrato_2025 AS (
    SELECT DISTINCT id_propiedad
    FROM solicitud_contrato
    WHERE YEAR(fecha_solicitud) = 2025
      AND estado IN ('en alquiler', 'en proceso')
)
SELECT
    p.id,
    p.direccion,
    p.zona,
    v25.cant_visitas,
    vp.valor as valor_al_momento_visita
FROM visitas_2025 v25
INNER JOIN propiedad p ON v25.id_propiedad = p.id
LEFT JOIN props_con_contrato_2025 pcc ON v25.id_propiedad = pcc.id_propiedad
INNER JOIN valor_propiedad vp ON vp.id_propiedad = v25.id_propiedad
    AND vp.fecha_hora_desde = (
        SELECT MAX(sub_vp.fecha_hora_desde)
        FROM valor_propiedad sub_vp
        WHERE sub_vp.id_propiedad = v25.id_propiedad
          AND sub_vp.fecha_hora_desde <= v25.ultima_visita
    )
WHERE pcc.id_propiedad IS NULL;


/*
 * AD.C3 - Cliente del Año (Ranking por Grupos).
 * Para cada año (basado en la fecha de pago), encontrar al cliente que más dinero ha pagado
 * a la inmobiliaria (suma de importes de todos sus pagos).
 *
 * El reporte debe mostrar: Año, ID del Cliente, Nombre, Apellido y el Total Pagado.
 * Si en un año hay empate en el monto máximo, mostrar a todos los clientes empatados.
 */

WITH pagos_por_cliente_anio AS (
    SELECT
        YEAR(p.fecha_hora_pago) as anio,
        sc.id_cliente,
        SUM(p.importe) as total_pagado
    FROM pago p
    INNER JOIN solicitud_contrato sc ON p.id_solicitud = sc.id
    GROUP BY YEAR(p.fecha_hora_pago), sc.id_cliente
),
max_pago_por_anio AS (
    SELECT
        anio,
        MAX(total_pagado) as max_total
    FROM pagos_por_cliente_anio
    GROUP BY anio
)
SELECT
    pca.anio,
    pca.id_cliente,
    per.nombre,
    per.apellido,
    pca.total_pagado
FROM pagos_por_cliente_anio pca
INNER JOIN max_pago_por_anio mpa ON pca.anio = mpa.anio
    AND pca.total_pagado = mpa.max_total
INNER JOIN persona per ON pca.id_cliente = per.id
ORDER BY pca.anio DESC;


/*
 * AD.C4 - Rendimiento Superior (Comparativo).
 * Listar las propiedades actualmente alquiladas (solicitud con estado 'en alquiler') cuyo
 * "Rendimiento Mensual" sea superior al promedio de rendimiento mensual de las propiedades
 * de su misma zona.
 *
 * El Rendimiento Mensual se calcula como: (Importe Mensual del Contrato / Valor de la Propiedad a la fecha del contrato).
 * Mostrar: ID Propiedad, Zona, Importe Mensual, Valor a fecha contrato, Rendimiento Propiedad y Promedio Rendimiento Zona.
 */

WITH rendimiento_propiedad AS (
    SELECT
        sc.id_propiedad,
        p.zona,
        sc.importe_mensual,
        vp.valor as valor_contrato,
        (sc.importe_mensual / vp.valor) as rendimiento
    FROM solicitud_contrato sc
    INNER JOIN propiedad p ON sc.id_propiedad = p.id
    INNER JOIN valor_propiedad vp ON vp.id_propiedad = sc.id_propiedad
        AND vp.fecha_hora_desde = (
            SELECT MAX(sub_vp.fecha_hora_desde)
            FROM valor_propiedad sub_vp
            WHERE sub_vp.id_propiedad = sc.id_propiedad
              AND sub_vp.fecha_hora_desde <= sc.fecha_contrato
        )
    WHERE sc.estado = 'en alquiler'
      AND sc.fecha_contrato IS NOT NULL
),
promedio_zona AS (
    SELECT
        zona,
        AVG(rendimiento) as prom_rendimiento_zona
    FROM rendimiento_propiedad
    GROUP BY zona
)
SELECT
    rp.id_propiedad,
    rp.zona,
    rp.importe_mensual,
    rp.valor_contrato,
    rp.rendimiento,
    pz.prom_rendimiento_zona
FROM rendimiento_propiedad rp
INNER JOIN promedio_zona pz ON rp.zona = pz.zona
WHERE rp.rend