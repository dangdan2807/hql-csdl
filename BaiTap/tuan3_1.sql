use AdventureWorks2008R2
GO

-- 1) Tạo view dbo.vw_Products hiển thị danh sách các sản phẩm từ bảng
-- Production.Product và bảng Production.ProductCostHistory. Thông tin bao gồm
-- ProductID, Name, Color, Size, Style, StandardCost, EndDate, StartDate
CREATE view products1 as 
    select pp.ProductID, pp.Name, pp.Color, pp.Size, pp.Style, 
        ppch.StandardCost, ppch.EndDate, ppch.StartDate
    from production.Product as pp join Production.ProductCostHistory as ppch
    on pp.ProductID = ppch.ProductID
GO
-- kiểm tra kết quả
select * from products1
-- huỷ view
drop view products1
go

-- 2) Tạo view List_Product_View chứa danh sách các sản phẩm có trên 500 đơn đặt
-- hàng trong quí 1 năm 2008 và có tổng trị giá >10000, thông tin gồm ProductID,
-- Product_Name, CountOfOrderID và SubTotal.
CREATE view List_Product_View as
    select pp.ProductID, pp.Name as 'Product_Name', CountOfOrderID = count(*), 
        SubTotal = sum(ssod.OrderQty * ssod.UnitPrice)
    from Production.Product as pp join Sales.SalesOrderDetail as ssod
    on pp.ProductID = ssod.ProductID join Sales.SalesOrderHeader as ssoh
    on ssod.SalesOrderID = ssoh.SalesOrderID
    where datepart(q, ssoh.OrderDate) = 1 and year(ssoh.OrderDate) = 2008
    group by pp.ProductID, pp.Name
    HAVING count(*) > 500 and sum(ssod.OrderQty * ssod.UnitPrice) > 10000
GO
-- kiểm tra kết quả
select * from List_Product_View
-- huỷ view
drop view List_Product_View
GO

-- 3) Tạo view dbo.vw_CustomerTotals hiển thị tổng tiền bán được (total sales) từ cột
-- TotalDue của mỗi khách hàng (customer) theo tháng và theo năm. Thông tin gồm
-- CustomerID, YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS
-- OrderMonth, SUM(TotalDue).
create view dbo.vw_CustomerTotals as
    select ssoh.CustomerID, year(ssoh.OrderDate) as OrderYear, month(ssoh.OrderDate) as OrderMonth, 
        SUM(ssoh.TotalDue) as TotalDue
    from Sales.SalesOrderHeader as ssoh
    GROUP by ssoh.CustomerID, year(ssoh.OrderDate), month(ssoh.OrderDate)
GO
-- kiểm tra kết quả
select * from dbo.vw_CustomerTotals
-- huỷ view
drop view dbo.vw_CustomerTotals
GO

-- 4) Tạo view trả về tổng số lượng sản phẩm (Total Quantity) bán được của mỗi nhân
-- viên theo từng năm. Thông tin gồm SalesPersonID, OrderYear, sumOfOrderQty
create view view_TotalQuantity as
    select ssoh.SalesPersonID, year(ssoh.OrderDate) as OrderYear, sum(ssod.OrderQty) as sumOfOrderQty
    from Sales.SalesOrderHeader as ssoh join Sales.SalesOrderDetail as ssod
    on ssoh.SalesOrderID = ssod.SalesOrderID
    group by ssoh.SalesPersonID, year(ssoh.OrderDate)
GO
-- kiểm tra kết quả
select * from view_TotalQuantity
-- huỷ view
drop view view_TotalQuantity
GO

-- 5) Tạo view ListCustomer_view chứa danh sách các khách hàng có trên 25 hóa đơn
-- đặt hàng từ năm 2007 đến 2008, thông tin gồm mã khách (PersonID) , họ tên
-- (FirstName +' '+ LastName as FullName), Số hóa đơn (CountOfOrders).
CREATE view ListCustomer_view as
    select PersonID = ssoh.CustomerID, (pp.FirstName +' '+ pp.LastName) as FullName, CountOfOrders = count(*)
    from Person.Person as pp join Sales.SalesOrderHeader as ssoh
    on pp.BusinessEntityID = ssoh.CustomerID
    where year(ssoh.OrderDate) BETWEEN 2007 AND 2008
    GROUP BY ssoh.CustomerID, (pp.FirstName +' '+ pp.LastName)
    HAVING COUNT(*) > 25
go
-- kiểm tra kết quả
select * from ListCustomer_view
-- huỷ view
drop view ListCustomer_view
go

