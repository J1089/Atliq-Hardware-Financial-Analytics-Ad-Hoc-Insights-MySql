CREATE DEFINER=`root`@`localhost` FUNCTION `get_fiscal_year`(
	calendar_date date
) RETURNS int
    DETERMINISTIC
BEGIN
	declare fiscal_year int;
    set fiscal_year = year(date_add(calendar_date,interval 4 month));
	return fiscal_year;
END