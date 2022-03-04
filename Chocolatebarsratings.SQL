----Querying the whole dataset
SELECT * FROM cocoa_flavors
LIMIT 5;

----Querying the distinct values, null values and empty values for all the categorical values
SELECT DISTINCT "Company" FROM cocoa_flavors
ORDER BY "Company" NULLS FIRST;

SELECT "Company" FROM cocoa_flavors
WHERE  "Company" =' ';---looking for empty strings

SELECT DISTINCT("geo-region of origin") FROM cocoa_flavors
ORDER BY "geo-region of origin" NULLS FIRST;

SELECT "geo-region of origin" FROM cocoa_flavors
WHERE  "geo-region of origin" =' ';

SELECT DISTINCT("Company Location") FROM cocoa_flavors
ORDER BY "Company Location" NULLS FIRST;

SELECT "Company Location" FROM cocoa_flavors
WHERE  "Company Location" =' ';

SELECT DISTINCT("Bean Type") FROM cocoa_flavors
ORDER BY "Bean Type" NULLS FIRST;

SELECT * FROM cocoa_flavors
WHERE "Bean Type" IS NULL OR "Bean Type"=' ';

SELECT DISTINCT("Broad Bean Origin") FROM cocoa_flavors
ORDER BY "Broad Bean Origin" NULLS FIRST;

SELECT "Broad Bean Origin" FROM cocoa_flavors
WHERE  "Broad Bean Origin" =' ';


SELECT * FROM cocoa_flavors
WHERE "Rating" IS NOT NULL;

SELECT * FROM cocoa_flavors
WHERE "REF" IS NOT NULL;

SELECT * FROM cocoa_flavors
WHERE "Review Date" IS NOT NULL;

----Querying the total number of companies in each country
SELECT "Company Location", COUNT(*) AS "Number of companies" FROM cocoa_flavors
GROUP BY "Company Location"
ORDER BY "Number of companies" DESC NULLS FIRST;

----Querying the average rating of each company throughout the years 
SELECT "Company", "Review Date", AVG("Rating") AS "Average Rating" FROM cocoa_flavors
GROUP BY "Company","Review Date"
ORDER BY "Company" DESC NULLS FIRST;

----Querying companies and geo region of origin for chocolates with avg high ratings(>3.5)
WITH CTE_avg_ratings AS(
	SELECT "Company", "geo-region of origin", AVG("Rating") AS "Average Rating" 
	FROM cocoa_flavors
	GROUP BY "Company","geo-region of origin"
	)
SELECT "Company", "geo-region of origin", "Average Rating"
FROM CTE_avg_ratings 
WHERE "Average Rating" > 3.5

----Querying Cocoa Percent and Rating to see the relationship between the two variables
SELECT "Cocoa Percent","Rating" 
FROM cocoa_flavors
ORDER BY "Cocoa Percent"; 



