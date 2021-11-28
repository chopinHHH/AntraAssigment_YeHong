/*
24.	Looks like that it is our missed purchase orders. Migrate these data into Stock Item, Purchase Order and Purchase Order Lines tables. 
Of course, save the script.
*/
Drop table if exists Stock_Item_New;
GO

DECLARE @json NVarChar(Max) = N'{
   "PurchaseOrders":[
      {
         "StockItemName":"Panzer Video Game",
         "Supplier":"7",
         "UnitPackageId":"1",
         "OuterPackageId":[
            6,
            7
         ],
         "Brand":"EA Sports",
         "LeadTimeDays":"5",
         "QuantityPerOuter":"1",
         "TaxRate":"6",
         "UnitPrice":"59.99",
         "RecommendedRetailPrice":"69.99",
         "TypicalWeightPerUnit":"0.5",
         "CountryOfManufacture":"Canada",
         "Range":"Adult",
         "OrderDate":"2018-01-01",
         "DeliveryMethod":"Post",
         "ExpectedDeliveryDate":"2018-02-02",
         "SupplierReference":"WWI2308"
      },
      {
         "StockItemName":"Panzer Video Game",
         "Supplier":"5",
         "UnitPackageId":"1",
         "OuterPackageId":"7",
         "Brand":"EA Sports",
         "LeadTimeDays":"5",
         "QuantityPerOuter":"1",
         "TaxRate":"6",
         "UnitPrice":"59.99",
         "RecommendedRetailPrice":"69.99",
         "TypicalWeightPerUnit":"0.5",
         "CountryOfManufacture":"Canada",
         "Range":"Adult",
         "OrderDate":"2018-01-025",
         "DeliveryMethod":"Post",
         "ExpectedDeliveryDate":"2018-02-02",
         "SupplierReference":"269622390"
      }
   ]
}';

-- Migrate into Stock Item table
Select (select max(StockItemID)+1 from Warehouse.StockItems) StockItemID, 
JSON_VALUE(@json,'$.PurchaseOrders[0].StockItemName') StockItemName,
JSON_VALUE(@json,'$.PurchaseOrders[0].Supplier') SupplierID,
NULL ColorID,
JSON_VALUE(@json,'$.PurchaseOrders[0].UnitPackageId') UnitPackageId,
JSON_VALUE(@json,'$.PurchaseOrders[0].OuterPackageId') OuterPackageId,
JSON_VALUE(@json,'$.PurchaseOrders[0].Brand') Brand,
NULL Size,
JSON_VALUE(@json,'$.PurchaseOrders[0].LeadTimeDays') LeadTimeDays,
JSON_VALUE(@json,'$.PurchaseOrders[0].QuantityPerOuter') QuantityPerOuter,
cast(0 as bit) IsChillerStock,NULL Barcode,
JSON_VALUE(@json,'$.PurchaseOrders[0].TaxRate') TaxRate ,
JSON_VALUE(@json,'$.PurchaseOrders[0].UnitPrice') UnitPrice,
JSON_VALUE(@json,'$.PurchaseOrders[0].RecommendedRetailPrice') RecommendedRetailPrice,
JSON_VALUE(@json,'$.PurchaseOrders[0].TypicalWeightPerUnit') TypicalWeightPerUnit,
NULL MarketingComments,NULL InternalComments,NULL Photo,
JSON_VALUE(@json,'$.PurchaseOrders[0].CountryOfManufacture') CustomFields,
NULL Tags,NULL SearchDetails,1 as LastEditedBy,
SYSDATETIME() as ValidFrom, (Select Max(ValidTo) from Warehouse.StockItems) as ValidTo
INTO Stock_Item_New
FROM Openjson(@JSON,'$.PurchaseOrders[0]')
WITH ([StockItemID] [int],
	[StockItemName] [nvarchar](100),
	[SupplierID] [int],
	[ColorID] [int],
	[UnitPackageID] [int],
	[OuterPackageID] [int],
	[Brand] [nvarchar](50),
	[Size] [nvarchar](20),
	[LeadTimeDays] [int],
	[QuantityPerOuter] [int],
	[IsChillerStock] [bit],
	[Barcode] [nvarchar](50),
	[TaxRate] [decimal](18, 3),
	[UnitPrice] [decimal](18, 2),
	[RecommendedRetailPrice] [decimal](18, 2),
	[TypicalWeightPerUnit] [decimal](18, 3),
	[MarketingComments] [nvarchar](max),
	[InternalComments] [nvarchar](max),
	[Photo] [varbinary](max),
	[CustomFields] [nvarchar](max),
	[Tags]  [nvarchar](max),
	[SearchDetails] [nvarchar](max),
	[LastEditedBy] [int],
	[ValidFrom] [datetime2](7),
	[ValidTo] [datetime2](7)
)