USE AdventureWorks2008R2
go

-- 1) Liệt kê danh sách các hóa đơn (SalesOrderID) lập trong tháng 6 năm 2008 có
-- tổng tiền > 70000, thông tin gồm SalesOrderID, Orderdate, SubTotal, trong đó
-- SubTotal =SUM(OrderQty*UnitPrice).
SELECT SOH.SalesOrderID, SOH.OrderDate, SUM(SOD.OrderQty * SOD.UnitPrice) AS 'SubTotal'
FROM Sales.SalesOrderHeader AS SOH JOIN Sales.SalesOrderDetail AS SOD
    ON SOH.SalesOrderID = SOD.SalesOrderID
WHERE month(soh.OrderDate) = 6 and year(soh.OrderDate) = 2008
GROUP BY SOH.SalesOrderID, SOH.OrderDate
HAVING SUM(SOD.OrderQty * SOD.UnitPrice) > 70000

-- 2) Đếm tổng số khách hàng và tổng tiền của những khách hàng thuộc các quốc gia
-- có mã vùng là US (lấy thông tin từ các bảng Sales.SalesTerritory,
-- Sales.Customer, Sales.SalesOrderHeader, Sales.SalesOrderDetail). Thông tin
-- bao gồm TerritoryID, tổng số khách hàng (CountOfCust), tổng tiền
-- (SubTotal) với SubTotal = SUM(OrderQty*UnitPrice)
SELECT SST.TerritoryID, Count(SC.CustomerID) AS 'CountOfCust', SUM(SSOD.OrderQty * SSOD.UnitPrice) AS 'SubTotal'
FROM Sales.SalesTerritory AS SST JOIN Sales.Customer AS SC
    ON SST.TerritoryID = SC.TerritoryID
    JOIN Sales.SalesOrderHeader AS SSOH
    ON SSOH.TerritoryID = SC.TerritoryID
    JOIN Sales.SalesOrderDetail AS SSOD
    ON SSOD.SalesOrderID = SSOH.SalesOrderID
WHERE SST.CountryRegionCode = 'US'
GROUP BY SST.TerritoryID

-- 3) Tính tổng trị giá của những hóa đơn với Mã theo dõi giao hàng
-- (CarrierTrackingNumber) có 3 ký tự đầu là 4BD, thông tin bao gồm
-- SalesOrderID, CarrierTrackingNumber, SubTotal=SUM(OrderQty*UnitPrice)
SELECT ssod.SalesOrderID, ssod.CarrierTrackingNumber, SUM(OrderQty*UnitPrice) as 'SubTotal'
from sales.SalesOrderDetail as ssod
group by ssod.SalesOrderID, ssod.CarrierTrackingNumber
having ssod.CarrierTrackingNumber like '4BD%'

-- 4) Liệt kê các sản phẩm (Product) có đơn giá (UnitPrice)<25 và số lượng bán
-- trung bình >5, thông tin gồm ProductID, Name, AverageOfQty.
select pp.ProductID, pp.Name, AVG(ssod.UnitPrice) as 'AverageOfQty'
from Production.Product as pp join sales.SalesOrderDetail as ssod
    on pp.ProductID = ssod.ProductID
WHERE ssod.UnitPrice < 25
GROUP BY pp.ProductID, pp.Name
having avg(ssod.OrderQty) > 5

-- 5) Liệt kê các công việc (JobTitle) có tổng số nhân viên >20 người, thông tin gồm
-- JobTitle,CountOfPerson=Count(*)
select hre.JobTitle, count(hre.BusinessEntityID) 'CountOfPerson'
from HumanResources.Employee hre
GROUP BY hre.JobTitle
having count(hre.BusinessEntityID) > 20

-- 6) Tính tổng số lượng và tổng trị giá của các sản phẩm do các nhà cung cấp có tên
-- kết thúc bằng ‘Bicycles’ và tổng trị giá > 800000, thông tin gồm
-- BusinessEntityID, Vendor_Name, ProductID, SumOfQty, SubTotal
-- (sử dụng các bảng [Purchasing].[Vendor], [Purchasing].[PurchaseOrderHeader] và
-- [Purchasing].[PurchaseOrderDetail])
select pv.BusinessEntityID, pv.Name, ppod.ProductID,
    SumOfQty = SUM(ppod.OrderQty), SubTotal = SUM(ppod.OrderQty * ppod.UnitPrice)
