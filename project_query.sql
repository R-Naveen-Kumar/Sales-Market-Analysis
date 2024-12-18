-- Month
-- Product
-- Variant
-- Sold Quantity
-- Gross Price Per Item
-- Gross Price Total


SELECT * FROM fact_sales_monthly
WHERE customer_code="90002002";

SELECT * FROM fact_sales_monthly
WHERE customer_code="90002002" AND 
YEAR(date)=2021 
ORDER BY date DESC;


-- 09-2020 -> 01-2021  #calender month + 4 months = Fiscal year
SELECT DATE_ADD("2020-010-01",INTERVAL 4 MONTH);

SELECT * FROM fact_sales_monthly 
WHERE customer_code="90002002" AND YEAR(DATE_ADD(date,INTERVAL 4 MONTH))=2021		#we get fiscal year
ORDER BY date DESC;

SELECT * FROM fact_sales_monthly 
WHERE customer_code="90002002" AND get_fiscal_year(date)=2021		#we get fiscal year after we used function
ORDER BY date ASC;

-- 9,10,11 ->Q1
-- 12,1,2 ->Q2
-- 6,7,8 ->Q4
SELECT MONTH("2019-04-01") ;   #tells the month

SELECT * FROM fact_sales_monthly 
WHERE 
customer_code="90002002" AND 
get_fiscal_year(date)=2021 AND 
get_fiscal_quarter(date)="Q4"	#we get fiscal quarter after we used function
ORDER BY date ASC
LIMIT 1000000;

-- for products and variants

SELECT * 
FROM fact_sales_monthly s
JOIN dim_product p					#to join product table know abt products and variant
ON p.product_code=s.product_code
WHERE 
customer_code="90002002" AND 
get_fiscal_year(date)=2021 	
ORDER BY date ASC
LIMIT 1000000;

SELECT 
	s.date,s.product_code,s.sold_quantity,
    p.product,p.variant
FROM fact_sales_monthly s
JOIN dim_product p					
ON p.product_code=s.product_code
WHERE 
customer_code="90002002" AND 
get_fiscal_year(date)=2021 	
ORDER BY date ASC
LIMIT 1000000;

-- for gross_price   

SELECT 
	s.date,s.product_code,s.sold_quantity,
    p.product,p.variant,
    g.gross_price
FROM fact_sales_monthly s
JOIN dim_product p					
ON p.product_code=s.product_code
JOIN fact_gross_price g
ON 
	g.product_code=s.product_code AND
	g.fiscal_year =get_fiscal_year(s.date)
WHERE 
customer_code="90002002" AND 
get_fiscal_year(date)=2021 	
ORDER BY date ASC
LIMIT 1000000;

-- to get gross price total

SELECT 
	s.date,s.product_code,
    p.product,p.variant,s.sold_quantity,
    g.gross_price,
    ROUND(g.gross_price*s.sold_quantity,2) AS gross_price_total
FROM fact_sales_monthly s
JOIN dim_product p					
ON p.product_code=s.product_code
JOIN fact_gross_price g
ON 
	g.product_code=s.product_code AND
	g.fiscal_year =get_fiscal_year(s.date)
WHERE 
customer_code="90002002" AND 
get_fiscal_year(date)=2021 	
ORDER BY date ASC
LIMIT 1000000;


-- Month
-- Total gross sales amount to croma india in this month

SELECT * 
FROM fact_sales_monthly s
JOIN fact_gross_price g
ON 
	g.product_code=s.product_code AND
    g.fiscal_year=get_fiscal_year(s.date)
WHERE customer_code=90002002
ORDER BY s.date ASC;

SELECT
	s.date,
	g.gross_price*s.sold_quantity AS gross_price_total
FROM fact_sales_monthly s
JOIN fact_gross_price g
ON 
	g.product_code=s.product_code AND
    g.fiscal_year=get_fiscal_year(s.date)
WHERE customer_code=90002002
ORDER BY s.date ASC;

SELECT
	s.date,
	SUM(g.gross_price*s.sold_quantity) AS gross_price_total					#we should write sum before grouping becase only group chooses random value not total sum
FROM fact_sales_monthly s
JOIN fact_gross_price g
ON 
	g.product_code=s.product_code AND
    g.fiscal_year=get_fiscal_year(s.date)
WHERE customer_code=90002002
GROUP BY s.date
ORDER BY s.date ASC;

