SELECT * FROM orders;

-- Orders shipped to US and France
SELECT * FROM orders
WHERE ship_country IN ('USA','France')
ORDER BY ship_country;

--Total numbers of orders shipped to USA or France
SELECT ship_country,
	   COUNT(order_id)
FROM orders
WHERE ship_country IN ('USA','France')
GROUP BY ship_country
ORDER BY ship_country;

-- Orders shipped to latin america
SELECT * FROM orders
WHERE ship_country IN ('Venezuela','Brazil','Mexico','Argentina')
ORDER BY ship_country;

--Show total order amount for eachorder
SELECT OD.order_id, 
	   OD.unit_price, 
	   OD.quantity, 
	   OD.discount,
	   (OD.unit_price*OD.quantity)- OD.discount AS Total_price
FROM order_details AS OD
ORDER BY 5;

--First the oldest and latest order date
SELECT MIN(order_date) AS min_order,
	   MAX(order_date) AS max_order
FROM orders

--Total products in each categories
SELECT C.category_name, 
	   COUNT(*) AS Total_products 
FROM products AS P
JOIN categories AS C
ON P.category_id=C.category_id
GROUP BY C.category_name
ORDER BY 2;

--List products that needs re-ordering
SELECT product_id, 
	   product_name,
	   units_in_stock,
	   reorder_level
FROM products 
WHERE units_in_stock<=reorder_level
ORDER BY reorder_level

--Freight analysis
--1) List top 5 highest freight charges
SELECT ship_country, 
		AVG(freight) 
FROM orders
GROUP BY ship_country
ORDER BY 2 DESC
LIMIT 5;

--2) List top 5 highest freight charges in year 1997
SELECT ship_country,
		AVG(freight) 
FROM orders
WHERE order_date BETWEEN '1997-01-01' AND '1997-12-31'
GROUP BY ship_country
ORDER BY 2 DESC
LIMIT 5;

--3) List top 5 highest freight charges in the last year
SELECT max(order_date) 
FROM orders; --to know the last year in which the orders were placed

SELECT ship_country,
		AVG(freight) 
FROM orders
WHERE order_date BETWEEN '1998-01-01' AND '1998-12-31'
GROUP BY ship_country
ORDER BY 2 DESC
LIMIT 5;

------Other way of doing the above step 
------i.e. how to rewrite the WHERE part 
------by not putting the starting and ending date of the last year manually
SELECT ship_country,
	   AVG(freight)
FROM orders
WHERE EXTRACT('Y'FROM order_date)= EXTRACT('Y' FROM (SELECT max(order_date) FROM orders))
GROUP BY ship_country
ORDER BY 2 DESC
LIMIT 5;
-------THIS part 
-------WHERE EXTRACT('Y'FROM order_date)= EXTRACT('Y' FROM (SELECT max(order_date) FROM orders))
-------that where year obtained from the order date is equal to the yaear obtained from max order_date

--Customers with no orders
-------LEFT join so that all the data from customers table is obtained
-------and from there data with null customer_id for orders table is obtained
SELECT * 
FROM customers AS C
LEFT JOIN orders AS O
ON O.customer_id=C.customer_id
WHERE  O.customer_id IS NULL;

--Top customers with total orders amount
SELECT C.customer_id,
	   C.company_name,
	   C.address,
	   C.postal_code, 
	   SUM((OD.unit_price*OD.quantity)-OD.discount ) AS "Total price"
FROM customers AS C 
INNER join orders AS O
ON O.customer_id = C.customer_id
INNER JOIN order_details AS OD
ON O.order_id=OD.order_id
GROUP BY C.customer_id,
		C.company_name,
		C.address,
		C.postal_code
ORDER BY 5 DESC;

-- Orders with many lines of ordered items(people/order ids which have ordered too many times)
SELECT order_id, 
	   COUNT(*)
FROM order_details
GROUP BY 1
ORDER BY 2 DESC;

--Orders with duplicate values of the quantity
WITH order_cte AS
(
	SELECT order_id, quantity, COUNT(*)
	FROM order_details
	GROUP BY 1,2
	HAVING COUNT(*)>1
	ORDER BY 2 DESC)
SELECT * FROM order_details
WHERE order_id IN (SELECT order_id FROM order_cte);

--Late shipped orders by employees
WITH delayed_orders AS
(
	SELECT employee_id, 
		COUNT(*) AS late_orders
	FROM orders
	WHERE required_date<shipped_date
	GROUP BY employee_id
)
,
total_orders AS
(
	SELECT employee_id, 
		   COUNT(*) AS all_orders
	FROM orders
	GROUP BY employee_id
)
SELECT  employees.employee_id,
		employees.first_name,
		employees.last_name,
		total_orders.all_orders, 
		delayed_orders.late_orders
FROM employees
JOIN total_orders
ON employees.employee_id=total_orders.employee_id
JOIN delayed_orders
ON employees.employee_id=delayed_orders.employee_id
;

--Countries with customers or suppliers
SELECT company_name, 
	   country 
FROM suppliers
UNION
SELECT company_name, country 
FROM customers;

------doing the above steps with the CTE

WITH suppliers_CTE AS
(
	SELECT company_name, 
		   country 
	FROM suppliers
),
customers_CTE AS
(
	SELECT company_name, 
		   country 
	FROM customers
)
SELECT suppliers_CTE.country AS suppliers_company_name,
	   customers_CTE.country AS customers_company_name
FROM suppliers_CTE
FULL JOIN  customers_CTE
ON suppliers_CTE.country=customers_CTE.country
ORDER BY suppliers_CTE.country,
customers_CTE.country;

--Customers with multiple orders
--1. Looking at the customers with more than 1 order
SELECT customer_id,
	   COUNT(*) FROM orders
GROUP BY customer_id
HAVING COUNT(*)>1
ORDER BY 2 DESC;

--2. Calculating number of days between the two orders to see which customers ordered more frequently

WITH orderdate_CTE AS
(
	SELECT customer_id, 
		order_date,
		LEAD(order_date,1) OVER(PARTITION BY customer_id ORDER BY customer_id) AS next_order_date
	FROM orders
)
SELECT customer_id, 
		order_date, 
		next_order_date,
		(next_order_date-order_date) AS no_of_days_between_orders
FROM orderdate_CTE
ORDER BY 3 DESC NULLS LAST;

--First order from each country
SELECT MIN(order_date), 
	   ship_country
FROM  orders
GROUP BY ship_country
ORDER BY ship_country;

----doing the same thing with cte
WITH orders_by_country AS
(
	SELECT order_id,
		   customer_id,
		   order_date, 
		   ship_country, 
		   ROW_NUMBER() OVER(PARTITION BY ship_country ORDER BY order_date)
	FROM orders
)
SELECT * FROM orders_by_country
WHERE row_number=1;
