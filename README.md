# Customer Segmentation Analysis with SQL
In this project I used;
- olist_customers_dataset.csv file as customers table, <br>
- olist_order_items_dataset.csv as order_items table  <br>
- olist_orders_dataset.csv file as orders table  <br>

## 1) Filter the Tables and Check for Duplicates.
## 1.1) Customer table
### select * from customers limit 5;<br>

![customers](https://user-images.githubusercontent.com/114496063/209448400-b199ed90-ca02-4e38-b187-b1aa8bd9a934.png)

### select c.customer_id,count(*) as CustomerIDDuplicate from customers c group by c.customer_id having count(*)>1;

![customersDuplicate](https://user-images.githubusercontent.com/114496063/209448582-5c396ecf-001a-45ad-b2e5-04a9cd28a3b2.png)
## 1.2) orders table
### select * from orders limit 5;<br>

![orders](https://user-images.githubusercontent.com/114496063/209448409-bfac0dac-9e27-4909-b795-fcfeab9eff1b.png)

### select o.order_id,count(*) as OrderIDDuplicate from orders o group by o.order_id having count(*)>1;

![ordersDuplicate](https://user-images.githubusercontent.com/114496063/209448591-11fb6c60-9dae-4bb6-9ae8-cb63ad30b40d.png)
## 1.3) order_items table
### select * from order_items limit 5;<br>

![order_items](https://user-images.githubusercontent.com/114496063/209448402-981fa596-13f3-498a-b87f-5de1be449b20.png)

### select oi.order_id,count(*) as OrderIDDuplicate from order_items oi group by oi.order_id having count(*)>1 order by OrderIDDuplicate desc limit 5 ;

## 1.3.1) order_items table has order_ids more than 1. Let's check one of them.

### select * from order_items oi where oi.order_id='8272b63d03f5f79c56e9e4120aec44ef' <br>

![orderitemfiltered](https://user-images.githubusercontent.com/114496063/209448837-492d1036-efc1-4640-a8e5-525d6aa9208d.png)

## As we can see, before we join order_items table with orders and customers table, we need to use group by function to sum all rows of price and freight value columns to avoid duplicate customers and orders.

## 2) Create one single view

SELECT c.customer_id,c.customer_state,c.customer_city,round(sum(oi.price+oi.freight_value),2) as TotalSpendbyCustomer, <br>
round(sum(oi.price+oi.freight_value) over (),2) as TotalSales,count(o.order_id) as TotalOrdersByCustomer, <br>
round(sum(oi.price+oi.freight_value) over () / count(oi.order_item_id) over (),2) as AvgSpendByCustomer, <br>
count(o.order_id) over () as TotalOrders,max(STR_TO_DATE(o.order_purchase_timestamp, "%m/%d/%Y")) as LastOrderDateByCustomer, <br>
max(STR_TO_DATE(o.order_purchase_timestamp, "%m/%d/%Y")) over () as LastOrderDate, <br>
DATEDIFF(max(STR_TO_DATE(o.order_purchase_timestamp, "%m/%d/%Y")) over (),max(STR_TO_DATE(o.order_purchase_timestamp, "%m/%d/%Y")))   <br>
as DateDiffFromLastOrderByCustomer FROM  customers c  <br>
inner join orders o on o.customer_id=c.customer_id  <br>
inner join order_items oi on oi.order_id=o.order_id  <br>
group by c.customer_id,c.customer_state,c.customer_city limit 10;  <br>

![singleview1](https://user-images.githubusercontent.com/114496063/209449137-7b7f4e42-8e04-4ce2-9301-55574450da8f.png)


