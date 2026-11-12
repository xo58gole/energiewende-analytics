"""Pull the Our World in Data energy dataset into DuckDB's raw layer.

We keep the raw table untouched (all columns, all countries) so every
cleaning step is visible later in dbt. Re-running this script just
replaces the raw table with a fresh download.
"""

from __future__ import annotations

import argparse
from pathlib import Path

import duckdb

SOURCE_URL = "https://raw.githubusercontent.com/owid/energy-data/master/owid-energy-data.csv"
ROOT = Path(__file__).resolve().parents[1]
DEFAULT_DB = ROOT / "data" / "energiewende.duckdb"
DEFAULT_CSV = ROOT / "data" / "owid-energy-data.csv"


def download(csv_path: Path) -> None:
    """Download the CSV once; skip if we already have it."""
    if csv_path.exists():
        print(f"Using cached file: {csv_path.name}")
        return
    import urllib.request

    print(f"Downloading {SOURCE_URL} ...")
    csv_path.parent.mkdir(parents=True, exist_ok=True)
    urllib.request.urlretrieve(SOURCE_URL, csv_path)


def load(csv_path: Path, db_path: Path) -> None:
    db_path.parent.mkdir(parents=True, exist_ok=True)
    con = duckdb.connect(str(db_path))
    con.execute("create schema if not exists raw")
    con.execute(
        "create or replace table raw.owid_energy as "
        "select * from read_csv_auto(?, header = true, sample_size = -1)",
        [str(csv_path)],
    )
    rows, countries = con.execute(
        "select count(*), count(distinct country) from raw.owid_energy"
    ).fetchone()
    print(f"Loaded raw.owid_energy: {rows:,} rows, {countries} countries/regions")
    con.close()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--csv", type=Path, default=DEFAULT_CSV)
    parser.add_argument("--db", type=Path, default=DEFAULT_DB)
    parser.add_argument("--refresh", action="store_true", help="re-download the CSV")
    args = parser.parse_args()

    if args.refresh and args.csv.exists():
        args.csv.unlink()
    download(args.csv)
    load(args.csv, args.db)


if __name__ == "__main__":
    main()
