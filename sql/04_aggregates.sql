-- High-value queries

-- Overall counts and missingness
SELECT
    COUNT(*) AS total_rows,
    COUNT(transported) FILTER (WHERE transported IS TRUE) AS transported_true,
    COUNT(transported) FILTER (WHERE transported IS FALSE) AS transported_false,
    COUNT(*) - COUNT(age) AS missing_age,
    COUNT(*) - COUNT(homeplanet) AS missing_homeplanet,
    COUNT(*) - COUNT(cryosleep) AS missing_cryosleep,
    COUNT(*) - COUNT(cabin) AS missing_cabin,
    COUNT(*) - COUNT(destination) AS missing_destination,
    COUNT(*) - COUNT(vip) AS missing_vip,
    COUNT(*) - COUNT(roomservice) AS missing_roomservice,
    COUNT(*) - COUNT(spa) AS missing_spa
FROM spaceship_titanic;

-- transported % by homeplanet
SELECT
    homeplanet,
    COUNT(*) AS n,
    SUM(CASE WHEN transported THEN 1 ELSE 0 END) AS transported_count,
    ROUND(100.0 * SUM(CASE WHEN transported THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2) AS pct_transported
FROM spaceship_titanic
GROUP BY homeplanet
ORDER BY COUNT(*) DESC;


-- spending distribution summary
SELECT
    COUNT(*) AS n,
    ROUND(AVG(total_spend), 2) AS avg_spend,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_spend)::NUMERIC, 2) AS median_spend,
    ROUND(MAX(total_spend),2) AS max_spend
FROM spaceship_titanic;

-- top 20 spenders
SELECT passengerid, name, total_spend
FROM spaceship_titanic
ORDER BY total_spend DESC
LIMIT 20;

-- age bucket vs transportation
SELECT age_bucket, COUNT(*) AS n,
    SUM(CASE WHEN transported THEN 1 ELSE 0 END) AS transported_count,
    ROUND(100*SUM(CASE WHEN transported THEN 1 ELSE 0 END)/NULLIF(COUNT(*),0),2) AS pct_transported
FROM (
    SELECT
        CASE
            WHEN age IS NULL THEN 'unknown'
            WHEN age < 12 THEN '0-11'
            WHEN age < 18 THEN '12-17'
            WHEN age < 30 THEN '18-29'
            WHEN age < 50 THEN '30-49'
            ELSE '50+'
        END AS age_bucket,
        transported
        FROM spaceship_titanic
) s
GROUP BY age_bucket
ORDER BY
    CASE age_bucket
        WHEN '0-11' THEN 1
        WHEN '12-17' THEN 2
        WHEN '18-29' THEN 3
        WHEN '30-49' THEN 4
        WHEN '50+' THEN 5
        WHEN 'unknown' THEN 6
    END;

-- cryosleep impact on transportation
SELECT
    CASE
        WHEN cryosleep IS NULL THEN 'unknown'
        WHEN cryosleep THEN 'Cryosleep'
        ELSE 'AWAKE'
    END AS status,
    COUNT(*) AS n,
    SUM(CASE WHEN transported THEN 1 ELSE 0 END) AS transported_count,
    ROUND(100*SUM(CASE WHEN transported THEN 1 ELSE 0 END)/NULLIF(COUNT(*),0),2) AS pct_transported,
    ROUND(AVG(total_spend),2) AS avg_spend
FROM spaceship_titanic
GROUP BY cryosleep
ORDER BY cryosleep NULLS LAST;

-- deck location analysis
SELECT deck, COUNT(*) AS n,
SUM(CASE WHEN transported THEN 1 ELSE 0 END) AS transported_count,
ROUND(100*SUM(CASE WHEN transported THEN 1 ELSE 0 END)/COUNT(*), 2) AS pct_transported,
ROUND(AVG(total_spend),2) AS avg_spend FROM spaceship_titanic
WHERE deck IS NOT NULL
GROUP BY deck
ORDER BY deck;

-- VIP status vs outcomes
SELECT
    CASE
        WHEN vip IS NULL THEN 'Unknown'
        WHEN vip THEN 'VIP'
        ELSE 'Standard'
    END AS vip_status,
    COUNT(*) AS n,
    SUM(CASE WHEN transported THEN 1 ELSE 0 END) AS transported_count,
    ROUND(100*SUM(CASE WHEN transported THEN 1 ELSE 0 END)/COUNT(*), 2) AS pct_transported,
    ROUND(AVG(total_spend),2) AS avg_spend
FROM spaceship_titanic
GROUP BY vip
ORDER BY vip NULLS LAST;

-- Correlations
-- Cryosleep adoption by homeplanet
SELECT
    homeplanet, COUNT(*) AS total,
    SUM(CASE WHEN cryosleep THEN 1 ELSE 0 END) AS cryosleep_count,
    ROUND(100.0*SUM(CASE WHEN cryosleep THEN 1 ELSE 0 END)/COUNT(*), 1) AS cryosleep_rate
FROM spaceship_titanic
WHERE homeplanet IS NOT NULL AND cryosleep IS NOT NULL
GROUP BY homeplanet
ORDER BY cryosleep_rate DESC;

-- Cryosleep distribution by Deck
SELECT
    deck, COUNT(*) AS total,
    SUM(CASE WHEN cryosleep THEN 1 ELSE 0 END) AS cryosleep_count,
    ROUND(100.0*SUM(CASE WHEN cryosleep THEN 1 ELSE 0 END)/COUNT(*), 1) AS cryosleep_rate
FROM spaceship_titanic
WHERE deck IS NOT NULL AND cryosleep IS NOT NULL
GROUP BY deck
ORDER BY deck;

-- Cabin side (port vs starboard) effect
SELECT
    side, COUNT(*) AS n,
    SUM(CASE WHEN transported THEN 1 ELSE 0 END) AS transported_count,
    ROUND(100.0*SUM(CASE WHEN transported THEN 1 ELSE 0 END)/COUNT(*), 1) AS pct_transported
FROM spaceship_titanic
WHERE side IS NOT NULL
GROUP BY side
ORDER BY side;

-- Destination analysis
SELECT
    destination, COUNT(*) AS n,
    SUM(CASE WHEN transported THEN 1 ELSE 0 END) AS transported_count,
    ROUND(100.0*SUM(CASE WHEN transported THEN 1 ELSE 0 END)/COUNT(*), 1) AS pct_transported
FROM spaceship_titanic
WHERE destination IS NOT NULL
GROUP BY destination
ORDER BY pct_transported DESC;