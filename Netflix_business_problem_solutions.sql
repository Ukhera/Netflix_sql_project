--- Netflix project
drop table if exists netflix;
create table netflix
(show_id varchar(5),
type varchar(10),
title varchar(110),
director varchar(210),
casts varchar(1000),
country varchar(150),
date_added varchar(50),
release_year int,
rating varchar(10),
duration varchar(50),
listed_in varchar(100),
description varchar(250)
);
select * from netflix;
select count(*) from netflix;
select distinct type from netflix;
select distinct type from netflix;

--Business problems

--1. Count the number of movies vs. tv shows

select 
type,
count(*) as total_content
from netflix
group by type;

--2. Find the most common rating for movies and Tv shows

select rating from netflix;
select distinct rating from netflix;

select
type,
rating
from

(select 
type, rating,  count(*),  rank() over(partition by type order by count(*) desc) as ranking
from netflix group by 1,2)
as t1 where ranking = 1;

--List all the movies released in a specific  year (e.g. 2020)

select * from netflix
where
type = 'Movie'
and 
release_year = 2020;

--Find the top 5 countries with the most content on netflix

select trim(unnest(string_to_array(country, ','))) as new_country, count(show_id) as total_content from netflix
group by 1 order by total_content DESC  limit 5;


--iDENTIFY THE LONGEST MOVIE

SELECT 
title,
cast(replace(duration, 'min','') as integer)  as duration_minutes
from netflix
where type  = 'Movie'
and  duration is not null
order by duration_minutes desc limit 1;

--Find the content added in the last 5 years

SELECT * 
FROM (
  SELECT *,
    CASE 
      WHEN date_added ~ '^\d{1}-[A-Za-z]{3}-\d{2}$' THEN  -- e.g., 1-Sep-21
        '0' || date_added
      WHEN date_added ~ '^[A-Za-z]{3}-\d{2}$' THEN        -- e.g., Aug-21
        '01-' || date_added
      WHEN date_added ~ '^\d{2}-[A-Za-z]{3}-\d{2}$' THEN  -- e.g., 25-Sep-21
        date_added
      ELSE NULL                                           -- invalid
    END AS padded_date
  FROM netflix
) AS sub
WHERE 
  padded_date IS NOT NULL
  AND TO_DATE(padded_date, 'DD-Mon-YY') >= current_date - INTERVAL '5 years';

  --Find all the movies/shows by director ' Rajiv Chilaka'

  select * from netflix
  where director ilike '%Rajiv Chilaka%'

  --Find only movies by director 'Rajiv Chilaka'

  select * from netflix where type = 'Movie' and director ilike '%Rajiv Chilaka';

 9.  --List all the TV shows more than 5 seasons

  select *
  from netflix
  where type = 'TV Show'
  and
  split_part (duration, ' ', 1)::numeric > 5
  

10. ---Count the number of content items in each genre

select 
trim(unnest(string_to_array(listed_in, ','))) as Genre,
count(show_id) as total_content
from netflix
Group by 1;

11.--Find each year and the average numbers of content release in India on netflix. 
--Return top 5 year with highest average content release

select * from netflix;
SELECT 
  EXTRACT(YEAR FROM TO_DATE(release_date, 'DD-Mon-YY')) AS release_year,
  COUNT(*) AS total_content,
  ROUND(
    COUNT(*)::numeric / (
      SELECT COUNT(*) 
      FROM netflix
      WHERE country ILIKE '%India%' 
        AND (
          date_added ~ '^\d{1}-[A-Za-z]{3}-\d{2}$' OR 
          date_added ~ '^[A-Za-z]{3}-\d{2}$' OR 
          date_added ~ '^\d{2}-[A-Za-z]{3}-\d{2}$'
        )
    ) * 100, 2
  ) AS avg_content_per_year
FROM (
  SELECT 
    CASE 
      WHEN date_added ~ '^\d{1}-[A-Za-z]{3}-\d{2}$' THEN '0' || date_added
      WHEN date_added ~ '^[A-Za-z]{3}-\d{2}$' THEN '01-' || date_added
      WHEN date_added ~ '^\d{2}-[A-Za-z]{3}-\d{2}$' THEN date_added
      ELSE NULL
    END AS release_date
  FROM netflix
  WHERE country ILIKE '%India%'
) AS cleaned
WHERE release_date IS NOT NULL
GROUP BY release_year
ORDER BY total_content DESC
LIMIT 5;

--11. List all movies that are documentaries

select * from netflix
where listed_in ilike '%documentaries%'

--12 Find all the content without a director

select * from netflix
where director is null

--13 find how many movie actor 'salman khan' appeared in last 10 year

select * from netflix
where casts ILIKE '%Salman khan%'
AND
release_year > extract(year from current_date) - 10

--14 Find the top 10 actors who have appeared in the highest number of movies produced in india


select 
trim(unnest(STRING_TO_ARRAY(casts, ',')))as actors,
count(*) as total_content
from netflix
where country ilike '%india%'
group by 1
order by total_content desc
limit 10

--15 Categorize the content based on the presence of keywords "kill" and "violence" in the description field
--label content containing these keywords as 'bad'and all other content as 'good. Count how many items fall into each category'

SELECT 
  CASE
    WHEN description ~* '\mkill\M' OR description ~* '\mviolence\M' THEN 'bad_content'
    ELSE 'good_content'
  END AS category,
count(*) as total
from netflix
group by category;


