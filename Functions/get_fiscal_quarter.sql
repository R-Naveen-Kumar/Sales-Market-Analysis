CREATE DEFINER=`root`@`localhost` FUNCTION `get_fiscal_quarter`(
		calender_date DATE
) RETURNS char(2) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
	DECLARE m TINYINT;
    DECLARE qtr CHAR(2);
    SET m = MONTH(calender_date);

	CASE
		WHEN m IN (9,10,11) THEN
			SET qtr="Q1";
		WHEN m IN (12,1,2) THEN
			SET qtr="Q2";
		WHEN m IN (3,4,5) THEN
			SET qtr="Q3";
		ELSE
			SET qtr="Q4";
    END CASE;
RETURN qtr;
END