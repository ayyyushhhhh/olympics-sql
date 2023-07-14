CREATE TABLE IF NOT EXISTS OLYMPICS_HISTORY
(
    ID          INT,
    name        VARCHAR,
    sex         VARCHAR,
    age         VARCHAR,
    height      VARCHAR,
    weight      VARCHAR,
    team        VARCHAR,
    noc         VARCHAR,
    games       VARCHAR,
    year        INT,
    season      VARCHAR,
    city        VARCHAR,
    sport       VARCHAR,
    event       VARCHAR,
    medal       VARCHAR
);

CREATE TABLE IF NOT EXISTS OLYMPICS_HISTORY_NOC_REGIONS
(
    noc         VARCHAR,
    region      VARCHAR,
    notes       VARCHAR
);

SELECT * 
FROM OLYMPICS_HISTORY 
LIMIT 5;

SELECT * 
FROM OLYMPICS_HISTORY_NOC_REGIONS 
LIMIT 5;