#exrc for yearly sales report
--  1.fiscal year
--  2.Total Gross sales amount in tht year from croma

SELECT get_fiscal_year(date) AS fiscal_year,
		SUM(ROUND(sold_quantity*gross_price,2)) AS gross_price_total
FROM fact_sales_monthly s
JOIN fact_gross_price g
ON g.product_code=s.product_code AND g.fiscal_year=get_fiscal_year(s.date) 
WHERE customer_code="90002002" 
GROUP BY get_fiscal_year(date)       
ORDER BY fiscal_year;

#INPUT
-- market
-- fiscal_year
#Output
-- market badge

SELECT 
	c.market,
    SUM(sold_quantity) AS total_qty
FROM fact_sales_monthly s
JOIN dim_customer c
ON s.customer_code=c.customer_code
WHERE get_fiscal_year(s.date)=2021
GROUP BY c.market;

SELECT 
	c.market,
    SUM(sold_quantity) AS total_qty
FROM fact_sales_monthly s
JOIN dim_customer c
ON s.customer_code=c.customer_code
WHERE get_fiscal_year(s.date)=2021 AND market="India"
GROUP BY c.market;

-- pre invoice discount

SELECT 
	s.date,s.product_code,
    p.product,p.variant,s.sold_quantity,
    g.gross_price,
    ROUND(g.gross_price*s.sold_quantity,2) AS gross_price_total,
    pre.pre_invoice_discount_pct
FROM fact_sales_monthly s
JOIN dim_product p					
ON p.product_code=s.product_code
JOIN fact_gross_price g
ON 
	g.product_code=s.product_code AND
	g.fiscal_year =get_fiscal_year(s.date)
JOIN fact_pre_invoice_deductions pre
ON 
	pre.customer_code=s.customer_code AND 
    pre.fiscal_year=get_fiscal_year(s.date)
WHERE  
get_fiscal_year(date)=2021 	
ORDER BY date ASC
LIMIT 1000000;

#improvise performance
-- 1 dim_date 
#=============
#2017-09-01->2018
#2017-10-01->2018
#2018-09-01->2019

SELECT 
	s.date,s.product_code,
    p.product,p.variant,s.sold_quantity,
    g.gross_price,
    ROUND(g.gross_price*s.sold_quantity,2) AS gross_price_total,
    pre.pre_invoice_discount_pct
FROM fact_sales_monthly s
JOIN dim_product p					
ON p.product_code=s.product_code
JOIN dim_date dt
ON dt.calender_date=s.date
JOIN fact_gross_price g
ON 
	g.product_code=s.product_code AND
	g.fiscal_year =dt.fiscal_year							#1 using dim_date table we reduced the time thn prevois one 
JOIN fact_pre_invoice_deductions pre
ON 
	pre.customer_code=s.customer_code AND 
    pre.fiscal_year=dt.fiscal_year
WHERE  
dt.fiscal_year=2021 	
ORDER BY date ASC
LIMIT 1000000;

-- 2 in fact_sales_monthly by adding fiscal year

SELECT 
	s.date,s.product_code,
    p.product,p.variant,s.sold_quantity,
    g.gross_price,
    ROUND(g.gross_price*s.sold_quantity,2) AS gross_price_total,
    pre.pre_invoice_discount_pct
FROM fact_sales_monthly s
JOIN dim_product p					
ON p.product_code=s.product_code
JOIN fact_gross_price g
ON 
	g.product_code=s.product_code AND
	g.fiscal_year =s.fiscal_year							#2 by addng fiscal year column in fact sales motnhly table
JOIN fact_pre_invoice_deductions pre
ON 
	pre.customer_code=s.customer_code AND 
    pre.fiscal_year=s.fiscal_year
WHERE  
s.fiscal_year=2021 	
ORDER BY date ASC
LIMIT 1000000;


-- Net invoice sales 

