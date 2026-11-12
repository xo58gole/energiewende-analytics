#!/usr/bin/env bash
# Same as run_pipeline.ps1, for macOS/Linux.  ./run_pipeline.sh [--refresh]
set -euo pipefail
cd "$(dirname "$0")"

echo "1/3 Loading raw data"
python3 ingest/load_raw.py "$@"

echo "2/3 Building dbt models and running tests"
(cd dbt && dbt build --profiles-dir .)

echo "3/3 Exporting for Power BI and the web dashboard"
python3 analysis/build_outputs.py

echo "Done. Open docs/index.html in your browser, or refresh Power BI."
