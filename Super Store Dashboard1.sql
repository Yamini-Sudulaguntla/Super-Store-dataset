CREATE DATABASE superstore_db
USE superstore_db
SELECT DATABASE()
CREATE TABLE superstore_raw (
    row_id INT,
    order_id VARCHAR(50),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(50),
    customer_id VARCHAR(50),
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    product_id VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(150),
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(5,2),
    profit DECIMAL(10,2)
);
DROP TABLE IF EXISTS superstore_raw;
SET GLOBAL local_infile = 1;
CREATE TABLE superstore_raw (
    row_id VARCHAR(50),
    order_id VARCHAR(50),
    order_date VARCHAR(50),
    ship_date VARCHAR(50),
    ship_mode VARCHAR(50),
    customer_id VARCHAR(50),
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    product_id VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(150),
    sales VARCHAR(50),
    quantity VARCHAR(50),
    discount VARCHAR(50),
    profit VARCHAR(50)
);

LOAD DATA LOCAL INFILE 'C:/Users/Sudulaguntla.Yamini/Downloads/samplesuperstore.csv'
INTO TABLE superstore_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
select count(*) from superstore_raw
select * from superstore_raw
limit 5




-- Check NULLs
SELECT
    SUM(order_id IS NULL) AS null_orders,
    SUM(customer_id IS NULL) AS null_customers,
    SUM(product_id IS NULL) AS null_products
FROM superstore_raw;

-- Check duplicates
select order_id,product_id,count(*)
from superstore_raw
group by order_id,product_id 
having count(*)>1

# CREATING CUSTOMER TABLE
create table customers
(customer_id varchar(50) primary key,customer_name varchar(1000),

segment VARCHAR(50),
    country VARCHAR(50),
    region VARCHAR(50),
    state VARCHAR(50),
    city VARCHAR(50),
    postal_code VARCHAR(20)
);

#INSERTING DATA INTO CUSTOMER TABLE
#This query deduplicates customer data by grouping raw transactional records into a single customer record per customer_id
# and inserts that clean data into the customers table.
INSERT INTO customers
SELECT
    customer_id,
    MAX(customer_name) AS customer_name,
    MAX(segment) AS segment,
    MAX(country) AS country,
    MAX(region) AS region,
    MAX(state) AS state,
    MAX(city) AS city,
    MAX(postal_code) AS postal_code
FROM superstore_raw
GROUP BY customer_id;
select customer_id,count(*) from customers
group by customer_id
having count(*)>1
select * from customers
# Creating products tables
CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(150),
    category VARCHAR(50),
    sub_category VARCHAR(50)
);
#inserting data into producta
INSERT INTO products
SELECT
    product_id,
    MAX(product_name) AS product_name,
    MAX(category) AS category,
    MAX(sub_category) AS sub_category
FROM superstore_raw
GROUP BY product_id;
#Creating orders table
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(50),
    customer_id VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

#Insert data into the table
insert into orders
select order_id,

STR_TO_DATE(MAX(order_date), '%m/%d/%Y') AS order_date,
    STR_TO_DATE(MAX(ship_date), '%m/%d/%Y') AS ship_date,
    MAX(ship_mode) AS ship_mode,
    MAX(customer_id) AS customer_id
FROM superstore_raw
GROUP BY order_id;

