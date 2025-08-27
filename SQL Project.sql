create database `SQL Project`;
ALTER TABLE `sql project`.`customer_usa(sheet1)` 
RENAME TO  `sql project`.`customer_usa` ;
ALTER TABLE `sql project`.`region_usa(sheet1)` 
RENAME TO  `sql project`.`region_usa` ;
ALTER TABLE `sql project`.`sales team_usa(sheet1)` 
RENAME TO  `sql project`.`sales team_usa` ;

Select *
from customer_usa;
select *
from region_usa;
Select *
from `sales order_usa`;
Select *
from `sales team_usa`;
Select *
from `store_sales_usa`;

ALTER TABLE `sql project`.`customer_usa` 
CHANGE COLUMN `ï»¿_CustomerID` `CustomerID` INT NULL DEFAULT NULL ;

ALTER TABLE `sql project`.`region_usa` 
CHANGE COLUMN `ï»¿StateCode` `State Code` TEXT NULL DEFAULT NULL ;

ALTER TABLE `sql project`.`sales order_usa` 
CHANGE COLUMN `ï»¿OrderNumber` `Order Number` TEXT NULL DEFAULT NULL ;

Select *
from `sales order_usa`
where `Unit Cost` like '%,%';

Update `sales order_usa`
set `unit cost` = replace(`unit cost`, ',', '') 
where `unit cost` like '%,%' ;
 -- to check version
 Select version();
 select @@version;
 
 -- 1. Add a temporary column
ALTER TABLE `sql project`.`sales order_usa`
ADD COLUMN deliverydate_tmp DATE;

-- 2. Convert the text format DD/MM/YYYY to DATE
UPDATE `sql project`.`sales order_usa`
SET deliverydate_tmp = STR_TO_DATE(deliverydate, '%d/%m/%Y');

-- 3. Drop the old column
ALTER TABLE `sql project`.`sales order_usa`
DROP COLUMN deliverydate;

-- 4. Rename the temp column to the original name
ALTER TABLE `sql project`.`sales order_usa`
CHANGE COLUMN deliverydate_tmp deliverydate DATE;

 
 show columns from `sales order_usa`
 like 'date_text';
 
-- To CALCULATE TOTAL PROFIT (PRICE-COST-DISCOUNT)
SELECT 
    round (SUM( (`Unit price` - `Unit cost` - `Discount applied`) * `Order quantity` ),2) AS Total_Profit
FROM `sales order_usa`;

-- To CALCULATE THE TOTAL QUANTITY SOLD
SELECT sum(`order quantity`) as Total_Quantity_Sold
from `sales order_usa`;

-- Count of Customers
SELECT COUNT(*) AS Total_Customers
FROM `sql project`.`customer_usa`;

-- What are the total profit by region, and which region performs best?
SELECT 
    r.Region,
    ROUND(SUM(
        (CAST(so.`Unit Price` AS DECIMAL(10,2)) 
       - CAST(so.`Unit Cost` AS DECIMAL(10,2)) 
       - so.`Discount Applied`) * so.`Order Quantity`
    ), 2) AS Total_Profit
FROM `sql project`.`sales order_usa` AS so
JOIN `sql project`.`store_sales_usa` AS s
    ON so._StoreID = s.StoreID
JOIN `sql project`.`region_usa` AS r
    ON s.StateCode = r.`State Code`
GROUP BY r.Region
ORDER BY Total_Profit DESC;


-- Which products contribute the most to profit in each region?
SELECT 
    r.Region,
    so._ProductID,
    ROUND(SUM(
        (CAST(so.`Unit Price` AS DECIMAL(10,2)) 
       - CAST(so.`Unit Cost` AS DECIMAL(10,2)) 
       - so.`Discount Applied`) * so.`Order Quantity`
    ), 2) AS Total_Profit
FROM `sql project`.`sales order_usa` AS so
JOIN `sql project`.`store_sales_usa` AS s
    ON so._StoreID = s.StoreID
JOIN `sql project`.`region_usa` AS r
    ON s.StateCode = r.`State Code`
GROUP BY r.Region, so._ProductID
ORDER BY r.Region, Total_Profit DESC;

-- How do the different sales channnels affect store profit?
SELECT 
    so.`Sales Channel`,
    s.StoreID,
    s.`City Name`,
    s.State,
    ROUND(SUM(
        (CAST(so.`Unit Price` AS DECIMAL(10,2)) 
       - CAST(so.`Unit Cost` AS DECIMAL(10,2)) 
       - so.`Discount Applied`) * so.`Order Quantity`
    ), 2) AS Store_Profit
FROM `sql project`.`sales order_usa` AS so
JOIN `sql project`.`store_sales_usa` AS s
    ON so._StoreID = s.StoreID
GROUP BY so.`Sales Channel`, s.StoreID, s.`City Name`, s.State
ORDER BY so.`Sales Channel`, Store_Profit DESC;

-- What is the average profit across different regions?
SELECT 
    r.Region,
    ROUND(AVG(
        (CAST(so.`Unit Price` AS DECIMAL(10,2)) 
       - CAST(so.`Unit Cost` AS DECIMAL(10,2)) 
       - so.`Discount Applied`) * so.`Order Quantity`
    ), 2) AS Avg_Profit
FROM `sql project`.`sales order_usa` AS so
JOIN `sql project`.`store_sales_usa` AS s
    ON so._StoreID = s.StoreID
JOIN `sql project`.`region_usa` AS r
    ON s.StateCode = r.`State Code`
GROUP BY r.Region
ORDER BY Avg_Profit DESC;

-- Top 10 Customers in terms of revenue generation.
SELECT 
    c.CustomerID,
    c.`Customer Names`,
    ROUND(SUM((CAST(so.`Unit Price` AS DECIMAL(10,2)) - so.`Discount Applied`) * so.`Order Quantity`), 2) AS Total_Revenue
FROM `sql project`.`sales order_usa` AS so
JOIN `sql project`.`customer_usa` AS c
    ON so._CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.`Customer Names`
ORDER BY Total_Revenue DESC
LIMIT 10;

-- What is the geographical distribution of customers? i.e count customer by different region
SELECT 
    r.Region,
    COUNT(DISTINCT c.CustomerID) AS Customer_Count
FROM `sql project`.`customer_usa` AS c
JOIN `sql project`.`sales order_usa` AS so
    ON c.CustomerID = so._CustomerID
JOIN `sql project`.`store_sales_usa` AS s
    ON so._StoreID = s.StoreID
JOIN `sql project`.`region_usa` AS r
    ON s.StateCode = r.`State Code`
GROUP BY r.Region
ORDER BY Customer_Count DESC;

-- Which sales team members or teams are driving the most revenue?
SELECT 
    st.SalesTeamID,
    st.`Sales Team`,
    st.Region,
    ROUND(SUM((CAST(so.`Unit Price` AS DECIMAL(10,2)) - so.`Discount Applied`) * so.`Order Quantity`), 2) AS Total_Revenue
FROM `sql project`.`sales order_usa` AS so
JOIN `sql project`.`sales team_usa` AS st
    ON so.SalesTeamID = st.SalesTeamID
GROUP BY st.SalesTeamID, st.`Sales Team`, st.Region
ORDER BY Total_Revenue DESC;
