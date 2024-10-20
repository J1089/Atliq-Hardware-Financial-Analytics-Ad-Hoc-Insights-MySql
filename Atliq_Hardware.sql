use gdb0041;

set autocommit = 0;
set SQL_SAFE_UPDATES = 0;
SET sql_mode='';
 
SELECT * FROM dim_customer;
select distinct market from dim_customer;
select distinct channel from dim_customer;
select distinct region from dim_customer;

SELECT * FROM dim_product;

select distinct division from dim_product;
select distinct segment from dim_product;
select distinct category from dim_product;

-- division -> segment -> category -> product -> variant

SELECT * FROM fact_gross_price;
select * from dim_product where product_code='A0118150101';

-- Month
-- Product Name
-- Variant
-- Sold Quantity
-- Gross Price Per Item
-- Gross Price Total

select * from dim_customer
where customer like "%croma%";

select * from fact_sales_monthly
where customer_code=90002002;

select * from fact_sales_monthly
where customer_code=90002002 and 
year(date_add(date,interval 4 month))=2021
order by date desc;

-- User Defined Functions
-- Fiscal year
select * from fact_sales_monthly
where customer_code=90002002 and
get_fiscal_year(date)=2021
order by date asc;


-- Quarter
-- 9,10,11 --> Q1
-- 12,1,2 --> Q2
-- 3,4,5 --> Q3
-- 6,7,8 --> Q4

-- Fiscal Quarter
select * from fact_sales_monthly
where customer_code=90002002 and
get_fiscal_year(date)=2021 and 
get_fiscal_quarter(date)="Q4"
order by date asc
limit 1000000;



-- Gross Sales Report:Monthly Product Transactions
select * from fact_sales_monthly;
select * from dim_product;

select s.date,s.product_code,s.sold_quantity,p.product_code,p.product,
p.variant,s.sold_quantity
from fact_sales_monthly s 
join dim_product p 
on p.product_code = s.product_code
where
customer_code = 90002002 and
get_fiscal_year(date)=2021
order by date asc
limit 1000000; 

-- Gross Price Per Item

select s.date,s.product_code,p.product,p.variant,s.sold_quantity,g.gross_price
from fact_sales_monthly s 
join dim_product p 
on p.product_code = s.product_code
join fact_gross_price g 
on g.product_code = s.product_code and 
g.fiscal_year = get_fiscal_year(s.date)
where 
customer_code = 90002002 and 
get_fiscal_year(date) = 2021
order by date asc
limit 1000000;

-- Gross Price Total
select s.date,s.product_code,p.product,p.variant,s.sold_quantity,g.gross_price,
ROUND(g.gross_price*s.sold_quantity,2) as gross_price_total
from fact_sales_monthly s 
join dim_product p 
on p.product_code = s.product_code
join fact_gross_price g 
on g.product_code = s.product_code and 
g.fiscal_year = get_fiscal_year(s.date)
where 
customer_code = 90002002 and 
get_fiscal_year(date) = 2021
order by date asc
limit 1000000;

-- Gross Sales Report:Total Sales Amount
select * from dim_customer
where customer_code = 90002002;
select * from fact_sales_monthly;
select * from fact_gross_price;

select s.date,
round(sum(g.gross_price*s.sold_quantity),2)as gross_price_total
from fact_sales_monthly s 
join fact_gross_price g 
on 
g.product_code=s.product_code and
g.fiscal_year = get_fiscal_year(s.date)
where customer_code=90002002
group by s.date
order by s.date asc;

-- Exercise
-- 1) Generate a yearly report for Croma India where there are two columns
-- 1. Fiscal Year
-- 2. Total Gross Sales amount In that year from Croma
select 
get_fiscal_year(date) as fiscal_year,
sum(round(sold_quantity*g.gross_price,2)) as yearly_sales
from fact_sales_monthly s
join fact_gross_price g 
on
g.fiscal_year=get_fiscal_year(s.date) and
g.product_code = s.product_code
where
customer_code = 90002002
group by get_fiscal_year(date)
order by fiscal_year;

