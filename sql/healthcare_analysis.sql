/*
==========================================
HEALTHCARE COST INEQUITY ANALYSIS
Analyzing Medicare hospital costs, community vulnerability, and quality across US states
Author: Sai Krishna Varshith Danda
Date: March 2026
==========================================

PROJECT STRUCTURE:
- This file: SQL queries with explanations and findings
- README.md: Project overview and key findings summary
- Excel files: Summary tables for quick reference
- Tableau workbook: Interactive visualizations and dashboards

METHODOLOGY SUMMARY:

WEIGHTED AVERAGES:
- Formula: SUM(value × weight) / SUM(weight)
- Costs weighted by patient discharges, vulnerability by population
- Quality uses simple average (ratings already normalized)
- Rationale: Reflects average person's experience, not average facility/county

DATA SOURCES & YEARS:
- hospital_costs: CMS Medicare IPPS (2023)
  * 146,427 records in analysis dataset
  * Hospital-condition-level payment data
  * Analysis filtered to septicemia (queries 1-6) and all conditions (queries 7-11)

- community_vulnerability: CDC Social Vulnerability Index (2022)
  * 3,144 records (one per U.S. county)
  * County-level demographic and socioeconomic metrics

- hospital_quality: CMS Hospital Compare (2025)
  * 2,869 records (one per rated hospital)
  * Hospital-level quality star ratings

- Note: Different years due to agency release schedules; metrics represent stable patterns

KEY METRICS:
- Avg_Tot_Pymt_Amt = Total payment (Medicare + patient copay) - represents actual cost
- rpl_themes = Percentile rank vs ALL US counties (0.57 = more vulnerable than 57%)
- overall_rating = CMS 5-star quality rating (5=excellent, 1=poor)

RUCA CODES (Geographic Classification):
- 1-3: Urban (metropolitan cores)
- 4-6: Suburban (micropolitan areas)
- 7-10: Rural (small towns, isolated areas)

DATA INTEGRATION:
- All datasets joined at state-level
- hospital_costs contains all medical conditions; queries 1-6 filtered to septicemia
- hospital_quality represents all rated hospitals regardless of conditions treated
- Facility IDs incompatible across datasets - state aggregation ensures valid comparison

DATA CLEANING:
- Missing values (-999) converted to NULL
- NULLIF used to prevent division by zero
- RUCA codes filtered to valid range (1-10)

ANALYSIS APPROACH:
- Queries 1-6: Septicemia-specific (most common condition, controlled comparison)
- Queries 7-11: All conditions (validates patterns are systemic, not disease-specific)
*/

-- ==========================================
-- SECTION 1: SEPTICEMIA & ALASKA DEEP DIVE (Q1-6)
-- Focused analysis on most common condition with Alaska cost comparison
-- ========================================== 


-- Query 1: Identify Most Common Medical Condition
-- Purpose: Establish baseline condition for controlled state-to-state comparison
-- Finding: Septicemia treated at 2,678 hospitals with 561,795 total patients
-- Why this matters: Universal treatment availability enables fair cost comparisons across states
SELECT
    "DRG_Desc" AS condition_name,
    COUNT(DISTINCT "Rndrng_Prvdr_CCN") AS num_hospitals,
    SUM("Tot_Dschrgs") AS total_patients
FROM hospital_costs
GROUP BY "DRG_Desc"
ORDER BY num_hospitals DESC;


-- Query 2: State-Level Cost Rankings for Septicemia Treatment
-- Purpose: Compare Medicare payments across all 51 states for identical treatment
-- Finding: Alaska charges $24,728 (highest), Vermont $12,079 (lowest) - 105% difference
-- Why this matters: Identifies extreme cost outliers that need investigation
-- Methodology: Weighted average by patient volume to reflect typical patient experience
SELECT 
    "Rndrng_Prvdr_State_Abrvtn" AS state,
    SUM("Tot_Dschrgs") AS total_patients,
    COUNT(DISTINCT "Rndrng_Prvdr_CCN") AS num_hospitals,
    ROUND(
        CAST(SUM("Tot_Dschrgs" * "Avg_Tot_Pymt_Amt") AS NUMERIC) / 
        NULLIF(SUM("Tot_Dschrgs"), 0), 
    2) AS avg_payment
