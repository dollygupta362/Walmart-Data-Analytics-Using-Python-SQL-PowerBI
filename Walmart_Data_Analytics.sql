-- Fetching all the data within the dataset
SELECT * FROM walmart_data;


-- Fetching the transaction counts by payment methods
SELECT DISTINCT payment_method, COUNT(*) 
FROM walmart_data
GROUP BY payment_method;


-- Fetching all the branches wuthin this dataset
SELECT COUNT(DISTINCT "Branch") AS total_branch
FROM walmart_data;


-- Fetching highest quantity ordered
SELECT MAX(quantity)
FROM walmart_data;


--BUSSINESS PROBLEM
--Q. 1 Find different payment method and number of transactions, number of qty sold
SELECT payment_method, COUNT(*)AS no_payments, SUM(quantity) as no_qty_sold
FROM walmart_data
GROUP BY payment_method;


--Q.2 Identify the highest-rated category in each branch ,displaying the branch ,category,average rating
SELECT "Branch", category, AVG(rating) AS avg_rating
FROM walmart_data
GROUP BY "Branch", category
ORDER BY avg_rating DESC;


--Q.3 Identify the busiest day for each branch based on the number of transaction.
SELECT "Branch", dow, no_transactions
FROM (
SELECT "Branch", EXTRACT(DOW FROM date) AS dow, COUNT(*) AS no_transactions,
RANK() OVER (PARTITION BY "Branch" 
ORDER BY COUNT(*) DESC) AS rank
FROM walmart_data
GROUP BY "Branch", EXTRACT(DOW FROM date)
) AS ranked_data
WHERE rank = 1;

  
--Q.4  Calculate the total quantity of items sold per payment method.List payment_method and total quantity.  
SELECT payment_method, SUM(quantity) as no_qty_sold
FROM walmart_data
GROUP BY payment_method;


--Q.5 Determine the average, minimum,and maximum rating of category for each city ,
 --     List the city, category, average_rating, min_rating, and max_rating.
SELECT "City" AS city, "category", AVG("rating") AS avg_rating, 
MAX("rating") AS max_rating, MIN("rating") AS min_rating
FROM walmart_data
GROUP BY "City", "category"
ORDER BY "City", "category";


--Q.6 Calculate the total profit for each category by considering total profit as (unit price * quantity * profit_margin).
SELECT category, SUM(unit_price * quantity * profit_margin) AS total_profit
FROM walmart_data
GROUP BY category
ORDER BY total_profit DESC;

 
--Q. 7 Determine the most common payment method for each Branch.
SELECT "Branch", payment_method AS preferred_payment_method
FROM (
SELECT "Branch", payment_method, COUNT(*) AS payment_count,
RANK() OVER (PARTITION BY "Branch" ORDER BY COUNT(*) DESC) AS rnk
FROM walmart_data
GROUP BY "Branch", payment_method
) AS ranked_methods
WHERE rnk = 1;


--Q.8 Categorize transactions in to 3 group MORNING, AFTERNOON, EVENING
SELECT
CASE 
    WHEN EXTRACT(HOUR FROM time::time) < 12 THEN 'MORNING'
    WHEN EXTRACT(HOUR FROM time::time) BETWEEN 12 AND 17 THEN 'AFTERNOON'
    ELSE 'EVENING'
END AS day_time,
COUNT(*) AS number_of_invoices
FROM walmart_data
GROUP BY day_time
ORDER BY number_of_invoices DESC;



-- Q9: Identify top 5 branches with highest revenue decrease ratio (RDR)
WITH yearly_revenue AS (
SELECT "Branch",
EXTRACT(YEAR FROM date) AS year,
SUM(unit_price * quantity) AS total_revenue
FROM walmart_data
GROUP BY "Branch", EXTRACT(YEAR FROM date)
),
pivoted AS (
SELECT "Branch",
MAX(CASE WHEN year = 2022 THEN total_revenue END) AS last_year,
MAX(CASE WHEN year = 2023 THEN total_revenue END) AS this_year
FROM yearly_revenue
GROUP BY "Branch"
)
SELECT "Branch", last_year, this_year,
ROUND(((last_year - this_year) / last_year * 100)::numeric, 2) AS rdr
FROM pivoted
WHERE last_year IS NOT NULL AND this_year IS NOT NULL
ORDER BY rdr DESC
LIMIT 5;


-- 10. Top 3 product categories by profit in each branch
SELECT "Branch", category, total_profit
FROM (
SELECT "Branch", category,
SUM(unit_price * quantity * profit_margin) AS total_profit,
RANK() OVER (PARTITION BY "Branch" ORDER BY SUM(unit_price * quantity * profit_margin) DESC) AS rnk
FROM walmart_data
GROUP BY "Branch", category
) AS ranked_data
WHERE rnk <= 3;


-- 11. Hourly sales trend – total sales by hour of the day
SELECT 
EXTRACT(HOUR FROM time::time) AS hour_of_day,
SUM(unit_price * quantity) AS total_sales
FROM walmart_data
GROUP BY hour_of_day
ORDER BY total_sales DESC;


-- 12. Identify the category with highest average profit per unit sold
SELECT category,
ROUND((SUM(unit_price * quantity * profit_margin) / SUM(quantity))::numeric, 2) AS avg_profit_per_unit
FROM walmart_data
GROUP BY category
ORDER BY avg_profit_per_unit DESC;


-- 13. City-wise sales and quantity breakdown
SELECT "City",
SUM(unit_price * quantity) AS total_sales,
SUM(quantity) AS total_quantity
FROM walmart_data
GROUP BY "City"
ORDER BY total_sales DESC;


-- 14. Weekday vs Weekend performance comparison.
SELECT 
CASE 
	WHEN EXTRACT(DOW FROM date) IN (0, 6) THEN 'Weekend'
	ELSE 'Weekday'
END AS day_type,
COUNT(*) AS total_invoices,
SUM(unit_price * quantity) AS total_sales
FROM walmart_data
GROUP BY day_type;


-- 15.  Average quantity sold per transaction for each category
SELECT category,
ROUND(AVG(quantity)::numeric, 0) AS avg_quantity_per_transaction
FROM walmart_data
GROUP BY category
ORDER BY avg_quantity_per_transaction DESC;




       

