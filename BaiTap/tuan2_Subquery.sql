USE AdventureWorks2008R2

-- 1. Liệt kê các sản phẩm gồm các thông tin Product Names và Product ID có
-- trên 100 đơn đặt hàng trong tháng 7 năm 2008
select pp.ProductID, pp.Name
from Production.Product as pp
where pp.ProductID in (
    select ssod.ProductID
    from sales.SalesOrderDetail as ssod join sales.SalesOrderHeader as ssoh
    on ssod.SalesOrderID = ssoh.SalesOrderID
WHERE MONTH(ssoh.OrderDate) = 7 and YEAR(ssoh.OrderDate) = 2008
group by ssod.ProductID
having count(*) > 100
)

-- 2. Liệt kê các sản phẩm (ProductID, Name) có số hóa đơn đặt hàng nhiều nhất
-- trong tháng 7/2008
select pp.ProductID, pp.Name
from Production.Product pp join Sales.SalesOrderDetail ssod
    on pp.ProductID = ssod.ProductID
    join Sales.SalesOrderHeader ssoh on ssod.SalesOrderID = ssoh.SalesOrderID
where MONTH(ssoh.OrderDate) = 7 and YEAR(ssoh.OrderDate) = 2008
group by pp.ProductID, pp.Name
having COUNT(*)>=all( 
    select COUNT(*)
    from Sales.SalesOrderDetail d join Sales.SalesOrderHeader h
    on d.SalesOrderID=h.SalesOrderID
where MONTH(OrderDate)=7 and YEAR(OrderDate)=2008
group by ProductID
)

-- 3. Hiển thị thông tin của khách hàng có số đơn đặt hàng nhiều nhất, thông tin gồm:
-- CustomerID, Name, CountOfOrder
select c.CustomerID, CountofOrder=COUNT(*)
from Sales.Customer c join Sales.SalesOrderHeader h on c.CustomerID=h.CustomerID
group by c.CustomerID
having COUNT(*)>=all (
    select COUNT(*)
    from Sales.Customer c join Sales.SalesOrderHeader h 
    on c.CustomerID=h.CustomerID
    group by c.CustomerID
)

-- 4. Liệt kê các sản phẩm (ProductID, Name) thuộc mô hình sản phẩm áo dài tay với
-- tên bắt đầu với “Long-Sleeve Logo Jersey”, dùng phép IN và EXISTS, (sử dụng
-- bảng Production.Product và Production.ProductModel)
select pp.ProductID, pp.Name
from Production.Product as pp
where exists (
    select ppm.ProductModelID
from Production.ProductModel as ppm
where ppm.Name like 'Long-Sleeve Logo Jersey'
    and pp.ProductModelID = ppm.ProductModelID
)

-- 5. Tìm các mô hình sản phẩm (ProductModelID) mà giá niêm yết (list price) tối
-- đa cao hơn giá trung bình của tất cả các mô hình.
select ppm.ProductModelID, ppm.Name, max(pp.ListPrice)
from Production.ProductModel ppm join Production.Product pp
    on ppm.ProductModelID = pp.ProductModelID
group by ppm.ProductModelID, ppm.Name
having max(pp.ListPrice) >= all (
    select avg(pp.ListPrice)
    from Production.ProductModel ppm join Production.Product pp
    on ppm.ProductModelID = pp.ProductModelID
)

-- 6. Liệt kê các sản phẩm gồm các thông tin ProductID, Name, có tổng số lượng
-- đặt hàng > 5000 (dùng IN, EXISTS.)
-- dùng in
select pp.ProductID, pp.Name
from Production.Product as pp
where pp.ProductID in (
    select ssod.ProductID
    from sales.SalesOrderDetail as ssod
    group by ssod.ProductID
    having sum(ssod.OrderQty) > 5000
)
-- dùng exists
select pp.ProductID, pp.Name
from Production.Product as pp
where exists (
    select ssod.ProductID
    from sales.SalesOrderDetail as ssod 
    where pp.ProductID = ssod.ProductID
    group by ssod.ProductID
    having sum(ssod.OrderQty) > 5000
)

-- 7. Liệt kê những sản phẩm (ProductID, UnitPrice) có đơn giá (UnitPrice) cao
-- nhất trong bảng Sales.SalesOrderDetail
select distinct ssod.ProductID, ssod.UnitPrice
from Sales.SalesOrderDetail as ssod
where ssod.UnitPrice >= all (
    select distinct ssod.UnitPrice
    from Sales.SalesOrderDetail as ssod
    group by ssod.UnitPrice
)

-- 8. Liệt kê các sản phẩm không có đơn đặt hàng nào thông tin gồm ProductID,
-- Nam; dùng 3 cách Not in, Not exists và Left join.
-- dùng not in
select pp.ProductID, pp.Name
from Production.Product as pp
where pp.ProductID not in (
    select ssod.ProductID
    from sales.SalesOrderDetail as ssod
)

-- dùng not exists
select pp.ProductID, pp.Name
from Production.Product as pp
where not exists (
    select ssod.ProductID
    from sales.SalesOrderDetail as ssod 
    where pp.ProductID = ssod.ProductID
)

-- dùng left join
select pp.ProductID, pp.Name
from Production.Product as pp left join Sales.SalesOrderDetail as ssod
    on pp.ProductID = ssod.ProductID
where ssod.ProductID is null

-- 9. Liệt kê các nhân viên không lập hóa đơn từ sau ngày 1/5/2008, thông tin gồm
-- EmployeeID, FirstName, LastName (dữ liệu từ 2 bảng
-- HumanResources.Employees và Sales.SalesOrdersHeader)
select EmployeeID = pp.BusinessEntityID, pp.FirstName, pp.LastName
from Person.Person as pp
where pp.BusinessEntityID in (
    select ssoh.SalesPersonID
    from Sales.SalesOrderHeader as ssoh
    where ssoh.OrderDate > '2008-05-01'
)

-- 10. Liệt kê danh sách các khách hàng (CustomerID, Name) có hóa đơn dặt hàng
-- trong năm 2007 nhưng không có hóa đơn đặt hàng trong năm 2008
select distinct ssoh.CustomerID
from Sales.SalesOrderHeader as ssoh
where ssoh.CustomerID in (
    select ssoh1.CustomerID
    from Sales.SalesOrderHeader as ssoh1
    where YEAR(ssoh1.OrderDate) = 2007
) 
and ssoh.CustomerID not in (
    select ssoh2.CustomerID
    from Sales.SalesOrderHeader as ssoh2
    where YEAR(ssoh2.OrderDate) = 2008
)