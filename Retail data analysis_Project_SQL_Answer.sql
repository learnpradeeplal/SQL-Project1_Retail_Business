-- Project Name - Retail Data Analysis
-- Language - SQL 
-- Student Name - Pradeep Kumar Lal

CREATE DATABASE RDA  -- RDA means Retail Data Analysis

-- I have uploaded all the three .csv files -  Customer , prod_cat_info , Transactions using Tasks>> Import Flat files

USE RDA
-- post uploading will check if the tables are correctly loaded into the DB

SELECT TOP 5 * FROM [dbo].[Customer]
SELECT TOP 5 * FROM [dbo].[Transactions]
SELECT TOP 5 * FROM [dbo].[prod_cat_info]

-- All the tables are correctly uploaded now in DB

SELECT * FROM INFORMATION_SCHEMA.TABLES



--DATA PREPARATION AND UNDERSTANDING

--1.	What is the total number of rows in each of the 3 tables in the database?

SELECT count(*) count_of_rows
FROM [dbo].[Transactions] as t -- gives output as 23053 rows 

SELECT count(*) count_of_rows
FROM [dbo].[Customer] as c -- gives output as 5647 rows 

SELECT count(*) count_of_rows
FROM [dbo].[prod_cat_info] as p -- gives output as 23 rows 


--2.	What is the total number of transactions that have a return?

SELECT count(*) No_of_returns
FROM [dbo].[Transactions] as t
WHERE t.Qty <0

-- Returned qty is 2177 

--3.	As you would have noticed, the dates provided across the datasets are not in a correct format. 
-- As first steps, pls convert the date variables into valid date formats before proceeding ahead.

SELECT ISDATE(c.DOB)
FROM [dbo].[Customer] c
-- Above is giving error - Msg 8116, Level 16, State 1, Line 46
-- Argument data type date is invalid for argument 1 of isdate function.

SELECT c.DOB
FROM [dbo].[Customer] c

SELECT CAST(c.DOB AS datetime) AS 'NewDate' --Coverted date into correct format
FROM [dbo].[Customer] c

EXEC sp_columns Customer --Type name is date

SELECT t.tran_date
FROM [dbo].[Transactions] t

SELECT ISDATE(t.tran_date) as Valid_Date -- Executing this shows this is valid date
FROM [dbo].[Transactions] t

SELECT ISDATE(t.tran_date) as Valid_Date
FROM [dbo].[Transactions] t
WHERE ISDATE(t.tran_date) = 0

--4.	What is the time range of the transaction data available for analysis? Show the output in number of days, 
-- months and years simultaneously in different columns.

SELECT 
     MIN(CAST(CAST(tran_date AS NCHAR(12)) AS date)) AS Start_tran_Date
    ,MAX(CAST(CAST(tran_date AS NCHAR(12)) AS date)) AS End_tran_Date
    ,DATEDIFF(DAY,  MIN(CAST(CAST(tran_date AS NCHAR(12)) AS date)) ,  MAX(CAST(CAST(tran_date AS NCHAR(12)) AS date)) ) AS Difference_in_Days
    ,DATEDIFF(MONTH,MIN(CAST(CAST(tran_date AS NCHAR(12)) AS date)),   MAX(CAST(CAST(tran_date AS NCHAR(12)) AS date)) ) AS Difference_in_Months
    ,DATEDIFF(YEAR, MIN(CAST(CAST(tran_date AS NCHAR(12)) AS date)),   MAX(CAST(CAST(tran_date AS NCHAR(12)) AS date)) ) AS Difference_in_Years
FROM [dbo].[Transactions]

-- Output will come Start date is 25-01-2011 and End date is 28-02-2014 and Total days difference is 1130 , 
-- Total months difference is 37 ,Total year difference is 3

--5.	Which product category does the sub-category “DIY” belong to?

SELECT p.prod_cat ,p.prod_subcat
FROM prod_cat_info p
WHERE p.prod_subcat = 'DIY'

-- prod_cat belongs to Books

--DATA ANALYSIS

--1.	Which channel is most frequently used for transactions?

SELECT  Store_type , COUNT(Store_type) Frequency_of_Channel_Used
FROM Transactions
GROUP BY Store_type
ORDER BY COUNT(Store_type) DESC

-- e-Shop shows count of 9311 , which is on top and Teleshop with count 4504 is the least used channel for transaction.

--2.	What is the count of Male and Female customers in the database?

SELECT c.Gender , COUNT(DISTINCT(c.customer_Id)) AS Count_of_Gender
FROM Customer c
WHERE c.Gender IS NOT NULL
GROUP BY c.Gender