-- 6) Tạo view ListProduct_view chứa danh sách những sản phẩm có tên bắt đầu với
-- ‘Bike’ và ‘Sport’ có tổng số lượng bán trong mỗi năm trên 50 sản phẩm, thông
-- tin gồm ProductID, Name, SumOfOrderQty, Year. (dữ liệu lấy từ các bảng
-- Sales.SalesOrderHeader, Sales.SalesOrderDetail, và
-- Production.Product)
CREATE View ListProduct_view AS
    select pp.ProductID, pp.Name, SumOfOrderQty = sum(ssod.OrderQty), year(ssoh.OrderDate) as 'Year'
    from Production.Product as pp join Sales.SalesOrderDetail as ssod
    on pp.ProductID = ssod.ProductID join Sales.SalesOrderHeader as ssoh
    on ssod.SalesOrderID = ssoh.SalesOrderID
    where pp.Name like 'Bike%' or  pp.Name like 'Sport%'
    group by pp.ProductID, pp.Name, ssoh.OrderDate
    HAVING sum(ssod.OrderQty) > 50
go
-- Kiểm tra kết quả
select * from ListProduct_view
-- huỷ view
drop view ListProduct_view
GO

-- 7) Tạo view List_department_View chứa danh sách các phòng ban có lương (Rate:
-- lương theo giờ) trung bình >30, thông tin gồm Mã phòng ban (DepartmentID),
-- tên phòng ban (Name), Lương trung bình (AvgOfRate). Dữ liệu từ các bảng
-- [HumanResources].[Department],
-- [HumanResources].[EmployeeDepartmentHistory],
-- [HumanResources].[EmployeePayHistory].
CREATE View List_department_View AS
    select hrd.DepartmentID, hrd.Name, AvgOfRate = avg(hreph.Rate)
    from [HumanResources].[Department] as hrd join [HumanResources].[EmployeeDepartmentHistory] as hredh
    on hrd.departmentID = hredh.departmentID join [HumanResources].[EmployeePayHistory] as hreph
    on hredh.BusinessEntityID = hreph.BusinessEntityID
    group by hrd.DepartmentID, hrd.Name
    having avg(hreph.Rate) > 30
go
-- Kiểm tra kết quả
select * from List_department_View
-- huỷ view
drop view List_department_View
GO

-- 8) Tạo view Sales.vw_OrderSummary với từ khóa WITH ENCRYPTION gồm
-- OrderYear (năm của ngày lập), OrderMonth (tháng của ngày lập), OrderTotal
-- (tổng tiền). Sau đó xem thông tin và trợ giúp về mã lệnh của view này
create view vw_OrderSummary WITH ENCRYPTION as
    select OrderYear = year(ssoh.OrderDate), OrderMonth = month(ssoh.OrderDate), 
        OrderTotal = sum(ssod.OrderQty * ssod.UnitPrice)
    from Sales.SalesOrderHeader as ssoh join Sales.SalesOrderDetail as ssod
    on ssoh.SalesOrderID =  ssod.SalesOrderID
    group by year(ssoh.OrderDate), month(ssoh.OrderDate)
go
-- Kiểm tra kết quả
EXEC sp_helptext [List_Product_view]
EXEC sp_helptext vw_OrderSummary

select * from vw_OrderSummary
-- huỷ view
drop view vw_OrderSummary
GO

-- 9) Tạo view Production.vwProducts với từ khóa WITH SCHEMABINDING
-- gồm ProductID, Name, StartDate,EndDate,ListPrice của bảng Product và bảng
-- ProductCostHistory. Xem thông tin của View. Xóa cột ListPrice của bảng
-- Product. Có xóa được không? Vì sao?
create view vwProducts WITH SCHEMABINDING as
    select pp.ProductID, pp.Name, ppch.StartDate, ppch.EndDate, pp.ListPrice
    from [Production].[Product] as pp join [Production].[ProductCostHistory] as ppch
    on pp.ProductID = ppch.ProductID
    GROUP BY pp.ProductID, pp.Name, ppch.StartDate, ppch.EndDate, pp.ListPrice
go
-- Kiểm tra kết quả
select * from vwProducts
-- huỷ view
drop view vwProducts
GO

-- 10) Tạo view view_Department với từ khóa WITH CHECK OPTION chỉ chứa các
-- phòng thuộc nhóm có tên (GroupName) là “Manufacturing” và “Quality
-- Assurance”, thông tin gồm: DepartmentID, Name, GroupName.
create view view_Department as
    select hrd.DepartmentID, hrd.Name, hrd.GroupName
    from [HumanResources].[Department] as hrd
    where GroupName='Manufacturing' or GroupName='Quality Assurance'
    WITH CHECK OPTION
go
-- Kiểm tra kết quả
select * from view_Department
-- huỷ view
drop view view_Department
go
-- a. Chèn thêm một phòng ban mới thuộc nhóm không thuộc hai nhóm
-- “Manufacturing” và “Quality Assurance” thông qua view vừa tạo. Có
-- chèn được không? Giải thích.
insert view_Department values( 'nhan su', 'a')
-- không chèn được vì thuộc tính with check option kiểm tra không cho chèn
select *from [HumanResources].[Department]

-- b. Chèn thêm một phòng mới thuộc nhóm “Manufacturing” và một
-- phòng thuộc nhóm “Quality Assurance”.
insert view_Department values( 'nhan su', 'Manufacturing'),
                            ('nhan su 2', 'Quality Assurance')
-- chèn thành công

-- c. Dùng câu lệnh Select xem kết quả trong bảng Department.
select *from [HumanResources].[Department]
