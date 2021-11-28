-- 25. Revisit your answer in (19). Convert the result in JSON string and save it to the server using TSQL FOR JSON PATH.
select * from StockGroupSold_1
FOR JSON PATH

-- 26. Revisit your answer in (19). Convert the result into an XML string and save it to the server using TSQL FOR XML PATH.
select * from StockGroupSold_1
FOR XML AUTO