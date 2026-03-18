# Healthcare Cost Inequity Analysis

A comprehensive data analysis examining geographic variation in U.S. healthcare costs, quality outcomes, and the disconnect between spending and care quality.

[![Tableau](https://img.shields.io/badge/Tableau-E97627?style=for-the-badge&logo=Tableau&logoColor=white)](https://public.tableau.com/app/profile/sai.krishna.varshith.danda1231/viz/Healthcare_Cost_Analysis_17736853143620/Story-HealthcareCostAnalysis)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)](sql/healthcare_analysis.sql)
[![Excel](https://img.shields.io/badge/Microsoft_Excel-217346?style=for-the-badge&logo=microsoft-excel&logoColor=white)](excel/)

---

## Project Overview

This project analyzes Medicare hospital payment data, CMS quality ratings, and CDC community vulnerability metrics to investigate healthcare cost inequities across the United States. Using SQL for data analysis, Excel for summary documentation, and Tableau for interactive visualization, the project reveals significant geographic cost variation independent of quality outcomes.

**Geographic Scope:** Analysis covers all 50 U.S. states plus Washington D.C., collectively referred to as "51 states" throughout the project.

**Central Finding:** Healthcare costs for identical treatments vary by 105% across states (Alaska: $24,728 vs Vermont: $12,079), with no correlation to hospital quality ratings (R² = 0.001), indicating systemic market inefficiencies rather than justifiable differences in care complexity.

---

## Key Findings

### 1. Significant Geographic Cost Variation (105%)
Septicemia treatment costs range from $12,079 (Vermont) to $24,728 (Alaska) across U.S. states for identical medical care, representing a 105% difference that cannot be explained by patient complexity or treatment differences.

### 2. No Correlation Between Cost and Quality (R² = 0.001)
Statistical analysis across all 51 states demonstrates zero correlation between healthcare spending and hospital quality ratings. Expensive states like Alaska ($24,728, quality: 2.88) and DC ($31,173, quality: 2.29) deliver care comparable to or worse than low-cost states.

### 3. Alaska's Triple Burden
Alaska demonstrates the worst combination of factors:
- 105% higher costs than Vermont ($24,728 vs $12,079)
- 148% higher population vulnerability (0.57 vs 0.23 on CDC Social Vulnerability Index)
- Similar poor quality ratings (2.88 vs 2.85 on CMS 5-star scale)

### 4. Rural Healthcare Premiums Are Rare (8% of states)
Only 4 of 51 states charge rural areas more than urban areas (New Mexico, Colorado, Kansas, California), contradicting common assumptions about rural healthcare costs. Most states show no rural premium or charge urban areas more due to infrastructure costs.

### 5. Alaska's Rural Premium Exception
Within Alaska specifically, rural areas pay 32% more than urban areas for septicemia treatment ($31,249 vs $23,693), representing one of the highest rural premiums nationally and compounding Alaska's already elevated baseline costs.

### 6. Cost-Vulnerability Correlation is Inconsistent
While 7 of the 10 most expensive states show high vulnerability, the pattern is not universal. Mississippi ($13,173, vulnerability: 0.75) charges less than half of Alaska despite higher vulnerability, indicating cost variation is not primarily driven by population need.

### 7. Vulnerable Populations Face Quality Gaps
Six of the 10 most vulnerable states have below-average hospital quality ratings, suggesting a potential double burden where struggling communities receive both higher costs and lower quality care.

### 8. Patient Volume Doesn't Predict Efficiency
Hospital patient volume per facility varies from 644 to 4,479 across states, but shows weak correlation with costs. Low-volume states demonstrate extreme variation (Louisiana 802 patients/hospital: $13,825 vs Alaska 1,173: $24,894), indicating economies of scale are not the primary cost driver.

### 9. Alaska Ranks Poorly Among Peer States
When compared to similarly-sized states (500K-1M population), Alaska ranks 5th in quality but 2nd in cost among 7 peer states, demonstrating the worst value proposition in its population category.

---

## Technologies and Tools

**Data Analysis:**
- **PostgreSQL** - Database management and complex SQL queries (11 analytical queries)
- **DBeaver** - SQL development environment and query execution

**Data Processing:**
- **Microsoft Excel** - Summary tables, quick reference documentation, and data validation

**Visualization:**
- **Tableau Public** - Interactive dashboards, story mode presentation (9 charts, 5 dashboards)

**Version Control:**
- **Git/GitHub** - Project documentation and code repository

---

## Dataset Information

### Primary Data Sources

All datasets are publicly available from U.S. government agencies:

| Dataset | Source | Year | Records | Description |
|---------|--------|------|---------|-------------|
| **Hospital Costs** | [CMS Medicare IPPS](https://data.cms.gov/provider-summary-by-type-of-service/medicare-inpatient-hospitals/medicare-inpatient-hospitals-by-provider-and-service/data) | 2023 | 146,427 | Medicare fee-for-service inpatient payment data by hospital and diagnosis-related group (DRG) |
| **Hospital Quality** | [CMS Hospital Compare](https://data.cms.gov/provider-data/dataset/xubh-q36u) | 2025 | 2,869 | CMS 5-star quality ratings for U.S. hospitals |
| **Community Vulnerability** | [CDC Social Vulnerability Index](https://www.atsdr.cdc.gov/place-health/php/svi/svi-data-documentation-download.html) | 2022 | 3,144 | County-level socioeconomic and demographic vulnerability metrics |

**Note on Data Years:** Different years reflect agency release schedules. Healthcare cost patterns and community demographics represent stable, long-term trends validated across multiple years.

### Processed Data Files

The `/data/` folder contains CSV files generated from SQL analysis:
- `state_costs.csv` - State-level cost rankings for septicemia treatment
- `cost_quality.csv` - Cost and quality metrics across all states
- `cost_vulnerability.csv` - Cost and vulnerability correlation data
- `alaska_similar_states.csv` - Alaska comparison with peer states (500K-1M population)
- `rural_premium_states.csv` - Rural vs urban cost analysis nationally
- `volume_efficiency.csv` - Patient volume per hospital and cost efficiency metrics

**Raw Data:** Original datasets are not included due to file size (150MB+). Links provided above for data access.

---

## Interactive Visualizations

### View Live Dashboards
[**Explore Interactive Tableau Dashboards**](https://public.tableau.com/app/profile/sai.krishna.varshith.danda1231/viz/Healthcare_Cost_Analysis_17736853143620/Story-HealthcareCostAnalysis)

The Tableau workbook includes:
- **9 Individual Charts** - Maps, scatter plots, bar charts, comparison tables
- **5 Interactive Dashboards** - Comprehensive analysis with filters and drill-down
- **Story Mode Presentation** - 5-slide narrative walkthrough of findings

---

## Dashboard Previews

### Dashboard 1: National Healthcare Cost Overview
![National Overview](images/dashboard1.png)

Septicemia treatment cost variation across U.S. states, showing geographic patterns and distribution.

### Dashboard 2: Cost vs Quality Analysis
![Cost vs Quality](images/dashboard2.png)

Statistical analysis demonstrating zero correlation (R² = 0.001) between healthcare spending and hospital quality ratings.

### Dashboard 3: Alaska Deep Dive
![Alaska Analysis](images/dashboard3.png)

Comparative analysis of Alaska vs Vermont and peer states, highlighting the triple burden of high cost, high vulnerability, and poor quality.

### Dashboard 4: Rural Premium Analysis
![Rural Premium](images/dashboard4.png)

National analysis showing rural healthcare premiums are rare - only 4 of 51 states charge rural areas more than urban.

### Story Mode: Interactive Presentation
![Story Mode](images/story_slide1.png)

Five-slide interactive story walking through key findings and policy implications.

---

## Project Structure
```
Healthcare-Cost-Analysis/
├── README.md                          # Project overview and documentation
├── data/                              # Processed CSV files from SQL queries
│   ├── state_costs.csv
│   ├── cost_quality.csv
│   ├── cost_vulnerability.csv
│   ├── alaska_similar_states.csv
│   ├── rural_premium_states.csv
│   └── volume_efficiency.csv
├── sql/
│   └── healthcare_analysis.sql        # All 11 SQL queries with methodology
├── excel/
│   └── Healthcare_Summary_Tables.xlsx # Summary tables for quick reference
├── tableau/
│   └── Healthcare_Cost_Analysis.twbx  # Complete Tableau workbook
└── images/                            # Dashboard screenshots
    ├── dashboard1.png
    ├── dashboard2.png
    ├── dashboard3.png
    ├── dashboard4.png
    └── story_slide1.png
```

---

## Analysis Methodology

### SQL Analysis (11 Queries)
Comprehensive analysis using PostgreSQL with weighted averages to reflect population-level experiences:
1. Identification of most common medical condition (septicemia)
2. State-level cost rankings for controlled comparison
3. Alaska rural vs urban cost analysis
4. Alaska vs Vermont cost and vulnerability comparison
5. Alaska vs Vermont with quality metrics integration
6. Alaska peer state comparison (similar population size)
7. National rural premium analysis (all conditions)
8. Cost vs vulnerability correlation testing
9. Vulnerability vs quality correlation analysis
10. Cost vs quality correlation (primary finding: R² = 0.001)
11. Patient volume efficiency analysis

**Methodology Details:**
- Weighted averages by patient volume for cost calculations
- Population-weighted averages for vulnerability metrics
- Simple averages for quality ratings (pre-normalized by CMS)
- State-level aggregation for valid cross-dataset comparison

### Excel Documentation
Four summary tables documenting:
- State cost rankings with key statistics
- Alaska vs Vermont comprehensive metrics
- Alaska peer state comparisons
- Cost-quality correlation summary

### Tableau Visualization
Interactive dashboards with:
- Geographic cost distribution maps
- Statistical correlation scatter plots
- Comparative bar charts and tables
- Integrated filters for exploration
- Story mode for presentation narrative

---

## Key Implications

### Healthcare Market Inefficiency
The 105% cost variation for identical treatments, combined with zero correlation to quality outcomes, indicates systemic market failures rather than justified differences in care complexity or resource requirements.

### Geographic Inequity
Patients in high-cost states pay dramatically more for equivalent or inferior care, suggesting pricing is driven by market dynamics and regional factors rather than medical necessity or quality differentiation.

### Alaska's Unique Crisis
Alaska faces compounding challenges: baseline costs are already 2× the national low, rural areas pay an additional 32% premium, and the most vulnerable population (0.57 SVI) receives below-average quality care (2.88/5 stars).

### Rural Premium Misconception
The finding that only 8% of states charge rural premiums challenges common assumptions about rural healthcare costs and suggests most geographic cost variation is driven by factors other than rural vs urban location.

---

## How to Explore This Project

### Option 1: Interactive Dashboards (Recommended)
Visit the [Tableau Public dashboard](https://public.tableau.com/app/profile/sai.krishna.varshith.danda1231/viz/Healthcare_Cost_Analysis_17736853143620/Story-HealthcareCostAnalysis) to:
- Interact with visualizations
- Filter by state, condition, or metric
- Explore the 5-slide story mode presentation

### Option 2: Review SQL Analysis
Open `sql/healthcare_analysis.sql` to see:
- Complete query methodology
- Data integration approach
- Statistical calculations

### Option 3: Examine Summary Tables
Open `excel/Healthcare_Summary_Tables.xlsx` for:
- Quick reference key findings
- Organized summary tables
- Calculated metrics

### Option 4: Local Tableau Exploration
1. Download `tableau/Healthcare_Cost_Analysis.twbx`
2. Open in Tableau Desktop or Tableau Public
3. Explore dashboards with full interactivity

---

## Technical Skills Demonstrated

- **SQL:** Complex queries, CTEs, window functions, weighted aggregations, multi-table joins
- **Data Analysis:** Statistical correlation (R²), comparative analysis, data validation
- **Data Visualization:** Interactive dashboards, story mode, geographic mapping, scatter plots
- **Data Integration:** Combining datasets from multiple sources with different granularities
- **Documentation:** Professional README, code comments, methodology documentation
- **Version Control:** Git/GitHub for project management
