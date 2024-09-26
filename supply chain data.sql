CREATE DATABASE Supply_Chain_Analysis
USE Supply_Chain_Analysis

CREATE TABLE Supply_data (
Product_type VARCHAR(50) NOT NULL,
SKU VARCHAR(20) PRIMARY KEY ,
Price INT NOT NULL,
Availability INT,
Number_of_products_sold INT,
Revenue_generated FLOAT,
Customer_demographics VARCHAR(100),
Stock_levels INT,
Lead_times INT,
Order_quantities INT,
Shipping_times INT,
Shipping_carriers VARCHAR(50),
Shipping_costs DECIMAL,
Supplier_name VARCHAR(20),
Location VARCHAR(20),
Lead_time INT,
Production_volumes INT,
Manufacturing_lead_time INT,
Manufacturing_costs DECIMAL,
Inspection_results VARCHAR(25),
Defect_rates DECIMAL,
Transportation_modes VARCHAR(25),
Routes VARCHAR(20),
Costs FLOAT
)

LOAD DATA INFILE 'E:/supply_data.csv'
INTO TABLE Supply_data
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES

SELECT * FROM Supply_data

-- 1.Count the number of rows 
SELECT COUNT(*)
FROM Supply_data

-- 2.What is the total revenue generated from all products

SELECT ROUND(SUM(Revenue_generated)*100,2) AS Total_Revenue
FROM Supply_data

-- 3.How many unique product types are there

SELECT COUNT(DISTINCT Product_Type) AS Unique_product
FROM Supply_data

-- 4.List all products with their prices and availability

SELECT SKU,Price,Availability
FROM Supply_data

-- 5.What is the average price of products

SELECT AVG(Price) AS Avg_price
FROM Supply_data

-- 6.Count the number of products sold for each product type

SELECT Product_type,SUM(Number_of_products_sold) AS Total_sold
FROM Supply_data
GROUP BY Product_type

-- 7.Find the product with the heighest revenue generated

SELECT SKU,MAX(Revenue_generated) AS Highest_Revenue
FROM Supply_data
GROUP BY SKU

-- 8.List products that have a defect rate higher than 5%

SELECT SKU,Defect_rates
FROM Supply_data
WHERE Defect_rates > 5

-- 9.Using a CTE find the average manufacturing cost for each product type

WITH Avg_Cost AS (
	SELECT Product_type,AVG(Manufacturing_costs) AS Avg_cost
    FROM Supply_data
    GROUP BY Product_type
)
SELECT * FROM Avg_cost

-- 10.Rank products by number of products sold using window function

SELECT SKU,Number_of_products_sold,
		RANK() OVER (ORDER BY Number_of_products_sold DESC) AS Sales_rank
FROM Supply_data

-- 11.Find the total number of products sold mand total revenue generated for each product type using CTE

WITH Sales_summary AS (
	SELECT Product_type,SUM(Number_of_products_sold) AS Total_sold,ROUND(SUM(Revenue_generated)*100,2) AS Total_Revenue
    FROM Supply_data
    GROUP BY Product_type
)
SELECT * FROM Sales_summary

-- 12.Using a CTE list the top 5 products by revenue generated

WITH Ranked_products AS (
	SELECT SKU,Revenue_generated,
			RANK() OVER(ORDER BY revenue_generated DESC) AS Revenue_Rank
	FROM Supply_data
)
SELECT SKU,Revenue_generated
FROM Ranked_products
WHERE Revenue_Rank <= 5

-- 13.Get the products with the highest shipping cost and their respective SKU.

SELECT SKU,Shipping_costs
FROM Supply_data
WHERE Shipping_costs = (
						SELECt MAX(Shipping_costs)
						FROM Supply_data
                        )
                        
-- 14.List the product types that have never been sold (0 products sold)

SELECT DISTINCT Product_type
FROM Supply_data
WHERE SKU NOT IN (
				 SELECT SKU 
                 FROM Supply_data
                 WHERE Number_of_products_sold > 0
                 )
			
-- 15.Using a CTE find all products that have a lead time greater than the average lead time

WITH Avg_Lead AS (
	SELECT AVG(Lead_time) AS Average_Lead_Time
    FROM Supply_data
)
SELECT SKU,Lead_time
FROM Supply_data,AVG_Lead
WHERE Lead_time > Average_Lead_Time

-- 16.Identify the top shipping carriers by total shipping costs.

SELECT Shipping_carriers,SUM(Shipping_costs) AS Total_Shipping_Cost 
FROM Supply_data
GROUP BY Shipping_carriers
ORDER BY Total_Shipping_Cost DESC

-- 17.What percentage of total revenue does each product type generate

SELECT Product_type,(
					SUM(Revenue_generated)/(
										   SELECT SUM(Revenue_generated)
                                           FROM Supply_data)*100
					                       ) AS Revenue_Percentage
FROM Supply_data
GROUP BY Product_type
                               
-- 18.Which location have the highest defect rates

SELECT Location, AVG(Defect_rates) AS Avg_Defect_rate
FROM Supply_data
GROUP BY Location
ORDER BY Avg_Defect_rate DESC

-- 19.Find the duplicate records of a table

SELECT SKU,Product_type,COUNT(*) AS Record_count
FROM Supply_data
GROUP BY SKU,Product_type
HAVING COUNT(*) > 1

-- 20.Find the 'N'th highest salasry from employee using (subquery and CTE)
-- Using subquery
SELECT DISTINCT Price
FROM Supply_data
WHERE Price IN (
			   SELECT DISTINCT Price
               FROM Supply_data
               ORDER BY Price DESC
            
)
ORDER BY Price DESC
LIMIT 1

--  using CTE

WITH TopPrices AS (
    SELECT DISTINCT Price
    FROM Supply_data
    ORDER BY Price DESC
    LIMIT 5
)
SELECT DISTINCT Price
FROM Supply_data
WHERE Price IN (SELECT Price FROM TopPrices)
ORDER BY Price DESC
LIMIT 1

-- 21.Find the number of spaces in a column product_type having string value

SELECT Product_type,
	   LENGTH(Product_type) - LENGTH(REPLACE (Product_type, ' ','')) AS Space_count
FROM Supply_data