# Creating sales table
CREATE TABLE sales (
    row_id INT PRIMARY KEY,
    order_id VARCHAR(50),
    product_id VARCHAR(50),
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(5,2),
    profit DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
select * from sales
select  c.customer_id,sum(s.sales) as total_sales from customers c
join orders o on c.customer_id=o.customer_id
join sales s on o.order_id=s.order_id
group by c.customer_id
having sum(s.sales)>500

select p.product_id,p.product_name,count(p.product_id) as quantity_sold,sum(s.sales) as total_sales from products p
join sales s on p.product_id=s.product_id
group by p.product_id
limit 10 
select * from(
select p.product_name,p.product_id,sum(s.sales)as total_sales,sum(s.profit) as total_profit,
rank() over(order by sum(s.sales) ) as rnk
from sales s
join products p on p.product_id=s.product_id
group by p.product_name,p.product_id)t
where total_profit < 0




#Table data types control how data is stored, not how it is read from the SELECT.
#CAST controls how data is interpreted and inserted from the source.
'''We use CAST heavily in fact tables like sales 
because numeric columns directly affect aggregations and KPIs.
 Dimension tables like customers and orders 
 mainly contain descriptive attributes that are already in the correct format,
 don’t undergo mathematical operations, and therefore don’t require explicit casting.'''
# inserting the data into the table
INSERT INTO sales
SELECT
    CAST(row_id AS UNSIGNED),
    order_id,
    product_id,
    CAST(sales AS DECIMAL(10,2)),
    CAST(quantity AS UNSIGNED),
    CAST(discount AS DECIMAL(5,2)),
    CAST(profit AS DECIMAL(10,2))
FROM superstore_raw;



SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM sales;

select count(*) from customers
group by customer_id
having count(*)>1

select count(*) from orders
group by order_id
having count(*)>1

select count(*) from sales
group by row_id
having count(*)>1
# SQL QUERIES

select * from  customers where segment='consumer'
select segment,count(*) from customers
group by segment


select * from orders
where year(order_date)='2023'

select * from sales where discount='0.2'

select sum(sales) as total_sales from sales
select count(*) from orders

select avg(sales) as Average_sales from sales
#Total sales by category.
select p.category,sum(s.sales) as total_sales
from sales s
join products p on s.product_id=p.product_id
group by p.category
order by total_sales desc


#Joining a dimension to a fact table via a bridge table
#When two tables are not directly related, we join them through a common table — this is called an indirect or multitable join.
#Customers with total sales greater than 10,000.
select o.customer_id,sum(s.sales) as total_sales
from orders o # customers c
join sales s on o.order_id=s.order_id
#join orders o on c.customer_id=o.customer_id
#join sales s on o.order_id=s.order_id
group by customer_id
having sum(sales)>10000
select c.customer_name,c.customer_id,sum(s.sales) as total_sales
from customers c
join orders o on c.customer_id=o.customer_id
join sales s on s.order_id=o.order_id
group by c.customer_id,c.customer_name
having total_sales>10000
======================================================================================================

#Number of orders per customer.
select customer_id,count(order_id) as order_count from orders
group by customer_id
=======================================================================================================
# Customer name and total sales.
select c.customer_name ,sum(s.sales) as total_sales from customers c join orders o
on c.customer_id=o.customer_id
join sales s on o.order_id=s.order_id
group by customer_name
=========================================================================================================
# Product name and total quantity sold
select p.product_name,sum(s.quantity) as total_quantity
from sales s
join products p on s.product_id=p.product_id
group by product_name
========================================================================================================

select p.product_name,sum(s.quantity) as total_quantity
from products p
left join sales s on p.product_id=s.product_id
group by product_name
==================================================================================================================

#Categorize sales as High / Medium / Low.
select sales ,
	case 
    when sales >=500 then 'High'
    when sales>=300 then 'Medium'
    else 'low'
    end as sales_category
from sales
=============================================================
# Classify customers based on total spending
select customer_id ,sum(sales) as total_spend,
	case
    when sum(sales)>=20000 then'Premimum'
    when sum(sales)>10000 then'Gold'
    else 'Regular'
    end as custo_type
from sales s
join orders o on s.order_id =o.order_id
group by customer_id
==========================================================================================


######SUBQUERIES############
#Customers whose total sales are above average
select customer_id,sum(sales) as total_sales
from sales s
join orders o on s.order_id=o.order_id
group by customer_id
having sum(sales)>(select avg(sales) from sales)
========================================================================================

#ROW_NUMBER()
#Latest order for each customer.
select * from
( select o.*,
row_number() over (partition by customer_id order by order_id desc)rn
from orders o)t
having rn=1
======================================================================
#RANK & DENSE_RANK
select customer_id ,sum(sales) as total_spent,
rank() over(order by sum(sales) desc)rnk
from sales s
join orders o on s.order_id=o.order_id
group by customer_id
=========================================================================
# Top 3 customers by sales
select * from
(select customer_id ,sum(sales) as total_sales,
dense_rank() over (order by sum(sales)  desc)rnk
from sales s
join orders o on s.order_id=o.order_id group by customer_id)t
where rnk<=3

SELECT *
FROM (
    SELECT customer_id,
           SUM(sales) AS total_sales,
           DENSE_RANK() OVER (ORDER BY SUM(sales) DESC) rnk
    FROM sales s
    JOIN orders o ON s.order_id = o.order_id
    GROUP BY customer_id
) t
WHERE rnk <= 3;
==========================================================================================
#WINDOW FUNCTIONS (ADVANCED )
#Running total of sales by order date.
select order_date,
sum(sales) as daily_sales,
sum(sum(sales)) over (order by order_date) as running_sales
from sales s
join orders o on s.order_id=o.order_id
group by order_date

SELECT order_date,
       SUM(sales) AS daily_sales,
       SUM(SUM(sales)) OVER (ORDER BY order_date) AS running_total
FROM sales s
JOIN orders o ON s.order_id = o.order_id
GROUP BY order_date;
Window functions are often combined with business logic functions'''
========================================================================================================
# Rank each order within a customer’s history
select customer_id,order_id,order_date,
row_number() over(partition by customer_id order by order_date)rn
from orders
===============================================================================================
#Find customers who placed two orders within 7 days
select DISTINCT customer_id,gap_days from(
select customer_id,order_date,
datediff(order_date,lag (order_date) over(partition by customer_id order by order_date)) as gap_days
from orders)t
where gap_days<=7

SELECT DISTINCT customer_id,order_date,gap_days
FROM (
    SELECT customer_id,
           order_date,
           DATEDIFF(
               order_date,
               LAG(order_date) OVER (
                   PARTITION BY customer_id
                   ORDER BY order_date
               )
           ) AS gap_days
    FROM orders
) t
WHERE gap_days <= 7;
'''Part  Why 
needed LAG(order_date) Access previous order
PARTITION BY customer_id Compare orders per customer
ORDER BY order_date Define previous order
DATEDIFF Calculate gap
Outer queryFilter window results
DISTINCT
Avoid duplicate customers'''
=======================================================================================================

#CTE( common table Expressions)
#Total Sales per Category

WITH category_sales AS (
    SELECT p.category,
           SUM(s.sales) AS total_sales
    FROM sales s
    join products p on s.product_id=p.product_id
    GROUP BY category
)
SELECT *
FROM category_sales;
============================================================
# Monthly Sales Trend
with month_sales as(
select date_format(o.order_date,'%Y-%m')as month,
sum(s.sales) as total_sales
from sales s
join orders o on s.order_id=o.order_id
group by date_format(o.order_date, '%Y-%m'))
select * from month_sales
ORDER BY month;


======================================================================================
with customer_sales as
(
select o.customer_id,sum(s.sales) as total_sales
from sales s
join orders o on s.order_id=o.order_id
group by o.customer_id),
Avg_sales as(
select avg(total_sales) as average_sales from customer_sales
)
select * from customer_sales
where total_sales >(select average_sales from  Avg_sales)
====================================================================================
#Top 5 Products by Sales
with product_sales as(
select p.product_id,p.product_name,sum(s.sales) as total_sales
from sales s
join products p on s.product_id=p.product_id
group by p.product_id,p.product_name),
ranked as(
select * ,
rank() over(order by total_sales desc)as rnk
from product_sales)
select * from ranked where rnk<=5
================================================================================
# Region‑wise Profit
with region_profit as
( select c.region,sum(s.profit) as total_profit from customers c
join orders o on c.customer_id=o.customer_id
join sales s on s.order_id=o.order_id group by c.region),
rank_region as(
select * ,
rank() over(order by total_profit desc)as rnk
from region_profit)
select * from rank_region
====================================================================================
# Best Selling Sub‑Category per Category
with subcategory_sales as(
select p.category,p.sub_category,sum(s.sales) as total_sales
from products p
join sales s on p.product_id=s.product_id
group by p.category,p.sub_category),
rank_category as(
select *,
rank() over( order by total_sales desc) as rnk
from subcategory_sales)
select * from rank_category 
where rnk<=3
=====================================================================================
# Loss_Making Products
with profit_loss as
(
select p.product_name,sum(s.profit) as total_profit
from products p 
join sales s on p.product_id=s.product_id
group by product_name)
select * from profit_loss
where total_profit<0

with loss_products as(
select product_id,sum(profit) as total_profit
from sales group by product_id),
rank_products as(
select *,
rank() over (order by total_profit )as rnk
from  loss_products )
select * from rank_products
where total_profit<0
============================================================================================
with customer_discount as
(
select o.customer_id,avg(s.discount) as  avg_discount from sales s
join orders o on s.order_id=o.order_id group by o.customer_id),
overall_avg_dis as
(select avg(avg_discount) as overall_avg from customer_discount)
select * from customer_discount where avg_discount>(select overall_avg from overall_avg_dis)
===================================================================================================
WITH loss_products AS (
    SELECT 
        product_id,
        SUM(profit) AS total_profit
    FROM sales
    GROUP BY product_id
),
rank_products AS (
    SELECT 
        product_id,
        total_profit,
        RANK() OVER (ORDER BY total_profit) AS rnk
    FROM loss_products
)
SELECT *
FROM rank_products
WHERE total_profit < 0;
select c.customer_name,sum(o.total_amout) as total_sales
from customers c
join orders o on c.customer_id=o.customer_id
group by customer_name

select customer_id,count(order_id) as order_count
from orders
group by customer_id 
having count(order_id)>1

select c.country, sum(o.total_amout) as total_sales
from customers c
join orders o on c.customer_id=o.customer_id
group by c.country


select p.product_name
from products p
left join order_items oi on p.product_id=oi.product_id
where oi.order_id is null


select order_id,count(DISTINCT product_id) as product_count from order_items
group by order_id
having count(DISTINCT product_id)>1

select c.customer_name,sum(o.total_amout) as amount_spent
select c.customer_name,sum(o.total_amout) as amount_spent,
    case
        when sum(o.total_amout)>= 1000000 then 'Premimum'
        when sum(o.total_amout)>=50000 then 'gold'
        else 'Silver'
        end as segment
	from customers c
    join orders o on c.customer_id=o.customer_id
    group by c.customer_name
        
select order_id,total_amout,
case
when total_amout >= 50000 then 'High Value'
when total_amout >=3000 then 'Medium Value'
else 'Low Value'
end as order_segment
from orders
select c.customer_id, sum(o.order_id) as total_orders
from customers c
join orders o on c.customer_id=o.customer_id
group by c.customer_id
order by sum(o.order_id)
limit 1
select customer_id,sum(order_id) as total_orders(
rank() over (order by sum(total_orders) rnk) from
orders
group by customer_id


select customer_id, total_spent
from(
select customer_id,sum(total_amout) as total_spent,
rank() over(order by sum(total_amout) )as rnk
from orders
group by customer_id)t
where rnk=1

select customer_id,sum(total_amout) as total_spent,
rank() over(order by sum(total_amout) )as rnk
from orders
group by customer_id



SELECT customer_id,
       total_spent
FROM (
    SELECT customer_id,
           SUM(total_amount) AS total_spent,
           RANK() OVER (ORDER BY SUM(total_amount) DESC) AS rnk
    FROM orders
    GROUP BY customer_id
) t
WHERE rnk = 1;


select c.customer_id,avg(total_amout) as avgera_sales
from customer c
join order
select customer_id,sum(total_amout) as total_sales
from orders
group by customer_id 
having sum(total_amout)>
 (select AVG(total_amout) from orders)


select * from orders
where total_amout=(select max(total_amout) from orders)


select product_id,sum(quantity*price) as product_sales
from order_items
group by product_id
having sum(quantity*price)>(select avg(quantity*price) from order_items)
select * from(
	select * ,
	row_number() over (partition by customer_id order by order_date desc) as rn
	from orders
	)t
where rn=1

#Get the First order for each customer

select * from
(
	select *,
    row_number() over(partition by customer_id order by order_date) as rn
    from orders)t
where rn=1

#Q3. Remove duplicate orders (same customer & date)
select * from(
select * ,row_number() over( partition by customer_id,order_date order by order_id)rn
from orders)t
where rn=1
#SECTION 2: RANK vs DENSE_RANK (TOP‑N QUESTIONS 
#to print the first rank customer according to total spnet
select customer_id,total_spent from(
select customer_id,sum(total_amout)as total_spent,
rank() over(order by sum(total_amout) desc)rnk
from orders
group by customer_id)t
where rnk=1

# Q4. Rank customers by total spending
select customer_id,sum(total_amout) as total_spent,
rank() over(order by sum(total_amout)  desc)rnk
from orders
group by customer_id

# Get the top‑spending customer(s)
select customer_id,total_spent from(
select customer_id,sum(total_amout) as total_spent,
rank() over (order by sum(total_amout) desc)rnk
from orders
group by customer_id)t
where rnk=1

# Get top 2 customers by spending (no gaps)
select customer_id,total_spent from(
select customer_id,sum(total_amout) as total_spent,
dense_rank() over (order by sum(total_amout )desc)rnk
from orders
group by customer_id)t
where rnk<=2

#RANK & DENSE_RANK (TOP‑N PROBLEMS 🔥)

# Top customer in each country
select country,customer_name,total_spent from
( select c.country,c.customer_name,sum(o.total_amout) as total_spent,
rank() over (partition by c.country order by sum(o.total_amout) desc)rnk
from customers c
join orders o on c.customer_id=o.customer_id
group by c.country,c.customer_id)t
where rnk=1


#Top 2 products by revenue in each category
select category,product_name,revenue ,rnk from(
select p.category,p.product_name,sum(oi.quantity*oi.price) as revenue,
dense_rank() over (partition by p.category order by sum(oi.quantity*oi.price) desc)rnk
from products p
join order_items oi on p.product_id=oi.product_id
group by p.category,p.product_name)t
where rnk<=2

SELECT category, product_name, revenue
FROM (
    SELECT p.category,
           p.product_name,
           SUM(oi.quantity * oi.price) AS revenue,
           DENSE_RANK() OVER (
               PARTITION BY p.category
               ORDER BY SUM(oi.quantity * oi.price) DESC
           ) rnk
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.category, p.product_name
) t
WHERE rnk <= 2;
# SUBQUERIES
#Customers whose total spend is above average
SELECT customer_id,sum(total_amout) as total_spent
from orders
group by customer_id
having sum(total_amout)>(select avg(total_amout) from orders)

#Orders that are higher than the customer’s average order value
#This is a correlated subquery (VERY IMPORTANT)( it depends on outer query)
select * from orders  o where  (total_amout)>(select avg(total_amout) from orders  where customer_id=o.customer_id)


#Products with sales higher than average product sales
select product_id,sum(price* quantity) as product_sales
from order_items
group by product_id
having sum(price*quantity)>(select avg(price*quantity) from order_items)


#Customers who placed the highest single order
select * from orders
where total_amout=(select max(total_amout) from orders)

#Rank customers using a CTE
with customer_sales as
(select customer_id,sum(total_amout) as total_spent from orders group by customer_id)
select customer_id,total_spent,
rank() over (order by total_spent desc) rnk from customer_sales

# Top customer using CTE
with customer_sales as(
select customer_id,sum(total_amout) as total_spent
from orders group by customer_id
)
select * from 
(select * ,rank() over (order by total_spent desc)  rnk
from customer_sales)t
where rnk=1

WITH customer_sales AS (
    SELECT customer_id,
           SUM(total_amout) AS total_spent
    FROM orders
    GROUP BY customer_id
)
SELECT *
FROM (
    SELECT *,
           RANK() OVER (ORDER BY total_spent DESC) rnk
    FROM customer_sales
) t
WHERE rnk = 1;