-- There are 2753 Females and 2892 Males and 2 NULL as and output.
-- ( We can comment the WHERE clause to get NULL COUNT if needed )

--3.	From which city do we have the maximum number of customers and how many?

SELECT TOP 1 c.city_code , COUNT(DISTINCT(c.customer_Id)) AS City_wise_count_of_Cust -- can use TOP 2 or 3 or any number to get list
FROM Customer c  
WHERE c.city_code IS NOT NULL
GROUP BY c.city_code
ORDER BY COUNT(DISTINCT(c.customer_Id)) DESC

-- From City - "3" we have max customers 595 available.

--4.	How many sub-categories are there under the Books category?

SELECT p.prod_cat , count(p.prod_subcat) as Count_SubCat_in_Books
FROM prod_cat_info p
WHERE p.prod_cat = 'Books'
GROUP BY p.prod_cat 

-- There are 6 sub-categories under the Books category.

--5.	What is the maximum quantity of products ever ordered?

SELECT t.prod_cat_code,sum(CAST(t.Qty AS smallint)) Sold_Qty
FROM Transactions t
GROUP BY t.prod_cat_code
ORDER BY sum(CAST(t.Qty AS smallint)) DESC

-- Maximum Ordered Category is Books Cat_Code -> 5 which is 14669 Qty is ordered 

--6.	What is the net total revenue generated in categories Electronics and Books?

SELECT sum(t.total_amt) Total_Revenue_ElectronicsBooks
FROM Transactions t
LEFT JOIN prod_cat_info p ON t.prod_cat_code =p.prod_cat_code
AND p.prod_sub_cat_code = t.prod_subcat_code
WHERE p.prod_cat IN('Books','Electronics')

-- The Revenue is 23545157.67 Approx

--7.	How many customers have >10 transactions with us, excluding returns?

-- To get only the number of customers having >10 txn and no returns , execute below code
-- Answer : The code will give count 6 . There are 6 such customers.

SELECT COUNT(k.cust_id) as No_of_Customers
FROM(SELECT t.cust_id,COUNT(t.cust_id) No_of_Txn
FROM [dbo].[Transactions] as t
WHERE t.total_amt > 0 
GROUP BY t.cust_id
HAVING COUNT(t.cust_id) > 10
) as k   

-- To get the list of such customers , run the below code.
SELECT t.cust_id,COUNT(t.cust_id) No_of_Txn
FROM [dbo].[Transactions] as t
WHERE t.total_amt > 0 
GROUP BY t.cust_id
HAVING COUNT(t.cust_id) > 10
ORDER BY COUNT(t.cust_id) DESC

--8. What is the combined revenue earned from the “Electronics” & “Clothing” categories, from “Flagship stores”?

SELECT sum(t.total_amt) Total_Revenue_ElectronicsBooks
FROM Transactions t
LEFT JOIN prod_cat_info p ON t.prod_cat_code =p.prod_cat_code
AND p.prod_sub_cat_code = t.prod_subcat_code
WHERE p.prod_cat IN('Clothing','Electronics') AND  t.Store_type like 'Flagship store'

-- Answer - Combined Revenue is 3409559.29 Approx

--9.What is the total revenue generated from “Male” customers in “Electronics” category? 
-- Output should display total revenue by prod sub-cat.

SELECT p.prod_subcat, SUM(t.total_amt) Revenue FROM [dbo].[Customer] c
LEFT JOIN [dbo].[Transactions] t ON c.customer_Id = t.cust_id
LEFT JOIN [dbo].[prod_cat_info] p ON p.prod_sub_cat_code = t.prod_subcat_code
WHERE p.prod_cat IN('Electronics') AND c.Gender = 'M'
GROUP BY p.prod_subcat


--10.	What is percentage of sales and returns by product sub category; display only top 5 sub categories in 
-- terms of sales?

USE RDA  


Select Top 5 t.prod_subcat_code,
Round(Sum(Cast(Case When Qty > 0 Then Qty Else 0 end as float)),2) Sales,
Round(Sum(Cast(Case When Qty < 0 Then Qty Else 0 end as Float)),2) Retrn,
Round(Sum(Cast(Case When Qty < 0 Then Qty Else 0 end as Float)),2)* 100/Round(Sum(Cast(Case When Qty > 0 Then Qty Else 0 end as float)),2) [asReturn%],
100 + Round(Sum(Cast(Case When Qty < 0 Then Qty Else 0 end as Float)),2)* 100/Round(Sum(Cast(Case When Qty > 0 Then Qty Else 0 end as float)),2) [Sales %]
from [dbo].[Transactions] t
group by t.prod_subcat_code 
Order By [Sales %]

