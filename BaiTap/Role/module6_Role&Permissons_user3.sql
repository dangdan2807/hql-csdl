USE AdventureWorks2008R2
GO

-- Kiểm tra cấp quyền select trên sales.Store
SELECT *
FROM sales.Store
GO

-- 7.a)
SELECT e.BusinessEntityID, e.JobTitle as 'Sale Manager'
FROM HumanResources.Employee e
WHERE e.BusinessEntityID = 1
GO
