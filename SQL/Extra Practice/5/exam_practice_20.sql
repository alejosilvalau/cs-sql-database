/*
 * AD.E12 - Propiedades con Cambios de Agente y Variación de Valor.
 * Listar las propiedades que hayan tenido al menos 3 cambios de agente entre 2024-2025
 * y cuyo valor actual sea al menos 10% mayor o menor que el valor promedio de la zona (actual).
 * Mostrar: ID propiedad, dirección, zona, cantidad de cambios de agente, valor actual,
 * promedio zona, % variación, agente actual (nombre y apellido).
 * Ordenar por % variación absoluta descendente.
 */
-- Mi solución
with cam_age_prop as (
-- Conseguir la cant. de cambios de agente por propiedad entre 2024 y 2025
select
	aa.id_propiedad,
	count(1) cant_cam_age
from
	agente_asignado aa
where
	year(aa.fecha_hora_desde) in (2024, 2025)
group by
	aa.id_propiedad
),
fec_age_act as (
-- Ultima asignacion de agente para c. propiedad
select
	aa.id_propiedad,
	max(aa.fecha_hora_desde) ult_asig
from
	agente_asignado aa
where
	aa.fecha_hora_desde <= current_timestamp()
group by
	aa.id_propiedad
),
age_act as (
-- Agente actual de asignacion por propiedad
select
	aa.id_propiedad,
	aa.id_agente,
	p.nombre,
	p.apellido
from
	fec_age_act fac
inner join agente_asignado aa on
	fac.id_propiedad = aa.id_propiedad
	and fac.ult_asig = aa.fecha_hora_desde
inner join persona p on
	aa.id_agente = p.id
),
fec_ult_val as (
-- Fecha del ultimo valor de las propiedades
select
	vp.id_propiedad,
	max(vp.fecha_hora_desde) ult_fec
from
	valor_propiedad vp
where
	vp.fecha_hora_desde <= current_timestamp()
group by
	vp.id_propiedad
),
ult_val as (
-- Valor actual de las propiedades
select
	vp.id_propiedad,
	vp.valor,
	vp.fecha_hora_desde
from
	fec_ult_val fuv
inner join valor_propiedad vp on
	fuv.id_propiedad = vp.id_propiedad
	and fuv.ult_fec = vp.fecha_hora_desde
),
val_prom_zona as (
-- Valor promedio por zona
select
	p.zona,
	avg(uv.valor) val_prom
from
	ult_val uv
inner join propiedad p on
	uv.id_propiedad = p.id
group by
	p.zona
)
select
	p.id,
	p.direccion,
	p.zona,
	cap.cant_cam_age cant_cambio_agente,
	uv.valor valor_actual,
	vpz.val_prom,
	round(((uv.valor - vpz.val_prom) / vpz.val_prom) * 100, 2) variacion_porcentual,
	aa.nombre,
	aa.apellido
from
	propiedad p
inner join cam_age_prop cap on
	p.id = cap.id_propiedad
inner join ult_val uv on
	p.id = uv.id_propiedad
inner join val_prom_zona vpz on
	p.zona = vpz.zona
inner join age_act aa on
	p.id = aa.id_propiedad
where abs((uv.valor - vpz.val_prom) / vpz.val_prom) >= 0.1
and cap.cant_cam_age >= 3
order by abs(variacion_porcentual) desc;

-- Solución por IA
WITH cambios_agente AS (
    SELECT
        aa.id_propiedad,
        COUNT(*) AS cambios
    FROM agente_asignado aa
    WHERE YEAR(aa.fecha_hora_desde) IN (2024, 2025)
    GROUP BY aa.id_propiedad
    HAVING COUNT(*) >= 3
),
val_actual AS (
    SELECT vp.id_propiedad, vp.valor
    FROM valor_propiedad vp
    INNER JOIN (
        SELECT id_propiedad, MAX(fecha_hora_desde) AS ult_fec
        FROM valor_propiedad
        GROUP BY id_propiedad
    ) ult ON vp.id_propiedad = ult.id_propiedad AND vp.fecha_hora_desde = ult.ult_fec
),
prom_zona AS (
    SELECT p.zona, AVG(va.valor) AS prom_zona
    FROM propiedad p
    INNER JOIN val_actual va ON p.id = va.id_propiedad
    GROUP BY p.zona
),
agente_actual AS (
    SELECT
        aa.id_propiedad,
        aa.id_agente,
        per.nombre,
        per.apellido
    FROM agente_asignado aa
    INNER JOIN persona per ON aa.id_agente = per.id
    WHERE aa.fecha_hora_hasta IS NULL
)
SELECT
    p.id,
    p.direccion,
    p.zona,
    ca.cambios,
    va.valor AS valor_actual,
    pz.prom_zona,
    ROUND(((va.valor - pz.prom_zona) / pz.prom_zona) * 100, 2) AS variacion_pct,
    ag.nombre,
    ag.apellido
