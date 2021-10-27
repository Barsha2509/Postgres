----Create a function for obtaining maximum order amount of every cuatomer
CREATE OR REPLACE FUNCTION func_max_orederamt(pcustomer_id character) RETURNS double precision AS
$$
SELECT MAX(orderamt) FROM
(
	SELECT o.order_id,
		c.customer_id,
		od.product_id,
		SUM((od.unit_price*od.quantity)-od.discount) AS orderamt
		FROM orders AS o
	NATURAL JOIN order_details AS od
	NATURAL JOIN customers AS c
	WHERE o.customer_id=pcustomer_id
	GROUP BY o.order_id,
	c.customer_id,
	od.product_id
	ORDER BY 4 DESC;
) AS T
$$
LANGUAGE SQL

SELECT func_max_orederamt('ALFKI');

--Create a function for obtaining the most ordered product by each customer
CREATE OR REPLACE FUNCTION most_ordered_product(c_customer_id bpchar) RETURNS character varying(40) AS
$$
SELECT  product_name FROM products
WHERE product_id IN
(
	SELECT product_id FROM
	(
		SELECT p.product_name, 
			p.product_id, 
			o.customer_id,
			SUM(od.quantity) 
		FROM orders AS o
		NATURAL JOIN order_details AS od
		NATURAL JOIN products AS p
		WHERE o.customer_id=c_customer_id 
		GROUP BY p.product_name, p.product_id, o.customer_id
		ORDER BY 4 DESC;
	)  AS C
)
$$
LANGUAGE SQL

SELECT most_ordered_product('TOMSP');

-- Function returning a composite
-- Function that returns most recent order
CREATE OR REPLACE FUNCTION most_recent_order() RETURNS orders AS
$$
 SELECT * FROM orders
 ORDER BY order_date DESC;
$$
LANGUAGE SQL

SELECT most_recent_order();
---- To obtain the results in table format for the above case use (function_name()).*
SELECT (most_recent_order()).*;
----To get a particular field for the reault in above 2 cases use (function_name()).field_name
SELECT (most_recent_order()).order_id;

-- Function returning a composite
-- Function that returns most recent order between date range
CREATE OR REPLACE FUNCTION fn_most_recent_order_range(p_date_from date, p_date_to date) RETURNS orders AS
$$
 SELECT * FROM orders
 WHERE order_date BETWEEN p_date_from AND p_date_to
 ORDER BY order_date DESC;
$$
LANGUAGE SQL
 
SELECT fn_most_recent_order_range('01-01-1990','01-01-1999');
SELECT (fn_most_recent_order_range('01-01-1990','01-01-1999')).*;

--Function returning multiple rows
--Function that returns the list of employees names that were hired in a particular year
-- next to RETURNS write SETOF and the table name from which you are creating this function
CREATE OR REPLACE FUNCTION fn_hiredate_emp(p_year int ) RETURNS SETOF employees AS
$$
  SELECT * FROM
  employees
  WHERE EXTRACT('YEAR' FROM hire_date)=p_year;
$$
LANGUAGE SQL

SELECT fn_hiredate_emp('1992');

-- For a function returning a table the order & the data type of the 
--columns in the output table should be same as that of the input table
CREATE OR REPLACE FUNCTION fn_most_recent_order() RETURNS Table
(
 order_id smallint,
 customer_id CHAR,
 order_date DATE	
)
AS
$$
 SELECT order_id,
	 customer_id,
	 order_date
 FROM orders
 ORDER BY order_date DESC;
$$
LANGUAGE SQL

SELECT fn_most_recent_order();
---- To obtain the results in table format for the above case use (function_name()).*
SELECT (fn_most_recent_order()).*;
----To get a particular field for the reault in above 2 cases use (function_name()).field_name
SELECT (fn_most_recent_order()).order_id;
------OR
SELECT  order_id 
FROM fn_most_recent_order();

-- Function parameters with default values
CREATE OR REPLACE FUNCTION fn_sum(x int, y int DEFAULT 10, z int DEFAULT 20) RETURNS int AS
$$
  SELECT x+y+z;
$$
LANGUAGE SQL
SELECT fn_sum(1);
-----NOTE- input parameters one after default should also be a default

--Function based on views
CREATE OR REPLACE VIEW  view_active_status AS
SELECT pid,
usename,
query_start,
(CURRENT_TIMESTAMP-query_start) AS runtime,
query
FROM
pg_stat_activity
WHERE state='active';

CREATE OR REPLACE FUNCTION fn_active_status(plimit int) RETURNS SETOF view_active_status AS
$$
  SELECT * FROM
  view_active_status 
  LIMIT plimit;
$$
LANGUAGE SQL

SELECT * FROM fn_active_status(3);