-- Stored Procedure : Monthly Gross Sales Report

select * from dim_customer
where customer like "%amazon%" and market="India"; 


-- Stored Procedure : Market Badge
-- India, 2021 --> Gold
-- Srilanka, 2020 --> Silver

select * from fact_sales_monthly;
select * from dim_customer ;


select * from fact_sales_monthly s 
join dim_customer c
on s.customer_code = c.customer_code
where get_fiscal_year(s.date)=2021;

select 
c.market,sum(sold_quantity) as total_qty 
from fact_sales_monthly s 
join dim_customer c 
on s.customer_code = c.customer_code
where get_fiscal_year(s.date) = 2021 and c.market="India"
group by c.market;

-- Problem Statement and Pre-Invoice Discount Report
select * from fact_pre_invoice_deductions;
desc fact_pre_invoice_deductions;
select * from dim_date;

### Module: Problem Statement and Pre-Invoice Discount Report

-- Include pre-invoice deductions in Croma detailed report
SELECT 
    	   s.date, 
           s.product_code, 
           p.product, 
		   p.variant, 
           s.sold_quantity, 
           g.gross_price as gross_price_per_item,
           ROUND(s.sold_quantity*g.gross_price,2) as gross_price_total,
           pre.pre_invoice_discount_pct
FROM fact_sales_monthly s
JOIN dim_product p
	ON s.product_code=p.product_code
JOIN fact_gross_price g
	ON g.fiscal_year=get_fiscal_year(s.date)
	AND g.product_code=s.product_code
	JOIN fact_pre_invoice_deductions as pre
		ON pre.customer_code = s.customer_code AND
	pre.fiscal_year=get_fiscal_year(s.date)
WHERE 
	s.customer_code=90002002 AND 
    	    get_fiscal_year(s.date)=2021     
	LIMIT 1000000;

-- Same report but all the customers
	SELECT 
    	   s.date, 
           s.product_code, 
           p.product, 
	   p.variant, 
           s.sold_quantity, 
           g.gross_price as gross_price_per_item,
           ROUND(s.sold_quantity*g.gross_price,2) as gross_price_total,
           pre.pre_invoice_discount_pct
	FROM fact_sales_monthly s
	JOIN dim_product p
            ON s.product_code=p.product_code
	JOIN fact_gross_price g
    	    ON g.fiscal_year=get_fiscal_year(s.date)
    	    AND g.product_code=s.product_code
	JOIN fact_pre_invoice_deductions as pre
            ON pre.customer_code = s.customer_code AND
            pre.fiscal_year=get_fiscal_year(s.date)
	WHERE 
    	    get_fiscal_year(s.date)=2021     
	LIMIT 1000000;
    
    
-- Performance Improvement 1

select s.date,s.product_code,p.product,p.variant,s.sold_quantity,
g.gross_price as gross_price_per_item,
ROUND(s.sold_quantity*g.gross_price,2) as gross_price_total,
pre.pre_invoice_discount_pct
from fact_sales_monthly s 
join dim_product p 
on s.product_code = p.product_code
join dim_date dt
on dt.calendar_date = s.date
join fact_gross_price g
on g.fiscal_year=dt.fiscal_year
and g.product_code = s.product_code
join fact_pre_invoice_deductions pre
on 
	pre.customer_code=s.customer_code and 
    pre.fiscal_year=dt.fiscal_year
where
	get_fiscal_year(s.date)=2021
limit 1000000;

