CREATE FUNCTION dbo.sonamCT(@empID INT)   
RETURNS  INT    
AS     
BEGIN
	DECLARE @no INT
	IF EXISTS ( SELECT *
	FROM HumanResources.Employee
	WHERE BusinessEntityID = @empID AND CurrentFlag = 1 )  
	SELECT @no = year(getdate()) - year(HireDate)
	FROM HumanResources.Employee
	WHERE BusinessEntityID = @empID

	RETURN @no
END 

--------------
--1)	Viết hàm tên CountOfEmployees (dạng scalar function) 
--với tham số @mapb, giá trị truyền vào lấy từ field [DepartmentID], 
--hàm trả về số nhân viên trong phòng ban tương ứng. 
--Áp dụng hàm đã viết vào câu truy vấn liệt kê danh sách 
--các phòng ban với số nhân viên của mỗi phòng ban, 
--thông tin gồm: [DepartmentID], Name, countOfEmp với 
--countOfEmp= CountOfEmployees([DepartmentID]). 
--(Dữ liệu lấy từ bảng 
--[HumanResources].[EmployeeDepartmentHistory] và 
--[HumanResources].[Department]) 
--1)	Viết hàm tên CountOfEmployees (dạng scalar function) 
--với tham số @mapb, giá trị truyền vào lấy từ field [DepartmentID], 
--hàm trả về số nhân viên trong phòng ban tương ứng. 
GO
CREATE FUNCTION CountOfEmployees(@mapb SMALLINT)
returns INT
AS
BEGIN
	DECLARE @no  INT
	IF EXISTS (SELECT *
	FROM HumanResources.EmployeeDepartmentHistory
	WHERE DepartmentID = @mapb)
	SELECT @no = count(*)
	FROM [HumanResources].[EmployeeDepartmentHistory]
	WHERE DepartmentID = @mapb AND EndDate IS NULL

	RETURN @no
END
GO
---
----- su dung ham 
---exec sp_help [HumanResources].[EmployeeDepartmentHistory]

DECLARE @no INT
SET @no = @no + dbo.CountOfEmployees(1)
PRINT @no
----
SET @no = dbo.CountOfEmployees(1)
IF @no >0 
	PRINT 'aaa'

SELECT dbo.CountOfEmployees(1)
PRINT  dbo.CountOfEmployees(16)

----
GO
SELECT DepartmentID , Name , countOfEmp =  dbo.CountOfEmployees(DepartmentID)
FROM HumanResources.Department


GO





-----
----- inline table-value function
GO
ALTER FUNCTION dbo.CountOfEmployees22(@mapb SMALLINT)
returns TABLE
AS
RETURN
	(SELECT DepartmentID, count(*) AS sonv
FROM [HumanResources].[EmployeeDepartmentHistory]
WHERE DepartmentID = @mapb AND EndDate IS NULL
GROUP BY DepartmentID
	)
GO
------ sudung ham
SELECT *
FROM dbo.CountOfEmployees22(1)

-----cau2
--2)	Viết hàm tên là InventoryProd (dạng scalar function) với tham số vào là 
--@ProductID và @LocationID trả về số lượng tồn kho 
--của sản phẩm trong khu vực tương ứng với giá trị của tham số 
--(Dữ liệu lấy từ bảng[Production].[ProductInventory]) 
----
GO
ALTER FUNCTION InventoryProd(@ProductID INT , @LocationID SMALLINT  )
returns SMALLINT
AS
BEGIN
	RETURN (
		SELECT Quantity
	FROM [Production].[ProductInventory]
	WHERE ProductID = @ProductID AND LocationID =  @LocationID   )
END
GO
----- su dung ham 
SELECT dbo.InventoryProd(1 , 6)
----
----inline table-value function
GO
CREATE  FUNCTION InventoryProd22(@ProductID INT , @LocationID SMALLINT  )
returns TABLE
AS
RETURN (
		SELECT productid, locationid, Quantity
FROM [Production].[ProductInventory]
WHERE ProductID = @ProductID AND LocationID =  @LocationID   )					
GO
----su dung ham 
SELECT *
FROM dbo.InventoryProd22(1 , 6)

----
-- cau 5 (trang 20)
--5)	Viết một thủ tục dùng để xem thông tin của nhóm sản phẩm (ProductCategory) 
--có tổng số lượng (OrderQty) đặt hàng cao nhất trong một năm tùy ý (tham số input), 
--thông tin gồm: ProductCategoryID, Name, SumOfQty. Dữ liệu từ bảng  
--ProductCategory, ProductSubCategory, Product và SalesOrderDetail. 
--(Lưu ý: dùng Sub Query)  

SELECT *
FROM Production.ProductCategory
SELECT *
FROM Production.ProductSubcategory
SELECT *
FROM Production.Product
WHERE ProductSubcategoryID = 1
GO
SELECT *
FROM Sales.SalesOrderDetail sod JOIN sales.SalesOrderHeader soh
	ON sod.SalesOrderID = soh.SalesOrderID
WHERE ProductID = 771 AND year(orderdate) = 2006
---
--- hien thi mat hang co tổng số lượng (OrderQty) đặt hàng cao nhất trong một năm 2006 
SELECT TOP 1
	ProductID, sum(OrderQty)  AS tongsl
FROM Sales.SalesOrderDetail sod JOIN sales.SalesOrderHeader soh
	ON sod.SalesOrderID = soh.SalesOrderID
WHERE  year(orderdate) = 2006
GROUP BY ProductID
ORDER BY tongsl DESC
---
SELECT TOP 1
	ProductCategoryID, sum(OrderQty)  AS tongsl
FROM Sales.SalesOrderDetail sod JOIN sales.SalesOrderHeader soh
	ON sod.SalesOrderID = soh.SalesOrderID
	JOIN Production.Product p ON sod.ProductID = p.ProductID
	JOIN Production.ProductSubcategory psc ON psc.ProductSubcategoryID=p.ProductSubcategoryID
WHERE  year(orderdate) = 2006
GROUP BY ProductCategoryID
ORDER BY tongsl DESC


---
GO
ALTER PROC cau5
	@nam INT
AS
BEGIN
	DECLARE @categoryID INT, @sumqty INT

	SELECT TOP 1
		@categoryID = ProductCategoryID, @sumqty = sum(OrderQty)
	----truyvan va ganbien
	FROM Sales.SalesOrderDetail sod JOIN sales.SalesOrderHeader soh
		ON sod.SalesOrderID = soh.SalesOrderID
		JOIN Production.Product p ON sod.ProductID = p.ProductID
		JOIN Production.ProductSubcategory psc ON psc.ProductSubcategoryID=p.ProductSubcategoryID
	WHERE  year(orderdate) = @nam
	GROUP BY ProductCategoryID
	ORDER BY sum(OrderQty)  DESC

	SELECT ProductCategoryID , name , sumofqty=  @sumqty
	FROM Production.ProductCategory
	WHERE ProductCategoryID = @categoryID
END
GO
--- su dung thu tuc
EXEC cau5 2006
EXEC cau5 2007






