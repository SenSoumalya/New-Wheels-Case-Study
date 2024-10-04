/*

-----------------------------------------------------------------------------------------------------------------------------------
													    Guidelines
-----------------------------------------------------------------------------------------------------------------------------------

Please read the instructions carefully before starting the project.
This is a sql file in which all the instructions and tasks to be performed are mentioned. Read along carefully to complete the project.

Blanks '___' are provided in the notebook that needs to be filled with an appropriate code to get the correct result. Please replace 
the blank with the right code snippet. With every '___' blank.
Identify the task to be performed correctly, and only then proceed to write the required code.
Please run the codes in a sequential manner from the beginning to avoid any unnecessary errors.
Use the results/observations derived from the analysis here to create the business report.

The provided document is a guide for the project. Follow the instructions and take the necessary steps to finish
the project in the SQL file			

-----------------------------------------------------------------------------------------------------------------------------------
                                                         Queries
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/
  
/*-- QUESTIONS RELATED TO CUSTOMERS
     [Q1] What is the distribution of customers across states?
     Hint: For each state, count the number of customers.*/

SELECT 
      state, 
      COUNT(customer_id) as no_of_customers
FROM customer_t
GROUP BY 1
ORDER BY 2 DESC;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q2] What is the average rating in each quarter?
-- Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.

Hint: Use a common table expression and in that CTE, assign numbers to the different customer ratings. 
      Now average the feedback for each quarter. 

Note: For reference, refer to question number 4. Week-2: mls_week-2_gl-beats_solution-1.sql. 
      You'll get an overview of how to use common table expressions from this question.*/


WITH feed_bucket AS
(
    SELECT 
	CASE 
			WHEN customer_feedback = 'Very Good' THEN 5
			WHEN customer_feedback = 'good' THEN '4'
            WHEN customer_feedback = 'okay' THEN '3'
            WHEN customer_feedback = 'bad' THEN '2'
            WHEN customer_feedback = 'very bad' THEN '1'
			END AS feedback_count,
            quarter_number
	FROM order_t
)
SELECT 
      quarter_number,
      ROUND(AVG(feedback_count), 2) avg_feedback
FROM feed_bucket
group by quarter_number
ORDER BY 1;



-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q3] Are customers getting more dissatisfied over time?

Hint: Need the percentage of different types of customer feedback in each quarter. Use a common table expression and
	  determine the number of customer feedback in each category as well as the total number of customer feedback in each quarter.
	  Now use that common table expression to find out the percentage of different types of customer feedback in each quarter.
      Eg: (total number of very good feedback/total customer feedback)* 100 gives you the percentage of very good feedback.
      
Note: For reference, refer to question number 4. Week-2: mls_week-2_gl-beats_solution-1.sql. 
      You'll get an overview of how to use common table expressions from this question.*/
      
WITH cust_feedback AS
(
	SELECT 
		quarter_number,
		SUM(CASE WHEN customer_feedback = 'Very Good' THEN 1 ELSE 0 END) AS very_good,
		SUM(CASE WHEN customer_feedback = 'good' THEN 1 ELSE 0 END) AS good,
        SUM(CASE WHEN customer_feedback = 'okay' THEN 1 ELSE 0 END) AS okay,
        SUM(CASE WHEN customer_feedback = 'bad' THEN 1 ELSE 0 END) AS bad,
        SUM(CASE WHEN customer_feedback = 'very bad' THEN 1 ELSE 0 END) AS very_bad,
		COUNT(customer_feedback) AS total_feedbacks
	FROM order_t
	GROUP BY 1
)
SELECT quarter_number,
        (very_good/total_feedbacks)*100 perc_very_good,
        (good/total_feedbacks)*100  perc_good,
        (okay/total_feedbacks)*100 perc_okay,
        (bad/total_feedbacks)*100 perc_bad,
        (very_bad/total_feedbacks)*100 perc_very_bad
