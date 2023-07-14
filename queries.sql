-- How many olympics games have been held? 

SELECT COUNT(DISTINCT games)
FROM OLYMPICS_HISTORY ;

-- List down all Olympics games held so far with year, season and city. 

SELECT year,season,city
FROM OLYMPICS_HISTORY ;


-- Mention the total no of nations who participated in each olympics game
WITH all_countries AS
        (SELECT games, nr.region
        FROM olympics_history oh
        JOIN olympics_history_noc_regions nr ON nr.noc = oh.noc
        GROUP BY games, nr.region)
    SELECT games, COUNT(1) AS total_countries
    FROM all_countries
    GROUP BY games
    ORDER BY games;
	
-- Which year saw the highest and lowest no of countries participating in olympics?

WITH all_countries AS
              (SELECT games, nr.region
              FROM olympics_history oh
              JOIN olympics_history_noc_regions nr ON nr.noc=oh.noc
              GROUP BY games, nr.region),
          tot_countries AS
              (SELECT games, COUNT(1) AS total_countries
              FROM all_countries
              GROUP BY games)
      SELECT DISTINCT 
      concat(FIRST_VALUE(games) OVER(ORDER BY total_countries)
      , ' - '
      , FIRST_VALUE(total_countries) OVER(ORDER BY total_countries)) AS Lowest_Countries,
      concat(FIRST_VALUE(games) OVER(ORDER BY total_countries DESC)
      , ' - '
      , FIRST_VALUE(total_countries) OVER(ORDER BY total_countries DESC)) AS Highest_Countries
      FROM tot_countries
      ORDER BY 1;

-- Which nation has participated in all of the olympic games?
 WITH tot_games AS
              (SELECT COUNT(DISTINCT games) AS total_games
              FROM olympics_history),
          countries AS
              (SELECT games, nr.region AS country
              FROM olympics_history oh
              JOIN olympics_history_noc_regions nr ON nr.noc=oh.noc
              GROUP BY games, nr.region),
          countries_participated AS
              (SELECT country, COUNT(1) AS total_participated_games
              FROM countries
              GROUP BY country)
      SELECT cp.*
      FROM countries_participated cp
      JOIN tot_games tg ON tg.total_games = cp.total_participated_games
      ORDER BY 1;

-- Identify the sport which was played in all summer olympics.

WITH t1 AS
          	(SELECT COUNT(DISTINCT games) AS total_games
          	FROM olympics_history WHERE season = 'Summer'),
          t2 AS
          	(SELECT DISTINCT games, sport
          	FROM olympics_history WHERE season = 'Summer'),
          t3 AS
          	(SELECT sport, COUNT(1) AS no_of_games
          	FROM t2
          	GROUP BY sport)
      SELECT *
      FROM t3
      JOIN t1 ON t1.total_games = t3.no_of_games;
	  
	  
-- Which Sports were just played only once in the olympics.

WITH t1 AS
          	(SELECT DISTINCT games, sport
          	FROM olympics_history),
          t2 AS
          	(SELECT sport, COUNT(1) AS no_of_games
          	FROM t1
          	GROUP BY sport)
      SELECT t2.*, t1.games
      FROM t2
      JOIN t1 ON t1.sport = t2.sport
      WHERE t2.no_of_games = 1
      ORDER BY t1.sport;


-- Fetch the total no of sports played in each olympic games.
WITH t1 AS
      	(SELECT DISTINCT games, sport
      	FROM olympics_history),
        t2 AS
      	(SELECT games, COUNT(1) AS no_of_sports
      	FROM t1
      	GROUP BY games)
      SELECT * FROM t2
      ORDER BY no_of_sports DESC;
	  
--Fetch oldest athletes to win a gold medal
WITH temp AS
            (SELECT name,sex,CAST(CASE WHEN age = 'NA' THEN '0' ELSE age END AS int) AS age
              ,team,games,city,sport, event, medal
            FROM olympics_history),
        ranking AS
            (SELECT *, RANK() OVER(ORDER BY age DESC) AS rnk
            FROM TEMP
            WHERE medal='Gold')
    SELECT *
    FROM ranking
    WHERE rnk = 1;
	
-- Find the Ratio of male and female athletes participated in all olympic games.
WITH t1 AS
        	(SELECT sex, COUNT(1) AS cnt
        	FROM olympics_history
        	GROUP BY sex),
        t2 AS
        	(SELECT *, ROW_NUMBER() OVER(ORDER BY cnt) AS rn
        	 FROM t1),
        min_cnt AS
        	(SELECT cnt FROM t2	WHERE rn = 1),
        max_cnt AS
        	(SELECT cnt FROM t2	WHERE rn = 2)
    SELECT concat('1 : ', round(max_cnt.cnt::decimal/min_cnt.cnt, 2)) AS ratio
    FROM min_cnt, max_cnt;
	
-- Fetch the top 5 athletes who have won the most gold medals.
WITH t1 AS
            (SELECT name, team, COUNT(1) AS total_gold_medals
            FROM olympics_history
            WHERE medal = 'Gold'
            GROUP BY name, team
            ORDER BY total_gold_medals DESC),
        t2 AS
            (SELECT *, DENSE_RANK() OVER (ORDER BY total_gold_medals DESC) AS rnk
            FROM t1)
    SELECT name, team, total_gold_medals
    FROM t2
    WHERE rnk <= 5;

-- Fetch the top 5 athletes who have won the most medals (gold/silver/bronze). 
WITH t1 AS
            (SELECT name, team, COUNT(1) AS total_medals
            FROM olympics_history
            WHERE medal IN ('Gold', 'Silver', 'Bronze')
            GROUP BY name, team
            ORDER BY total_medals DESC),
        t2 AS
            (SELECT *, DENSE_RANK() OVER (ORDER BY total_medals DESC) AS rnk
            FROM t1)
    SELECT name, team, total_medals
    FROM t2
    WHERE rnk <= 5;
	
-- Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
WITH t1 AS
            (SELECT nr.region, COUNT(1) AS total_medals
            FROM olympics_history oh
            JOIN olympics_history_noc_regions nr ON nr.noc = oh.noc
            WHERE medal <> 'NA'
            GROUP BY nr.region
            ORDER BY total_medals DESC),
        t2 AS
            (SELECT *, DENSE_RANK() OVER(ORDER BY total_medals DESC) AS rnk
            FROM t1)
    SELECT *
    FROM t2
    WHERE rnk <= 5;