WITH cte1 AS (SELECT 
	s.date,s.product_code,
    p.product,p.variant,s.sold_quantity,
    g.gross_price,
    ROUND(g.gross_price*s.sold_quantity,2) AS gross_price_total,
    pre.pre_invoice_discount_pct
FROM fact_sales_monthly s
JOIN dim_product p					
ON p.product_code=s.product_code
JOIN fact_gross_price g
ON 
	g.product_code=s.product_code AND
	g.fiscal_year =s.fiscal_year							#2 by addng fiscal year column in fact sales motnhly table
JOIN fact_pre_invoice_deductions pre
ON 
	pre.customer_code=s.customer_code AND 
    pre.fiscal_year=s.fiscal_year
WHERE  
s.fiscal_year=2021 	
ORDER BY date ASC
LIMIT 1000000)
SELECT *, 
		(gross_price_total-gross_price_total*pre_invoice_discount_pct) AS net_invoice_sales
FROM cte1;

#after creating virtual table as VIEW 

SELECT *, 
		(gross_price_total-gross_price_total*pre_invoice_discount_pct) AS net_invoice_sales		#similar result as prevs query
FROM sales_preinv_discount;

SELECT *, 
		(1-pre_invoice_discount_pct)*gross_price_total AS net_invoice_sales		#similar result as prevs query
FROM sales_preinv_discount;

-- post invoice deduction

SELECT *, 
		(1-pre_invoice_discount_pct)*gross_price_total AS net_invoice_sales,
		(po.discounts_pct+po.other_deductions_pct) AS post_invoice_discount_pct
FROM sales_preinv_discount s
JOIN fact_post_invoice_deductions po
ON s.date=po.date AND
s.product_code=po.product_code AND 
s.customer_code=po.customer_code; 

-- Net Sales

SELECT 
	*,
    (1-post_invoice_discount_pct)*net_invoice_sales AS net_sales
    FROM sales_postinv_discount;
    
-- Excr on create view 0n gross sales (Check in view tables)

CREATE  VIEW `gross sales` AS
	SELECT 
		s.date,
		s.fiscal_year,
		s.customer_code,
		c.customer,
		c.market,
		s.product_code,
		p.product, p.variant,
		s.sold_quantity,
		g.gross_price as gross_price_per_item,
		round(s.sold_quantity*g.gross_price,2) as gross_price_total
	from fact_sales_monthly s
	join dim_product p
	on s.product_code=p.product_code
	join dim_customer c
	on s.customer_code=c.customer_code
	join fact_gross_price g
	on g.fiscal_year=s.fiscal_year
	and g.product_code=s.product_code;
    
-- Top markets and customers
#MARKETS
SELECT 
	market,
    SUM(net_sales) AS net_sales
FROM net_sales
WHERE fiscal_year=2021
GROUP BY market;


SELECT 
	market,
    ROUND(SUM(net_sales)/1000000,2) AS net_sales_mln
FROM net_sales
WHERE fiscal_year=2021												#In million
GROUP BY market
ORDER BY net_sales_mln DESC
LIMIT 5;
    
#CUSTOMERS

SELECT 
	c.customer,
    ROUND(SUM(net_sales)/1000000,2) AS net_sales_mln
FROM net_sales n
JOIN dim_customer c
ON n.customer_code=c.customer_code
WHERE fiscal_year=2021							#to filter by customers we joined DIm customer table using customer code
GROUP BY customer
ORDER BY net_sales_mln DESC
LIMIT 5;

#creating net charts using window
SELECT 
	c.customer,
    ROUND(SUM(net_sales)/1000000,2) AS net_sales_mln
FROM net_sales n
JOIN dim_customer c
ON n.customer_code=c.customer_code
WHERE fiscal_year=2021 						
GROUP BY customer
ORDER BY net_sales_mln DESC;
    
    
WITH cte1 AS (SELECT 
	c.customer,
    ROUND(SUM(net_sales)/1000000,2) AS net_sales_mln  #similsr to prvs
FROM net_sales n
JOIN dim_customer c
ON n.customer_code=c.customer_code
WHERE fiscal_year=2021 						
GROUP BY customer)
SELECT * FROM cte1
ORDER BY net_sales_mln DESC;


WITH cte1 AS (SELECT 
	c.customer,
    ROUND(SUM(net_sales)/1000000,2) AS net_sales_mln  #similsr to prvs
FROM net_sales n
JOIN dim_customer c
ON n.customer_code=c.customer_code
WHERE fiscal_year=2021 						
GROUP BY customer)
SELECT *,
	net_sales_mln*100/SUM(net_sales_mln) AS pct
    FROM cte1
ORDER BY net_sales_mln DESC;

