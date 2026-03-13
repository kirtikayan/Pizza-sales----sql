use pizza;

-- Q.Retrieve the total number of orders placed.

select count(*) as total_orders from orders;



--------------------------------------------------------------------------------------------------------------------------------------
--Q.Calculate the total revenue generated from pizza sales.

select 
round(sum(pizzas.price * order_details.quantity),2) as Total_revenue
from order_details join pizzas
on pizzas.pizza_id = order_details.pizza_id;



--------------------------------------------------------------------------------------------------------------------------------------
--Q.Identify the highest-priced pizza.

SELECT TOP 1
    pizza_types.name,
    pizzas.price  
FROM pizza_types
JOIN pizzas
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price DESC;



--------------------------------------------------------------------------------------------------------------------------------------
--Q.Identify the most common pizza size ordered.

SELECT TOP 1
    p.size,
    SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p 
    ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY total_quantity DESC;



--------------------------------------------------------------------------------------------------------------------------------------
-- Q.List the top 5 most ordered pizza types along with their quantities.

SELECT TOP 5
    pt.name AS pizza_name,
    SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p 
    ON od.pizza_id = p.pizza_id
JOIN pizza_types pt 
    ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_quantity DESC;



--------------------------------------------------------------------------------------------------------------------------------------
-- Q.Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pt.category,
    sum(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p 
    ON od.pizza_id = p.pizza_id
JOIN pizza_types pt
    ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantity DESC;



--------------------------------------------------------------------------------------------------------------------------------------
-- Q.Determine the distribution of orders by hour of the day.

SELECT top 20
    DATEPART(HOUR, time) AS order_hour,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY DATEPART(HOUR, time)
ORDER BY order_hour ;



--------------------------------------------------------------------------------------------------------------------------------------
-- Q.Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category,
    count(name) AS total_pizzas
FROM pizza_types
GROUP BY category
ORDER BY total_pizzas DESC;



--------------------------------------------------------------------------------------------------------------------------------------
-- Q.Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    AVG(daily_total) AS avg_pizzas_per_day
FROM (
    SELECT 
        o.date,
        SUM(od.quantity) AS daily_total
    FROM orders o
    JOIN order_details od
        ON o.order_id = od.order_id
    GROUP BY o.date
) AS daily_orders;



--------------------------------------------------------------------------------------------------------------------------------------
-- Q.Determine the top 3 most ordered pizza types based on revenue.

SELECT TOP 3
    pt.name AS pizza_name,
    SUM(p.price * od.quantity) AS total_revenue
FROM order_details od
JOIN pizzas p
    ON od.pizza_id = p.pizza_id
JOIN pizza_types pt
    ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC;


--------------------------------------------------------------------------------------------------------------------------------------
-- Q.Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pt.category,
    ROUND(SUM(p.price * od.quantity), 0) AS total_revenue,
    ROUND(SUM(p.price * od.quantity) * 100.0 /SUM(SUM(p.price * od.quantity)) OVER (),2) AS revenue_percentage
FROM order_details od
JOIN pizzas p
    ON od.pizza_id = p.pizza_id
JOIN pizza_types pt
    ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_revenue DESC;

--------------------------------------------------------------------------------------------------------------------------------------
-- Q.Analyze the cumulative revenue generated over time.

SELECT 
    o.date,
    SUM(p.price * od.quantity) AS daily_revenue,
    SUM(SUM(p.price * od.quantity)) OVER (ORDER BY o.date) AS cumulative_revenue
FROM orders o
JOIN order_details od
    ON o.order_id = od.order_id
JOIN pizzas p
    ON od.pizza_id = p.pizza_id
GROUP BY o.date
ORDER BY o.date;

--------------------------------------------------------------------------------------------------------------------------------------
-- Q.Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT 
    category,
    pizza_name,
    total_revenue
FROM (
    SELECT 
        pt.category,
        pt.name AS pizza_name,
        round(SUM(p.price * od.quantity),0) AS total_revenue,
        RANK() OVER (
            PARTITION BY pt.category
            ORDER BY SUM(p.price * od.quantity) DESC
        ) AS rank_in_category
    FROM order_details od
    JOIN pizzas p 
        ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt 
        ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.name
) AS ranked_pizzas
WHERE rank_in_category <= 3
ORDER BY category, total_revenue DESC;