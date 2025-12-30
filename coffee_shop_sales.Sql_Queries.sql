create database coffee_shop_sales_db;
show databases;
use coffee_shop_sales_db;
Describe coffee_shop_sales;
select* from coffee_shop_sales;
UPDATE coffee_shop_sales
SET transaction_date = STR_TO_DATE(transaction_date, '%d-%m-%Y');

ALTER TABLE coffee_shop_sales 
MODIFY COLUMN transaction_date DATE;

UPDATE coffee_shop_sales 
SET transaction_time=str_to_date(transaction_time,'%H:%i:%s');

ALTER TABLE coffee_shop_sales 
MODIFY COLUMN transaction_time TIME;

ALTER TABLE coffee_shop_sales 
CHANGE COLUMN ï»¿transaction_id transaction_id INT;

-- 1. CALCULATE THE TOTAL SALES FOR EACH RESPECTIVE MONTH--

SELECT round(sum(unit_price * transaction_qty),1)As TOTAL_SALES
FROM coffee_shop_sales where month(transaction_date)= 5;-- march month

-- 2.TOTAL SALES  -MOM DIFFERENCE AND MOM GROWTH

SELECT MONTH(transaction_date)AS month, -- number of month
ROUND(SUM(unit_price*transaction_qty)) As total_sales, -- Total sales column
(sum(unit_price*transaction_qty)-lag(sum(unit_price*transaction_qty),1) -- month sales difference
over(order by month(transaction_date)))/lag(sum(unit_price*transaction_qty),1) -- Division by PM sales
over(order by month(transaction_date))*100 As mom_increase_percentage -- percentage 
from coffee_shop_sales
where month(transaction_date)IN(4,5) -- for month of april (PM)and may (PM)
group by month(transaction_date)
order by month(transaction_date);

-- 3.Total Orders by month

SELECT COUNT(transaction_id) AS Total_orders
from coffee_shop_sales
where month(transaction_date)=5; -- may month 

-- 4.MOM INCREASE OR DECREASE IN NUMBER OF ORDERS

SELECT MONTH(transaction_date)AS month, -- number of month
ROUND(COUNT(transaction_id)) As total_sales, -- Total sales column
(COUNT(transaction_id)-lag(count(transaction_id),1) -- month sales difference
over(order by month(transaction_date)))/lag(count(transaction_id),1) -- Division by PM sales
over(order by month(transaction_date))*100 As mom_increase_percentage -- percentage 
from coffee_shop_sales
where month(transaction_date)IN(4,5) -- for month of april (PM)and may (PM)
group by month(transaction_date)
order by month(transaction_date);

-- 5. TOTAL QUANTITY SOLD

SELECT SUM(transaction_qty) AS Total_Quantity_sold
from coffee_shop_sales
where month(transaction_date)=5; -- may month 


SELECT MONTH(transaction_date)AS month, 
ROUND(SUM(transaction_qty)) As total_quantity_sold, 
(sum(transaction_qty)-lag(sum(transaction_qty),1) 
over(order by month(transaction_date)))/lag(sum(transaction_qty),1)
over(order by month(transaction_date))*100 As mom_increase_percentage 
from coffee_shop_sales
where month(transaction_date)IN(4,5) 
group by month(transaction_date)
order by month(transaction_date);

-- 6.DISPLAY DETAILED METRICS(SALES,ORDERS,qUANTITY) THE OVER SPECIFIC DAY

select 
     concat(round(sum(unit_price*transaction_qty)/1000,1),'K')As Total_sales,
     concat(round(SUM(transaction_qty)/1000,1), 'K')AS Total_qty_sold,
     concat(round(count(transaction_id)/1000,1),'K')AS Total_Orders
from coffee_shop_sales 
where transaction_date='2023-05-18';
     
-- 7.SALES ANALYSIS BY WEEKDAYS AND WEEKENDS

SELECT 
     CASE WHEN DAYOFWEEK(transaction_date)IN(1,7)THEN 'Weekends'
     ELSE 'Weekdays'
     END AS day_type,
     CONCAT(ROUND(SUM(unit_price*transaction_qty)/1000,1),'k')AS Total_sales
	FROM coffee_shop_sales
    WHERE MONTH(transaction_date)=2 -- Feb_month
    GROUP BY 
          CASE WHEN DAYOFWEEK(transaction_date)IN(1,7)THEN 'Weekends'
          ELSE 'Weekdays'
          END;
          
-- 8. SALES ANALYSIS BY STORE LOCATION
 
SELECT 
    store_location,
    CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000, 2), 'k') AS Total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 6 -- jun month
GROUP BY store_location
ORDER BY SUM(unit_price * transaction_qty) DESC;

-- 9.DAILY SALES WITH AVERAGE

SELECT
      CONCAT(ROUND(AVG(total_sales)/1000,1),'K') AS Avg_Sales
FROM
    (
    SELECT SUM(transaction_qty*unit_price)AS total_sales
    FROM coffee_shop_sales
    WHERE MONTH(transaction_date)=5
    GROUP BY transaction_date
    )AS Internal_query

-- 10. Day-wise Sales Performance (May)

SELECT
     DAY(transaction_date)AS day_of_month,
     SUM(unit_price*transaction_qty)AS total_sales
from coffee_shop_sales
WHERE MONTH(transaction_date)=5
GROUP BY DAY(transaction_date)
ORDER BY DAY(transaction_date)
     
-- 11.COMPARING DAILY SALES WITH AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”

SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Equal to Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        coffee_shop_sales
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY day_of_month;

-- 12.Category-wise Sales Performance – May

SELECT product_category,
      ROUND(SUM(unit_price * transaction_qty))As total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date)=5
GROUP BY product_category
ORDER BY SUM(unit_price*transaction_qty)DESC

-- 13.TOP 10 PRODUCTS BY SALES

SELECT product_type,
      round(SUM(unit_price * transaction_qty))As total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date)=5 AND product_category='coffee'
GROUP BY product_type
ORDER BY SUM(unit_price*transaction_qty)DESC 
LIMIT 10

-- 14.SALES ANALYSIS BY DAYS AND HOURS

SELECT 
    SUM(unit_price * transaction_qty) AS total_sales,
    SUM(transaction_qty) AS total_quantity_sold,
    COUNT(*) AS total_orders
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5      -- May
  AND DAYOFWEEK(transaction_date) = 1 -- Monday
  AND HOUR(transaction_time) = 14      -- 2 PM
  
select
     HOUR(transaction_time),
     SUM(unit_price *transaction_qty) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date)=5
GROUP BY HOUR(transaction_time)
ORDER BY HOUR(transaction_time)

-- TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY

SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;

  
  


