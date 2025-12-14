/*
 * AD.D1 - Auditoría de Garantías (DDL + Migración).
 * La empresa necesita llevar un registro histórico de los cambios de estado en las garantías.
 * Actualmente, cuando el estado de una garantía cambia, se pierde el historial del estado anterior.
 *
 * Se requiere:
 * 1. Crear una tabla `historico_garantia` que registre cada cambio de estado con fecha.
 * 2. Migrar el estado actual de todas las garantías como primer registro en el histórico.
 * 3. Modificar la tabla `garantia` para eliminar el campo `estado` (ahora estará en el histórico).
 * 4. Realizar todo en una transacción.
 */
CREATE TABLE inmobiliaria_calciferhowl_mod4.historico_garantia (
	fecha_hora_desde date NOT NULL,
	id_solicitud int unsigned NOT NULL,
	id_garante int unsigned NOT NULL,
	estado varchar(20) NOT NULL,
	CONSTRAINT pk_historico_garantia PRIMARY KEY (fecha_hora_desde,id_garante,id_solicitud),
	CONSTRAINT fk_historico_garantia_garantia FOREIGN KEY (id_solicitud,id_garante) REFERENCES inmobiliaria_calciferhowl_mod4.garantia(id_solicitud,id_garante) ON DELETE RESTRICT ON UPDATE CASCADE
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;

start transaction;

insert into historico_garantia (fecha_hora_desde, id_solicitud, id_garante, estado)
select current_date(), g.id_solicitud, g.id_garante, g.estado from garantia g;

commit;

ALTER TABLE inmobiliaria_calciferhowl_mod4.garantia DROP COLUMN estado;


/*
 * AD.D2 - Propiedades Problemáticas.
 * Identificar propiedades cuyos contratos tienen comportamientos irregulares en los pagos.
 * Listar propiedades que cumplan TODAS estas condiciones simultáneamente:
 * - Tienen al menos un contrato activo ('en alquiler')
 * - El último pago de alquiler fue hace más de 60 días (desde hoy)
 * - La suma total de pagos de alquiler es menor al 80% del total que deberían haber pagado
 *   (calculado como: meses transcurridos desde fecha_contrato × importe_mensual)
 *
 * Mostrar: ID propiedad, dirección, zona, fecha del último pago, días desde último pago,
 * total pagado, total esperado y proporción pagada.
 * Nota: usar DATEDIFF para calcular diferencias en días y TIMESTAMPDIFF(MONTH,...) para meses.
 */

with prop_pag as (
    -- conseguir el último pago y total pagado del contrato activo de cada propiedad
    select
        sc.id_propiedad,
        max(p.fecha_hora_pago) ult_pag,
        sum(p.importe) tot_pag
    from
        solicitud_contrato sc
    left join pago p on p.id_solicitud = sc.id and p.concepto = 'pago alquiler'
    where sc.estado = 'en alquiler'
      and sc.fecha_contrato is not null
    group by
        sc.id_propiedad
),
deb_pag as (
    -- conseguir el total que debería haber pagado por el contrato activo
    select
        sc.id_propiedad,
        sc.importe_mensual * timestampdiff(month, sc.fecha_contrato, current_date()) tot_esp
    from
        solicitud_contrato sc
    where sc.estado = 'en alquiler'
      and sc.fecha_contrato is not null
)
select
    p.id,
    p.direccion,
    p.zona,
    pp.ult_pag,
    datediff(current_date(), pp.ult_pag) dias_ult_pag,
    pp.tot_pag,
    dp.tot_esp,
    (pp.tot_pag / dp.tot_esp) proporcion
from
    propiedad p
inner join prop_pag pp on p.id = pp.id_propiedad
inner join deb_pag dp on p.id = dp.id_propiedad
where
    datediff(current_date(), pp.ult_pag) > 60
    and (pp.tot_pag / dp.tot_esp) < 0.8;


WITH contratos_activos AS (
    SELECT
        sc.id,
        sc.id_propiedad,
        sc.fecha_contrato,
        sc.importe_mensual,
        TIMESTAMPDIFF(MONTH, sc.fecha_contrato, CURDATE()) as meses_transcurridos
    FROM solicitud_contrato sc
    WHERE sc.estado = 'en alquiler'
      AND sc.fecha_contrato IS NOT NULL
),
pagos_alquiler AS (
    SELECT
        ca.id,
        ca.id_propiedad,
        ca.importe_mensual,
        ca.meses_transcurridos,
        COALESCE(SUM(p.importe), 0) as total_pagado,
        MAX(p.fecha_hora_pago) as ultimo_pago
    FROM contratos_activos ca
    LEFT JOIN pago p ON p.id_solicitud = ca.id
        AND p.concepto = 'pago alquiler'
    GROUP BY ca.id, ca.id_propiedad, ca.importe_mensual, ca.meses_transcurridos
),
calc_esperado AS (
    SELECT
        pa.*,
        (pa.meses_transcurridos * pa.importe_mensual) as total_esperado,
        DATEDIFF(CURDATE(), pa.ultimo_pago) as dias_ultimo_pago
    FROM pagos_alquiler pa
)
SELECT
    p.id,
    p.direccion,
    p.zona,
    ce.ultimo_pago,
    ce.dias_ultimo_pago,
    ce.total_pagado,
    ce.total_esperado,
    (ce.total_pagado / ce.total_esperado) as proporcion_pagada
FROM calc_esperado ce
INNER JOIN propiedad p ON ce.id_propiedad = p.id
WHERE ce.dias_ultimo_pago > 60
  AND (ce.total_pagado / ce.total_esperado) < 0.8;


/*
 * AD.D3 - Análisis de Revalorización.
 * Para cada tipo de propiedad, calcular la tasa de crecimiento promedio anual del valor
 * entre 2023 y 2025. Mostrar solo aquellos tipos donde al menos una propiedad haya
 * experimentado un crecimiento superior al 50% en ese período.
 *
 * Para cada propiedad, comparar su primer valor registrado en 2023 con su último valor
 * registrado en 2025. La tasa de crecimiento se calcula como:
 * ((valor_final - valor_inicial) / valor_inicial) * 100
 *
 * Mostrar: Tipo de propiedad, cantidad de propiedades de ese tipo que crecieron más del 50%,
 * tasa de crecimiento promedio del tipo, valor mínimo de crecimiento y valor máximo de crecimiento.
 */

with max_min_fec_prop as (
    select
        id_propiedad,
        min(fecha_hora_desde) min_fecha,
        max(fecha_hora_desde) max_fecha
    from valor_propiedad vp
    where year(fecha_hora_desde) between 2023 and 2025
    group by id_propiedad
),
min_val_prop as (
    select
        mmfp.id_propiedad,
        min_vp.valor min_valor,
        max_vp.valor max_valor
    from max_min_fec_prop mmfp
    inner join valor_propiedad min_vp on
        mmfp.id_propiedad = min_vp.id_propiedad
        and mmfp.min_fecha = min_vp.fecha_hora_desde
    inner join valor_propiedad max_vp on
        mmfp.id_propiedad = max_vp.id_propiedad
        and mmfp.max_fecha = max_vp.fecha_hora_desde
),
tasa_creci_prop as (
    select
        p.id,
        p.tipo,
        ((max_valor - min_valor) / min_valor) * 100 tasa_crecimiento
    from min_val_prop mvp
    inner join propiedad p on mvp.id_propiedad = p.id
),
cant_alto_creci as (
    select
        tipo,
        count(*) cant_prop
    from tasa_creci_prop
    where tasa_crecimiento > 50
    group by tipo
)
select
    tcp.tipo,
    cac.cant_prop,
    avg(tcp.tasa_crecimiento) promedio,
    min(tcp.tasa_crecimiento) min_creci,
    max(tcp.tasa_crecimiento) max_creci
from tasa_creci_prop tcp
inner join cant_alto_creci cac on tcp.tipo = cac.tipo
group by tcp.tipo, cac.cant_prop;


/*
 * AD.D4 - Efectividad de Agentes por Zona.
 * Determinar qué agentes son más efectivos en cada zona. Un agente es efectivo si:
 * - Tiene alta tasa de conversión: (solicitudes con contrato / total solicitudes) > 60%
 * - Tiempo promedio entre solicitud y contrato es menor a 30 días
 * - Ha gestionado al menos 2 solicitudes en la zona
 *
 * Para cada zona que tenga al menos un agente efectivo, mostrar al mejor agente
 * (el de mayor tasa de conversión, en caso de empate el de menor tiempo promedio).
 *
 * Mostrar: Zona, ID agente, nombre y apellido del agente, total de solicitudes en la zona,
 * cantidad de contratos cerrados, tasa de conversión (%), tiempo promedio de cierre (días),
 * y valor total de contratos cerrados (suma de importes mensuales).
 */

-- AD.D4 - Efectividad de Agentes por Zona

with cant_sol_cont as (
-- Conseguir la cantidad solicitudes con contrato por agente
select
	sc.id_agente,
	count(1) cant_sol_cont,
	sum(sc.importe_mensual) val_tot_cont
from
	solicitud_contrato sc
where
	sc.fecha_contrato is not null
group by
	sc.id_agente
),
cant_sol_sin_cont as (
-- Conseguir la cantidad de solicitudes generales por agente
select
	sc.id_agente,
	count(1) cant_sol_tot
from
	solicitud_contrato sc
group by
	sc.id_agente
),
tas_conv_age as (
-- Conseguir la tasa de conversiones por agente
select
	csc.id_agente,
	csc.cant_sol_cont / cssc.cant_sol_tot tasa_conv
from
	cant_sol_sin_cont cssc
inner join cant_sol_cont csc on
	csc.id_agente = cssc.id_agente
where
	csc.cant_sol_cont / cssc.cant_sol_tot > 0.6
),
tie_prom_age as (
-- Conseguir los agentes con un tiempo promedio de solicitud y contrato menor a 30 dias
select
	sc.id_agente,
	avg(datediff(sc.fecha_contrato, sc.fecha_solicitud)) tie_prom_cierre
from
	solicitud_contrato sc
where
	sc.fecha_contrato is not null
group by
	sc.id_agente
having
	tie_prom_cierre < 30
),
cant_ges_zona as (
-- Conseguir los agentes que por zona, han gestionado <= 2 solicitudes de contrato
select
	sc.id_agente,
	p.zona,
	count(1) cant_sol
from
	solicitud_contrato sc
inner join propiedad p on
	sc.id_propiedad = p.id
group by
	sc.id_agente,
	p.zona
having
	cant_sol >= 2
),
age_efe as (
-- Los agentes más efectivos y la zona en donde son más efectivos
select
	cgz.zona,
	a.id,
	a.nombre,
	a.apellido,
	tpa.tie_prom_cierre,
	tca.tasa_conv,
	cgz.cant_sol cant_sol_zona,
	csc.cant_sol_cont cant_sol_cerrados,
	csc.val_tot_cont val_tot_cont_cerrados
from
	persona a
inner join tas_conv_age tca on
	a.id = tca.id_agente
inner join tie_prom_age tpa on
	a.id = tpa.id_agente
inner join cant_ges_zona cgz on
	a.id = cgz.id_agente
inner join cant_sol_cont csc on
	a.id = csc.id_agente
),
age_mas_efe as (
-- Conseguir por zona, el agente más efectivo por mayor conversion. Sino, menor tiempo promedio
select
	zona,
	max(tasa_conv) mayor_tasa,
	min(tie_prom_cierre) min_tiem_prom_cierre
from
	age_efe
group by
	zona
)
select
	ame.zona,
	ae.id,
	ae.nombre,
	ae.apellido,
	ame.min_tiem_prom_cierre,
	ame.mayor_tasa,
	ae.cant_sol_zona,
	ae.cant_sol_cerrados,
	ae.val_tot_cont_cerrados
from
	age_efe ae
inner join age_mas_efe ame on
	ae.zona = ame.zona
	and ae.tasa_conv = ame.mayor_tasa
	and ae.tie_prom_cierre = ame.min_tiem_prom_cierre;


with sol_por_zona as (
    -- Total de solicitudes por agente y zona
    select
        sc.id_agente,
        p.zona,
        count(*) cant_sol_tot
    from solicitud_contrato sc
    inner join propiedad p on sc.id_propiedad = p.id
    group by sc.id_agente, p.zona
    having cant_sol_tot >= 2
),
cont_cerr_zona as (
    -- Contratos cerrados por agente y zona
    select
        sc.id_agente,
        p.zona,
        count(*) cant_cont_cerrados,
        sum(sc.importe_mensual) val_tot_cont
    from solicitud_contrato sc
    inner join propiedad p on sc.id_propiedad = p.id
    where sc.fecha_contrato is not null
    group by sc.id_agente, p.zona
),
dias_cierre_zona as (
    -- Suma de días de cierre por agente y zona
    select
        sc.id_agente,
        p.zona,
        sum(datediff(sc.fecha_contrato, sc.fecha_solicitud)) suma_dias
    from solicitud_contrato sc
    inner join propiedad p on sc.id_propiedad = p.id
    where sc.fecha_contrato is not null
    group by sc.id_agente, p.zona
),
metricas_zona as (
    -- Unir todas las métricas
    select
        spz.id_agente,
        spz.zona,
        spz.cant_sol_tot,
        coalesce(ccz.cant_cont_cerrados, 0) cant_cont_cerrados,
        coalesce(ccz.val_tot_cont, 0) val_tot_cont,
        coalesce(dcz.suma_dias, 0) suma_dias
    from sol_por_zona spz
    left join cont_cerr_zona ccz on
        spz.id_agente = ccz.id_agente
        and spz.zona = ccz.zona
    left join dias_cierre_zona dcz on
        spz.id_agente = dcz.id_agente
        and spz.zona = dcz.zona
),
tas_conv_zona as (
    -- Calcular tasa de conversión
    select
        id_agente,
        zona,
        cant_sol_tot,
        cant_cont_cerrados,
        val_tot_cont,
        suma_dias,
        (cant_cont_cerrados / cant_sol_tot) * 100 tasa_conv
    from metricas_zona
    where (cant_cont_cerrados / cant_sol_tot) > 0.6
),
tie_prom_zona as (
    -- Calcular tiempo promedio
    select
        id_agente,
        zona,
        cant_sol_tot,
        cant_cont_cerrados,
        val_tot_cont,
        tasa_conv,
        suma_dias / cant_cont_cerrados tie_prom_cierre
    from tas_conv_zona
    where cant_cont_cerrados > 0
    having tie_prom_cierre < 30
),
max_tasa_zona as (
    -- Mayor tasa por zona
    select
        zona,
        max(tasa_conv) max_tasa
    from tie_prom_zona
    group by zona
),
age_max_tasa as (
    -- Agentes con la mayor tasa por zona
    select
        tpz.id_agente,
        tpz.zona,
        tpz.cant_sol_tot,
        tpz.cant_cont_cerrados,
        tpz.val_tot_cont,
        tpz.tasa_conv,
        tpz.tie_prom_cierre
    from tie_prom_zona tpz
    inner join max_tasa_zona mtz on
        tpz.zona = mtz.zona
        and tpz.tasa_conv = mtz.max_tasa
),
min_tie_zona as (
    -- Menor tiempo promedio entre los de mayor tasa por zona
    select
        zona,
        min(tie_prom_cierre) min_tie
    from age_max_tasa
    group by zona
),
mejor_por_zona as (
    -- El mejor agente por zona
    select
        amt.id_agente,
        amt.zona,
        amt.cant_sol_tot,
        amt.cant_cont_cerrados,
        amt.tasa_conv,
        amt.tie_prom_cierre,
        amt.val_tot_cont
    from age_max_tasa amt
    inner join min_tie_zona mtz on
        amt.zona = mtz.zona
        and amt.tie_prom_cierre = mtz.min_tie
)
select
    mpz.zona,
    mpz.id_agente,
    p.nombre,
    p.apellido,
    mpz.cant_sol_tot,
    mpz.cant_cont_cerrados,
    round(mpz.tasa_conv, 2) tasa_conversion_pct,
    round(mpz.tie_prom_cierre, 1) dias_promedio_cierre,
    mpz.val_tot_cont
from mejor_por_zona mpz
inner join persona p on mpz.id_agente = p.id;