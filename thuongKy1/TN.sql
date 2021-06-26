USE AdventureWorks2008R2
GO

SELECT *
FROM Production.ProductInventory

-- phân quyền cho nhân viên
GRANT SELECT, INSERT, UPDATE ,DELETE
ON Production.ProductInventory
TO NV

-- 1c
-- chọn ProductID = 3 để xóa
DELETE FROM Production.ProductInventory 
WHERE ProductID = 3

-- 1d
SELECT *
FROM Production.Product

-- không thể truy cập Production.Product vì chỉ có quyền trên Production.ProductInventory

--1E
REVOKE SELECT , INSERT , UPDATE ,DELETE 
ON Production.ProductInventory
TO NV