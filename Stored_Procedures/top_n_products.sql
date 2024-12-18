CREATE DEFINER=`root`@`localhost` PROCEDURE `get_top_n_products_per_division_by_qty_sold`(
	in_fiscal_year INT,
    in_top_n INT
)
BEGIN
	WITH cte1 AS (SELECT 
	p.division,
    p.product,
    SUM(sold_quantity) AS total_qty
FROM fact_sales_monthly s
JOIN dim_product p
ON p.product_code=s.product_code
WHERE fiscal_year=in_fiscal_year
GROUP BY p.product),
cte2 AS(SELECT *,
DENSE_RANK() OVER(PARTITION BY division ORDER BY total_qty DESC) AS drnk
FROM cte1)
SELECT * FROM cte2 WHERE drnk=in_top_n;

END