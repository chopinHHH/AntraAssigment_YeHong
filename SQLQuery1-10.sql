-- 1. List of Persons' full name, all their fax and phone numbers, 
-- as well as the phone number and fax of the company they are working for (if any). 
select p.FullName, p.FaxNumber, p.PhoneNumber, c.FaxNumber as Company_fax, c.PhoneNumber as Company_phone
from Application.People p left join Sales.Customers c
on p.PersonID=c.PrimaryContactPersonID


-- 2. If the customer's primary contact person has the same phone number as the customer's phone number, list the customer companies. 
select c.CustomerName 
from Application.People p join Sales.Customers c
on p.PersonID=c.PrimaryContactPersonID and p.FaxNumber=c.FaxNumber and p.PhoneNumber=c.PhoneNumber


-- 3. List of customers to whom we made a sale prior to 2016 but no sale since 2016-01-01.
select c.CustomerName from sales.Customers c
join sales.CustomerTransactions ct
on c.CustomerID=ct.CustomerID
where c.CustomerID not in (select distinct CustomerID from sales.CustomerTransactions where year(TransactionDate)>=2016)


-- 4. List of Stock Items and total quantity for each stock item in Purchase Orders in Year 2013.
select si.StockItemName, sum(ol.Quantity) as total_quantity
from Warehouse.StockItems si left join Sales.OrderLines ol
on ol.StockItemID=si.StockItemID
left join Sales.Orders o
on ol.OrderID=o.OrderID
where year(o.OrderDate)=2013
group by si.StockItemName


-- 5. List of stock items that have at least 10 characters in description.
select StockItemName --, pol.Description 
from Warehouse.StockItems s left join Purchasing.PurchaseOrderLines pol
on s.StockItemID=pol.StockItemID
where len(pol.Description) >= 10


-- 6. List of stock items that are not sold to the state of Alabama and Georgia in 2014.
select distinct si.StockItemName
from Warehouse.StockItems si left join sales.OrderLines ol
on ol.StockItemID=si.StockItemID
left join Sales.Orders o 
on o.OrderID=ol.OrderID and year(o.OrderDate)=2014
left join Sales.Customers c
on c.CustomerID=o.CustomerID
join Application.Cities ci
on ci.CityID = c.DeliveryCityID
join Application.StateProvinces p 
on p.StateProvinceID=ci.StateProvinceID and p.StateProvinceName not in ('Alabama','Georgia')


-- 7. List of States and Avg dates for processing (confirmed delivery date ¨C order date).
select p.StateProvinceName,
avg(datediff(DAY,CAST(o.orderdate as datetime2),(ConfirmedDeliveryTime))) as date_diff
from sales.Orders o left join sales.Invoices i
on o.OrderID=i.OrderID
left join Sales.Customers c
on c.CustomerID=o.CustomerID
join Application.Cities ci
on ci.CityID = c.DeliveryCityID
join Application.StateProvinces p 
on p.StateProvinceID=ci.StateProvinceID
group by p.StateProvinceName
order by 1


-- 8. List of States and Avg dates for processing (confirmed delivery date ¨C order date) by month.
-- First Solution
select p.StateProvinceName,month(o.orderdate) as [Month],
avg(datediff(DAY,CAST(o.orderdate as datetime2),(ConfirmedDeliveryTime))) as date_diff
from sales.Orders o left join sales.Invoices i
on o.OrderID=i.OrderID
left join Sales.Customers c
on c.CustomerID=o.CustomerID
join Application.Cities ci
on ci.CityID = c.DeliveryCityID
join Application.StateProvinces p 
on p.StateProvinceID=ci.StateProvinceID
group by p.StateProvinceName,month(o.orderdate)
order by 1,2

-- 2nd Solution - Pivot Table
Select StateProvinceName as StateProvinceName,
	[1] AS Jan,[2] AS Feb,[3] AS Mar,[4] AS Apr,[5] AS May,[6] AS Jun,
	[7] AS Jul,[8] AS Aug,[9] AS Sep,[10] AS Oct,[11] AS Nov,[12] AS Dec
From
(select p.StateProvinceName,month(o.orderdate) as [Month],
avg(datediff(DAY,CAST(o.orderdate as datetime2),i.ConfirmedDeliveryTime)) as date_diff
from sales.Orders o left join sales.Invoices i on o.OrderID=i.OrderID 
left join Sales.Customers c on c.CustomerID=o.CustomerID 
join Application.Cities ci on ci.CityID = c.DeliveryCityID 
join Application.StateProvinces p on p.StateProvinceID=ci.StateProvinceID
group by p.StateProvinceName, month(o.orderdate)) as ST
Pivot
(max(St.date_diff)
For Month In ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
)as PT 
order by StateProvinceName


-- 9. List of StockItems that the company purchased more than sold in the year of 2015.
select si.StockItemName
, sum(pol.ReceivedOuters), sum(ol.Quantity) 
from Purchasing.PurchaseOrderLines pol join sales.OrderLines ol
on pol.StockItemID=ol.StockItemID
left join sales.Orders o 
on o.OrderID=ol.OrderID
left join purchasing.PurchaseOrders po 
on po.PurchaseOrderID=pol.PurchaseOrderID
left join Warehouse.StockItems si 
on si.StockItemID=pol.StockItemID
where year(o.OrderDate) = 2015 and year(po.OrderDate) = 2015
group by si.StockItemName


-- 10. List of Customers and their phone number, together with the primary contact person's name, 
-- to whom we did not sell more than 10 mugs (search by name) in the year 2016.
select c.CustomerName, c.PhoneNumber, c.FaxNumber, p.FullName 
--, ol.Description, sum(ol.Quantity) as Total_Sell
from sales.Customers c left join Application.People p
on c.PrimaryContactPersonID=p.PersonID
left join Sales.Orders o on o.CustomerID=c.CustomerID
left join Sales.OrderLines ol on o.OrderID=ol.OrderID and year(o.OrderDate)=2016
where ol.Description like '%mug%'
group by c.CustomerName, c.PhoneNumber, c.FaxNumber, p.FullName
having sum(ol.Quantity)<=10