-- Performance Improvement 2
select s.date,s.product_code,p.product,p.variant,s.sold_quantity,
g.gross_price as gross_price_per_item,
ROUND(s.sold_quantity*g.gross_price,2) as gross_price_total,
pre.pre_invoice_discount_pct
from fact_sales_monthly s 
join dim_product p 
on s.product_code = p.product_code
join fact_gross_price g
on g.fiscal_year=s.fiscal_year
and g.product_code = s.product_code
join fact_pre_invoice_deductions pre
on 
	pre.customer_code=s.customer_code and 
    pre.fiscal_year=s.fiscal_year
where
	s.fiscal_year=2021
limit 1000000;

-- Database Views : Introduction
-- Calculate net invest sales

-- Views
select *,
(gross_price_total - gross_price_total * pre_invoice_discount_pct) as net_invest_sales 
from sales_preinv_discount;


-- Post Invoice Discount,Net Sales
select 
     *,
     (1-pre_invoice_discount_pct)*gross_price_total as net_invoice_sales,
     (po.discounts_pct+po.other_deductions_pct) as post_invoice_discount_pct
from sales_preinv_discount s 
join fact_post_invoice_deductions po 
on 
s.date=po.date and
s.product_code=po.product_code and
s.customer_code=po.customer_code;
-------------------------------------------------------------------------------
-- sales pre invoice discount
SELECT 
    	    s.date, 
            s.fiscal_year,
            s.customer_code,
            c.market,
            s.product_code, 
            p.product, 
            p.variant, 
            s.sold_quantity, 
            g.gross_price as gross_price_per_item,
            ROUND(s.sold_quantity*g.gross_price,2) as gross_price_total,
            pre.pre_invoice_discount_pct
	FROM fact_sales_monthly s
	JOIN dim_customer c 
		ON s.customer_code = c.customer_code
	JOIN dim_product p
        	ON s.product_code=p.product_code
	JOIN fact_gross_price g
    		ON g.fiscal_year=s.fiscal_year
    		AND g.product_code=s.product_code
	JOIN fact_pre_invoice_deductions as pre
        	ON pre.customer_code = s.customer_code AND
    		pre.fiscal_year=s.fiscal_year;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- sales post invoice discount
SELECT 
    	    s.date, s.fiscal_year,
            s.customer_code, s.market,
            s.product_code, s.product, s.variant,
            s.sold_quantity, s.gross_price_total,
            s.pre_invoice_discount_pct,
            (s.gross_price_total-s.pre_invoice_discount_pct*s.gross_price_total) as net_invoice_sales,
            (po.discounts_pct+po.other_deductions_pct) as post_invoice_discount_pct
	FROM sales_preinv_discount s
	JOIN fact_post_invoice_deductions po
		ON po.customer_code = s.customer_code AND
   		po.product_code = s.product_code AND
   		po.date = s.date;

-------------------------------------------------------------------------------
-- Create view on gross sales
CREATE  VIEW gross_sales AS
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
    
    
select * from gross_sales;


-- Final net sales
select 
     *,
     (1-post_invoice_discount_pct)*net_invoice_sales as net_sales
     from sales_postinv_discount;
----------------------------------------------------------------------------------
-- Top Markets And Customers
select 
	market,
    round(sum(net_sales)/1000000,2) as net_sales_mln
from net_sales
where fiscal_year=2021
group by market
order by net_sales_mln desc
limit 5;


-- Top customers
select
    c.customer,
    round(sum(net_sales)/1000000,2) as net_sales_mln
    from net_sales n 
    join dim_customer c 
    on n.customer_code=c.customer_code
    where fiscal_year=2021
    group by c.customer
    order by net_sales_mln desc 
    limit 5;
    
-- Top Products
select
product_code,
round(sum(net_sales)/1000000,2) as net_sales_mln
from net_sales
where fiscal_year=2021
group by product_code
order by net_sales_mln desc
limit 5;    

-- Window function Using it in a task
select 
customer,
round(sum(net_sales)/1000000,2) as net_sales_mln
from net_sales s 
join dim_customer c 
on s.customer_code = c.customer_code
where s.fiscal_year=2021 
group by customer
order by net_sales_mln desc;

