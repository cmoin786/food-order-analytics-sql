create database food_db;


create table customers (
customer_id varchar(20) primary key,
customer_name varchar(20),
age int,
gender varchar(20),
city varchar(20),
signup_date date

);


create table restaurants(

restaurant_id varchar(20) primary key,
restaurant_name varchar(30),
cuisine varchar(20),
city varchar(20),rating float
);


create table delivery_agents (
agent_id varchar(20) primary key,
agent_name varchar(20),
vehicle_type varchar(20),
joining_date date,
city varchar(20)
);


create table order_items(

order_item_id varchar(20),
order_id varchar(20),
item_name varchar(20),
category varchar(20),
quantity int,
price int,
foreign key  (order_id) REFERENCES orders(order_id)
);



create table orders (
order_id varchar(20) primary key,
customer_id varchar(20),
restaurant_id varchar(20),
agent_id varchar(20),
order_date date,
delivery_time_minutes int,
order_status varchar(20),
payment_method varchar(20),
total_amount int,
foreign key (customer_id) references customers(customer_id) ,
foreign key (restaurant_id) references restaurants(restaurant_id),
foreign key  (agent_id) references delivery_agents(agent_id)
);


copy customers
from 'C:\data analyst\sql\customers.csv'
DELIMITER ','
csv header;

copy restaurants
from 'C:\data analyst\sql\restaurants.csv'
delimiter ','
csv header;

copy delivery_agents
from 'C:\data analyst\sql\delivery_agents.csv'
delimiter ','
csv header;

copy orders
from 'C:\data analyst\sql\orders.csv'
delimiter ','
csv header;


copy order_items
from 'C:\data analyst\sql\order_items.csv'
delimiter ','
csv header;

select * from orders;



-- Show all customers.

select customer_id, customer_name from customers;


-- Show all restaurants in Delhi.

select restaurant_id, restaurant_name, city from restaurants where lower(city) = 'delhi';


-- Find all delivered orders.

select order_id, order_date, order_status from orders where lower(order_status) = 'delivered'; 


-- Show orders above 500 amount.

select order_id, order_date, total_amount from orders where total_amount >500;


-- Find customers whose age is greater than 24.

select customer_id, customer_name, age from customers WHERE  age > 24;

-- Show all UPI payments.

select order_id, order_date, payment_method from orders where lower(payment_method) = 'upi';


-- Find restaurants with rating above 4.3.

select restaurant_id, restaurant_name, rating from restaurants where rating > 4.3;

-- Count total customers.

select count(customer_id) total_customers from customers;


-- Count delivered orders.

select count(order_id) as total_order from orders where lower(order_status) = 'delivered';

-- Find average delivery time.

select round(avg(delivery_time_minutes)::numeric,2) as avg_delivery_time from orders;





-- Total revenue generated.

select sum(total_amount) as total_revenue from orders ;

-- Revenue city wise.

select city, sum(total_amount) as total_revenue from orders as o
join customers as c
on o.customer_id = c.customer_id
group by city
order by total_revenue desc;

-- Restaurant wise total sales.

select restaurant_name , sum(total_amount) as total_revenue from orders as o
join Restaurants as r 
on r.Restaurant_id = o.Restaurant_id
group by restaurant_name
order by total_revenue desc;


-- Find top 3 highest orders.

select order_id, total_amount from orders
order by total_amount desc
limit 3;

-- Find most used payment method.

select payment_method, count(order_id) as total_order from orders
group by payment_method
order by total_order desc
limit 1;


-- Average delivery time per restaurant.

select restaurant_name, round(avg(delivery_time_minutes)::numeric,2) as avg_dtp from orders as o
join restaurants as r
on r.restaurant_id = o.restaurant_id
group by restaurant_name;

-- Count cancelled orders.

select count(order_id) as total_order from orders where lower(order_status) = 'cancelled'  ;

-- Find customers with multiple orders.

select c.customer_id, customer_name, count(order_id) as total_order from orders as o
join customers as c
on o.customer_id = c.customer_id
group by c.customer_id, customer_name
having  count(order_id) > 1;


-- Find highest spending customer.

select c.customer_id, customer_name, sum(total_amount) as total_spending from orders as o
join customers as c
on c.customer_id = o.customer_id
group  by c.customer_id, customer_name
order by total_spending desc
limit 5;


-- Category wise sales.

select category, sum(total_amount) as total_sales from orders as o
join order_items as oi
on o.order_id = oi.order_id
group by category
order by total_sales desc;



-- Show customer name with order details.

select customer_name, order_id,order_date,delivery_time_minutes,order_status,payment_method,total_amount from orders as o 
join customers as c
on o.customer_id = c.customer_id;


-- Show restaurant name with total orders.

select restaurant_name, count(order_id) as total_order from orders as o
join restaurants as r
on r.restaurant_id = o.restaurant_id
group by restaurant_name
order by total_order desc;

-- Show delivery agent with delivered orders count.

select d.agent_id, agent_name, count(order_id) as total_order from orders as o
join delivery_agents as d
on o.agent_id = d.agent_id
group by d.agent_id, agent_name
order by total_order desc;


-- Show item names with restaurant names.

select item_name, restaurant_name from orders as o
join restaurants as r
on r.restaurant_id = o.restaurant_id
join order_items as oi
on oi.order_id = o.order_id;

-- Find city wise revenue with restaurant details.

select city, sum(total_amount) as revenue, r.restaurant_id,restaurant_name,cuisine,rating from orders as o
join restaurants as r
on o.restaurant_id = r.restaurant_id
group by city,r.restaurant_id,restaurant_name,cuisine,rating;


