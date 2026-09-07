#######USE CASES#################
# Use Case 1: Monthly Sales Trend
select date_format(o.order_date,'%Y-%m') as month,
sum(s.sales) as total_sales
from sales s
join orders o on s.order_id=o.order_id
group by date_format(o.order_date,'%Y-%m')
order by month
=========================================================================
# Use Case 2: Profit by Region
select c.region,sum(s.profit)as total_profit
from customers c
join orders o on c.customer_id=o.customer_id
join sales s on o.order_id=s.order_id
group by c.region order by total_profit desc
============================================================================
#Profit ranking by region
select * from(
select c.region,sum(s.profit)as total_profit,
rank() over (order by sum(s.sales) desc)as rnk from
customers c
join orders o on c.customer_id=o.customer_id
join sales s on s.order_id=o.order_id
group by c.region
)t
where rnk<=5
===============================================================================
with region_profit as(
select c.region,sum(s.profit) as total_profit
from customers c
join orders o on c.customer_id=o.customer_id
join sales s on o.order_id=s.order_id
group by c.region),
rank_region as(
select region,total_profit, 
rank() over (order by total_profit desc) as rnk
from region_profit)
select * from rank_region
where rnk<=5
==================================================================================
# Use Case 3: Category Performance
#Use Case 3: Category Performance
select p.category,sum(s.sales) as total_sales ,sum(s.profit) as total_profit
from sales s
join products p on s.product_id=p.product_id
group by p.category
=======================================================================================
#Use Case 4: High_Value Customers
select c.customer_id,c.customer_name,sum(s.sales) as total_sales
from customers c
join orders o on c.customer_id=o.customer_id
join sales s on o.order_id=s.order_id
group by c.customer_id,customer_name
order by sum(s.sales) desc 
limit 10

WITH customer_sales AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        SUM(s.sales) AS total_sales
    FROM customers c
    join orders o on c.customer_id=o.customer_id
    join sales s on o.order_id=s.order_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT *
FROM customer_sales
ORDER BY total_sales DESC
LIMIT 10;
==============================================================================
#Use Case 5: Loss-Making Products
with product_profit as(
select p.product_id,p.product_name,sum(s.profit) as total_profit
from products p
join sales s on p.product_id=s.product_id group by p.product_id,product_name)
select * from product_profit
where total_profit<0
order by total_profit
=================================================================================
#Use Case 6: Product Ranking by Category
with product_sales as
(
select p.category,p.product_id,
sum(s.sales) as total_sales from products p
join sales s on p.product_id=s.product_id
group by p.category,p.product_id),
rank_category as(
select * ,rank() over (order by total_sales desc) as rnk
from product_sales)
select * from rank_category where rnk<=5
==========================================================
WITH product_sales AS (
    SELECT
        p.category,
        p.product_name,
        SUM(s.sales) AS total_sales
    FROM products p
    join sales s on p.product_id=s.product_id
    GROUP BY p.category,p.product_name
),
ranked_products AS (
    SELECT *,
           RANK() OVER (
               
               ORDER BY total_sales DESC
           ) AS rnk
    FROM product_sales
)
SELECT *
FROM ranked_products
WHERE rnk <= 3;
========================================================================
#Use Case 7: Discount Impact Analysis
#Pricing strategy changes
#Discount caps
select discount,sum(sales) as total_sales,
sum(profit) as total_profit from sales group by discount
order by discount
========================================================================
#Use Case 8: Shipping Delay Analysis
select ship_mode,avg(datediff(ship_date,order_date)) as avg_shipping_days
from orders
group by ship_mode
==========================================================================
# Use Case 9: Customers With Above-Average Discount
with customer_discount as
(
select o.customer_id,avg(s.discount) as avg_discount
from orders o
join sales s on o.order_id=s.order_id
group by o.customer_id),

overall_avg_dis as
(
select 
avg(avg_discount) as avg_disc
from customer_discount)
select * from customer_discount 
where avg_discount>(select  avg_disc from overall_avg_dis)
=========================================================================================
#Use Case 10: Running Sales Total (Trend KPI)
with monthly_sales as
(
select date_format(o.order_date,'%Y-%m') as month,
sum(s.sales) as total_sales
from orders o
join sales s on o.order_id=s.order_id
group by date_format(o.order_date,'%Y-%m'))

select month,total_sales,sum(total_sales) over (order by month) as total_running_sales
from monthly_sales

