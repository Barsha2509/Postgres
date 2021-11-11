SELECT * FROM rainfalls;
--In order to use CROSSTAB need to install tablefunc extension of POSTGRES

CREATE EXTENSION IF NOT EXISTS tablefunc;

--To check whether it has been installed
SELECT * FROM pg_extension;

--x: year(columns for the crosstab), y:(row) location, v(values):sum(rainfall)
--Below codes to obtain the distict values we will be outputting for the year/(columns) variable
SELECT DISTINCT(year) 
FROM rainfalls
ORDER BY year;

------------------------------------Ceating crosstab---------------------------------------------------
SELECT * FROM CROSSTAB
( ---put the columns in the select statement in the order in which you want the output
  ---i.e. y 1st,x 2nd,v 3rd
  ---Don't forget to use the order by to obtain results in proper order
'
  SELECT location,
          year,
          SUM(raindays)::INT
  FROM rainfalls
  GROUP BY location,
           year
  ORDER BY location,
           year
'
) AS T
( ---here write the output column names & their data types
  ---instead of year/x name put its different values name as the different columns
  ---b/c that's how they will appear in the final report
	location TEXT,
	"2012" INT,
	"2013" INT,
	"2014" INT,
	"2015" INT,
	"2016" INT,
	"2017" INT	
);



---------------------------------------Pivoting rows and columns-------------------------------------------------
-----codes to obtain the distict values we will be outputting for the location 
SELECT DISTINCT(location) 
FROM rainfalls
ORDER BY location;

SELECT * FROM CROSSTAB
( ---put the columns in the select statement in the order in which you want the output
  ---i.e. y 1st,x 2nd,v 3rd
  ---Don't forget to use the order by to obtain results in proper order
'
  SELECT  year,
	      location,
          SUM(raindays)::INT
  FROM rainfalls
  GROUP BY year,
           location
  ORDER BY year,
           location
'
) AS T
( ---here write the output column names & their data types
  ---instead of year/x name put its different values name as the different columns
  ---b/c that's how they will appear in the final report
	year INT,
	"Dubai" INT,
	"France" INT,
	"Germany" INT,
	"London" INT,
	"Malaysia" INT,
	"Qatar" INT	,
	"Singapore" INT,
	"Sydney" INT
);

------------------------------------------------------------------------------------------------------
------------Creating crosstab report by using simple query(without using CROSSTAB)---------------------------
SELECT location,
	SUM(raindays) FILTER (WHERE year='2012') AS "2012", 
	SUM(raindays) FILTER (WHERE year='2013') AS"2013",
	SUM(raindays) FILTER (WHERE year='2014') AS"2014",
	SUM(raindays) FILTER (WHERE year='2015') AS"2015",
	SUM(raindays) FILTER (WHERE year='2016') AS"2016",
	SUM(raindays) FILTER (WHERE year='2017') AS"2017"	
FROM rainfalls
GROUP BY location --(always row variable)
ORDER BY location;



