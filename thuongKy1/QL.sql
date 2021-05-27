USE AdventureWorks2008R2
GO

select * 
from Production.ProductInventory
Where ProductID = 2 and ProductID = 3

-- 1d
select *
from Production.Product

-- có thể truy cập Production.Product vì chỉ có quyền db_datawriter