-- =========================================================
-- 02_views_for_model.sql
-- Purpose: Build views for analysis over scoped_eeoc. Each view 
--          should help answer a specific question about DEI in the data.
-- Input:   scoped_eeoc (eeoc_data but only NAICS Sector 54 rows)
-- Output:  multiple SQL views
-- =========================================================

-- view for race of employees

DROP VIEW IF EXISTS v_racial_comp;

CREATE VIEW v_racial_comp AS
SELECT s.Year, s.State, d.race, SUM(
    CASE d.col_name
        WHEN 'WHT10' THEN s.WHT10
        WHEN 'BLKT10' THEN s.BLKT10
        WHEN 'HISPT10' THEN s.HISPT10
        WHEN 'ASIANT10' THEN s.ASIANT10
        WHEN 'AIANT10' THEN s.AIANT10
        WHEN 'NHOPIT10' THEN s.nhopiT10
        WHEN 'TOMRT10' THEN s.tomrT10
    END) AS Employees
FROM scoped_eeoc s
JOIN demographics_ref d ON d.sex = 'Aggregate' AND d.job_cat = 'Aggregate' AND d.race != 'Aggregate'
GROUP BY s.Year, s.State, d.race;

-- view for sex of employees

DROP VIEW IF EXISTS v_sex_comp;

CREATE VIEW v_sex_comp AS
SELECT s.Year, s.State, d.sex, SUM(
    CASE d.col_name
        WHEN 'MT10' THEN s.MT10
        WHEN 'FT10' THEN s.FT10
    END) AS Employees
FROM scoped_eeoc s
JOIN demographics_ref d ON d.race = 'Aggregate' AND d.job_cat = 'Aggregate' AND d.sex != 'Aggregate'
GROUP BY s.Year, s.State, d.sex;

-- view for race of employees in senior leadership 

DROP VIEW IF EXISTS v_exec_race;

CREATE VIEW v_exec_race AS
SELECT s.Year, s.State, d.race, SUM(
    CASE d.col_name
        WHEN 'WHT1' THEN s.WHT1
        WHEN 'BLKT1' THEN s.BLKT1
        WHEN 'HISPT1' THEN s.HISPT1
        WHEN 'ASIANT1' THEN s.ASIANT1
        WHEN 'AIANT1' THEN s.AIANT1
        WHEN 'NHOPIT1' THEN s.nhopiT1
        WHEN 'TOMRT1' THEN s.tomrT1
    END) AS Employees
FROM scoped_eeoc s
JOIN demographics_ref d ON d.sex = 'Aggregate' AND d.job_cat = 'Senior Off and Managers' AND d.race != 'Aggregate'
GROUP BY s.Year, s.State, d.race;

-- view for race x sex of employees in senior leadership 

DROP VIEW IF EXISTS v_exec_intersectional;

CREATE VIEW v_exec_intersectional AS
SELECT s.Year, s.State, d.race, d.sex, SUM(
    CASE d.col_name
        WHEN 'WHM1' THEN s.WHM1
        WHEN 'WHF1' THEN s.WHF1
        WHEN 'BLKM1' THEN s.BLKM1
        WHEN 'BLKF1' THEN s.BLKF1
        WHEN 'HISPM1' THEN s.HISPM1
        WHEN 'HISPF1' THEN s.HISPF1
        WHEN 'ASIANM1' THEN s.ASIANM1
        WHEN 'ASIANF1' THEN s.ASIANF1
        WHEN 'AIANM1' THEN s.AIANM1
        WHEN 'AIANF1' THEN s.AIANF1
        WHEN 'NHOPIM1' THEN s.NHOPIM1
        WHEN 'NHOPIF1' THEN s.NHOPIF1
        WHEN 'TOMRM1' THEN s.TOMRM1
        WHEN 'TOMRF1' THEN s.TOMRF1
    END) AS Employees
FROM scoped_eeoc s
JOIN demographics_ref d ON d.sex != 'Aggregate' AND d.job_cat = 'Senior Off and Managers' AND d.race != 'Aggregate'
GROUP BY s.Year, s.State, d.race, d.sex;

-- view for race by job level

DROP VIEW IF EXISTS v_leadership_ladder;

CREATE VIEW v_leadership_ladder AS
SELECT Year, State, 'Executive' AS job_level, race, employees FROM v_exec_race
UNION ALL
SELECT s.Year, s.State, 'Mid' AS job_level, d.race, SUM(
    CASE d.col_name
        WHEN 'WHT1_2'    THEN s.WHT1_2
        WHEN 'BLKT1_2'   THEN s.BLKT1_2
        WHEN 'HISPT1_2'  THEN s.HISPT1_2
        WHEN 'ASIANT1_2' THEN s.ASIANT1_2
        WHEN 'AIANT1_2'  THEN s.AIANT1_2
        WHEN 'NHOPIT1_2' THEN s.nhopiT1_2
        WHEN 'TOMRT1_2'  THEN s.tomrT1_2
    END) AS Employees
FROM scoped_eeoc s
JOIN demographics_ref d
    ON d.sex = 'Aggregate'
    AND d.job_cat = 'Mid Off and Managers'
    AND d.race != 'Aggregate'
GROUP BY s.Year, s.State, d.race
UNION ALL
SELECT s.Year, s.State, 'Professional' AS job_level, d.race, SUM(
    CASE d.col_name
        WHEN 'WHT2'    THEN s.WHT2
        WHEN 'BLKT2'   THEN s.BLKT2
        WHEN 'HISPT2'  THEN s.HISPT2
        WHEN 'ASIANT2' THEN s.ASIANT2
        WHEN 'AIANT2'  THEN s.AIANT2
        WHEN 'NHOPIT2' THEN s.nhopiT2
        WHEN 'TOMRT2'  THEN s.tomrT2
    END) AS Employees
FROM scoped_eeoc s
JOIN demographics_ref d
    ON d.sex = 'Aggregate'
    AND d.job_cat = 'Professionals'
    AND d.race != 'Aggregate'
GROUP BY s.Year, s.State, d.race;

-- view for showing the number of establishments contributed to each row of year x state

DROP VIEW IF EXISTS v_establishment_context;

CREATE VIEW v_establishment_context AS
SELECT
    Year,
    State,
    SUM(Establishments) AS total_establishments,
    SUM(TOTAL10) AS total_employees,
    ROUND(1.0 * SUM(TOTAL10) / NULLIF(SUM(Establishments), 0), 1) AS avg_employees_per_establishment
FROM scoped_eeoc
GROUP BY Year, State;

-- view for seeing BIPOC pop vs White pop by different geographical units

DROP VIEW IF EXISTS v_geography_bipoc;

CREATE VIEW v_geography_bipoc AS
SELECT Year, Region, Division, State,  
    SUM(BLKT10 + HISPT10 + ASIANT10 + AIANT10 + nhopiT10 + tomrT10) AS non_white,
    SUM(TOTAL10) AS total,
    ROUND(
        100.0 * SUM(BLKT10 + HISPT10 + ASIANT10 + AIANT10 + nhopiT10 + tomrT10)
        / NULLIF(SUM(TOTAL10), 0),
        2
    ) AS non_white_ratio
FROM scoped_eeoc
GROUP BY Year, Region, Division, State;


