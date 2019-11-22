-- For each product in the database, calculate how many more orders where placed in 
-- each month compared to the previous month.

-- IMPORTANT! This is going to be a 2-day warmup! FOR NOW, assume that each product
-- has sales every month. Do the calculations so that you're comparing to the previous 
-- month where there were sales.
-- For example, product_id #1 has no sales for October 1996. So compare November 1996
-- to September 1996 (the previous month where there were sales):
-- So if there were 27 units sold in November and 20 in September, the resulting 
-- difference should be 27-7 = 7.
-- (Later on we will work towards filling in the missing months.)

-- BIG HINT: Look at the expected results, how do you convert the dates to the 
-- correct format (year and month)?

WITH order_info AS ( 
	SELECT *,
		od.quantity as od_quantity,
		od.productid as od_product_id, 
		to_char(o.orderdate, 'YYYY') as year,to_char(o.orderdate, 'MM') as month
	FROM orders as o 
		JOIN order_details as od ON o.orderid = od.orderid
		JOIN products as p ON od.productid = p.productid
		JOIN customers as c ON o.customerid = c.customerid
),
product_totals as ( 
	SELECT 
		od_product_id,
		year,month,
		SUM(od_quantity) as units_sold
	FROM order_info
	GROUP BY od_product_id, year, month
),

product_totals_lags as ( 
	SELECT *,
		LAG(units_sold,1) OVER(PARTITION BY year, month ORDER BY units_sold) as prev_month
	FROM product_totals
)

SELECT od_product_id as p_product_id,
	year,month,
	units_sold,
	prev_month,
	COALESCE(units_sold-prev_month,0) as difference 
FROM product_totals_lags
ORDER BY year, month, units_sold DESC;

