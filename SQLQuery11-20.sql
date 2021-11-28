-- 11. List all the cities that were updated after 2015-01-01.
select * from Application.Cities
where ValidFrom >= '2015-01-01'


-- 12. List all the Order Detail (Stock Item name, delivery address, delivery state, city, country, 
-- customer name, customer contact person name, customer phone, quantity) for the date of 2014-07-01. 
-- Info should be relevant to that date.
select si.StockItemName, o.OrderDate, c.CustomerName, c1.CustomerName as CustomerContactPerson, c.PhoneNumber,
c.DeliveryAddressLine1, c.DeliveryAddressLine2, sp.StateProvinceName, cty.CountryName, ol.Quantity
from Sales.OrderLines ol left join Warehouse.StockItems si
on si.StockItemID=ol.StockItemID
left join Sales.Orders o
on o.OrderID=ol.OrderID
left join Sales.Customers c on c.CustomerID=o.CustomerID
left join Application.Cities cy on cy.CityID=c.DeliveryCityID
left join Application.StateProvinces sp on sp.StateProvinceID=cy.StateProvinceID
left join Application.Countries cty on cty.CountryID=sp.CountryID
left join Sales.Customers c1 on c1.CustomerID=o.ContactPersonID
where o.OrderDate='2014-07-01'


-- 13. List of stock item groups and total quantity purchased, total quantity sold, 
-- and the remaining stock quantity (quantity purchased ¨C quantity sold)
select *, total_quan_purchased - total_quan_sold as remain_quan from
(select sg.StockGroupName,
coalesce(sum(cast(pol.OrderedOuters as bigint)),0) as total_quan_purchased,
coalesce(sum(cast(ol.Quantity as bigint)),0) as total_quan_sold
from Warehouse.StockGroups sg left join Warehouse.StockItemStockGroups sisg
on sisg.StockGroupID=sg.StockGroupID
left join Warehouse.StockItems si 
on si.StockItemID=sisg.StockItemID
left join Purchasing.PurchaseOrderLines pol
on pol.StockItemID=si.StockItemID
left join Sales.OrderLines ol
on ol.StockItemID=si.StockItemID
group by sg.StockGroupName) a


-- 14. List of Cities in the US and the stock item that the city got the most deliveries in 2016. 
-- If the city did not purchase any stock items in 2016, print “No Sales”.
select a.CityID,a.CityName,a.StateProvinceName,
Coalesce(a.StockItemName,'No Sales') as StockItemName, a.PurchasedQuantity from
(select ci.CityID,ci.CityName,sp.StateProvinceName,si.StockItemName,
count(i.InvoiceID) as PurchasedQuantity,
DENSE_RANK() over (partition by ci.CityID,ci.CityName,sp.StateProvinceName order by count(i.invoiceID) desc) as rnk
from Application.Cities ci left join Application.StateProvinces sp
on sp.StateProvinceID=ci.StateProvinceID
left join Sales.Customers c 
on c.DeliveryCityID=ci.CityID
left join Sales.Invoices i
on i.CustomerID=c.CustomerID and year(i.ConfirmedDeliveryTime)=2016
left join Sales.InvoiceLines il
on il.InvoiceID=i.InvoiceID
left join Warehouse.StockItems si
on si.StockItemID=il.StockItemID
group by ci.CityID,ci.CityName,sp.StateProvinceName,si.StockItemName) a
where a.rnk=1


-- 15. List any orders that had more than one delivery attempt (located in invoice table).
-- 1st Undestanding: First delivery time equals confirmed delivery time means first attempt is successfully delivered.
select * from
(select i.OrderID,i.ReturnedDeliveryData, 
JSON_VALUE(i.ReturnedDeliveryData,'$.Events[1].EventTime') as FirstDeliveryTime,
i.ConfirmedDeliveryTime
from Sales.Invoices i) a
where FirstDeliveryTime <> ConfirmedDeliveryTime
-- 2nd Understanding: "Receiver not presented" means first delivery attempt is unsuccessful.
select i.OrderID, 
JSON_VALUE(i.ReturnedDeliveryData,'$.Events[1].Comment') as Delivery_Status
from Sales.Invoices i
where JSON_VALUE(i.ReturnedDeliveryData,'$.Events[1].Comment') is not null


