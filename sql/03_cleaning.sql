DROP TABLE IF EXISTS spaceship_titanic;


CREATE TABLE spaceship_titanic AS
SELECT
    passengerid,
    NULLIF(TRIM(homeplanet),'')::TEXT AS homeplanet,

    CASE
      WHEN LOWER(TRIM(cryosleep)) IN ('true','t','1') THEN TRUE
      WHEN TRIM(cryosleep) = '' OR cryosleep IS NULL THEN NULL
      ELSE FALSE
    END AS cryosleep,

    cabin,
    split_part(cabin, '/', 1) AS deck,
    NULLIF(split_part(cabin, '/', 2),'')::INT AS cabin_num,
    split_part(cabin, '/', 3) AS side,

    destination,
    NULLIF(age,'')::NUMERIC AS age,

    CASE
        WHEN LOWER(TRIM(vip)) IN ('true', 't', '1') THEN TRUE
        WHEN TRIM(vip) = '' OR vip IS NULL THEN NULL
        ELSE FALSE
    END AS vip,

    NULLIF(roomservice,'')::NUMERIC AS roomservice,
    NULLIF(foodcourt,'')::NUMERIC AS foodcourt,
    NULLIF(shoppingmall,'')::NUMERIC AS shoppingmall,
    NULLIF(spa,'')::NUMERIC AS spa,
    NULLIF(vrdeck,'')::NUMERIC AS vrdeck,

    name,

    CASE
        WHEN LOWER(TRIM(transported)) IN ('true', 't', '1') THEN TRUE
        WHEN TRIM(transported) = '' OR transported IS NULL THEN NULL
        ELSE FALSE
    END AS transported,


    -- Calculate total spend inline
    COALESCE(NULLIF(roomservice,'')::NUMERIC, 0) +
    COALESCE(NULLIF(foodcourt,'')::NUMERIC, 0) +
    COALESCE(NULLIF(shoppingmall,'')::NUMERIC, 0) +
    COALESCE(NULLIF(spa,'')::NUMERIC, 0) +
    COALESCE(NULLIF(vrdeck,'')::NUMERIC, 0) AS total_spend

FROM spaceship_titanic_raw;

-- Create indexes for faster queries
CREATE INDEX idx_transported ON spaceship_titanic(transported);
CREATE INDEX idx_homeplanet ON spaceship_titanic(homeplanet);
CREATE INDEX idx_deck ON spaceship_titanic(deck);


