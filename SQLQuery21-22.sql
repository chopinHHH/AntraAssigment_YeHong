-- 21. Create a new table called ods.Orders. Create a stored procedure, with proper error handling and transactions, that input is a date; 
-- when executed, it would find orders of that day, calculate order total, and save the information (order id, order date, order total, customer id) into the new table. 
-- If a given date is already existing in the new table, throw an error and roll back. 
-- Execute the stored procedure 5 times using different dates. 
Drop PROCEDURE if exists Sales.Orders1;
GO

CREATE PROCEDURE Sales.Orders1
@OrderDate Date
AS
SET NOCOUNT ON;
select o.OrderID, o.OrderDate, 
sum(ol.Quantity*ol.UnitPrice+ol.TaxRate) as OrderTotal ,o.CustomerID
from Sales.Orders o left join Sales.OrderLines ol
on ol.OrderID=o.OrderID
where OrderDate = @OrderDate
group by o.OrderID, o.OrderDate, o.CustomerID;
Go

EXEC Sales.Orders1 @OrderDate = '2013-01-01'
EXEC Sales.Orders1 @OrderDate = '2014-06-30'
EXEC Sales.Orders1 @OrderDate = '2015-02-20'
EXEC Sales.Orders1 @OrderDate = '2015-12-31'
EXEC Sales.Orders1 @OrderDate = '2016-06-01'


-- 22. Create a new table called ods.StockItem. 
-- It has following columns: [StockItemID],[StockItemName],[SupplierID],[ColorID],[UnitPackageID],[OuterPackageID],
-- [Brand],[Size],[LeadTimeDays],[QuantityPerOuter],[IsChillerStock],[Barcode],[TaxRate],[UnitPrice],[RecommendedRetailPrice],
-- [TypicalWeightPerUnit],[MarketingComments],[InternalComments],[CountryOfManufacture],[Range],[Shelflife]. 
-- Migrate all the data in the original stock item table.
Select StockItemID,StockItemName,SupplierID,ColorID,UnitPackageID, OuterPackageID,Brand,
Size,LeadTimeDays,QuantityPerOuter,IsChillerStock,Barcode,TaxRate,UnitPrice,RecommendedRetailPrice,
TypicalWeightPerUnit,MarketingComments,InternalComments,
jSON_Value(si.CustomFields, '$.CountryOfManufacture') as CountryOfManufacture,
jSON_Value(si.CustomFields, '$.Range') as [Range],
jSON_Value(si.CustomFields, '$.Shelflife') as Shelflife
into StockItem
from Warehouse.StockItems si