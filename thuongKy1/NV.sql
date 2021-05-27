USE AdventureWorks2008R2
GO

select * 
from Production.ProductInventory

-- chọn ProductID = 2 để xóa
Delete from Production.ProductInventory 
where ProductID = 2

-- 1d
select *
from Production.Product

-- không có thể truy cập Production.Product vì chỉ có quyền trên Production.ProductInventory

-- 1e
select * 
from Production.ProductInventory