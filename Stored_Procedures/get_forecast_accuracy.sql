CREATE DEFINER=`root`@`localhost` PROCEDURE `get_forecast_accuracy`(
	in_fiscal_year INT
)
BEGIN
	WITH forecast_err_table AS (SELECT 
	s.customer_code,
    SUM((forecast_quantity-sold_quantity)) AS net_err,
    SUM(abs(forecast_quantity-sold_quantity)) AS abs_err,
    SUM((forecast_quantity-sold_quantity))*100/SUM(forecast_quantity) AS net_err_pct,
    SUM(abs(forecast_quantity-sold_quantity))*100/SUM(forecast_quantity) AS abs_err_pct
FROM fact_act_est s
WHERE s.fiscal_year=in_fiscal_year
GROUP BY s.customer_code)
SELECT 
e.*,
c.customer,
c.market,
 IF(abs_err_pct>100,0,100-abs_err_pct) AS forecast_accuracy
 FROM forecast_err_table e
 JOIN dim_customer c
 USING(customer_code)
 ORDER BY forecast_accuracy DESC;
END