-- Show customer and payment method.

select c.customer_id, customer_name, payment_method from orders as o
join customers as c
on c.customer_id = o.customer_id;


-- Find restaurants with highest average order value.

select restaurant_name, round(avg(total_amount::numeric),2) as avg_order_value from orders as o
join restaurants as r
on r.restaurant_id = o.restaurant_id
group by restaurant_name
order by avg_order_value desc 
limit 3;

-- Show order items with customer names.

select item_name, customer_name from orders as o
join order_items as  oi 
on o.order_id = oi.order_id
join customers as c
on c.customer_id = o.customer_id;

-- Find agents delivering in multiple cities.

select d.agent_id, agent_name, count( DISTINCT city) as total_orders from orders as o
join delivery_agents as d
on o.agent_id = d.agent_id
group  by d.agent_id, agent_name
having count( DISTINCT city) > 1
order by agent_id asc
;

-- Show complete order report.

select count(order_id) as total_order, 
round(avg(delivery_time_minutes)::numeric,2) as avg_dtm, 
sum(total_amount) as total_revenue  from orders as o
;




-- Daily revenue trend.

select order_id,order_date,total_amount,
sum(total_amount) over(partition by order_date order by order_date asc ) as daily_revenue
from orders;

-- Monthly revenue growth.

select 
extract(month from order_date) as months,
sum(total_amount) over(
partition by extract(month from order_date)
order by extract(month from order_date)
) as monthly_revenue
from orders;

select * from orders;

-- Running total revenue.

select 
order_id,
order_date,
total_amount,
sum(total_amount) over(
order by order_date
) as running_total
from orders;

-- Rank restaurants by revenue.

select restaurant_name, sum(total_amount) as revenue, 
rank() over(order by sum(total_amount) desc) as ranks
from orders as o
join restaurants as r
on o.restaurant_id = r.restaurant_id
group by restaurant_name;

-- Top selling food category.

select category, count(o.order_id) as top_selling from orders as o
join order_items as oi
on o.order_id = oi.order_id
group by category
order by top_selling desc
limit 1;


-- Percentage contribution of each restaurant.

select 
restaurant_name,
sum(total_amount) as restaurant_revenue,

(sum(total_amount) * 100.0 /
(sum(sum(total_amount)) over())
) as percentage_contribution

from orders as o
join restaurants as r
on o.restaurant_id = r.restaurant_id

group by restaurant_name;


-- Find fastest delivery agent.

select d.agent_id, agent_name, round(avg(delivery_time_minutes)::numeric,2) as fast_delivery_agent from orders as o
join delivery_agents as d
on d.agent_id = o.agent_id
group by d.agent_id, agent_name
order by fast_delivery_agent asc
limit 1; 

-- Detect late deliveries above average time.

select * from orders where delivery_time_minutes >(
(select round(avg(delivery_time_minutes)::numeric,2)  from orders ));

-- Repeat customers analysis.

select c.customer_id, customer_name, count(order_id) as repeat_customers from orders as o
join customers as c
on o.customer_id = c.customer_id
group by c.customer_id, customer_name
having count(order_id) > 1;

-- Customer lifetime value.

select c.customer_id, customer_name, sum(total_amount) as lifetime_value from orders as o
join customers as c
on o.customer_id = c.customer_id
group by c.customer_id, customer_name
order by lifetime_value desc;


-- Rank customers by spending.

select c.customer_id, customer_name, sum(total_amount) as total_spending,
rank() over(order by sum(total_amount) desc ) as ranks
from orders as o
join customers as c
on o.customer_id = c.customer_id
group by c.customer_id, customer_name ;



-- Dense rank restaurants by sales.

select r.restaurant_id, restaurant_name, sum(total_amount) as total_sales,
dense_rank() over(order by sum(total_amount) desc) as ranks
from orders as o
join restaurants as r
on r.restaurant_id = o.restaurant_id
group by r.restaurant_id, restaurant_name;

-- Running revenue total.

select *,
sum(total_amount) over(order by  order_date asc) as running_revenue from orders;

-- Lag previous order amount.

select order_id, total_amount,
lag(total_amount) over() as previous_order_amount
from orders as o

-- Compare current order with previous order.

select order_id, total_amount,
total_amount-lag(total_amount)over() as compare
from orders 


-- Find top order per city.
with top_city as (
select city, order_id, total_amount,
rank() over(partition by city order by total_amount desc) as ranks
from orders as o
join customers as c
on c.customer_id = o.customer_id)
select * from top_city where ranks = 1;

-- Average order amount by city.

select city, round(avg(total_amount)::numeric,2) as avg_amount,
dense_rank() over(order by avg(total_amount) desc) as ranks
from orders as o
join customers as c
on c.customer_id = o.customer_id
group by city;

-- Revenue percentage contribution.

select order_id, total_amount,
sum(total_amount)*100/sum(total_amount)
over() as revenue_percentage_contribution
from orders
group by order_id, total_amount;

-- Highest delivery time per restaurant.

select r.restaurant_id, restaurant_name, delivery_time_minutes,
rank() over(partition by restaurant_name )
from orders as o
join restaurants as r
on r.restaurant_id = o.restaurant_id;


-- First order of every customer.


select c.customer_id, customer_name, order_id, order_date,
rank()over(partition by order_date order by order_date asc) as rk
from orders as o
join customers as c
on o.customer_id = c.customer_id
group by c.customer_id, customer_name, order_id, order_date;