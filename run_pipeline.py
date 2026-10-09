"""
run_pipeline.py
Combines the yearly excel data into one CSV if one does not already exist, loads that csv into SQLite.

Will eventually run the sql scripts to make the database usable.
"""


from pathlib import Path
import pandas as pd
import sqlite3
from prepare_data import build_combined_csv, build_ref_table


PROJECT_ROOT = Path(__file__).resolve().parent
RAW_DIR      = PROJECT_ROOT / "data" / "raw"
COMBINED_CSV = RAW_DIR / "combined_data.csv"
DB_PATH = PROJECT_ROOT / "data" / "processed" / "eeoc.db"



def main():
    # make sure there's a combined yearly csv and if not creates one by calling the build_combined_csv function
    if not COMBINED_CSV.exists():
        build_combined_csv(RAW_DIR)

    # connect to sql
    conn = sqlite3.connect(DB_PATH)

    # load combined data into eeoc database
    df = pd.read_csv(COMBINED_CSV)
    df.to_sql("eeoc_data", conn, if_exists="replace", index=False)
    print(f"Loaded data in EEOC database with {len(df):,} rows")

    # makes demographic col reference table and loads into eeoc database
    demographic_cols = df.columns[12:275]
    build_ref_table(demographic_cols).to_sql("demographics_ref", conn, if_exists="replace", index=False)

    conn.commit()
    conn.close()


if __name__ == "__main__":
    main()