-- One row per country and year, only the electricity columns we use,
-- renamed to clear units. Filtered to our country scope and 2000 onwards.

with source as (

    select * from {{ source('raw', 'owid_energy') }}

),

scope as (

    select country_name from {{ ref('country_scope') }}

)

select
    s.country                                   as country_name,
    cast(s.year as integer)                     as year,
    cast(s.population as bigint)                as population,

    -- generation by source, terawatt-hours
    s.coal_electricity                          as coal_twh,
    s.gas_electricity                           as gas_twh,
    s.oil_electricity                           as oil_twh,
    s.nuclear_electricity                       as nuclear_twh,
    s.wind_electricity                          as wind_twh,
    s.solar_electricity                         as solar_twh,
    s.hydro_electricity                         as hydro_twh,
    s.biofuel_electricity                       as bioenergy_twh,
    s.other_renewable_exc_biofuel_electricity   as other_renewable_twh,

    -- totals and context
    s.electricity_generation                    as total_generation_twh,
    s.electricity_demand                        as demand_twh,
    s.net_elec_imports                          as net_imports_twh,
    s.carbon_intensity_elec                     as carbon_intensity_g_per_kwh

from source s
inner join scope c on s.country = c.country_name
where s.year >= {{ var('start_year') }}
  and s.electricity_generation is not null