WITH cte1 AS (SELECT 
	c.customer,
    ROUND(SUM(net_sales)/1000000,2) AS net_sales_mln  #similsr to prvs
FROM net_sales n
JOIN dim_customer c
ON n.customer_code=c.customer_code
WHERE fiscal_year=2021 						
GROUP BY customer)
SELECT *,
	net_sales_mln*100/SUM(net_sales_mln) OVER() AS pct		#over
    FROM cte1
ORDER BY net_sales_mln DESC;

#Excr to create net share including regions 

SELECT 
	c.customer,
    c.region,
    ROUND(SUM(net_sales)/1000000,2) AS net_sales_mln  
FROM net_sales n
JOIN dim_customer c
ON n.customer_code=c.customer_code
WHERE fiscal_year=2021 						
GROUP BY c.customer,c.region
ORDER BY net_sales_mln DESC;

WITH cte1 AS (SELECT 
	c.customer,
    c.region,
    ROUND(SUM(net_sales)/1000000,2) AS net_sales_mln  
FROM net_sales n
JOIN dim_customer c
ON n.customer_code=c.customer_code
WHERE fiscal_year=2021 						
GROUP BY c.customer,c.region)
SELECT *
FROM cte1
ORDER BY net_sales_mln DESC;

WITH cte1 AS (SELECT 
	c.customer,
    c.region,
    ROUND(SUM(net_sales)/1000000,2) AS net_sales_mln  
FROM net_sales n
JOIN dim_customer c
ON n.customer_code=c.customer_code
WHERE fiscal_year=2021 						
GROUP BY c.customer,c.region)
SELECT *,
net_sales_mln*100/SUM(net_sales_mln) OVER (PARTITION BY region) AS pct_share_region
FROM cte1
ORDER BY region,net_sales_mln DESC;

SELECT * FROM expenses
ORDER BY category;
#SHOW 2 TOP expenses in each category

SELECT 
	*,
	ROW_NUMBER() OVER(PARTITION BY category ORDER BY amount DESC) AS rn
 FROM expenses
 ORDER BY category;
 
 WITH cte1 AS (SELECT 
	*,
	ROW_NUMBER() OVER(PARTITION BY category ORDER BY amount DESC) AS rn   #similar
 FROM expenses
 ORDER BY category)
 SELECT * FROM cte1 ;


WITH cte1 AS (SELECT 
	*,
	ROW_NUMBER() OVER(PARTITION BY category ORDER BY amount DESC) AS rn   #showing top  2
 FROM expenses
 ORDER BY category)
 SELECT * FROM cte1 WHERE rn<=2;
 
 SELECT 
	*,
	ROW_NUMBER() OVER(PARTITION BY category ORDER BY amount DESC) AS rn,
    RANK() OVER(PARTITION BY category ORDER BY amount DESC) AS rnk     #showing rank
 FROM expenses
 ORDER BY category;
 
WITH cte1 AS (SELECT 
	*,
	ROW_NUMBER() OVER(PARTITION BY category ORDER BY amount DESC) AS rn,
    RANK() OVER(PARTITION BY category ORDER BY amount DESC) AS rnk,
    DENSE_RANK() OVER(PARTITION BY category ORDER BY amount DESC) AS d_rnk#showing rank
 FROM expenses
 ORDER BY category)
 SELECT * FROM cte1 WHERE d_rnk<=2;
 
 SELECT *,
	ROW_NUMBER() OVER(ORDER BY marks DESC) AS rn,
    RANK() OVER(ORDER BY marks DESC) AS rnk,
    DENSE_RANK() OVER(ORDER BY marks DESC) AS d_rnk
 FROM random_tables.student_marks;
 
 #top 3 products sold
 
SET sql_mode = ''; 
SELECT 
	p.division,
    p.product,
    SUM(sold_quantity) AS total_qty
FROM fact_sales_monthly s
JOIN dim_product p
ON p.product_code=s.product_code
WHERE fiscal_year=2021 
GROUP BY p.product;

SET sql_mode = ''; 
WITH cte1 AS (SELECT 
	p.division,
    p.product,
    SUM(sold_quantity) AS total_qty
FROM fact_sales_monthly s
JOIN dim_product p
ON p.product_code=s.product_code
WHERE fiscal_year=2021
GROUP BY p.product),
cte2 AS(SELECT *,
DENSE_RANK() OVER(PARTITION BY division ORDER BY total_qty DESC) AS drnk
FROM cte1)
SELECT * FROM cte2 WHERE drnk=3;


