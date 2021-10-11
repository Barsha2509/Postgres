SELECT * FROM "Nashville Housing";

SELECT TO_DATE("SaleDate",'Month DD, YYYY') FROM "Nashville Housing";

--UPDATE "Nashville Housing"
--SET "SaleDate"=TO_DATE("SaleDate",'Month DD, YYYY');


ALTER  TABLE "Nashville Housing"
ALTER COLUMN "SaleDate"
TYPE date USING TO_DATE("SaleDate",'Month DD, YYYY');

--Filling up all the null values for the address column by using
--the value from the properties with same ParcelID

SELECT * FROM "Nashville Housing"
WHERE "PropertyAddress" is null;

SELECT a."ParcelID", 
		a."PropertyAddress",
		b."ParcelID",
		b."PropertyAddress"
FROM "Nashville Housing" AS a
JOIN "Nashville Housing" AS b
ON a."ParcelID"=b."ParcelID"
AND a."UniqueID "<> b."UniqueID "
WHERE a."PropertyAddress" IS NULL;


UPDATE "Nashville Housing" AS a
SET "PropertyAddress"=COALESCE(a."PropertyAddress",b."PropertyAddress")
FROM "Nashville Housing" AS b
WHERE a."ParcelID"=b."ParcelID"
AND a."UniqueID "<> b."UniqueID "
AND a."PropertyAddress" IS NULL;

--Splitting PropertyAddress into Address and city

--part1:looking how substring seperates the PropertyAddress
SELECT SUBSTRING("PropertyAddress",1, POSITION(',' IN "PropertyAddress" )-1) AS "Address",
SUBSTRING("PropertyAddress",POSITION(',' IN "PropertyAddress" )+1) AS "City"
FROM "Nashville Housing"
;

FROM "Nashville Housing"
--part2:Adding 2 new columns, address and city to the table
ALTER TABLE "Nashville Housing"
ADD "PropertySplitAddress"  VARCHAR(250),
ADD "PropertySplitCity"  VARCHAR(250);

--part3:updating the added columns with the substring values
UPDATE "Nashville Housing"
SET "PropertySplitAddress"= SUBSTRING("PropertyAddress",1, POSITION(',' IN "PropertyAddress" )-1),
"PropertySplitCity" =SUBSTRING("PropertyAddress",POSITION(',' IN "PropertyAddress" )+1) ;

--EASIER way to split the address

SELECT SPLIT_PART("OwnerAddress", ',', 1) AS "OwnerSplitAddress" ,
		SPLIT_PART("OwnerAddress", ',', 2) AS "OwnerSplitCity",
		SPLIT_PART("OwnerAddress", ',', 3) AS "OwnerSplitState"
FROM "Nashville Housing";

ALTER TABLE "Nashville Housing"
ADD "OwnerSplitAddress"   VARCHAR(250),
ADD "OwnerSplitCity"  VARCHAR(250),
ADD "OwnerSplitState"  VARCHAR(20)
;

UPDATE "Nashville Housing"
SET "OwnerSplitAddress"=SPLIT_PART("OwnerAddress", ',', 1),
	"OwnerSplitCity" =SPLIT_PART("OwnerAddress", ',', 2),
	"OwnerSplitState"=SPLIT_PART("OwnerAddress", ',', 3);

--Change Y and N to Yes and No for SoldAsVacant column
UPDATE "Nashville Housing"
SET "SoldAsVacant" = CASE 
                         WHEN "SoldAsVacant" = 'Y'
						 THEN 'Yes'
						 WHEN "SoldAsVacant" = 'N'
						 THEN 'No'
						 ELSE "SoldAsVacant"	 
					 END;

--Remove duplicates

WITH CTE_ROW AS(
	SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY "ParcelID",
				 "PropertyAddress",
				 "SaleDate",
				 "SalePrice",
			     "LegalReference"
				 ORDER BY "UniqueID ")
	FROM "Nashville Housing"
				) 
DELETE FROM "Nashville Housing" AS n
USING CTE_ROW AS c WHERE n."UniqueID "=c."UniqueID " AND row_number > 1;

--Deleting unused columns
ALTER TABLE "Nashville Housing"
DROP COLUMN "PropertyAddress", 
DROP COLUMN"OwnerAddress";

