-- The sources should add up to total generation.
-- We allow up to 2% difference: the EU-27 aggregate for 2000-2003 is missing
-- about 1-1.5% of source detail in the upstream data (see README, data notes).
-- Anything bigger means a source is missing or double-counted.

select
    f.country_key,
    f.year,
    sum(f.generation_twh)       as sum_of_sources,
    max(c.total_generation_twh) as reported_total
from {{ ref('fact_generation') }} f
join {{ ref('fact_country_year') }} c using (country_key, year)
group by 1, 2
having abs(sum(f.generation_twh) - max(c.total_generation_twh))
       > 0.02 * max(c.total_generation_twh)
