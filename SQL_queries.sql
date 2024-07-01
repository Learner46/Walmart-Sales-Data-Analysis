 create database walmart_sales
 
-- Create table
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

-- ----------------------------------Feature Engineering -------------------------------
		
# time_to_day

select time from sales 

select time,
     (case 
          when `time` between "00:00:00" and "12:00:00" then "Mornin"
          when `time` between "12:01:00" and  "16:00:00" then "afternoon"
          else "evening"
	 end ) as time_of_date
from sales;

alter table sales  add column time_of_day varchar(50)

update sales 
set time_of_day = (
	case 
          when `time` between "00:00:00" and "12:00:00" then "Mornin"
          when `time` between "12:01:00" and  "16:00:00" then "afternoon"
          else "evening"
	 end )
-- ---------------------------------------------------------------------------------------

-- day name

select date ,
       dayname(date) as day_name
from sales

alter table sales add column day_name varchar(10)

update sales
set day_name =  dayname(date)

-- ---------------------------------------------------------------------------------------

-- month name

select date, monthname(date) from sales as month_name

alter table sales add column month_name varchar(20)

update sales 
set month_name = monthname(date)

-- ---------------------------------------------------------------------------------------
-- ------------------------Generic Question---------------------------------

-- 1) How many unique cities does the data have?

select distinct(city) 
from sales

-- 2) In which city is each branch?

select distinct (city), branch
from sales
 
-- ---------------------Product_question------------------------------------
 
-- 1) How many unique product lines does the data have?

select count(distinct product_line) from sales
           
-- 2) What is the most common payment method?

select payment,
      count(payment) as cnt from sales
group by payment 
order by cnt desc limit 1

--  3) What is the most selling product line? 

select product_line,
	 count(product_line) as most_selling_product from sales
group by product_line 
order by most_selling_product desc limit 1

-- 4) What is the total revenue by month? 

select month_name,
       sum(total) as total_revenue from sales
       group by month_name
       order by total_revenue desc limit 1
       
-- 5)  What month had the largest COGS?

select month_name , 
        sum(cogs) as largest_cogs from sales
        group by month_name 
        order by largest_cogs desc limit 1
        
-- 6) What product line had the largest revenue?

select product_line,
        sum(total) as largest_revenue from sales
        group by product_line
        order by largest_revenue desc limit 1
        
-- 7) What is the city with the largest revenue?

select city, 
      sum(total) as largest_rev from sales
      group by city 
      order by largest_rev desc limit 1
      
-- 8)  What product line had the largest VAT?

select product_line,
        sum(tax_pct) from sales
        group by product_line 
        order by sum(tax_pct) desc limit 1
        
-- -------------------------------------------------------------------------        
-- 9) Fetch each product line and add a column to those product line showing "Good", "Bad". 
   --  Good if its greater than average sales
   
SET @avg_total = (SELECT AVG(total) FROM sales)
                  
alter table sales add column feedback varchar(10)

update sales 
set feedback = (
                case
                  when total > @avg_total  then 'good'
                  else 'bad'
                  end )

-- -----------------------------------------------------------------------------

-- 10) Which branch sold more products than average product sold?

select branch,
       sum(quantity) as qty
       from sales
       group by branch
       having sum(quantity) > (select avg(quantity) from sales)

-- 11) What is the most common product line by gender?

select  gender , product_line,
        count(gender) as total_cnt from sales
        group by gender, product_line
        order by total_cnt desc
        
-- 12) What is the average rating of each product line?

select product_line , 
       round(avg(rating),2) as avg_rating from sales
       group by product_line
       
-- ----------------------------Sales_Questions----------------------------------------

-- 1)Number of sales made in each time of the day per weekday?

select time_of_day,
       count(*)  as total_sales
       from sales
       where day_name in ('Monday','Tuesday', 'Wednesday', 'Thursday', 'Friday')
       group by time_of_day
       order by time_of_day desc
       
-- 2) Which of the customer types brings the most revenue?

select customer_type,
       sum(total) as TR
       from sales
       group by customer_type
       order by TR desc
       
-- 3) Which city has the largest tax percent/ VAT (Value Added Tax)?

select city,
        sum(tax_pct) as VAT
        from sales
        group by city
        order by VAT desc
        
-- 4) Which customer type pays the most in VAT?

SELECT customer_type,
       sum(tax_pct) as VAT
       from sales
       group by customer_type
       order by VAT desc
       
-- --------------------------customer----------------------------------------
       
 -- 1) How many unique customer types does the data have?
 
 select distinct customer_type,
        count(*) as unique_type
        from sales
        group by customer_type
        
 
-- 2) How many unique payment methods does the data have?

select distinct payment,
       count(*) as cnt
       from sales
       group by payment
       
-- 3) What is the most common customer type?
      
select  customer_type,
         count(*) as common_customer_type
        from sales
        group by customer_type
        order by common_customer_type desc limit 1
        
-- 4)  Which customer type buys the most?

select customer_type,
       count(quantity) as total_quantity
       from sales
       group by customer_type
       
-- 5) What is the gender of most of the customers?

select gender, 
       count(*) as cnt
       from sales
       group by gender
       
-- 6) What is the gender distribution per branch?

select gender,branch,
       count(gender) as cnt
       from sales
       group by gender, branch
       order by branch
       
-- 7) Which time of the day do customers give most ratings?

select time_of_day,
       count(rating) as Rating
       from sales
       group by time_of_day
       order by Rating desc
       
-- 8) Which time of the day do customers give most ratings per branch?

select time_of_day,branch,
       count(rating) as Rating
       from sales
       group by time_of_day,branch
       order  by branch
       
-- 9) Which day for the week has the best avg ratings?

select day_name,
       avg(rating) as best_avg
       from sales
       group by day_name
       order by best_avg desc 
       
-- 10) Which day of the week has the best average ratings per branch?

select day_name, branch,
       avg(rating) as best_avg
       from sales
       group by day_name,branch
       order by branch

-- --------------------------------------------------------------------------
       
       
       


  


 



           
           