FROM hospital_costs
WHERE "DRG_Desc" = 'SEPTICEMIA OR SEVERE SEPSIS WITHOUT MV >96 HOURS WITH MCC'
GROUP BY "Rndrng_Prvdr_State_Abrvtn"
ORDER BY avg_payment DESC;


-- Query 3: Alaska Rural vs Urban Cost Analysis
-- Purpose: Determine if Alaska's high costs are concentrated in remote areas
-- Finding: Rural Alaska charges $31,249 (32% more than urban $23,693)
-- Why this matters: Tests if geography within Alaska explains the high baseline costs
-- Note: Even Alaska's urban areas are expensive compared to national averages
SELECT 
    CASE 
        WHEN "Rndrng_Prvdr_RUCA" <= 3 THEN 'urban'
        WHEN "Rndrng_Prvdr_RUCA" <= 6 THEN 'suburban'
        WHEN "Rndrng_Prvdr_RUCA" <= 10 THEN 'rural'
    END AS area_type,
    ROUND(
        CAST(SUM("Avg_Tot_Pymt_Amt" * "Tot_Dschrgs") AS NUMERIC) / 
        NULLIF(SUM("Tot_Dschrgs"), 0), 
    2) AS avg_payment,
    SUM("Tot_Dschrgs") AS total_patients,
    COUNT(DISTINCT "Rndrng_Prvdr_CCN") AS num_hospitals
FROM hospital_costs
WHERE "Rndrng_Prvdr_State_Abrvtn" = 'AK' 
  AND "DRG_Desc" = 'SEPTICEMIA OR SEVERE SEPSIS WITHOUT MV >96 HOURS WITH MCC'
GROUP BY area_type
ORDER BY avg_payment DESC;


-- Query 4: Alaska vs Vermont - Cost and Vulnerability Comparison
-- Purpose: Compare highest-cost and lowest-cost states on socioeconomic factors
-- Finding: Alaska charges $24,728 with 0.57 vulnerability vs Vermont $12,079 with 0.23 vulnerability
-- Why this matters: Tests if high costs correlate with vulnerable populations needing more care
-- Key insight: Alaska has BOTH higher costs AND higher vulnerability (counterintuitive - should cost less if population is struggling)
-- Data note: Combines hospital costs (2023) with CDC vulnerability data (2022)
WITH septicemia_costs AS (
    SELECT 
        "Rndrng_Prvdr_State_Abrvtn" AS state,
        ROUND(
            CAST(SUM("Tot_Dschrgs" * "Avg_Tot_Pymt_Amt") / 
            NULLIF(SUM("Tot_Dschrgs"), 0) AS NUMERIC), 
        2) AS avg_payment,
        SUM("Tot_Dschrgs") AS total_patients,
        COUNT(DISTINCT "Rndrng_Prvdr_CCN") AS num_hospitals
    FROM hospital_costs
    WHERE "DRG_Desc" = 'SEPTICEMIA OR SEVERE SEPSIS WITHOUT MV >96 HOURS WITH MCC'
    GROUP BY "Rndrng_Prvdr_State_Abrvtn"
),

state_vulnerability AS (
    SELECT 
        state,
        SUM(e_totpop) AS total_population,
        ROUND(SUM(rpl_themes * e_totpop) / NULLIF(SUM(e_totpop), 0), 2) AS avg_vulnerability,
        ROUND(SUM(ep_pov150 * e_totpop) / NULLIF(SUM(e_totpop), 0), 1) AS pct_poverty,
        ROUND(SUM(ep_uninsur * e_totpop) / NULLIF(SUM(e_totpop), 0), 1) AS pct_uninsured,
        ROUND(SUM(ep_unemp * e_totpop) / NULLIF(SUM(e_totpop), 0), 1) AS pct_unemployed,
        ROUND(SUM(ep_age65 * e_totpop) / NULLIF(SUM(e_totpop), 0), 1) AS pct_elderly,
        ROUND(SUM(ep_age17 * e_totpop) / NULLIF(SUM(e_totpop), 0), 1) AS pct_youth,
        ROUND(SUM(ep_disabl * e_totpop) / NULLIF(SUM(e_totpop), 0), 1) AS pct_disabled
    FROM community_vulnerability
    GROUP BY state
)

