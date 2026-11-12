# Rebuilds everything: download -> DuckDB -> dbt models + tests -> exports + dashboard data.
# Run from the repo root in PowerShell:  .\run_pipeline.ps1
# Add -Refresh to re-download the source CSV.

param([switch]$Refresh)
$ErrorActionPreference = "Stop"

Write-Host "1/3 Loading raw data" -ForegroundColor Cyan
if ($Refresh) { python ingest/load_raw.py --refresh } else { python ingest/load_raw.py }
if ($LASTEXITCODE -ne 0) { throw "Load failed" }

Write-Host "2/3 Building dbt models and running tests" -ForegroundColor Cyan
Push-Location dbt
dbt build --profiles-dir .
$dbtExit = $LASTEXITCODE
Pop-Location
if ($dbtExit -ne 0) { throw "dbt build failed - check the test output above" }

Write-Host "3/3 Exporting for Power BI and the web dashboard" -ForegroundColor Cyan
python analysis/build_outputs.py
if ($LASTEXITCODE -ne 0) { throw "Export failed" }

Write-Host "Done. Open docs/index.html in your browser, or refresh Power BI." -ForegroundColor Green