from Purchasing.Vendor pv
    join Purchasing.PurchaseOrderHeader ppoh on pv.BusinessEntityID = ppoh.VendorID
    join Purchasing.PurchaseOrderDetail ppod on ppoh.PurchaseOrderID = ppod.PurchaseOrderID
WHERE pv.Name like '%Bicycles'
group by pv.BusinessEntityID, pv.Name, ppod.ProductID
having SUM(ppod.OrderQty * ppod.UnitPrice) > 800000

-- 7) Liệt kê các sản phẩm có trên 500 đơn đặt hàng trong quí 1 năm 2008 và có tổng
-- trị giá >10000, thông tin gồm ProductID, Product_Name, CountOfOrderID và SubTotal
select pp.ProductID, pp.Name, CountOfOrderID = count(ssod.SalesOrderID), SubTotal = SUM(ssod.OrderQty * ssod.UnitPrice)
from Production.Product pp
    join sales.SalesOrderDetail ssod on ssod.ProductID = pp.ProductID
    join sales.SalesOrderHeader ssoh on ssod.SalesOrderID = ssoh.SalesOrderID
WHERE Datepart(q, ssoh.OrderDate) = 1 and YEAR(ssoh.OrderDate) = 2008
group by pp.ProductID, pp.Name
HAVING SUM(ssod.OrderQty * ssod.UnitPrice) > 10000 and count(ssod.SalesOrderID) > 500

-- 8) Liệt kê danh sách các khách hàng có trên 25 hóa đơn đặt hàng từ năm 2007 đến
-- 2008, thông tin gồm mã khách (PersonID) , họ tên (FirstName +' '+ LastName
-- as FullName), Số hóa đơn (CountOfOrders).
select sc.PersonID, FullName = (pp.FirstName + ' ' + pp.LastName), CountOfOrders = count(ssoh.SalesOrderID)
from Person.Person pp
    join Sales.Customer sc on pp.BusinessEntityID = sc.CustomerID
    join Sales.SalesOrderHeader ssoh on ssoh.CustomerID = sc.CustomerID
WHERE year(ssoh.OrderDate) BETWEEN 2007 and 2008
group by sc.PersonID, pp.FirstName + ' ' + pp.LastName
having count(ssoh.SalesOrderID) > 25

-- 9) Liệt kê những sản phẩm có tên bắt đầu với ‘Bike’ và ‘Sport’ có tổng số lượng
-- bán trong mỗi năm trên 500 sản phẩm, thông tin gồm ProductID, Name,
-- CountOfOrderQty, Year. (Dữ liệu lấy từ các bảng Sales.SalesOrderHeader,
-- Sales.SalesOrderDetail và Production.Product)
select pp.ProductID, pp.Name, CountOfOrderQty = sum(ssod.OrderQty), YearOfSale=year(ssoh.OrderDate)
from Production.Product pp
    join sales.SalesOrderDetail ssod on ssod.ProductID = pp.ProductID
    join sales.SalesOrderHeader ssoh on ssod.SalesOrderID = ssoh.SalesOrderID
WHERE pp.Name like '%Bike' or pp.Name like '%Sport'
group by pp.ProductID, pp.Name, year(ssoh.OrderDate)
having sum(ssod.OrderQty) > 500

-- 10)Liệt kê những phòng ban có lương (Rate: lương theo giờ) trung bình >30, thông
-- tin gồm Mã phòng ban (DepartmentID), tên phòng ban (Name), Lương trung
-- bình (AvgofRate). Dữ liệu từ các bảng
-- [HumanResources].[Department],
-- [HumanResources].[EmployeeDepartmentHistory],
-- [HumanResources].[EmployeePayHistory]
select hrd.DepartmentID, hrd.Name, AvgofRate = avg(heph.Rate)
from HumanResources.Department hrd
    join HumanResources.EmployeeDepartmentHistory hedh on hrd.DepartmentID = hedh.DepartmentID
    join HumanResources.EmployeePayHistory heph on hedh.BusinessEntityID = heph.BusinessEntityID
group by hrd.DepartmentID, hrd.Name
having avg(heph.Rate) > 30