FROM cust_feedback
ORDER BY 1;


-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q4] Which are the top 5 vehicle makers preferred by the customer.

Hint: For each vehicle make what is the count of the customers.*/

SELECT
      vehicle_maker,
      COUNT(cust.customer_id) as number_of_customers
FROM product_t pro 
	join order_t ord
	    ON pro.product_id = ord.product_id
	join customer_t cust
	    ON ord.customer_id = cust.customer_id
GROUP BY 1
ORDER BY 2 desc
limit 5;  

-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q5] What is the most preferred vehicle make in each state?

Hint: Use the window function RANK() to rank based on the count of customers for each state and vehicle maker. 
After ranking, take the vehicle maker whose rank is 1.*/

SELECT state, vehicle_maker FROM (
	SELECT
		  state,
		  vehicle_maker,
		  COUNT(cust.customer_id) AS no_of_cust,
		  RANK() OVER (PARTITION BY state ORDER BY COUNT(cust.customer_id) DESC) AS rnk
FROM product_t pro 
	join order_t ord
	    ON pro.product_id = ord.product_id
	join customer_t cust
	    ON ord.customer_id = cust.customer_id
	GROUP BY state,
		  vehicle_maker) tbl
WHERE rnk = 1;




-- ---------------------------------------------------------------------------------------------------------------------------------

/*QUESTIONS RELATED TO REVENUE and ORDERS 

-- [Q6] What is the trend of number of orders by quarters?

Hint: Count the number of orders for each quarter.*/


SELECT 
	  quarter_number, 
	  count(order_id) as total_orders
FROM order_t
GROUP BY 1
ORDER BY 1 ASC;




-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q7] What is the quarter over quarter % change in revenue? 

Hint: Quarter over Quarter percentage change in revenue means what is the change in revenue from the subsequent quarter to the previous quarter in percentage.
      To calculate you need to use the common table expression to find out the sum of revenue for each quarter.
      Then use that CTE along with the LAG function to calculate the QoQ percentage change in revenue.
*/
      
      
WITH QoQ AS 
(
	SELECT
		  quarter_number,
		  ROUND(SUM(quantity * (vehicle_price - ((discount/100)*vehicle_price))), 0) AS revenue
	FROM order_t
	GROUP BY quarter_number
)
SELECT
      quarter_number,
  	  revenue,
      ROUND(LAG(revenue) OVER(ORDER BY quarter_number), 2) AS previous_revenue,
      ROUND((revenue - LAG(revenue) OVER(ORDER BY quarter_number))/LAG(revenue) OVER(ORDER BY quarter_number), 2) AS qoq_perc_change
FROM QoQ;
      
      

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q8] What is the trend of revenue and orders by quarters?

Hint: Find out the sum of revenue and count the number of orders for each quarter.*/


SELECT  
      quarter_number,
      ROUND(SUM(quantity*vehicle_price), 0) AS revenue,
      COUNT(order_id) AS total_orders
FROM order_t
GROUP BY quarter_number
ORDER BY 1;




-- ---------------------------------------------------------------------------------------------------------------------------------

/* QUESTIONS RELATED TO SHIPPING 
    [Q9] What is the average discount offered for different types of credit cards?

Hint: Find out the average of discount for each credit card type.*/

SELECT 
     credit_card_type, 
     ROUND(AVG(discount), 2) AS average_discount
FROM order_t ord 
join customer_t cust
	ON ord.customer_id = cust.customer_id
GROUP BY 1
ORDER BY 2 DESC;


-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q10] What is the average time taken to ship the placed orders for each quarters?
	Hint: Use the dateiff function to find the difference between the ship date and the order date.
*/

SELECT 
      quarter_number, 
       ROUND(AVG(DATEDIFF(ship_date, order_date)), 0) AS average_shipping_time
FROM order_t
GROUP BY 1
ORDER BY 1;



-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------



