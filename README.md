# 🚀 Spaceship Titanic SQL Analysis

![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-blue)
![Python](https://img.shields.io/badge/Language-Python%203.11-yellow)
![Data%20Viz](https://img.shields.io/badge/Visualization-Matplotlib%20%7C%20Seaborn-green)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

**End-to-end SQL analytics pipeline — from raw CSV → PostgreSQL → Python (insights).**

---

## 💡 What This Is

Analyzed 8,693 passengers from the Kaggle *Spaceship Titanic* dataset to figure out who got transported and why.  
SQL handled the processing, Python powered the charts — and some wild patterns showed up.

**Bottom line:** Being in CryoSleep saved you. Being awake got you transported. Simple as that.

---

## 📊 The Numbers

- **CryoSleep passengers:** 82% transported  
- **Awake passengers:** 33% transported  
- **Starboard side:** 10% higher survival than Port  
- **Deck B:** 73% transported (CryoSleep pod location)  
- **Deck E:** 36% transported (regular cabins)

**Key insight:** Every pattern (planet, deck, destination) boils down to one thing — CryoSleep adoption.

---

## 🧰 Tech Stack

- **PostgreSQL 14** → data storage & querying  
- **Python 3.11** → analysis & visualization  
- **pandas** → wrangling  
- **matplotlib + seaborn** → charts  
- **psycopg2** → PostgreSQL ↔ Python bridge  
- **Duration:** ~3 days (SQL + analysis + docs)

---

## 📁 Project Structure
    spaceship-titanic-sql/
    ├── data/
    │   └── spaceship_titanic.csv
    ├── sql/
    │   ├── 01_create_schema.sql
    │   ├── 02_load_csv.sql
    │   ├── 03_cleaning.sql
    │   ├── 04_aggregates.sql
    │   └── 05_materialized_views.sql
    ├── images/
    ├── docs/
    │   └── case_study.md
    ├── visualizations.py
    └── README.md


---

## How It Works

### 1. Load Raw Data
    psql -U postgres -d spaceship_titanic -f sql/01_create_schema.sql
    psql -U postgres -d spaceship_titanic -f sql/02_load_csv.sql
Creates table, loads 8,693 rows as TEXT (safe import).

### 2. Clean & Transform
    psql -U postgres -d spaceship_titanic -f sql/03_cleaning.sql
- Converts types (TEXT → BOOLEAN, NUMERIC)
- Splits cabin into deck/num/side
- Creates total_spend column
- Adds indexes for speed

### 3. Analyze
    psql -U postgres -d spaceship_titanic -f sql/04_aggregates.sql
Runs 13 queries: demographics, spending, correlations.

### 4. Optimize
    psql -U postgres -d spaceship_titanic -f sql/05_materialized_views.sql
Pre-computes common queries for 10x speedup.

### 5. Visualize
    python visualizations.py
Connects to PostgreSQL, pulls data, generates 9 charts.

---

## Key Findings

### CryoSleep = Survival
**82% transported (CryoSleep) vs 33% (Awake)**

Being frozen in suspended animation saved you. End of story.

### Planet "Effect" is Fake
- Europa: 65% transported (but 44% CryoSleep rate)
- Earth: 42% transported (but only 31% CryoSleep rate)

Europa passengers weren't biologically different - they just used CryoSleep more (wealthier/longer trips).

### Deck "Effect" is Fake Too
- Deck B: 73% transported (because 55% CryoSleep rate - pod facility)
- Deck E: 36% transported (only 20% CryoSleep rate - regular cabins)

Upper decks weren't "safer" - they housed the CryoSleep pods.

### Starboard Side Had Real Advantage
- Starboard: 55% transported
- Port: 45% transported

This 10% gap is REAL and independent of CryoSleep. The anomaly had directional properties.

### Money Didn't Matter
- No spending: 79% transported (CryoSleep = can't spend)
- Any spending: 26-33% transported (awake = vulnerable)

Rich or poor, if you were awake using amenities, you had ~30% survival. Wealth was irrelevant.

---

## SQL Techniques Used

- Type casting with `NULLIF` for safe conversions
- `CASE` statements for bucketing
- Window functions and CTEs
- `FILTER` clause for conditional counts
- B-tree indexing (10x query speedup)
- Materialized views for dashboard performance
- String splitting for cabin feature extraction

---

## Data Source

**Kaggle Spaceship Titanic Competition**  
Using the **training dataset** (renamed to `spaceship_titanic.csv`)  
8,693 passengers | 13 features | Binary target (transported)

---

## Installation
# Clone repo
    git clone https://github.com/anudeepreddy332/spaceship-titanic-sql.git
    cd spaceship-titanic-sql

# Install Python dependencies
    pip install -r requirements.txt

# Create PostgreSQL DB
    createdb spaceship_titanic

# Run the pipeline (steps 1–5 above)
## 📦 Requirements.txt
    psycopg2-binary==2.9.9
    pandas==2.1.3
    matplotlib==3.8.2
    seaborn==0.13.0

## 🔮 What’s Next
    Phase 2: Machine Learning
        •	Feature engineering (family groups, interaction terms)
        •	Models: Logistic Regression, Random Forest, XGBoost
        •	Cross-validation + feature importance analysis

## 📸 Charts
    All in images/:
    
    Primary Analysis:
        1.	CryoSleep impact
        2.	Planet transport rates
        3.	Deck analysis
        4.	Age demographics
        5.	Spending patterns

    Correlation Analysis:
        6. CryoSleep by planet
        7. CryoSleep by deck
        8. Port vs Starboard
        9. Destination analysis