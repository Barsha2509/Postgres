--Querying the whole dataset
SELECT * FROM listings;

--Selecting distinct room type 
SELECT DISTINCT(room_type) FROM listings
GROUP BY room_type;

--Querying those listings which have word wonderful in their overview
SELECT neighborhood_overview FROM listings
WHERE neighborhood_overview LIKE '%wonderful%' ;

--Querying those listings which have words wonderful or safe in their overview
UPDATE listings
SET  neighborhood_search=to_tsvector(neighborhood_overview );

CREATE INDEX idx_gin_neighborhood_search ON listings USING GIN(neighborhood_search);

SELECT id, name, neighborhood_overview, host_name FROM listings
WHERE neighborhood_search @@ to_tsquery ('wonderful | safe' );

--Converting price from text to double precision
SELECT price FROM listings;
-----Removing dollar sign in front of the price
SELECT SUBSTRING(price,2,9) FROM listings;

UPDATE listings 
SET price=SUBSTRING(price,2,9);

----Price column values have commas in between ( like 1,000) which raises following error
----ERROR:  invalid input syntax for type NUMERIC: ",000.00"
----Below query is to resolve the above mentioned error by changing the format of the price values
SELECT to_number(price, '9999.99')::NUMERIC FROM listings;

ALTER TABLE listings
ALTER COLUMN price
TYPE NUMERIC USING to_number(price, '9999.99');

--Querying average price for each room type
SELECT room_type, ROUND(AVG(price),2) AS "Average Price" FROM listings 
GROUP BY room_type;

--Querying listings with review score greater than 7
SELECT id, name, price, neighborhood_overview, host_name, review_scores_value FROM listings
WHERE review_scores_value > 7
ORDER BY review_scores_value;

--Querying total count for different number of bedrooms available in each listed home
SELECT bedrooms, COUNT(bedrooms) 
FROM listings
GROUP BY bedrooms
ORDER BY bedrooms NULLS LAST;

--Querying the listing id's with 3 consecutive nieghborhood overview with word wonderful in it
WITH CTE AS (
	SELECT l.id, name, price, host_name, neighborhood_overview, review_scores_value,review_scores_rating, reviewer_id, reviewer_name,
	LEAD(neighborhood_overview) OVER(PARTITION BY l.id) AS "good_neighborhood1",
	LAG(neighborhood_overview) OVER(PARTITION BY l.id) AS "good_neighborhood2"
	FROM listings AS l
	JOIN reviews AS r
	ON l.id=r.listing_id
	)
SELECT DISTINCT(id)
FROM CTE
WHERE neighborhood_overview LIKE '%wonderful%' AND 
good_neighborhood1 LIKE '%wonderful%' AND
good_neighborhood2 LIKE '%wonderful%'
;

--Querying all the data from the review table
SELECT * FROM reviews;

--Querying total number of reviews received by each airbnb listing
SELECT listing_id, COUNT(comments) AS "Toatl reviews"
FROM reviews
GROUP BY listing_id;

--CREATING VIEW by joining listings and review table
CREATE VIEW VIEW_l AS (
	SELECT l.id, name, price, host_name, room_type, bedrooms, review_scores_value,reviewer_id,comments
	FROM listings AS l
	INNER JOIN reviews AS r
	ON l.id=r.listing_id
)
SELECT * FROM VIEW_l;
