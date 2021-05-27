USE AdventureWorks2008R2
GO

select * 
from Production.ProductInventory

-- phân quyền cho nhân viên
GRANT SELECT, INSERT, UPDATE ,DELETE
ON Production.ProductInventory
TO NV

-- 1c
-- chọn ProductID = 3 để xóa
Delete from Production.ProductInventory 
where ProductID = 3

-- 1d
select *
from Production.Product

-- không thể truy cập Production.Product vì chỉ có quyền trên Production.ProductInventory

--1E
REVOKE SELECT , INSERT , UPDATE ,DELETE 
ON Production.ProductInventory
TO NV