"""
prepare_data.py
Reads raw EEOC PUF Excel files, adds a Year column, and combines them
into a single CSV. Also creates a reference table that contains the 
race x sex x job category breakdown of each column to use to unpivot
the wide table later.
"""

import pandas as pd
import os
import re


def build_combined_csv(raw_data_path, combined_filename = "combined_data.csv"):

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
    new_path = f"{raw_data_path}{combined_filename}"
    full_data.to_csv(new_path, index=False)


# make reference/lookup table funtion to add to the db by splitting the col names etc
def build_ref_table(demographic_cols):
    race_encodings = {
    'WH': 'White',
    'BLK': 'Black',
    'HISP': 'Hispanic',
    'ASIAN': 'Asian',
    'AIAN': 'AmericanIndian',
    'NHOPI': 'PacificIslander',
    'TOMR': 'Multiracial',
    'TOTAL': 'Aggregate'
}
    job_encodings = {
    '1': 'Senior Off and Managers',
    '2': 'Professionals',
    '3': 'Technicians',
    '4': 'Sales Workers',
    '5': 'Clericals',
    '6': 'Craft',
    '7': 'Operatives',
    '8': 'Labors',
    '9': 'Service',
    '10': 'Aggregate', 
    '1_2': 'Mid Off and Managers'
}
    races = ['WH', 'BLK', 'HISP', 'ASIAN', 'AIAN', 'NHOPI', 'TOMR', 'TOTAL', 'T']
    sexes = ['M', 'F', 'T', 'TOTAL']
    job_cats = [str(i) for i in range(1, 11)]
    job_cats.append("1_2")

    pattern = r'^(?:(?P<tot_agg>TOTAL)(?P<job_tot>1_2|10|[1-9])|(?P<sex_first>[MF])(?P<race_agg>T)(?P<job_sex>1_2|10|[1-9])|(?P<race>WH|BLK|HISP|ASIAN|AIAN|NHOPI|TOMR)(?P<sex_mid>T|M|F)?(?P<job_race>1_2|10|[1-9])?)$'    

    lookup_rows = []

    for col in demographic_cols:
        col = col.upper()
        match = re.match(pattern, col, re.IGNORECASE)

        if match:
            d = match.groupdict()

            if d['tot_agg']:
                demo_race = 'TOTAL'
                demo_sex = 'Aggregate'
                demo_job = d['job_tot']

            elif d['sex_first']:
                demo_race = 'TOTAL'
                demo_sex = 'Aggregate'
                demo_job = d['job_sex']

            else:
                if d['sex_mid'] == 'T':
                    demo_sex = 'Aggregate'
                else: 
                    demo_sex = d['sex_mid']
                    
                demo_race = d['race']
                demo_job = d['job_race']

            lookup_rows.append({
                        'col_name': col,
                        'race': race_encodings[demo_race],
                        'sex': demo_sex,
                        'job_cat': job_encodings[demo_job]
                    })

    return pd.DataFrame(lookup_rows)


