-- 1. Transport by planet
DROP MATERIALIZED VIEW IF EXISTS mv_transport_by_planet;
CREATE MATERIALIZED VIEW mv_transport_by_planet AS
SELECT homeplanet, COUNT(*) AS n, SUM(CASE WHEN transported THEN 1 ELSE 0 END) AS transported_count,
ROUND(100*SUM(CASE WHEN transported THEN 1 ELSE 0 END)/NULLIF(COUNT(*),0),2) AS pct_transported
FROM spaceship_titanic
GROUP BY homeplanet
ORDER BY n DESC;

-- 2. CryoSleep impact (for main chart on website)
DROP MATERIALIZED VIEW IF EXISTS mv_cryosleep_impact;
CREATE MATERIALIZED VIEW mv_cryosleep_impact AS
SELECT
  CASE WHEN cryosleep IS NULL THEN 'Unknown'
       WHEN cryosleep THEN 'CryoSleep'
       ELSE 'Awake' END AS status,
  COUNT(*) AS n,
  SUM(CASE WHEN transported THEN 1 ELSE 0 END) AS transported_count,
  ROUND(100.0 * SUM(CASE WHEN transported THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_transported
FROM spaceship_titanic
GROUP BY cryosleep;

-- 3. Deck location (spatial analysis chart)
DROP MATERIALIZED VIEW IF EXISTS mv_deck_analysis;
CREATE MATERIALIZED VIEW mv_deck_analysis AS
SELECT deck, COUNT(*) AS n,
  SUM(CASE WHEN transported THEN 1 ELSE 0 END) AS transported_count,
  ROUND(100.0 * SUM(CASE WHEN transported THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_transported
FROM spaceship_titanic
WHERE deck IS NOT NULL
GROUP BY deck
ORDER BY deck;

-- 4. Age demographics
DROP MATERIALIZED VIEW IF EXISTS mv_age_transport;
CREATE MATERIALIZED VIEW mv_age_transport AS
SELECT age_bucket, COUNT(*) AS n,
  SUM(CASE WHEN transported THEN 1 ELSE 0 END) AS transported_count,
  ROUND(100.0 * SUM(CASE WHEN transported THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_transported
FROM (
  SELECT CASE WHEN age IS NULL THEN 'unknown'
              WHEN age < 12 THEN '0-11'
              WHEN age < 18 THEN '12-17'
              WHEN age < 30 THEN '18-29'
              WHEN age < 50 THEN '30-49'
              ELSE '50+' END AS age_bucket,
         transported
  FROM spaceship_titanic
) s
GROUP BY age_bucket;