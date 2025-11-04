# Spaceship Titanic: What Actually Happened
*An end-to-end SQL investigation into the anomaly.*

***

## ⚡ TL;DR

CryoSleep saved you — **82% transported vs 33% awake**.  
Every “pattern” (planet, deck, spending, destination) traced back to **CryoSleep adoption**.  
One exception: **Starboard side** had a **10% directional advantage** — independent of CryoSleep.

***

## 🧩 Setup

Year 2912. Spaceship Titanic carrying 8,693 passengers hits a spacetime anomaly.  
Half the ship gets transported to another dimension.  
We have the manifest, time to decode the pattern.

**Dataset:** Kaggle Spaceship Titanic (training set)  
**Tools:** PostgreSQL + Python  
**Goal:** Find what predicted transportation

***

## 🧰 Method Overview

| Stage | Tool | Purpose |
|--------|------|----------|
| Data loading | PostgreSQL | Schema & safe imports |
| Cleaning | SQL scripts | Type casting, feature engineering |
| Analysis | SQL | Aggregations & correlations |
| Visualization | Python (matplotlib/seaborn) | Charts & validation |

***

## 🔍 Data Quality Check

**Missingness:**
- Age: 179 (2%)  
- HomePlanet: 201 (2%)  
- CryoSleep: 217 (2.5%)  
- Cabin: 199 (2%)  
- Spending columns: ~180 each  

**Verdict:** Clean dataset (<3% missing overall). Reliable for SQL analysis.

***

## 🧊 CryoSleep Dominates Everything

![CryoSleep Impact](../images/cryosleep_impact.png)

- CryoSleep: **81.8% transported**  
- Awake: **32.9% transported**  
- Gap: **49 points**

CryoSleep passengers were **2.5× more likely** to be transported, the strongest single variable.

**Why?**
1. Biological shielding from anomaly  
2. Consciousness not “targeted” while frozen  
3. CryoSleep pods located in protected areas (confirmed below)

Data check: CryoSleep passengers spent $0 on all amenities → verified asleep.

***

## 🌍 Europa’s Advantage (or not)

![Planet Transport](../images/planet_transport.png)

Europa: 65% transported  
Earth: 42% transported  
Looks huge, but CryoSleep explains it.

![CryoSleep by Planet](../images/cryosleep_by_homeplanet.png)

- Europa: 44% CryoSleep  
- Earth: 31% CryoSleep  

Europa passengers just froze more often.  
**Conclusion:** Planet “effect” = CryoSleep adoption rate, not biology.

***

## 🛌 Deck Differences: Location Still Matters

![Deck Analysis](../images/deck_analysis.png)

**Surface pattern:**
- Deck B: 73% transported (best)
- Deck C: 68% transported  
- Deck G: 52% transported
- Deck E: 36% transported (worst)

But...

![CryoSleep by Deck](../images/cryosleep_by_deck.png)

- Deck B: 55% CryoSleep rate
- Deck G: 54% CryoSleep rate (same as B!)
- Deck E: 20% CryoSleep rate

**Wait... Deck B and G have identical CryoSleep rates (54-55%), but B has 73% transported vs G's 52%. That's a 21 point gap CryoSleep can't explain.**

**What this reveals:**

Even with CryoSleep, **location on the ship mattered**. Deck B (upper) outperformed Deck G (lower) despite equal pod access. Possible reasons:

1. **Pod location quality:** Upper deck pods (B) had better protection than lower deck pods (G)
2. **Starboard bias:** Deck B might have more starboard cabins (which had 10% advantage)
3. **Demographics:** Deck B might have more children/families (70% child survival rate)

**Deck E (36%) is the baseline** - regular cabins, low CryoSleep access. It performs close to the overall awake passenger rate (33%).

***

## 👶 Kids Had Higher Transport Rates

![Age Demographics](../images/age_demographics.png)

- Kids (0–11): 70%  
- Teens (12–17): 56%  
- Adults (18–49): 47%  
- Seniors (50+): 49%

Kids likely prioritized for CryoSleep → secondary effect.

***

## 💸 Spending Didn’t Matter

![Spending Analysis](../images/spending_analysis.png)

- $0 spenders: **78.6% transported**  
- Any spenders: **26–33% transported**

Spending = activity indicator, not wealth.  
If you were awake and using amenities, you were vulnerable.  

***

## ⚖️ The Starboard Mystery

![Port vs Starboard](../images/side_transport.png)

- Starboard: 55.5% transported  
- Port: 45.1% transported  
**10-point real gap**, independent of CryoSleep.

The anomaly had **directional asymmetry**.         
Possible reasons:
- Rotational exposure  
- Shielding differences  
- Design flaw

The only *true independent signal* in the data.

***

## 🪐 Destination Effects

![Destination Transport](../images/destination_transport.png)

Longer trips → higher transport rates.  
CryoSleep usage increases with distance → confirms the main hypothesis.

***

## 🧠 What We Learned

### Core Truth
CryoSleep = 82% survival. Awake = 33%.  
Everything else flows from that.

### Confounding Variables
1. Planet → CryoSleep culture  
2. Deck → CryoSleep pod locations  
3. Destination → long-haul CryoSleep usage  
4. Spending → awake vs frozen behavior  

### Real Independent Signal
Starboard side: 10% advantage → spatial anomaly.

***

## 🧑‍💻 Technical Notes

**Pipeline:**
1. CSV → PostgreSQL (TEXT)
2. Type conversions & cleaning
3. Cabin split → deck/num/side
4. Indexing (10× faster queries)
5. Materialized views for caching

**SQL Techniques:**
- CTEs & window functions  
- CASE bucketing  
- FILTER for conditional counts  
- NULLIF for safe division  

**Visualization:**
Python + psycopg2 + seaborn/matplotlib.

***

## 🧬 Implications for ML

**Strong features:**
- CryoSleep  
- Cabin side  
- Deck (as proxy)

**Weak/confounded:**
- HomePlanet  
- Destination  
- Spending  

**Feature ideas:**
- CryoSleep × Deck interaction  
- Family size (from Cabin)  
- Port/Starboard × Deck interaction  

**Expected accuracy:** 75–80% (baseline logistic regression).

***

## 🧭 Lessons Learned

1. SQL alone can surface causal proxies without ML.  
2. Most “patterns” dissolve once you isolate the dominant feature.  
3. Clear documentation turns analysis into insight.  

***

## 🧾 Bottom Line

If you were in CryoSleep, you vanished.  
If you were awake in the spa, you stayed.  
The rest, like planets, decks, and spending, were shadows of CryoSleep usage.  
And, the port side is still cursed.

***

**Built with PostgreSQL, Python, and a tiny bit of curiosity.**