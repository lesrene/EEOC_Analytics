-- =========================================================
-- 03_audit.sql
-- Purpose: Checks that the views have integrity/ match the original table 
-- Input:   
-- Output:  
-- =========================================================

-- checking that the view totals match the raw data's totals
SELECT
    (SELECT SUM(Employees) FROM v_racial_comp) AS view_total,
    (SELECT SUM(WHT10+BLKT10+HISPT10+ASIANT10+AIANT10+nhopiT10+tomrT10) FROM scoped_eeoc) AS raw_sum,
    (SELECT SUM(TOTAL10) FROM scoped_eeoc) AS raw_total; 
-- gap of 384 employees between view_total/raw_sum and raw_total 
-- 384 out of ~41 million is 0.0009% so that isn't too troubling; we can assume this gap is due to EEOC's 
-- suppression and rounding of small cells for confidentiality measures

SELECT
    COUNT(*) AS rows_with_gap,
    SUM(TOTAL10 - (
        COALESCE(WHT10,0) + COALESCE(BLKT10,0) + COALESCE(HISPT10,0)
      + COALESCE(ASIANT10,0) + COALESCE(AIANT10,0)
      + COALESCE(nhopiT10,0) + COALESCE(tomrT10,0)
    )) AS total_gap
FROM scoped_eeoc
WHERE TOTAL10 != (
    COALESCE(WHT10,0) + COALESCE(BLKT10,0) + COALESCE(HISPT10,0)
  + COALESCE(ASIANT10,0) + COALESCE(AIANT10,0)
  + COALESCE(nhopiT10,0) + COALESCE(tomrT10,0)
);
-- this confirms the gap of 384 is coming from 14 rows that contain NULLs in 
-- smaller categories like AIANT10, nhopiT10, tomrT10 that were probably suppressed/rounded down


-- checking to make sure the genders match up to raw 
SELECT COUNT(*) AS rows_with_gender_mismatch
FROM scoped_eeoc
WHERE COALESCE(MT10, 0) + COALESCE(FT10, 0) != COALESCE(TOTAL10, 0);

SELECT
    (SELECT SUM(Employees) FROM v_sex_comp) AS view_total,
    (SELECT SUM(COALESCE(MT10,0) + COALESCE(FT10,0)) FROM scoped_eeoc) AS raw_sum;








