-- 23. Rewrite your stored procedure in (21). 
-- Now with a given date, it should wipe out all the order data prior to the input date and 
-- load the order data that was placed in the next 7 days following the input date.

Drop View if exists Orders1;
GO

Create View Orders1
AS
Select * from Sales.Orders o;
GO

Drop Procedure if exists WipeOutData;
GO

Create Procedure WipeOutData @InputDate Date
AS
Begin 
Delete Orders1 
where DATEADD(day,-7,@InputDate) > OrderDate
END;
GO

EXEC WipeOutData @InputDate = '2013-05-31'