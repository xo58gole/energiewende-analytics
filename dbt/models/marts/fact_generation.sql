-- Grain: one row per country, year and energy source.

with gen as (

    select * from {{ ref('stg_generation_by_source') }}

),

countries as (

    select country_key, country_name from {{ ref('dim_country') }}

),

totals as (

    select country_name, year, total_generation_twh
    from {{ ref('stg_electricity') }}

)

select
    c.country_key,
    g.year,
    g.source_key,
    round(g.generation_twh, 3)                                          as generation_twh,
    round(100.0 * g.generation_twh / nullif(t.total_generation_twh, 0), 2) as share_of_generation_pct
from gen g
join countries c using (country_name)
join totals t using (country_name, year)
