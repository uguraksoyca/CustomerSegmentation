/* creating one view to calculate total points based on total spend, total orders and 
difference between last order date and customer's last order date*/
create view customerordersview as 
select x.*,max(x.TotalOrdersByCustomer) over() as MaxOrdersByCustomer,min(x.DateDiffFromLastOrderByCustomer) over() as MinDateDiffFromLastOrder,
max(x.DateDiffFromLastOrderByCustomer) over() as MaxDateDiffFromLastOrder,avg(x.DateDiffFromLastOrderByCustomer) over() as AvgDateDiffFromLastOrder from (
SELECT c.customer_id,c.customer_state,c.customer_city,round(sum(oi.price+oi.freight_value),2) as TotalSpendbyCustomer,
round(sum(oi.price+oi.freight_value) over (),2) as TotalSales,count(o.order_id) as TotalOrdersByCustomer,
round(sum(oi.price+oi.freight_value) over () / count(oi.order_item_id) over (),2) as AvgSpendByCustomer,
count(o.order_id) over () as TotalOrders,max(STR_TO_DATE(o.order_purchase_timestamp, "%m/%d/%Y")) as LastOrderDateByCustomer,
max(STR_TO_DATE(o.order_purchase_timestamp, "%m/%d/%Y")) over () as LastOrderDate,
DATEDIFF(max(STR_TO_DATE(o.order_purchase_timestamp, "%m/%d/%Y")) over (),max(STR_TO_DATE(o.order_purchase_timestamp, "%m/%d/%Y"))) as DateDiffFromLastOrderByCustomer FROM  customers c
inner join orders o on o.customer_id=c.customer_id
inner join order_items oi on oi.order_id=o.order_id
group by c.customer_id,c.customer_state,c.customer_city) x;

/* Creating customer segmentation*/
create view segmentationview as 
Select x.*,x.TotalSpendPoints+x.TotalOrderPoints+x.TotalDaysDiffPoints as TotalPoints,
case when x.TotalSpendPoints+x.TotalOrderPoints+x.TotalDaysDiffPoints >12 then "Champions"
when x.TotalSpendPoints+x.TotalOrderPoints+x.TotalDaysDiffPoints >8 then "Loyal customers"
when x.TotalSpendPoints+x.TotalOrderPoints+x.TotalDaysDiffPoints >4 then "Potential Loyalists"
else "At Risk Customers" end as CustomerSegment from (
select c.*,case when c.TotalSpendbyCustomer>=c.AvgSpendByCustomer*2 then 5
when c.TotalSpendbyCustomer>=c.AvgSpendByCustomer then 4
when c.TotalSpendbyCustomer>=c.AvgSpendByCustomer*0.7 then 3
when c.TotalSpendbyCustomer>=c.AvgSpendByCustomer*0.4 then 2
else 1 end as TotalSpendPoints,
case when c.totalOrdersByCustomer>=c.MaxOrdersByCustomer*0.8 then 5
when c.totalOrdersByCustomer>=c.MaxOrdersByCustomer*0.5 then 4
when c.totalOrdersByCustomer>=c.MaxOrdersByCustomer*0.2 then 3
when c.totalOrdersByCustomer>=c.MaxOrdersByCustomer*0.1 then 2
else 1 end as TotalOrderPoints,
case when c.DateDiffFromLastOrderByCustomer<=c.MaxDateDiffFromLastOrder*0.1 then 5
when c.DateDiffFromLastOrderByCustomer<=c.MaxDateDiffFromLastOrder*0.2 then 4
when c.DateDiffFromLastOrderByCustomer<=c.MaxDateDiffFromLastOrder*0.3 then 3
when c.DateDiffFromLastOrderByCustomer<=c.MaxDateDiffFromLastOrder*0.5 then 2
else 1 end as TotalDaysDiffPoints from customerordersview c) x ;

/*Total Numbers of Customers based on Segmentation  and avg spend*/
Select s.CustomerSegment,count(*) as TotalCustomerNumbers,round(avg(s.totalSpendByCustomer),2) as totalSpend from segmentationview s
group by s.CustomerSegment;

/*Total Numbers of Customers based on Segmentation,state and avg spend*/
Select s.CustomerSegment,s.customer_state,count(*) as TotalCustomerNumbers,round(avg(s.totalSpendByCustomer),2) as totalSpend from segmentationview s
group by s.CustomerSegment,s.customer_state;

/* States which don't have Champions*/
select y.customer_state from (
select distinct s.customer_state,x.customer_state as customer_state2 from segmentationview s 
left join (
select distinct s.customer_state from segmentationview s where s.CustomerSegment="Champions") x
on s.customer_state=x.customer_state) y where y.customer_state2 is null