--11.	For all customers aged between 25 to 35 years find what is the net total revenue 
-- generated by these consumers in last 30 days of transactions from max transaction date available in the data?
 
 SELECT t.cust_id,sum(total_amt) as Revenue  From [dbo].[Transactions] t
 WHERE t.cust_id IN 
      ( SELECT c.customer_Id 
        FROM Customer c
        WHERE ( DATEDIFF(YEAR, CONVERT(date , DOB , 103 ) , GETDATE()) between 25 AND 35)
        AND CONVERT(date , tran_date ,103) BETWEEN DATEADD(DAY,-30,(SELECT MAX(convert(date,tran_date,103)) FROM [dbo].[Transactions]))
            AND (SELECT MAX(convert(date,tran_date,103)) FROM [dbo].[Transactions] ))
 GROUP BY t.cust_id 
 -- there are 88 such customers who fall in the age group of 25 and 35 and transaction in last 30 days.

--12.	Which product category has seen the max value of returns in the last 3 months of transactions?

SELECT TOP 1 t.prod_cat_code , sum(t.total_amt) 
FROM Transactions t
LEFT JOIN prod_cat_info p ON p.prod_cat_code = t.prod_cat_code AND p.prod_sub_cat_code = t.prod_subcat_code
WHERE t.total_amt < 0 
AND 
CONVERT(DATE , t.tran_date ,103 ) BETWEEN DATEADD(Month,-3,(SELECT MAX(CONVERT(DATE, k.tran_date ,103)) FROM Transactions k))
AND (SELECT MAX(CONVERT(DATE, k.tran_date ,103)) FROM Transactions k)
GROUP BY t.prod_cat_code
ORDER BY sum(t.total_amt) ASC

--Category 5 , Books has max value of returns in the last 3 months.

--13.	Which store-type sells the maximum products; by value of sales amount and by quantity sold?

SELECT t.Store_type , SUM(convert(int,t.total_amt)) Total_Amount, SUM(convert(int,t.Qty)) Total_Qty
FROM Transactions t 
WHERE t.Qty > 0
group by t.Store_type
Order by SUM(convert(int,t.total_amt)) DESC , SUM(convert(int,t.Qty))

-- eShop sells Max products by Total amount of 22181497 Rs and Max Qty 25435 Followed by MBR 


--14.	What are the categories for which average revenue is above the overall average.
SELECT t.prod_cat_code,AVG(convert(int,t.total_amt)) as CatWise_AVG
FROM Transactions t 
LEFT JOIN [dbo].[prod_cat_info] p ON p.prod_cat_code = t.prod_cat_code AND p.prod_sub_cat_code = t.prod_subcat_code
WHERE t.Qty > 0
GROUP BY t.prod_cat_code
HAVING AVG(convert(int,t.total_amt)) > (SELECT AVG(convert(int,total_amt))  FROM Transactions WHERE Qty > 0 )

-- Overall Average across category is 2607 Rs . Category 1 ,3, 4, 5 are more Avg Revenue than the Overall Average.


--15.	Find the average and total revenue by each subcategory for the categories 
--  which are among top 5 categories in terms of quantity sold.

--To understand the top 5 categories run below code
SELECT TOP 5 p.prod_cat, sum(Cast(t.Qty as int)) Quantities_sold 
FROM prod_cat_info as p
inner join Transactions as t
ON p.prod_cat_code = t.prod_cat_code AND p.prod_sub_cat_code = t.prod_subcat_code
group by p.prod_cat
order by sum(Cast(t.Qty as int)) DESC

--To know average and total revenue by each subcategory among top 5 categories , run below code

Select prod_cat, prod_subcat , avg(total_amt) as average_Rev , sum(total_amt) as total_Rev
From transactions as t 
inner join prod_cat_info as p 
on t.prod_subcat_code=p.prod_sub_cat_code and t.prod_cat_code = p.prod_cat_code
Where prod_cat 
IN (Select Top 5 prod_cat
	From transactions as t 
	inner join prod_cat_info as p 
	on t.prod_subcat_code=p.prod_sub_cat_code and t.prod_cat_code = p.prod_cat_code
	Where total_amt > 0  AND qty > 0 
	Group by prod_cat
	Order by count(qty) DESC
	) 
Group by prod_cat, prod_subcat
Order by prod_cat ASC;


-----------------------------------Projected Completed --------------------------------------------