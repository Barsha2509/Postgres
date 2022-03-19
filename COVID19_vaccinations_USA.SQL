----Querying first 5 rows of this dataset
SELECT *
FROM "COVID19_vaccinations"
LIMIT 5;

----------Replacing null/missing values					  
----Replacing null values with 0 in all the booster doses columns
UPDATE "COVID19_vaccinations"
SET "Booster_Doses_Vax_Pct" = COALESCE("Booster_Doses_Vax_Pct",0),
	"Booster_Doses_12Plus" = COALESCE("Booster_Doses_12Plus",0),
 	"Booster_Doses_12Plus_Vax_Pct" = COALESCE("Booster_Doses_12Plus_Vax_Pct",0),
	"Booster_Doses_18Plus" = COALESCE("Booster_Doses_18Plus",0),
	"Booster_Doses_18Plus_Vax_Pct" = COALESCE("Booster_Doses_18Plus_Vax_Pct",0),
	"Booster_Doses_50Plus" = COALESCE("Booster_Doses_50Plus",0),
 	"Booster_Doses_50Plus_Vax_Pct" = COALESCE("Booster_Doses_50Plus_Vax_Pct",0),
	"Booster_Doses_65Plus" = COALESCE("Booster_Doses_65Plus",0),
	"Booster_Doses_65Plus_Vax_Pct" = COALESCE("Booster_Doses_65Plus_Vax_Pct",0);
	
----Replacing null values with 0 in all the series_complete columns
UPDATE "COVID19_vaccinations"
SET "Series_Complete_Yes" = COALESCE("Series_Complete_Yes",0),
	"Series_Complete_Pop_Pct" = COALESCE("Series_Complete_Pop_Pct",0),
 	"Series_Complete_5Plus" = COALESCE("Series_Complete_5Plus",0),
	"Series_Complete_5PlusPop_Pct" = COALESCE("Series_Complete_5PlusPop_Pct",0),
	"Series_Complete_12Plus" = COALESCE("Series_Complete_12Plus",0),
	"Series_Complete_12PlusPop_Pct" = COALESCE("Series_Complete_12PlusPop_Pct",0),
 	"Series_Complete_18Plus" = COALESCE("Series_Complete_18Plus",0),
	"Series_Complete_18PlusPop_Pct" = COALESCE("Series_Complete_18PlusPop_Pct",0),
	"Series_Complete_65Plus" = COALESCE("Series_Complete_65Plus",0),
	"Series_Complete_65PlusPop_Pct" = COALESCE("Series_Complete_65PlusPop_Pct",0);

----Other way of bulk updating columns
----Replacing null values with 0 in all the administered columns
---------Quering all columns which have word administered in their names
select COLUMN_NAME
from INFORMATION_SCHEMA.COLUMNS 
where table_name =  'COVID19_vaccinations' and COLUMN_NAME LIKE 'Administered%';							
------Execute below query
------then copy the output of this query and execute it
select concat('update ',table_name,'set ', COLUMN_NAME , '= COALESCE ','(',COLUMN_NAME,'0);')
from information_schema.columns
where table_name = 'COVID19_vaccinations' and COLUMN_NAME LIKE 'Administered%';

update COVID19_vaccinationsset Administered_Dose1_Recip= COALESCE (Administered_Dose1_Recip0);
update COVID19_vaccinationsset Administered_Dose1_Pop_Pct= COALESCE (Administered_Dose1_Pop_Pct0);
update COVID19_vaccinationsset Administered_Dose1_Recip_5Plus= COALESCE (Administered_Dose1_Recip_5Plus0);
update COVID19_vaccinationsset Administered_Dose1_Recip_5PlusPop_Pct= COALESCE (Administered_Dose1_Recip_5PlusPop_Pct0);
update COVID19_vaccinationsset Administered_Dose1_Recip_12Plus= COALESCE (Administered_Dose1_Recip_12Plus0);
update COVID19_vaccinationsset Administered_Dose1_Recip_12PlusPop_Pct= COALESCE (Administered_Dose1_Recip_12PlusPop_Pct0);
update COVID19_vaccinationsset Administered_Dose1_Recip_18Plus= COALESCE (Administered_Dose1_Recip_18Plus0);
update COVID19_vaccinationsset Administered_Dose1_Recip_18PlusPop_Pct= COALESCE (Administered_Dose1_Recip_18PlusPop_Pct0);
update COVID19_vaccinationsset Administered_Dose1_Recip_65Plus= COALESCE (Administered_Dose1_Recip_65Plus0);
update COVID19_vaccinationsset Administered_Dose1_Recip_65PlusPop_Pct= COALESCE (Administered_Dose1_Recip_65PlusPop_Pct0);

---Replacing the null values with the avg value
--As the data is incremental therefore can not calculate avg values directly
--thus, first calculated the max value for each county of each state and 
--then took average of those values 
WITH CTE_sum AS(
SELECT "Recip_State", 
	MAX("Series_Complete_Yes") AS "Max"
FROM "COVID19_vaccinations"
GROUP BY "Recip_County", 
	"Recip_State"
ORDER BY "Recip_State" DESC
),CTE_avg AS(
SELECT "Recip_State", 
	AVG("Max") AS "AVG"
FROM CTE_sum
Group By "Recip_State")
UPDATE "COVID19_vaccinations"
SET "Series_Complete_Yes"="AVG"
FROM CTE_avg
WHERE "Series_Complete_Yes" IS NULL

