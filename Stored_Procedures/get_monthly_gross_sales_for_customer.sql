CREATE DEFINER=`root`@`localhost` PROCEDURE `get_monthly_gross_sales_for_customer`(
	in_customer_codes TEXT

)
BEGIN
	SELECT
	s.date,
		SUM(ROUND(g.gross_price*s.sold_quantity,2)) AS monthly_sales					#we should write sum before grouping becase only group chooses random value not total sum
	FROM fact_sales_monthly s
	JOIN fact_gross_price g
	ON 
		g.product_code=s.product_code AND
    g.fiscal_year=get_fiscal_year(s.date)
	WHERE
		FIND_IN_SET(s.customer_code,in_customer_codes)>0
	GROUP BY date;
END