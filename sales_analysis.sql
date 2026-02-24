CREATE TABLE sales_store (
transaction_id VARCHAR(15),
customer_id VARCHAR(15),
customer_name VARCHAR(30),
customer_age INT,
gender VARCHAR(15),
product_id VARCHAR(15),
product_name VARCHAR(15),
product_category VARCHAR(15),
quantiy INT,
prce FLOAT,
payment_mode VARCHAR(15),
purchase_date DATE,
time_of_purchase TIME,
status VARCHAR(15)
);

SELECT * FROM sales_store

SET DATEFORMAT dmy 
BULK INSERT sales_store
FROM 'C:\SQLData\sales.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
); 
--YYYY--MM--DD
--Data cleaning 

SELECT * FROM sales_store
SELECT * INTO sales FROM sales_store
SELECT * FROM sales_store
SELECT * FROM sales

-- Data cleaning 
--cheaking dublicate in data --

SELECT transaction_id,COUNT (*)
FROM sales 
GROUP BY transaction_id
HAVING COUNT  (transaction_id) >1

TXN240646
TXN342128
TXN855235
TXN981773

WITH CTE AS (
SELECT *,
    ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY transaction_id) AS Row_Num
FROM sales
)

--DELETE FROM CTE
--WHERE Row_Num=2

SELECT * FROM CTE
WHERE transaction_id IN ('TXN240646', 'TXN342128', 'TXN855235', 'TXN981773')

----------------------------------------------------------------------------------------------------------
--Step 2:Correction of Headers

SELECT * FROM sales
EXEC sp_rename'sales.quantiy', 'quantity', 'COLUMN'
EXEC sp_rename'sales.prce', 'price', 'COLUMN'
----------------------------------------------------------------------------------------------------------

--step 3 to cheak data type--

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME='sales'
----------------------------------------------------------------------------------------------------------
--step4  to cheak the null values 

--to check null count

DECLARE @SQL NVARCHAR(MAX) = '' ;