# Excr to get top 2 markets

SET sql_mode = ''; 
WITH cte1 AS (
		SELECT
			c.market,
			c.region,
			round(sum(gross_price_total)/1000000,2) as gross_sales_mln
			FROM gross_sales s
			JOIN dim_customer c
			ON c.customer_code=s.customer_code
			WHERE fiscal_year=2021
			GROUP BY market
			ORDER BY gross_sales_mln DESC
		),
		cte2 AS (
			SELECT *,
			DENSE_RANK() OVER(PARTITION BY region ORDER BY gross_sales_mln DESC) AS drnk
			FROM cte1
		)
SELECT *FROM cte2 WHERE drnk<=2;

-- Supply chain analytics
    
SELECT * FROM fact_forecast_monthly;

#joining both sales and forecast month

SELECT s.*,f.forecast_quantity
 FROM fact_sales_monthly s
 JOIN fact_forecast_monthly f
 USING(date,product_code,customer_code) ;
 
 CREATE TABLE fact_actl_est
 (
	SELECT
		s.date AS date,
        s.fiscal_year AS fiscal_year,
        s.product_code AS product_code,
        s.customer_code AS customer_code,
        s.sold_quantity AS sold_quantity,
        f.forecast_quantity AS forecast_quantity
	FROM fact_sales_monthly s
    LEFT JOIN fact_forecast_monthly f
    USING (date,customer_code,product_code)
    
    UNION
    
    SELECT
		f.date AS date,
        f.fiscal_year AS fiscal_year,
        f.product_code AS product_code,
        f.customer_code AS customer_code,
        s.sold_quantity AS sold_quantity,
        f.forecast_quantity AS forecast_quantity
	FROM fact_forecast_monthly f
    LEFT JOIN fact_sales_monthly s
    USING (date,customer_code,product_code));

SET sql_mode = '';
UPDATE fact_act_est
SET sold_quantity=0
WHERE sold_quantity IS NULL;
    
UPDATE fact_act_est
SET forecast_quantity=0
WHERE forecast_quantity IS NULL;

-- Forecast accuracy report

SET sql_mode = '';
SELECT 
	*,
    SUM((forecast_quantity-sold_quantity)) AS net_err,
    SUM(abs(forecast_quantity-sold_quantity)) AS abs_err,
    SUM((forecast_quantity-sold_quantity))*100/SUM(forecast_quantity) AS net_err_pct,
    SUM(abs(forecast_quantity-sold_quantity))*100/SUM(forecast_quantity) AS abs_err_pct
FROM fact_act_est s
WHERE s.fiscal_year=2021
GROUP BY s.customer_code
ORDER BY abs_err_pct DESC;

SET sql_mode = '';
WITH forecast_err_table AS (SELECT 
	*,
    SUM((forecast_quantity-sold_quantity)) AS net_err,
    SUM(abs(forecast_quantity-sold_quantity)) AS abs_err,
    SUM((forecast_quantity-sold_quantity))*100/SUM(forecast_quantity) AS net_err_pct,
    SUM(abs(forecast_quantity-sold_quantity))*100/SUM(forecast_quantity) AS abs_err_pct
FROM fact_act_est s
WHERE s.fiscal_year=2021
GROUP BY s.customer_code)
SELECT 
*,
 (100-abs_err_pct) AS forecast_accuracy
 FROM forecast_err_table
 ORDER BY forecast_accuracy ASC;


WITH forecast_err_table AS (SELECT 
	*,
    SUM((forecast_quantity-sold_quantity)) AS net_err,
    SUM(abs(forecast_quantity-sold_quantity)) AS abs_err,
    SUM((forecast_quantity-sold_quantity))*100/SUM(forecast_quantity) AS net_err_pct,
    SUM(abs(forecast_quantity-sold_quantity))*100/SUM(forecast_quantity) AS abs_err_pct
FROM fact_act_est s
WHERE s.fiscal_year=2021
GROUP BY s.customer_code)
SELECT 
e.*,
c.customer,
 IF(abs_err_pct>100,0,100-abs_err_pct) AS forecast_accuracy
 FROM forecast_err_table e
 JOIN dim_customer c
 USING(customer_code)
 ORDER BY forecast_accuracy DESC;