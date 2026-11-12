# Building the Power BI report

About an hour, start to finish. You need **Power BI Desktop** (free, Microsoft Store)
on Windows. Everything else is already in this repo.

The finished report has one page, laid out like the web dashboard in `docs/`:
four KPI cards on top, the mix chart in the middle, two comparison charts below.

---

## 1. Load the data

1. Open Power BI Desktop → **Get data → Text/CSV**.
2. Load all five files from the `exports/` folder, one at a time:
   `dim_country.csv`, `dim_year.csv`, `dim_energy_source.csv`,
   `fact_generation.csv`, `fact_country_year.csv`.
   For each one click **Load** (not Transform). The defaults are fine.
3. Check the types in **Table view**: `year` should be a whole number,
   `generation_twh` and the other `_twh`/`_pct` columns decimal numbers,
   `is_renewable`/`is_low_carbon`/`is_benchmark` True/False.

## 2. Build the star schema

Go to **Model view**. Power BI may have guessed some relationships; delete any
that don't match this list, then drag to create the missing ones.
All are **many-to-one, single direction**, from the fact (many) to the dimension (one):

| From (many) | To (one) |
| --- | --- |
| `fact_generation[country_key]` | `dim_country[country_key]` |
| `fact_generation[year]` | `dim_year[year]` |
| `fact_generation[source_key]` | `dim_energy_source[source_key]` |
| `fact_country_year[country_key]` | `dim_country[country_key]` |
| `fact_country_year[year]` | `dim_year[year]` |

That's the star: two facts in the middle, three dimensions around them.
Take a screenshot of this view for the README (save it as `docs/img/powerbi-model.png`).

Two small tidy-ups:
- Select `dim_energy_source[source_name]` → **Column tools → Sort by column** → `sort_order`.
  This keeps Coal, Gas, … in a sensible order in every chart.
- Hide the key columns in the fact tables (right-click → Hide in report view),
  so report builders only see the dimension versions.

## 3. Add the measures

Open `DAX_measures.md` and paste in each measure. Format the `%` ones as
percentages with 1 decimal.

## 4. Apply the theme

**View → Themes → Browse for themes** → pick `powerbi/energiewende-theme.json`.
This gives you the same colours as the web dashboard.

## 5. Build the page

Set up two slicers first, top right: `dim_country[country_name]` (single select,
default **Germany**) and `dim_year[year]` (single select, default **2025**).
Set the year slicer to *not* filter the mix chart (Format → Edit interactions),
so that chart always shows the full 2000–2025 range.

| Visual | Type | Fields |
| --- | --- | --- |
| KPI: Renewable share | Card | `Renewable Share %` |
| KPI: Carbon intensity | Card | `Carbon Intensity g/kWh`; subtitle: `Carbon Intensity vs EU` |
| KPI: Carbon rank | Card | `Carbon Rank (1 = cleanest)` |
| KPI: Net imports | Card | `Net Imports TWh`; subtitle: `Trade Position` |
| Power mix over time | Stacked area | X `dim_year[year]`, Y `Generation TWh`, Legend `dim_energy_source[source_name]` |
| What replaced what | Clustered bar | Y `dim_energy_source[source_name]`, X `Generation Change vs 2010 TWh` |
| Carbon intensity vs peers | Clustered bar | Y `dim_country[country_name]`, X `Carbon Intensity g/kWh`; sort descending; edit interactions so the country slicer only highlights |
| Low-carbon share vs carbon | Scatter | X `Low-Carbon Share %`, Y `Carbon Intensity g/kWh`, Values `dim_country[country_name]` |

Tips:
- In the bar charts, turn on **data labels** and turn off gridlines you don't need.
- On "What replaced what", use **Format → Bars → Conditional formatting** to colour
  bars blue when positive and red when negative.
- Give every visual a title that states the point, not the field names
  ("Wind and solar replaced coal and nuclear", not "Generation Change by source_name").

## 6. Save and share

- Save as `powerbi/energiewende.pbix`.
- **File → Export → Export to PDF** and save as `powerbi/energiewende-report.pdf`,
  so people without Power BI can see it on GitHub.
- Screenshot the page as `docs/img/powerbi-report.png` and add it to the README.

## Refreshing with new data

Run the pipeline again (see the README), then in Power BI click **Home → Refresh**.
The CSVs are overwritten in place, so nothing else changes.
