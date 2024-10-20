CREATE PROCEDURE `get_monthly_sales_for_customer` (
	c_code int
)
BEGIN
	select
		s.date,
			sum(round(s.sold_quantity*g.gross_price,2)) as monthly_sales
		from fact_sales_monthly s
        join fact_gross_price g
			on g.fiscal_year=get_fiscal_year(s.date)
		and g.product_code = s.product_code
        where 
			customer_code = c_code
		group by date;
END
