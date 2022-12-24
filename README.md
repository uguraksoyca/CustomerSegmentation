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

## 2.1) Join all tables, then create new columns like total orders, total sales and TotalOrdersByCustomer. To find dates, first we need to use STR_TO_DATE function to convert text values to date.

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

## 2.2) Create one single view by using create view statement

## Ceating one view to calculate total points based on total spend, total orders and difference between last order date and customer's last order date
create view customer_orders_view as 
select x.*,max(x.TotalOrdersByCustomer) over() as MaxOrdersByCustomer,min(x.DateDiffFromLastOrderByCustomer) over() as MinDateDiffFromLastOrder, <br>
max(x.DateDiffFromLastOrderByCustomer) over() as MaxDateDiffFromLastOrder,avg(x.DateDiffFromLastOrderByCustomer) over() as AvgDateDiffFromLastOrder from ( <br>
SELECT c.customer_id,c.customer_state,c.customer_city,round(sum(oi.price+oi.freight_value),2) as TotalSpendbyCustomer, <br>
round(sum(oi.price+oi.freight_value) over (),2) as TotalSales,count(o.order_id) as TotalOrdersByCustomer, <br>
round(sum(oi.price+oi.freight_value) over () / count(oi.order_item_id) over (),2) as AvgSpendByCustomer, <br>
count(o.order_id) over () as TotalOrders,max(STR_TO_DATE(o.order_purchase_timestamp, "%m/%d/%Y")) as LastOrderDateByCustomer, <br>
max(STR_TO_DATE(o.order_purchase_timestamp, "%m/%d/%Y")) over () as LastOrderDate, <br>
DATEDIFF(max(STR_TO_DATE(o.order_purchase_timestamp, "%m/%d/%Y")) over (), <br>
max(STR_TO_DATE(o.order_purchase_timestamp, "%m/%d/%Y"))) as DateDiffFromLastOrderByCustomer  FROM  customers c <br>
inner join orders o on o.customer_id=c.customer_id <br>
inner join order_items oi on oi.order_id=o.order_id  <br>
group by c.customer_id,c.customer_state,c.customer_city) x; <br>

## 2.3) select customer_orders_view

### select * from customer_orders_view limit 10;

![singleview2](https://user-images.githubusercontent.com/114496063/209449370-97320da2-6eac-42ac-b627-c26e6c6532f3.png)

## 3) Create Segmentation

create view segmentationview as   <br>
Select x.*,x.TotalSpendPoints+x.TotalOrderPoints+x.TotalDaysDiffPoints as TotalPoints,  <br>
case when x.TotalSpendPoints+x.TotalOrderPoints+x.TotalDaysDiffPoints >12 then "Champions"  <br> 
when x.TotalSpendPoints+x.TotalOrderPoints+x.TotalDaysDiffPoints >8 then "Loyal customers"  <br>
when x.TotalSpendPoints+x.TotalOrderPoints+x.TotalDaysDiffPoints >4 then "Potential Loyalists"  <br>
else "At Risk Customers" end as CustomerSegment from (  <br>
select c.*,case when c.TotalSpendbyCustomer>=c.AvgSpendByCustomer*2 then 5  <br>
when c.TotalSpendbyCustomer>=c.AvgSpendByCustomer then 4  <br>
when c.TotalSpendbyCustomer>=c.AvgSpendByCustomer*0.7 then 3  <br>
when c.TotalSpendbyCustomer>=c.AvgSpendByCustomer*0.4 then 2  <br>
else 1 end as TotalSpendPoints,  <br>
case when c.totalOrdersByCustomer>=c.MaxOrdersByCustomer*0.8 then 5  <br>
when c.totalOrdersByCustomer>=c.MaxOrdersByCustomer*0.5 then 4  <br>
when c.totalOrdersByCustomer>=c.MaxOrdersByCustomer*0.2 then 3  <br>
when c.totalOrdersByCustomer>=c.MaxOrdersByCustomer*0.1 then 2  <br>
else 1 end as TotalOrderPoints,  <br>
case when c.DateDiffFromLastOrderByCustomer<=c.MaxDateDiffFromLastOrder*0.1 then 5  <br>
when c.DateDiffFromLastOrderByCustomer<=c.MaxDateDiffFromLastOrder*0.2 then 4  <br>
when c.DateDiffFromLastOrderByCustomer<=c.MaxDateDiffFromLastOrder*0.3 then 3  <br>
when c.DateDiffFromLastOrderByCustomer<=c.MaxDateDiffFromLastOrder*0.5 then 2  <br>
else 1 end as TotalDaysDiffPoints from customerordersview c) x ;  <br>

## 3.1) Total Numbers of Customers based on Segmentation  and avg spend  <br>
Select s.CustomerSegment,count(*) as TotalCustomerNumbers,round(avg(s.totalSpendByCustomer),2) as totalSpend from segmentationview s  <br>
group by s.CustomerSegment;  <br>

![segmentation1](https://user-images.githubusercontent.com/114496063/209449557-7710f26c-6be8-457c-81fe-9f08de453a31.png)

## 3.2) Total Numbers of Customers based on Segmentation,state and avg spend  <br>
Select s.CustomerSegment,s.customer_state,count(*) as TotalCustomerNumbers,round(avg(s.totalSpendByCustomer),2) as totalSpend from segmentationview s  <br>
group by s.CustomerSegment,s.customer_state;  <br>

![segmentation2](https://user-images.githubusercontent.com/114496063/209449559-a515df23-7978-4327-b7e0-1979dba6af59.png)

## 3.3) States which don't have Champions  <br>
select y.customer_state from (  <br>
select distinct s.customer_state,x.customer_state as customer_state2 from segmentationview s   <br>
left join (  <br>
select distinct s.customer_state from segmentationview s where s.CustomerSegment="Champions") x  <br>
on s.customer_state=x.customer_state) y where y.customer_state2 is null;  <br>

![segmentation3](https://user-images.githubusercontent.com/114496063/209449562-d9d9bec3-e977-412a-8813-320d7e1f9cf2.png)
