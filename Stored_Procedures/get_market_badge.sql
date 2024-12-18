CREATE DEFINER=`root`@`localhost` PROCEDURE `get_market_badge`(
	IN in_market varchar(45),
    IN in_fiscal_year year,
    OUT out_badge varchar(45)
)
BEGIN
	DECLARE qty INT DEFAULT 0;
    #retrieve total qty for given market+fyear
	SELECT 
    SUM(sold_quantity) INTO qty
	FROM fact_sales_monthly s
	JOIN dim_customer c
	ON s.customer_code=c.customer_code
	WHERE get_fiscal_year(s.date)=in_fiscal_year AND 
    c.market=in_market
	GROUP BY c.market;
    
    #determine market badge
    
    IF qty > 5000000 THEN
		SET out_badge = "GOLD";
	ELSE 
		SET out_badge = "SILVER";
	END IF;
END