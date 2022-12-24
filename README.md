# CustomerSegmentation
In this project I imported <br>
- olist_customers_dataset.csv file as customers table, <br>
- olist_order_items_dataset.csv as order_items table  <br>
- olist_orders_dataset.csv file as orders table to SQL.  <br>
First I created a single view by joining the tables and adding new columns such as TotalSpendbyCustomer,TotalOrdersByCustomer.
To calculate total points for each customer I needed to find total spend point, total order point and date difference from last order point.
By creating avg, max and min of totals and analysing them, I found intervals. Then I wrote case when functions to create total spend point, total 
order point and total date difference from last order point. After thar I sum up these 3 columns to calcualte Total points by customer.
Finally I created Segmentation of customers by total points.
