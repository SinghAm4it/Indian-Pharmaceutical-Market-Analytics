# Indian Pharmaceutical Market Analytics

## 📌 Project Overview
This project presents a **comprehensive analytical study of the Indian pharmaceutical market**, focusing on **product pricing, formulation strategy, therapeutic segmentation, manufacturer behavior, and market structure**.

The project is fully implemented using **Python, SQL, and Tableau dashboards**, with structured storytelling and business interpretation.

---

## 🎯 Business Objectives
The analysis answers key industry-driven questions:

- How does **pricing vary across dosage forms**?
- Which **therapeutic classes dominate** the Indian market?
- Are **combination drugs priced at a premium**?
- Is there **price inconsistency** for identical drug formulations?
- Which **active ingredients and manufacturers control market share**?
- How diversified are manufacturers across **therapies and dosage forms**?
- Are brands pricing significantly **above market benchmarks**?
- What signals indicate **pricing volatility and fragmentation**?

---

## 🧠 Key Business Questions Answered

### Pricing & Market Structure
- Dosage-form price landscape (tablets vs injectables vs syrups)
- Therapeutic class pricing and volatility
- Brand-level and internal price inconsistencies
- Market-wide price gaps for identical formulations

### Product & Portfolio Analytics
- Market share by active ingredient
- Single vs combination drug strategy
- Manufacturer portfolio mix by therapy
- Dosage-form diversification analysis

### Competitive Intelligence
- Top manufacturers by therapeutic class
- Top manufacturers by dosage form
- Manufacturer core competency identification
- Premium brand pricing detection

---

## 🗂️ Dataset Description
**Source:** Indian pharmaceutical product listings  
**Granularity:** Product-level  

### Key Fields
- `brand_name`
- `manufacturer`
- `price_inr`
- `dosage_form`
- `packaging_raw`
- `primary_ingredient`
- `primary_strength`
- `secondary_ingredient`
- `therapeutic_class`
- `num_active_ingredients`
- `combination_drug`
- `is_discontinued`

---

## 🛠️ Tech Stack
| Layer | Tools |
|------|------|
| Data Cleaning | Python (Pandas, NumPy) |
| EDA | Python |
| Advanced Analytics | SQL (CTEs, Window Functions) |
| Modeling | Clustering, Discontinuation Risk |
| Visualization | BI Dashboard (Power BI / Tableau style) |
| Documentation | Markdown |

---

## 📊 SQL Analytics Coverage
The SQL layer includes **15+ advanced analytical queries**, covering:

- Dosage-form price benchmarking
- Therapeutic market size & pricing
- Price inconsistency detection
- Market share computation
- Brand premium analysis
- Portfolio mix analytics
- Volatility ranking
- Manufacturer dominance analysis

Techniques used:
- `CTE`s  
- `WINDOW FUNCTIONS`  
- `RANK()` / `DENSE_RANK()`  
- Market normalization logic  
- Percentage share calculations  

---

## 📈 Dashboards & Storytelling (Completed)
The project includes an **interactive dashboard and analytical story**, covering:

- Market overview & pricing heatmaps
- Therapy-wise and dosage-wise trends
- Manufacturer comparison views
- Price gap and premium detection visuals
- Strategic insights & recommendations
.

---

## 🧪 Advanced Analytics Modules
- **Product Clustering:** Identify similar drugs based on pricing, formulation, and therapy
- **Discontinuation Risk Analysis:** Predict product discontinuation patterns
- **Data Quality Audits:** Detect inconsistencies and standardization gaps

---

## 📁 Project Structure
```text
├── data/
│   ├── indian_pharmaceutical_products.csv
│   ├── indian_pharmaceutical_products_cleaned.csv
│   └── indian_pharmaceutical_products_segmented.csv
│
├── notebooks/
│   ├── DataCleaning_Pharmaceutical.ipynb
│   ├── EDA_Pharmaceutical.ipynb
│   ├── Clustering.ipynb
│   └── Discontinuation Risk Analysis.ipynb
│
├── sql/
│   └── pharma_market_analysis.sql
│
├── dashboards/
│   └── pharma_market_dashboard.pbix
│
└── README.md