SELECT 
    c.state,
    c.avg_payment,
    c.total_patients,
    c.num_hospitals,
    v.total_population,
    v.avg_vulnerability,
    v.pct_poverty,
    v.pct_uninsured,
    v.pct_unemployed,
    v.pct_elderly,
    v.pct_youth,
    v.pct_disabled
FROM septicemia_costs c
INNER JOIN state_vulnerability v ON c.state = v.state
WHERE c.state IN ('AK', 'VT')
ORDER BY v.total_population;


-- Query 5: Alaska vs Vermont - Adding Hospital Quality to Comparison
-- Purpose: Test if Alaska's high costs buy better quality care
-- Finding: Both states have poor quality (~2.88 rating) despite Alaska charging 2× more
-- Why this matters: Proves Alaska's high costs don't translate to better outcomes
-- Key insight: This is the "triple burden" - high cost, high vulnerability, poor quality
-- Data note: Quality ratings (2025) represent overall hospital performance, not septicemia-specific (CMS doesn't rate by condition)
WITH septicemia_costs AS (
    SELECT 
        "Rndrng_Prvdr_State_Abrvtn" AS state,
        ROUND(
            CAST(SUM("Tot_Dschrgs" * "Avg_Tot_Pymt_Amt") /  
            NULLIF(SUM("Tot_Dschrgs"), 0) AS NUMERIC), 
        2) AS avg_payment,
        SUM("Tot_Dschrgs") AS total_patients,
        COUNT(DISTINCT "Rndrng_Prvdr_CCN") AS num_hospitals
    FROM hospital_costs
    WHERE "DRG_Desc" = 'SEPTICEMIA OR SEVERE SEPSIS WITHOUT MV >96 HOURS WITH MCC'
    GROUP BY "Rndrng_Prvdr_State_Abrvtn"
),

state_vulnerability AS (
    SELECT 
        state,
        SUM(e_totpop) AS total_population,
        ROUND(SUM(rpl_themes * e_totpop) / NULLIF(SUM(e_totpop), 0), 2) AS avg_vulnerability,
        ROUND(SUM(ep_pov150 * e_totpop) / NULLIF(SUM(e_totpop), 0), 1) AS pct_poverty,
        ROUND(SUM(ep_uninsur * e_totpop) / NULLIF(SUM(e_totpop), 0), 1) AS pct_uninsured,
        ROUND(SUM(ep_unemp * e_totpop) / NULLIF(SUM(e_totpop), 0), 1) AS pct_unemployed,
        ROUND(SUM(ep_age65 * e_totpop) / NULLIF(SUM(e_totpop), 0), 1) AS pct_elderly,
        ROUND(SUM(ep_age17 * e_totpop) / NULLIF(SUM(e_totpop), 0), 1) AS pct_youth,
        ROUND(SUM(ep_disabl * e_totpop) / NULLIF(SUM(e_totpop), 0), 1) AS pct_disabled
    FROM community_vulnerability
    GROUP BY state
),

state_quality AS (
    SELECT 
        state,
        COUNT(facility_id) AS num_rated_hospitals,
        ROUND(AVG(overall_rating), 2) AS avg_quality_rating
    FROM hospital_quality
    GROUP BY state
)

SELECT 
    c.state,
    c.avg_payment,
    c.total_patients,
    c.num_hospitals,
    v.total_population,
    v.avg_vulnerability,
    v.pct_poverty,
    v.pct_uninsured,
    v.pct_unemployed,
    v.pct_elderly,
    v.pct_youth,
    v.pct_disabled,
    q.num_rated_hospitals,
    q.avg_quality_rating
FROM septicemia_costs c
INNER JOIN state_vulnerability v ON c.state = v.state
INNER JOIN state_quality q ON c.state = q.state
WHERE c.state IN ('AK', 'VT');


-- Query 6: Alaska vs Similar Population States - Peer Comparison
-- Purpose: Compare Alaska to states with similar population size (500K-1M) to control for scale
-- Finding: Among 7 peer states, Alaska ranks 5th in quality but 2nd in cost (worst value)
-- Why this matters: Shows Alaska's problem isn't just "small state" - other small states have better quality for less cost
-- Key insight: Vermont has similar poor quality but charges half the price, proving Alaska's costs aren't justified
-- Population filter: 500K-1M ensures comparable infrastructure and economies of scale
WITH septicemia_costs AS (
    SELECT 
        "Rndrng_Prvdr_State_Abrvtn" AS state,
        SUM("Tot_Dschrgs") AS total_patients,
        ROUND(
            CAST(SUM("Tot_Dschrgs" * "Avg_Tot_Pymt_Amt") AS NUMERIC) / 
            NULLIF(SUM("Tot_Dschrgs"), 0), 
        2) AS avg_payment,
        COUNT(DISTINCT "Rndrng_Prvdr_CCN") AS num_hospitals
    FROM hospital_costs
    WHERE "DRG_Desc" = 'SEPTICEMIA OR SEVERE SEPSIS WITHOUT MV >96 HOURS WITH MCC'
    GROUP BY "Rndrng_Prvdr_State_Abrvtn"
),

state_vulnerability AS (
    SELECT 
        state,
        SUM(e_totpop) AS total_population,
        ROUND(SUM(rpl_themes * e_totpop) / SUM(e_totpop), 2) AS avg_vulnerability,
        ROUND(SUM(ep_pov150 * e_totpop) / SUM(e_totpop), 2) AS pct_poverty,
        ROUND(SUM(ep_uninsur * e_totpop) / SUM(e_totpop), 2) AS pct_uninsured,
        ROUND(SUM(ep_unemp * e_totpop) / SUM(e_totpop), 2) AS pct_unemployed,
        ROUND(SUM(ep_age65 * e_totpop) / SUM(e_totpop), 2) AS pct_elderly,
        ROUND(SUM(ep_age17 * e_totpop) / SUM(e_totpop), 2) AS pct_youth,
        ROUND(SUM(ep_disabl * e_totpop) / SUM(e_totpop), 2) AS pct_disabled
    FROM community_vulnerability
    GROUP BY state
),

state_quality AS (
    SELECT 
        state,
        COUNT(DISTINCT facility_id) AS num_rated_hospitals,
        ROUND(AVG(overall_rating), 2) AS avg_quality_rating
    FROM hospital_quality
    GROUP BY state
)

SELECT 
    c.state,
    c.total_patients,
    c.avg_payment,
    c.num_hospitals,
    v.total_population,
    v.avg_vulnerability,
    v.pct_poverty,
    v.pct_uninsured,
    v.pct_unemployed,
    v.pct_elderly,
    v.pct_youth,
    v.pct_disabled,
    q.num_rated_hospitals,
    q.avg_quality_rating,
    DENSE_RANK() OVER (ORDER BY q.avg_quality_rating DESC) AS quality_rank
FROM septicemia_costs c
INNER JOIN state_vulnerability v ON c.state = v.state
INNER JOIN state_quality q ON c.state = q.state
WHERE v.total_population BETWEEN 500000 AND 1000000
ORDER BY q.avg_quality_rating DESC;

 
-- ==========================================
-- SECTION 2: BROADER VALIDATION (Q7-11)
-- Testing if patterns hold across all medical conditions (not just septicemia)
-- ==========================================


-- Query 7: National Rural vs Urban Healthcare Costs (All Conditions)
-- Purpose: Determine how common rural healthcare premiums are across the U.S.
-- Finding: Only 4 of 51 states charge rural areas more (NM, CO, KS, CA) - just 8%
-- Why this matters: Challenges common assumption that rural healthcare is always more expensive
-- Key insight: Alaska's 32% rural premium (from Query 3) is unusual nationally
-- Data scope: All medical conditions (not septicemia-specific) to validate broad pattern
WITH area_costs AS (
    SELECT 
        "Rndrng_Prvdr_State_Abrvtn" AS state,
        CASE 
            WHEN "Rndrng_Prvdr_RUCA" <= 3 THEN 'urban'
            WHEN "Rndrng_Prvdr_RUCA" <= 6 THEN 'suburban'
            WHEN "Rndrng_Prvdr_RUCA" <= 10 THEN 'rural'
        END AS area_type,
        COUNT(DISTINCT "Rndrng_Prvdr_CCN") AS num_hospitals,
        SUM("Tot_Dschrgs") AS total_patients,
        ROUND(
            CAST(SUM("Tot_Dschrgs" * "Avg_Tot_Pymt_Amt") AS NUMERIC) / 
            SUM("Tot_Dschrgs"), 
        2) AS avg_payment
    FROM hospital_costs
    WHERE "Rndrng_Prvdr_RUCA" IS NOT NULL 
      AND "Rndrng_Prvdr_RUCA" BETWEEN 1 AND 10
    GROUP BY state, area_type
)

SELECT 
    state,
    MAX(CASE WHEN area_type = 'rural' THEN avg_payment END) AS rural_cost,
    MAX(CASE WHEN area_type = 'urban' THEN avg_payment END) AS urban_cost,
    (MAX(CASE WHEN area_type = 'rural' THEN avg_payment END) - 
     MAX(CASE WHEN area_type = 'urban' THEN avg_payment END)) AS cost_difference,
    ROUND(
        (MAX(CASE WHEN area_type = 'rural' THEN avg_payment END) - 
         MAX(CASE WHEN area_type = 'urban' THEN avg_payment END)) * 100.0 / 
        MAX(CASE WHEN area_type = 'urban' THEN avg_payment END), 
    1) AS rural_premium_pct
FROM area_costs
WHERE area_type IN ('rural', 'urban')
GROUP BY state
HAVING MAX(CASE WHEN area_type = 'rural' THEN avg_payment END) > 
       MAX(CASE WHEN area_type = 'urban' THEN avg_payment END)
ORDER BY rural_premium_pct DESC;


-- Query 8: Cost vs Vulnerability Correlation Analysis (All Conditions)
-- Purpose: Test if high healthcare costs correlate with vulnerable populations
-- Finding: Mixed pattern - 7 of 10 expensive states are vulnerable, but not all vulnerable states are expensive
-- Why this matters: If vulnerable populations needed more care, costs might be justified - but pattern is inconsistent
-- Example: Mississippi (vulnerability 0.75) costs $13,173 while Alaska (vulnerability 0.57) costs $24,894
-- Key insight: Vulnerability doesn't fully explain cost variation
WITH state_costs AS (
    SELECT 
        "Rndrng_Prvdr_State_Abrvtn" AS state,
        ROUND(
            CAST(SUM("Tot_Dschrgs" * "Avg_Tot_Pymt_Amt") AS NUMERIC) / 
            SUM("Tot_Dschrgs"), 
        2) AS avg_payment,
        SUM("Tot_Dschrgs") AS total_patients,
        COUNT("Rndrng_Prvdr_CCN") AS num_hospitals
    FROM hospital_costs
    GROUP BY state
),

state_vulnerability AS (
    SELECT 
        state,
        SUM(e_totpop) AS total_population,
        ROUND(
            CAST(SUM(rpl_themes * e_totpop) AS NUMERIC) / 
            SUM(e_totpop), 
        2) AS avg_vulnerability
    FROM community_vulnerability
    GROUP BY state
)

SELECT 
    c.state,
    c.avg_payment,
    v.avg_vulnerability,
    CASE 
        WHEN v.avg_vulnerability >= 0.75 THEN 'High vulnerability'
        WHEN v.avg_vulnerability >= 0.50 THEN 'Above avg vulnerability'
        WHEN v.avg_vulnerability >= 0.25 THEN 'Below avg vulnerability'
        ELSE 'Low vulnerability'
    END AS vulnerability_category
FROM state_costs c
INNER JOIN state_vulnerability v ON c.state = v.state
ORDER BY c.avg_payment DESC;


-- Query 9: Vulnerability vs Quality Correlation Analysis (All Conditions)
-- Purpose: Test if vulnerable populations receive lower quality healthcare (double burden)
-- Finding: Moderate correlation - 6 of 10 most vulnerable states have below-average quality
-- Why this matters: Suggests struggling populations may face both economic hardship AND poor healthcare
-- Key insight: Pattern exists but isn't universal - some vulnerable states have good hospitals
WITH state_vulnerability AS (
    SELECT 
        state,
        SUM(e_totpop) AS total_population,
        ROUND(
            CAST(SUM(e_totpop * rpl_themes) AS NUMERIC) / 
            SUM(e_totpop), 
        2) AS avg_vulnerability
    FROM community_vulnerability
    GROUP BY state
),

state_quality AS (
    SELECT 
        state,
        ROUND(AVG(overall_rating), 2) AS avg_quality_rating
    FROM hospital_quality
    GROUP BY state
)

SELECT 
    v.state,
    v.total_population,
    v.avg_vulnerability,
    q.avg_quality_rating,
    CASE 
        WHEN v.avg_vulnerability >= 0.75 THEN 'High vulnerability'
        WHEN v.avg_vulnerability >= 0.50 THEN 'Above avg vulnerability'
        WHEN v.avg_vulnerability >= 0.25 THEN 'Below avg vulnerability'
        ELSE 'Low vulnerability'
    END AS vulnerability_category,
    CASE
        WHEN q.avg_quality_rating >= 4.5 THEN 'Excellent'
        WHEN q.avg_quality_rating >= 4 THEN 'Above average'
        WHEN q.avg_quality_rating >= 3 THEN 'Average'
        WHEN q.avg_quality_rating >= 2 THEN 'Below average'
        ELSE 'Poor'
    END AS quality_category
FROM state_vulnerability v
INNER JOIN state_quality q ON v.state = q.state
ORDER BY v.avg_vulnerability DESC;


-- Query 10: Cost vs Quality Correlation Analysis - PRIMARY FINDING (All Conditions)
-- Purpose: Test if higher healthcare spending produces better quality outcomes ("you get what you pay for")
-- Finding: NO CORRELATION - R² = 0.001 (essentially zero)
-- Why this matters: This is the project's most important finding - expensive states don't get better care
-- Examples: DC ($31,173, quality 2.29) and Alaska ($24,894, quality 2.88) vs cheap states with similar quality
-- Key insight: Healthcare markets are failing - prices vary dramatically but quality doesn't improve with spending
-- Implication: Cost variation is driven by market factors, not quality differences
WITH state_costs AS (
    SELECT 
        "Rndrng_Prvdr_State_Abrvtn" AS state,
        ROUND(
            CAST(SUM("Tot_Dschrgs" * "Avg_Tot_Pymt_Amt") AS NUMERIC) / 
            SUM("Tot_Dschrgs"), 
        2) AS avg_payment,
        SUM("Tot_Dschrgs") AS total_patients,
        COUNT("Rndrng_Prvdr_CCN") AS num_hospitals
    FROM hospital_costs
    GROUP BY state
),

state_quality AS (
    SELECT 
        state,
        ROUND(AVG(overall_rating), 2) AS avg_quality_rating
    FROM hospital_quality
    GROUP BY state
)

SELECT 
    c.state,
    c.avg_payment,
    q.avg_quality_rating,
    CASE
        WHEN q.avg_quality_rating >= 4.5 THEN 'Excellent'
        WHEN q.avg_quality_rating >= 4 THEN 'Above average'
        WHEN q.avg_quality_rating >= 3 THEN 'Average'
        WHEN q.avg_quality_rating >= 2 THEN 'Below average'
        ELSE 'Poor'
    END AS quality_category
FROM state_costs c
INNER JOIN state_quality q ON c.state = q.state
ORDER BY c.avg_payment DESC;


-- Query 11: Patient Volume vs Cost Efficiency Analysis (All Conditions)
-- Purpose: Test if high patient volume per hospital reduces costs through economies of scale
-- Finding: Weak correlation - volume varies from 644 to 4,479 patients per hospital but doesn't predict costs
-- Why this matters: If volume created efficiency, high-volume states should have lower costs - but they don't
-- Example: Louisiana (802 patients/hospital, $13,825) vs Alaska (1,173 patients/hospital, $24,894)
-- Key insight: Economies of scale are not the primary cost driver - other factors dominate
WITH state_metrics AS (
    SELECT 
        "Rndrng_Prvdr_State_Abrvtn" AS state,
        SUM("Tot_Dschrgs") AS total_patients,
        COUNT(DISTINCT "Rndrng_Prvdr_CCN") AS num_hospitals,
        ROUND(
            CAST(SUM("Tot_Dschrgs" * "Avg_Tot_Pymt_Amt") AS NUMERIC) / 
            SUM("Tot_Dschrgs"), 
        2) AS avg_payment
    FROM hospital_costs
    GROUP BY state
)

SELECT 
    state,
    total_patients,
    num_hospitals,
    avg_payment,
    ROUND(total_patients * 1.0 / num_hospitals, 0) AS patients_per_hospital
FROM state_metrics
ORDER BY patients_per_hospital DESC;