FROM cambios_agente ca
INNER JOIN propiedad p ON ca.id_propiedad = p.id
INNER JOIN val_actual va ON p.id = va.id_propiedad
INNER JOIN prom_zona pz ON p.zona = pz.zona
LEFT JOIN agente_actual ag ON p.id = ag.id_propiedad
WHERE ABS((va.valor - pz.prom_zona) / pz.prom_zona) >= 0.10
ORDER BY ABS((va.valor - pz.prom_zona) / pz.prom_zona) DESC;


/*
 * AD.E13 - Contratos con Garantías Diversas y Clientes con Antecedentes.
 * Listar los contratos de 2023 con al menos 2 tipos de garantía diferentes y cuyo cliente haya
 * tenido alguna garantía rechazada en cualquier contrato. Mostrar: ID contrato, cliente
 * (nombre y apellido), dirección, fecha de contrato, cantidad de garantías.
 * Ordenar por cantidad de garantías descendente y nombre de cliente.
 */
with cant_gar_dif as (
-- Cantidad de garantias diferentes por contrato en 2023
select
	sc.id id_contrato,
	count(distinct tg.id) cant_gar_dif,
	count(1) cant_gar
from
	solicitud_contrato sc
inner join garantia g on
	sc.id = g.id_solicitud
inner join tipo_garantia tg on
	g.id_tipo_garantia = tg.id
where
	year(sc.fecha_contrato) = 2023
group by
	sc.id
having
	cant_gar_dif >= 2
)
select
	sc.id,
	cli.nombre,
	cli.apellido,
	p.direccion,
	sc.fecha_contrato,
	cgd.cant_gar
from
	solicitud_contrato sc
inner join cant_gar_dif cgd on
	sc.id = cgd.id_contrato
inner join persona cli on
	sc.id_cliente = cli.id
inner join propiedad p on
	sc.id_propiedad = p.id
where
	sc.id_cliente in (
	-- 	Listado de clientes que tuvieron alguna garantia rechazada
	select
		sub_sc.id_cliente
	from
		solicitud_contrato sub_sc
	inner join garantia sub_g on
		sub_sc.id = sub_g.id_solicitud
	where
		sub_g.estado = 'rechazada'
		and sub_sc.id_cliente = sc.id_cliente
)
order by
	cgd.cant_gar_dif desc,
	cli.nombre;

WITH garantias_por_contrato AS (
    SELECT
        g.id_solicitud,
        COUNT(DISTINCT g.id_tipo_garantia) AS tipos_garantia,
        COUNT(*) AS cant_garantias
    FROM garantia g
    INNER JOIN tipo_garantia tg ON g.id_tipo_garantia = tg.id
    GROUP BY g.id_solicitud
),
clientes_rechazo AS (
    SELECT DISTINCT sc.id_cliente
    FROM solicitud_contrato sc
    INNER JOIN garantia g ON sc.id = g.id_solicitud
    WHERE g.estado = 'rechazada'
)
SELECT
    sc.id,
    per.nombre,
    per.apellido,
    p.direccion,
    sc.fecha_contrato,
    gpc.cant_garantias
FROM solicitud_contrato sc
INNER JOIN garantias_por_contrato gpc ON sc.id = gpc.id_solicitud
INNER JOIN propiedad p ON sc.id_propiedad = p.id
INNER JOIN persona per ON sc.id_cliente = per.id
WHERE YEAR(sc.fecha_contrato) = 2023
  AND gpc.tipos_garantia >= 2
  AND sc.id_cliente IN (SELECT id_cliente FROM clientes_rechazo)
ORDER BY gpc.cant_garantias DESC, per.nombre;


/*
 * AD.E14 - Clientes con Rechazos y Cambios de Zona.
 * Identificar clientes que hayan tenido al menos 2 solicitudes rechazadas en 2024-2025 y que esas solicitudes sean de propiedades en zonas diferentes.
 * Mostrar: ID cliente, nombre, apellido, cantidad de rechazos, zonas involucradas (concatenadas), cantidad de zonas.
 * Ordenar por cantidad de zonas descendente, luego por cantidad de rechazos descendente.
 */

WITH rechazos_cliente AS (
    SELECT
        sc.id_cliente,
        COUNT(*) AS cant_rechazos,
        GROUP_CONCAT(DISTINCT p.zona ORDER BY p.zona) AS zonas,
        COUNT(DISTINCT p.zona) AS cant_zonas
    FROM solicitud_contrato sc
    INNER JOIN propiedad p ON sc.id_propiedad = p.id
    WHERE sc.estado = 'rechazada'
      AND YEAR(sc.fecha_solicitud) IN (2024, 2025)
    GROUP BY sc.id_cliente
    HAVING COUNT(*) >= 2 AND COUNT(DISTINCT p.zona) >= 2
)
SELECT
    rc.id_cliente,
    per.nombre,
    per.apellido,
    rc.cant_rechazos,
    rc.zonas,
    rc.cant_zonas
