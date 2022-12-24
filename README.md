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
## 1.1) order_items table
### select * from order_items limit 5;<br>

![order_items](https://user-images.githubusercontent.com/114496063/209448402-981fa596-13f3-498a-b87f-5de1be449b20.png)

### select oi.order_id,count(*) as OrderIDDuplicate from order_items oi group by oi.order_id having count(*)>1 order by OrderIDDuplicate desc limit 5 ;

## order_items table has order_ids more than 1. Let's check one of them.

### select * from order_items oi where oi.order_id='8272b63d03f5f79c56e9e4120aec44ef' <br>

![orderitemfiltered](https://user-images.githubusercontent.com/114496063/209448837-492d1036-efc1-4640-a8e5-525d6aa9208d.png)