SELECT @SQL = STRING_AGG(
'SELECT ''' + COLUMN_NAME + ''' AS ColumnName,
COUNT(*) AS NullCount
FROM ' + QUOTENAME(TABLE_SCHEMA) + '.sales
WHERE ' + QUOTENAME(COLUMN_NAME) + ' IS NULL',
' UNION ALL '
)
WITHIN GROUP (ORDER BY COLUMN_NAME)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'sales';

-- Execute the dynamic SQL
EXEC sp_executesql @SQL;
----------------------------------------------------------------------------------------------------------
--treating null values 

SELECT * FROM sales 
WHERE transaction_id IS NULL 
OR 
customer_id IS NULL
OR 
customer_id IS NULL 
OR
customer_name IS NULL 
OR 
customer_age IS NULL 
OR
gender IS NULL 
OR
product_id IS NULL 
OR 
product_name IS NULL 
OR 
product_category IS NULL 
OR 
quantity IS NULL 
OR 
price IS NULL 
OR 
payment_mode IS NULL 
OR 
purchase_date IS NULL 
OR 
time_of_purchase IS NULL 
OR 
status IS NULL;

DELETE FROM sales 
WHERE transaction_id IS NULL 

 
 SELECT * FROM sales 
 WHERE customer_name ='Ehsaan Ram'

 UPDATE sales 
 SET customer_id= 'CUST9494'
 WHERE transaction_id ='TXN977900'

 SELECT * FROM sales 
 WHERE customer_name ='Damini Raju'

 UPDATE sales
 SET customer_name= 

 UPDATE sales 
 SET customer_id= 'CUST1401'
 WHERE transaction_id ='TXN985663'

 SELECT* FROM sales 
 WHERE customer_id ='CUST1003'

 UPDATE sales 
 SET customer_name ='Mahika Saini',customer_age=35,gender='Male'
 WHERE transaction_id ='TXN432798'

SELECT * FROM sales 

SELECT DISTINCT gender 
FROM sales 

UPDATE sales 
SET gender='Male'
WHERE gender ='M'

UPDATE sales 
SET gender='Female'
WHERE gender ='F'

SELECT DISTINCT payment_mode
FROM sales  

UPDATE sales 
SET payment_mode='Credit Card'
WHERE payment_mode ='CC'

--  Analysis
--lets find  the top 5 most selling product by quantity 
----------------------------------------------------------------------------------------------------------


SELECT  TOP 5 product_name, SUM(quantity) AS total_quantity_sold
FROM sales
WHERE status='delivered'
GROUP BY product_name
ORDER BY total_quantity_sold DESC


-- by this we find that we can prioritized stock and and give promotion to this items 

----------------------------------------------------------------------------------------------------------

SELECT  TOP 5 product_name, COUNT(*) AS total_canceled 
FROM sales
WHERE status='cancelled'
GROUP BY product_name
ORDER BY total_canceled DESC

--so by this we find that this products are frequently cancelled again and again
--we should not spent too much on this on promotion as well in stock too 

----------------------------------------------------------------------------------------------------------

SELECT
    CASE
        WHEN DATEPART(HOUR, time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
        WHEN DATEPART(HOUR, time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
        WHEN DATEPART(HOUR, time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
        WHEN DATEPART(HOUR, time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
    END AS time_of_day,
    COUNT(*) AS total_order
FROM sales
GROUP BY
    CASE
        WHEN DATEPART(HOUR, time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
        WHEN DATEPART(HOUR, time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
        WHEN DATEPART(HOUR, time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
        WHEN DATEPART(HOUR, time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
    END
    ORDER BY total_order DESC

    -- by this we find the peak hours time in a daz that which time the most sales done 
    --busssiness impact :  is  that we can stock much at that time  manage staff properly at that time 
    -- and serveer loads cheak 
    ----------------------------------------------------------------------------------------------------------

SELECT * FROM sales

SELECT TOP 5 customer_name,
    FORMAT(SUM(price * quantity), 'C0', 'en-IN') AS total_spend
FROM sales
GROUP BY customer_name
ORDER BY SUM (price*quantity) DESC

-- from this that we find our top 5 spending customes  we should give them proper time and 
-- and we should not let them any where else 


----------------------------------------------------------------------------------------------------------

SELECT * FROM sales

SELECT
    product_category,
    FORMAT(SUM(price * quantity), 'C0', 'en-IN') AS Revenue
FROM sales
GROUP BY product_category
ORDER BY SUM(price * quantity) DESC

--by this we know the most selling prodcuts of our comapany
--Business Problem Solved: Identify top-performing product categories.

--Business Impact: Refine product strategy, supply chain, and promotions.
--allowing the business to invest more in high-margin or high-demand categories.

----------------------------------------------------------------------------------------------------------

--now we have to find the return mean cancellation rate per product 

SELECT * FROM sales


--cancellation
SELECT product_category,
FORMAT (COUNT (CASE WHEN status='cancelled' THEN 1 END)*100.0/COUNT(*), 'N3')+'%' AS cancelled_percent
FROM sales
GROUP BY product_category
ORDER BY cancelled_percent DESC

--returm 

SELECT * FROM sales
--cancellation
SELECT product_category,
FORMAT (COUNT (CASE WHEN status='returned' THEN 1 END)*100.0/COUNT(*), 'N3')+'%' AS returned_percent
FROM sales
GROUP BY product_category
ORDER BY returned_percent DESC


--Business Problem Solved: Monitor dissatisfaction trends per category.
---Business Impact: Reduce returns, improve product descriptions/expectations.
--Helps identify and fix product or logistics issues.

----------------------------------------------------------------------------------------------------------


-- 7 payment mode used most 


SELECT * FROM sales

SELECT payment_mode, COUNT(payment_mode) AS total_count
FROM sales
GROUP BY payment_mode
ORDER BY total_count desc


---Business Problem Solved: Know which payment options customers prefer.
--Business Impact: Streamline payment processing, prioritize popular modes.
----------------------------------------------------------------------------------------------------------

-- age group afeect the purchasing behaviour 

SELECt * FROM sales

SELECT
    CASE
        WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
        WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
        WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '51+'
    END AS customer_age,
    FORMAT(SUM(price*quantity),'C0','en-IN') AS total_purchase
FROM sales
GROUP BY CASE
        WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
        WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
        WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '51+'
    END
ORDER BY total_purchase DESC


-- business problem solved age group afeect the purchasing behaviour  
-- traget the product liked by the age group who purchase the most 
----------------------------------------------------------------------------------------------------------


-- problem  no 9 : wahts the monthly sales trends 

 
 
SELECt * FROM sales


SELECT
    --YEAR(purchase_date) AS Years,
    MONTH(purchase_date) AS Months,
    FORMAT(SUM(price*quantity), 'C0', 'en-IN') AS total_sales,
    SUM(quantity) AS total_quantity
FROM sales
GROUP BY MONTH(purchase_date)
ORDER BY Months



--business problem solve because we can now plan inventry according to month now understand that in which 
--month we can have as much 
-- as anough for this month  we can hire more staff for that specific months
----------------------------------------------------------------------------------------------------------

SELECT gender,product_category,COUNT(product_category) AS total_purchase
FROM sales
GROUP BY gender,product_category
ORDER BY gender

-- business problem solved as we can target  specific gender_focud campaign 




