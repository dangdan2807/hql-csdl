USE AdventureWorks2008R2
GO

SELECT *
FROM Production.ProductInventory

-- chọn ProductID = 2 để xóa
DELETE FROM Production.ProductInventory 
WHERE ProductID = 2

-- 1d
SELECT *
FROM Production.Product

-- không có thể truy cập Production.Product vì chỉ có quyền trên Production.ProductInventory

-- 1e
SELECT *
FROM Production.ProductInventory