-- Year dimension with the policy milestones that explain Germany's curve.

with years as (

    select distinct year from {{ ref('stg_electricity') }}

),

milestones as (

    select * from (values
        (2000, 'EEG renewable energy law passed'),
        (2011, 'Fukushima: 8 reactors shut down'),
        (2020, 'Coal phase-out law passed'),
        (2022, 'Energy crisis after gas supply cut'),
        (2023, 'Last nuclear plants close')
    ) as m(year, milestone)

)

select
    y.year,
    (y.year // 10) * 10                                     as decade,
    case
        when y.year < 2011 then '2000-2010 Early expansion'
        when y.year < 2020 then '2011-2019 Nuclear exit begins'
        else '2020+ Coal exit & energy crisis'
    end                                                     as policy_phase,
    m.milestone,
    y.year = (select max(year) from years)                  as is_latest_year
from years y
left join milestones m using (year)