----------------------------------------------------------------
with cte1 as(
select 
customer,
round(sum(net_sales)/1000000,2) as net_sales_mln
from net_sales s 
join dim_customer c 
on s.customer_code = c.customer_code
where s.fiscal_year=2021 
group by customer)
select *,
		net_sales_mln*100/sum(net_sales_mln) over() as pct
from cte1
order by net_sales_mln desc;



-- Exercise : Window function OVER clause
with cte1 as(
select c.region,c.customer,round(sum(n.net_sales)/1000000,2) as net_sales_mln from net_sales n
join dim_customer c on c.customer_code = n.customer_code 
where fiscal_year = 2021
group by c.region,c.customer)
select 
    *,
    net_sales_mln*100/sum(net_sales_mln) over (partition by region) as pct_share_region
    from cte1
order by net_sales_mln desc;

-- Windows function : Row number,Rank,Dense Rank
with cte1 as(
select 
p.division,
p.product,
sum(sold_quantity) as total_qty
from fact_sales_monthly s 
join dim_product p
on p.product_code = s.product_code
where fiscal_year=2021
group by p.product),
cte2 as(
select 
     *,
     dense_rank() over (partition by division order by total_qty desc) as drnk
     from cte1)
select * from cte2 where drnk<=3;

-- Exercise: Retrieve the top 2 markets in every region 
-- by their gross sales amount in FY=2021.
 with cte1 as (
		select
			c.market,
			c.region,
			round(sum(gross_price_total)/1000000,2) as gross_sales_mln
			from gross_sales s
			join dim_customer c
			on c.customer_code=s.customer_code
			where fiscal_year=2021
			group by market
			order by gross_sales_mln desc
		),
		cte2 as (
			select *,
			dense_rank() over(partition by region order by gross_sales_mln desc) as drnk
			from cte1
		)
	select * from cte2 where drnk<=2;
    
--------------------------------------------------------------------------------------------
-- Supply Chain Domain
 select * from fact_sales_monthly;
 select * from fact_forecast_monthly;
create table fact_act_est
( 
select 
    s.date as date,
    s.fiscal_year as fiscal_year,
    s.product_code as product_code,
    s.customer_code as customer_code,
    s.sold_quantity as sold_quantity,
    f.forecast_quantity as forecast_quantity
    from 
    fact_sales_monthly s 
left join fact_forecast_monthly f 
using(date,customer_code,product_code)
union
 select 
    f.date as date,
    f.fiscal_year as fiscal_year,
    f.product_code as product_code,
    f.customer_code as customer_code,
    s.sold_quantity as sold_quantity,
    f.forecast_quantity as forecast_quantity
    from 
    fact_forecast_monthly f 
left join fact_sales_monthly s  
using(date,customer_code,product_code));   
 
 
update fact_act_est
set sold_quantity = 0
where sold_quantity is null;
 
update fact_act_est
set forecast_quantity = 0
where forecast_quantity is null;



-- Triggers
show triggers;

insert into fact_sales_monthly
       (date,product_code,customer_code,sold_quantity)
values("2030-09-01","HAWUP", 99 ,89);   
select * from fact_sales_monthly where customer_code=99;
select * from fact_act_est where customer_code=99;

insert into fact_forecast_monthly
       (date,product_code,customer_code,forecast_quantity)
values("2030-09-01","HAWUP", 99 ,120);  
select * from fact_act_est where customer_code=99;

