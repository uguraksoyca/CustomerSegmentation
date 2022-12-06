# CustomerSegmentation
In this project I imported 3 excel files to SQL.
First I created a single view by joining the tables and adding new columns such as TotalSpendbyCustomer,TotalOrdersByCustomer.
To calculate total points for each customer I needed to find total spend point, total order point and total date difference from last order point.
By creating avg, max and min of totals and analysing them, I found intervals. Then I wrote case when functions to create total spend point, total 
order point and total date difference from last order point. After thar I sum up these 3 columns to calcualte Total poitns by customer.
Finally I created Segmentation of customers by total points.