-----------------Querying overall vaccination coverage % for each state
--Since this is an incremental data that is data for each day is added as it's collected and 
--is added to the previous day data. For example- total vaccination in TX yesterday was 100 
--and today 20 more people got vaccinated so today's data is 120
--Therefore, calculating sum will give you incremental/running sum 
--Therefore use MAX which will return the maximum value/end day (latest) result
--Due to some error in data getting vaccination coverage for few states higher than 100 therefore
--used where filtet to filter out those values and to filter out all the null value
WITH CTE_sum AS(
SELECT "Recip_State", 
	MAX("Series_Complete_Yes") AS "Max",
	MAX("Census2019") AS "Total population"
FROM "COVID19_vaccinations"
GROUP BY "Recip_County", 
	"Recip_State"
ORDER BY "Recip_State" DESC
)
SELECT "Recip_State", 
	(SUM("Max")/SUM("Total population"))*100 AS "Vaccination Coverage"
FROM CTE_sum
Group By "Recip_State"
--HAVING (SUM("Max")/SUM("Total population"))*100 IS NOT NULL
ORDER BY "Vaccination Coverage" DESC

-----------------Querying vaccination coverage % for 5+ years old for each state
WITH CTE_sum1 AS(
SELECT "Recip_State",
	MAX("Series_Complete_5Plus") AS "Max 5plus",
	MAX("Census2019_5PlusPop") AS "Total population(5+)"
FROM "COVID19_vaccinations"
GROUP BY "Recip_County", 
	 "Recip_State"
)
SELECT "Recip_State", 
	(SUM("Max 5plus")/SUM("Total population(5+)"))*100 AS "Vaccination Coverage(5+)"
FROM CTE_sum1
Group By "Recip_State"
HAVING (SUM("Max 5plus")/SUM("Total population(5+)"))*100 IS NOT NULL
ORDER BY "Vaccination Coverage(5+)" DESC;

-----------------Querying vaccination coverage % for 12+ years old for each state
WITH CTE_sum2 AS(
SELECT "Recip_State", 
	MAX("Series_Complete_12Plus") AS "Max 12plus",
	MAX("Census2019_12PlusPop") AS "Total population(12+)"
FROM "COVID19_vaccinations"
GROUP BY "Recip_County", 
	"Recip_State"
)
SELECT "Recip_State", 
	(SUM("Max 12plus")/SUM("Total population(12+)"))*100 AS "Vaccination Coverage(12+)"
FROM CTE_sum2
Group By "Recip_State"
HAVING (SUM("Max 12plus")/SUM("Total population(12+)"))*100 IS NOT NULL
ORDER BY "Vaccination Coverage(12+)" DESC;

-----------------Querying vaccination coverage % for 18+ years old for each state
WITH CTE_sum2 AS(
SELECT "Recip_State", 
	MAX("Series_Complete_18Plus") AS "Max 18plus",
	MAX("Census2019_18PlusPop") AS "Total population(18+)"
FROM "COVID19_vaccinations"
GROUP BY "Recip_County", 
	"Recip_State"
)
SELECT "Recip_State", 
	(SUM("Max 18plus")/SUM("Total population(18+)"))*100 AS "Vaccination Coverage(18+)"
FROM CTE_sum2
Group By "Recip_State"
HAVING (SUM("Max 18plus")/SUM("Total population(18+)"))*100 IS NOT NULL
ORDER BY "Vaccination Coverage(18+)" DESC;

-----------------Querying vaccination coverage % for 65+ years old for each state
WITH CTE_sum4 AS(
SELECT "Recip_State", 
	MAX("Series_Complete_65Plus") AS "Max 65plus",
	MAX("Census2019_65PlusPop") AS "Total population(65+)"
FROM "COVID19_vaccinations"
GROUP BY "Recip_County", 
	"Recip_State"
)
SELECT "Recip_State", 
	(SUM("Max 65plus")/SUM("Total population(65+)"))*100 AS "Vaccination Coverage(65+)"
FROM CTE_sum4
Group By "Recip_State"
HAVING (SUM("Max 65plus")/SUM("Total population(65+)"))*100 IS NOT NULL AND (SUM("Max 65plus")/SUM("Total population(65+)"))*100 <=100
ORDER BY "Vaccination Coverage(65+)" DESC;

-----------------Querying booster dosage coverage% for each state
WITH CTE_sum5 AS(
SELECT "Recip_State", 
	MAX("Booster_Doses") AS "Total number of people who got boosted",
	MAX("Census2019") AS "Total population"
FROM "COVID19_vaccinations"
GROUP BY "Recip_County", 
	"Recip_State"
)
SELECT "Recip_State", 
	(SUM("Total number of people who got boosted")/SUM("Total population"))*100 AS "Booster dosage coverage %"
FROM CTE_sum5
Group By "Recip_State"
HAVING (SUM("Total number of people who got boosted")/SUM("Total population"))*100 IS NOT NULL 
ORDER BY "Booster dosage coverage %" DESC;

-----------------Querying number of people vaccinated per year

--Converting the data type of date column from text to date 
ALTER TABLE "COVID19_vaccinations"
ALTER COLUMN "Date"
Type date USING "Date"::date;

--Adding year column to the data
ALTER TABLE "COVID19_vaccinations"
ADD COLUMN Year INT;

--Extracting year from date column and updating this info into the newly created year column
UPDATE "COVID19_vaccinations"
SET "year" = EXTRACT( YEAR FROM "Date");


WITH CTE_sum AS(
SELECT "Recip_State", 
	MAX("Series_Complete_Yes") AS "Max",
	"year"
FROM "COVID19_vaccinations"
GROUP BY "Recip_State","year"
ORDER BY "Recip_State" DESC
)
SELECT SUM("Max") AS "Total vaccinations",
	"year"
FROM CTE_sum
GROUP BY  "year"


