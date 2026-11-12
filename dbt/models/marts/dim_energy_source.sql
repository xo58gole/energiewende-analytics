select
    source_key,
    source_name,
    source_group,
    is_renewable,
    is_low_carbon,
    sort_order
from {{ ref('energy_source') }}