-- 16. List all stock items that are manufactured in China. (Country of Manufacture)
select distinct StockItemName, JSON_VALUE(s.customfields,'$.CountryOfManufacture') as Manufacture_Country
from warehouse.stockitems s
where JSON_VALUE(s.customfields,'$.CountryOfManufacture') = 'China'


-- 17.	Total quantity of stock items sold in 2015, group by country of manufacturing.
select a.Manufacture_Country, 
isnull(b.stock_items_sold,0) as Stock_Items_Sold
from
(select distinct JSON_VALUE(s.customfields,'$.CountryOfManufacture') as Manufacture_Country
from warehouse.stockitems s) a
left join
(select JSON_VALUE(si.customfields,'$.CountryOfManufacture') as Manufacture_Country,
sum(ol.Quantity) as stock_items_sold
from sales.OrderLines ol left join Warehouse.StockItems si
on si.StockItemID=ol.StockItemID
left join Sales.Orders o on o.OrderID=ol.OrderID
where year(o.OrderDate)=2015
group by JSON_VALUE(si.customfields,'$.CountryOfManufacture')) b
on b.Manufacture_country=a.Manufacture_Country
order by 2 desc


-- 18. Create a view that shows the total quantity of stock items of each stock group sold 
-- (in orders) by year 2013-2017. 
-- [Stock Group Name, 2013, 2014, 2015, 2016, 2017]
Create View StockGroupSold_1 as
Select StockGroupName as StockGroupName,
[2013] as '2013', 
[2014] as '2014',
[2015] as '2015',
[2016] as '2016',
[2017] as '2017' 
from
(select sg.StockGroupName, YEAR(o.OrderDate) as [Year], coalesce(sum(ol.Quantity),0) as TotalQuantity
from Warehouse.StockGroups sg left join Warehouse.StockItemStockGroups sisg
on sisg.StockGroupID=sg.StockGroupID
left join Warehouse.StockItems si
on si.StockItemID=sisg.StockItemID
left join Sales.OrderLines ol
on ol.StockItemID=si.StockItemID
left join Sales.Orders o
on o.OrderID=ol.OrderID
group by sg.StockGroupName, YEAR(o.OrderDate)) st
Pivot
(sum(TotalQuantity) For Year in ([2013],[2014],[2015],[2016],[2017])) as pv


-- 19. Create a view that shows the total quantity of stock items of each stock group sold 
-- (in orders) by year 2013-2017. 
-- [Year, Stock Group Name1, Stock Group Name2, Stock Group Name3, … , Stock Group Name10] 
Create View StockGroupSold_2 as
Select FiscalYear as Fiscal_Year,
[T-Shirts],[USB Novelties],[Airline Novelties],[Packaging Materials],[Clothing],
[Novelty Items],[Furry Footwear],[Mugs],[Computing Novelties],[Toys]
from
(select sg.StockGroupName, YEAR(o.OrderDate) as [FiscalYear], coalesce(sum(ol.Quantity),0) as TotalQuantity
from Warehouse.StockGroups sg left join Warehouse.StockItemStockGroups sisg
on sisg.StockGroupID=sg.StockGroupID
left join Warehouse.StockItems si
on si.StockItemID=sisg.StockItemID
left join Sales.OrderLines ol
on ol.StockItemID=si.StockItemID
join Sales.Orders o
on o.OrderID=ol.OrderID
group by sg.StockGroupName, YEAR(o.OrderDate)) st
Pivot
(sum(TotalQuantity) For StockGroupName in 
([T-Shirts],[USB Novelties],[Airline Novelties],[Packaging Materials],[Clothing],
[Novelty Items],[Furry Footwear],[Mugs],[Computing Novelties],[Toys])) as pv


-- 20. Create a function, input: order id; return: total of that order. 
-- List invoices and use that function to attach the order total to the other fields of invoices.
Drop function if exists dbo.return_total; 
GO

CREATE FUNCTION return_total(@InvoiceID int)
RETURNS Decimal(18,2)
AS 
BEGIN
RETURN
(select sum(il.ExtendedPrice) as Order_Total 
from Sales.Invoices i left join sales.InvoiceLines il
on il.InvoiceID=i.InvoiceID
where I.InvoiceID=@InvoiceID
group by i.InvoiceID)
END;
GO

Select *, dbo.return_total(InvoiceID) AS TOTAL from Sales.Invoices
WHERE InvoiceID=3