FROM rechazos_cliente rc
INNER JOIN persona per ON rc.id_cliente = per.id
ORDER BY rc.cant_zonas DESC, rc.cant_rechazos DESC;


/*
 * AD.E15 - Propiedades con Valor en Baja y Sin Contrato Reciente.
 * Listar las propiedades cuyo valor actual es al menos 20% menor que el valor máximo histórico y que no hayan tenido ningún contrato firmado en 2025.
 * Mostrar: ID propiedad, dirección, zona, valor actual, valor máximo, % baja, fecha del último contrato (si existe).
 * Ordenar por % baja descendente.
 */

WITH val_max AS (
    SELECT id_propiedad, MAX(valor) AS max_valor FROM valor_propiedad GROUP BY id_propiedad
),
val_actual AS (
    SELECT vp.id_propiedad, vp.valor
    FROM valor_propiedad vp
    INNER JOIN (
        SELECT id_propiedad, MAX(fecha_hora_desde) AS ult_fec
        FROM valor_propiedad
        GROUP BY id_propiedad
    ) ult ON vp.id_propiedad = ult.id_propiedad AND vp.fecha_hora_desde = ult.ult_fec
),
ult_contrato AS (
    SELECT sc.id_propiedad, MAX(sc.fecha_contrato) AS ult_contrato
    FROM solicitud_contrato sc
    GROUP BY sc.id_propiedad
)
SELECT
    p.id,
    p.direccion,
    p.zona,
    va.valor AS valor_actual,
    vm.max_valor,
    ROUND(((vm.max_valor - va.valor) / vm.max_valor) * 100, 2) AS porc_baja,
    uc.ult_contrato
FROM val_max vm
INNER JOIN val_actual va ON vm.id_propiedad = va.id_propiedad
INNER JOIN propiedad p ON p.id = vm.id_propiedad
LEFT JOIN ult_contrato uc ON p.id = uc.id_propiedad
WHERE va.valor < vm.max_valor * 0.8
  AND p.id NOT IN (
      SELECT id_propiedad FROM solicitud_contrato WHERE YEAR(fecha_contrato) = 2025
  )
ORDER BY porc_baja DESC;


/*
 * AD.E16 - Agentes con Diversidad y Éxito en Tipos de Propiedad.
 * Listar los agentes que durante 2025 gestionaron contratos de al menos 3 tipos de
 *  propiedad diferentes y cuya tasa de éxito (contratos cerrados / solicitudes) sea
 * superior al 60%. Mostrar: ID agente, nombre, apellido, cantidad de tipos, tipos de
 * propiedad (concatenados), tasa de éxito (%), cantidad de contratos cerrados.
 * Ordenar por cantidad de tipos descendente, luego por tasa de éxito descendente.
 */

WITH tipos_por_agente AS (
    SELECT
        sc.id_agente,
        COUNT(DISTINCT p.tipo) AS cant_tipos,
        GROUP_CONCAT(DISTINCT p.tipo ORDER BY p.tipo SEPARATOR ', ') AS tipos
    FROM solicitud_contrato sc
    INNER JOIN propiedad p ON sc.id_propiedad = p.id
    WHERE YEAR(sc.fecha_solicitud) = 2025
    GROUP BY sc.id_agente
    HAVING COUNT(DISTINCT p.tipo) >= 3
),
exito_agente AS (
    SELECT
        sc.id_agente,
        COUNT(*) AS total_sol,
        SUM(CASE WHEN sc.fecha_contrato IS NOT NULL THEN 1 ELSE 0 END) AS contratos_cerrados
    FROM solicitud_contrato sc
    WHERE YEAR(sc.fecha_solicitud) = 2025
    GROUP BY sc.id_agente
)
SELECT
    tpa.id_agente,
    per.nombre,
    per.apellido,
    tpa.cant_tipos,
    tpa.tipos,
    ROUND((ea.contratos_cerrados / ea.total_sol) * 100, 2) AS tasa_exito,
    ea.contratos_cerrados
FROM tipos_por_agente tpa
INNER JOIN exito_agente ea ON tpa.id_agente = ea.id_agente
INNER JOIN persona per ON tpa.id_agente = per.id
WHERE (ea.contratos_cerrados / ea.total_sol) > 0.6
ORDER BY tpa.cant_tipos DESC, tasa_exito DESC;