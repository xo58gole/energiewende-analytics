-- Unpivot the wide source columns into one row per country, year and source.
-- This long shape is what a star schema fact table (and Power BI) wants.
-- Missing values are dropped here (DuckDB's UNPIVOT skips nulls by default).

with long as (

    unpivot {{ ref('stg_electricity') }}
    on coal_twh, gas_twh, oil_twh, nuclear_twh, wind_twh,
       solar_twh, hydro_twh, bioenergy_twh, other_renewable_twh
    into
        name source_column
        value generation_twh

)

select
    country_name,
    year,
    replace(source_column, '_twh', '')  as source_key,
    generation_twh
from long
