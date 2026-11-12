-- Grain: one row per country and year. Totals, context and the
-- headline KPIs, so a dashboard doesn't have to rebuild them.

with e as (

    select * from {{ ref('stg_electricity') }}

),

mix as (

    select
        f.country_key,
        f.year,
        sum(case when s.is_renewable then f.generation_twh else 0 end)  as renewable_twh,
        sum(case when s.is_low_carbon then f.generation_twh else 0 end) as low_carbon_twh,
        sum(case when s.source_group = 'Fossil' then f.generation_twh else 0 end) as fossil_twh
    from {{ ref('fact_generation') }} f
    join {{ ref('dim_energy_source') }} s using (source_key)
    group by 1, 2

)

select
    c.country_key,
    e.year,
    e.population,
    round(e.total_generation_twh, 3)                                   as total_generation_twh,
    round(e.demand_twh, 3)                                             as demand_twh,
    round(e.net_imports_twh, 3)                                        as net_imports_twh,
    round(e.carbon_intensity_g_per_kwh, 1)                             as carbon_intensity_g_per_kwh,
    round(m.renewable_twh, 3)                                          as renewable_twh,
    round(m.fossil_twh, 3)                                             as fossil_twh,
    round(100.0 * m.renewable_twh  / nullif(e.total_generation_twh, 0), 2) as renewable_share_pct,
    round(100.0 * m.low_carbon_twh / nullif(e.total_generation_twh, 0), 2) as low_carbon_share_pct,
    round(100.0 * m.fossil_twh     / nullif(e.total_generation_twh, 0), 2) as fossil_share_pct,
    round(1e9 * e.demand_twh / nullif(e.population, 0), 0)             as demand_kwh_per_person
from e
join {{ ref('dim_country') }} c using (country_name)
join mix m on m.country_key = c.country_key and m.year = e.year
