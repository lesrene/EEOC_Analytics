"""
prepare_data.py
Reads raw EEOC PUF Excel files, adds a Year column, and combines them
into a single CSV. 
"""

import pandas as pd
import os


def build_combined_csv():

    raw_data_path = "data/raw/"

    yearly_data = []

    for filename in os.listdir(raw_data_path):
        if filename.endswith(".xlsx"):
            if "_" in filename:
                year = filename.split("_")
            else: 
                year = filename.split()
            path = os.path.join(raw_data_path, filename)
            df = pd.read_excel(path)
            df["Year"] = year
            yearly_data.append(df)

    full_data = pd.concat(yearly_data, ignore_index=True)
    new_path = f"{raw_data_path}combined_data.csv"
    full_data.to_csv(new_path, index=False)