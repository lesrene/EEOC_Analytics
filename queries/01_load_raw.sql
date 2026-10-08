-- =========================================================
-- 01_load_raw.sql
-- Purpose: Filter eeoc_data table so only rows with 
--          NAICS Sector 54 (Professional,
--          Scientific, and Technical Services) are included.
-- Input:   eeoc_data (combined yearly data)
-- Output:  scoped_eeoc (eeoc_data but only NAICS Sector 54 rows)
-- =========================================================

-- sanity checks on the raw table

SELECT YEAR, COUNT(*) AS rows_per_year
FROM eeoc_data
GROUP BY YEAR
ORDER BY YEAR;

SELECT NAICS2, COUNT(*) AS row_count
FROM eeoc_data
GROUP BY NAICS2
ORDER BY row_count DESC
LIMIT 20;


-- build table filtered to NAICS Sector 54

DROP TABLE IF EXISTS scoped_eeoc;

CREATE TABLE scoped_eeoc AS
SELECT *
FROM eeoc_data
WHERE NAICS2 = '54';


-- confirms the filter did what was intended

SELECT
    (SELECT COUNT(*) FROM eeoc_data) AS raw_rows,
    (SELECT COUNT(*) FROM eeoc_data WHERE NAICS2 = '54') AS expected_scoped,
    (SELECT COUNT(*) FROM scoped_eeoc) AS actual_scoped;

