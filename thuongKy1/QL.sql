USE AdventureWorks2008R2
GO

SELECT *
FROM Production.ProductInventory
WHERE ProductID = 2 AND ProductID = 3

-- 1d
SELECT *
FROM Production.Product

-- có thể truy cập Production.Product vì chỉ có quyền db_datawriter