-- Temporary tables and forecast accuracy report
WITH forecast_err_table AS (
    SELECT
        s.customer_code AS customer_code,
        c.customer AS customer_name,
        c.market AS market,
        SUM(s.sold_quantity) AS total_sold_qty,
        SUM(s.forecast_quantity) AS total_forecast_qty,
        SUM(CAST(s.forecast_quantity AS SIGNED) - CAST(s.sold_quantity AS SIGNED)) AS net_error,
        ROUND(SUM(CAST(s.forecast_quantity AS SIGNED) - CAST(s.sold_quantity AS SIGNED)) * 100 / NULLIF(SUM(s.forecast_quantity), 0), 1) AS net_error_pct,
        SUM(ABS(CAST(s.forecast_quantity AS SIGNED) - CAST(s.sold_quantity AS SIGNED))) AS abs_error,
        ROUND(SUM(ABS(CAST(s.forecast_quantity AS SIGNED) - CAST(s.sold_quantity AS SIGNED))) * 100 / NULLIF(SUM(s.forecast_quantity), 0), 2) AS abs_error_pct
    FROM fact_act_est s
    JOIN dim_customer c ON s.customer_code = c.customer_code
    WHERE s.fiscal_year = 2021
    GROUP BY s.customer_code, c.customer, c.market
)
SELECT
    *,
    CASE 
        WHEN abs_error_pct > 100 THEN 0 
        ELSE 100.0 - abs_error_pct 
    END AS forecast_accuracy
FROM forecast_err_table
ORDER BY forecast_accuracy DESC;


-- Exercise --
-- 2021
drop table if exists forecast_accuracy_2021;
create temporary table forecast_accuracy_2021
with forecast_err_table as (
        select
                s.customer_code as customer_code,
                c.customer as customer_name,
                c.market as market,
                sum(s.sold_quantity) as total_sold_qty,
                sum(s.forecast_quantity) as total_forecast_qty,
                sum(s.forecast_quantity-s.sold_quantity) as net_error,
                round(sum(s.forecast_quantity-s.sold_quantity)*100/sum(s.forecast_quantity),1) as net_error_pct,
                sum(abs(s.forecast_quantity-s.sold_quantity)) as abs_error,
                round(sum(abs(s.forecast_quantity-sold_quantity))*100/sum(s.forecast_quantity),2) as abs_error_pct
        from fact_act_est s
        join dim_customer c
        on s.customer_code = c.customer_code
        where s.fiscal_year=2021
        group by customer_code
)
select 
        *,
    if (abs_error_pct > 100, 0, 100.0 - abs_error_pct) as forecast_accuracy
from 
	forecast_err_table
order by forecast_accuracy desc;

-- 2020
drop table if exists forecast_accuracy_2020;
create temporary table forecast_accuracy_2020
with forecast_err_table as (
        select
                s.customer_code as customer_code,
                c.customer as customer_name,
                c.market as market,
                sum(s.sold_quantity) as total_sold_qty,
                sum(s.forecast_quantity) as total_forecast_qty,
                sum(s.forecast_quantity-s.sold_quantity) as net_error,
                round(sum(s.forecast_quantity-s.sold_quantity)*100/sum(s.forecast_quantity),1) as net_error_pct,
                sum(abs(s.forecast_quantity-s.sold_quantity)) as abs_error,
                round(sum(abs(s.forecast_quantity-sold_quantity))*100/sum(s.forecast_quantity),2) as abs_error_pct
        from fact_act_est s
        join dim_customer c
        on s.customer_code = c.customer_code
        where s.fiscal_year=2020
        group by customer_code
)
select 
        *,
    if (abs_error_pct > 100, 0, 100.0 - abs_error_pct) as forecast_accuracy
from 
	forecast_err_table
order by forecast_accuracy desc;

-- Step 3
select 
	f_2020.customer_code,
	f_2020.customer_name,
	f_2020.market,
	f_2020.forecast_accuracy as forecast_acc_2020,
	f_2021.forecast_accuracy as forecast_acc_2021
from forecast_accuracy_2020 f_2020
join forecast_accuracy_2021 f_2021
on f_2020.customer_code = f_2021.customer_code 
where f_2021.forecast_accuracy < f_2020.forecast_accuracy
order by forecast_acc_2020 desc;

---------------------------------------------------------------------------------