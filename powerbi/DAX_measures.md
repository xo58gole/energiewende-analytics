# DAX measures

Paste each one into Power BI via **Home → New measure**. Put them all in a
measure table called `_Measures` (Home → Enter data → name it `_Measures` → Load,
then create the measures on it) so they're easy to find.

Table names match the CSVs in `exports/`.

## Base measures

```dax
Generation TWh =
SUM ( fact_generation[generation_twh] )
```

```dax
Total Generation TWh =
SUM ( fact_country_year[total_generation_twh] )
```

```dax
Renewable TWh =
CALCULATE (
    [Generation TWh],
    dim_energy_source[is_renewable] = TRUE ()
)
```

```dax
Low-Carbon TWh =
CALCULATE (
    [Generation TWh],
    dim_energy_source[is_low_carbon] = TRUE ()
)
```

## Shares

```dax
Share of Generation % =
DIVIDE (
    [Generation TWh],
    CALCULATE ( [Generation TWh], REMOVEFILTERS ( dim_energy_source ) )
)
```

```dax
Renewable Share % =
DIVIDE ( [Renewable TWh], [Total Generation TWh] )
```

```dax
Low-Carbon Share % =
DIVIDE ( [Low-Carbon TWh], [Total Generation TWh] )
```

Format the three share measures as **Percentage, 1 decimal** (Measure tools → Format).

## Carbon intensity

Carbon intensity is a ratio, so it can't be summed across countries. This
averages it weighted by how much power each country makes, which is the honest
way to combine several countries.

```dax
Carbon Intensity g/kWh =
DIVIDE (
    SUMX (
        fact_country_year,
        fact_country_year[carbon_intensity_g_per_kwh] * fact_country_year[total_generation_twh]
    ),
    SUMX ( fact_country_year, fact_country_year[total_generation_twh] )
)
```

```dax
Carbon Intensity vs EU =
VAR Selected = [Carbon Intensity g/kWh]
VAR EU =
    CALCULATE (
        [Carbon Intensity g/kWh],
        REMOVEFILTERS ( dim_country ),
        dim_country[country_key] = "EU27"
    )
RETURN
    Selected - EU
```

## Change over time

```dax
Generation Change vs 2010 TWh =
VAR LatestYear = MAX ( dim_year[year] )
VAR Now =
    CALCULATE ( [Generation TWh], dim_year[year] = LatestYear )
VAR Then =
    CALCULATE ( [Generation TWh], dim_year[year] = 2010 )
RETURN
    Now - Then
```

```dax
Net Imports TWh =
SUM ( fact_country_year[net_imports_twh] )
```

```dax
Trade Position =
IF ( [Net Imports TWh] > 0, "Net importer", "Net exporter" )
```

## Ranking

```dax
Carbon Rank (1 = cleanest) =
IF (
    HASONEVALUE ( dim_country[country_name] ),
    RANKX (
        FILTER ( ALL ( dim_country ), dim_country[is_benchmark] = FALSE () ),
        [Carbon Intensity g/kWh],
        ,
        ASC
    )
)
```
