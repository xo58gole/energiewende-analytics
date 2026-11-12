select
    country_code                    as country_key,
    country_name,
    region,
    is_benchmark,
    country_name = 'Germany'        as is_focus_country
from {{ ref('country_scope') }}
