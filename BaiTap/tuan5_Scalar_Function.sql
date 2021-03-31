USE AdventureWorks2008R2
go

-- 1) Viết hàm tên CountOfEmployees (dạng scalar function) với tham số @mapb, 
-- giá trị truyền vào lấy từ field [DepartmentID], hàm trả về số nhân viên trong 
-- phòng ban tương ứng. Áp dụng hàm đã viết vào câu truy vấn liệt kê danh sách các
-- phòng ban với số nhân viên của mỗi phòng ban, thông tin gồm: [DepartmentID],
-- Name, countOfEmp với countOfEmp= CountOfEmployees([DepartmentID]).
-- (Dữ liệu lấy từ bảng 
-- [HumanResources].[EmployeeDepartmentHistory] và 
-- [HumanResources].[Department])
create function CountOfEmployees(@mapb int)
returns int
as
BEGIN
    RETURN (select count(a.DepartmentID)
    from HumanResources.EmployeeDepartmentHistory as a
    where a.DepartmentID = @mapb
    )
END
go

select a.DepartmentID, a.Name, countOfEmp = dbo.CountOfEmployees(a.DepartmentID)
from [HumanResources].[Department] as a

drop function CountOfEmployees
go

-- 2) Viết hàm tên là InventoryProd (dạng scalar function) với tham số vào là
-- @ProductID và @LocationID trả về số lượng tồn kho của sản phẩm trong khu 
-- vực tương ứng với giá trị của tham số
-- (Dữ liệu lấy từ bảng[Production].[ProductInventory])
create function InventoryProd
(@ProductID int, @LocationID int)
RETURNS int
as
BEGIN
    return (
        select a.Quantity
        from Production.ProductInventory as a
        where a.ProductID = @ProductID and a.LocationID = @LocationID
    )
end
GO

DECLARE @SL int, @locationID int, @productID int

set @productID = 1
set @locationID = 1
set @SL = dbo.InventoryProd(@ProductID, @LocationID);

print N'Sản phẩm có mã: ' + convert(nvarchar(4), @productID) + 
    N' và LocationID: ' + convert(nvarchar(4), @locationID) +
    N' có số lượng sản phẩm tồn kho là: ' + convert(nvarchar(8), @SL)

drop function dbo.InventoryProd
GO

-- 3) Viết hàm tên SubTotalOfEmp (dạng scalar function) trả về tổng doanh thu của 
-- một nhân viên trong một tháng tùy ý trong một năm tùy ý, với tham số vào
-- @EmplID, @MonthOrder, @YearOrder
-- (Thông tin lấy từ bảng [Sales].[SalesOrderHeader])
create function SubTotalOfEmp
(
    @EmplID int, 
    @MonthOrder int, 
    @YearOrder int
)
RETURNS real
as
BEGIN
    return (
        select sum(a.TotalDue)
        from Sales.SalesOrderHeader as a
        where MONTH(a.OrderDate) = @MonthOrder and year(a.OrderDate) = @YearOrder
            and a.SalesPersonID = @EmplID
    )
END
GO

DECLARE @maNV int, @thang int, @nam int, @doanhThu real

set @maNV = 280
set @thang = 1
set @nam = 2008
set @doanhThu = dbo.SubTotalOfEmp(@maNV, @thang, @nam)

print N'Nhan vien co ma: ' + convert(nvarchar(4), @maNV) +
    N' trong thang ' + convert(nvarchar(2), @thang) +
    N' nam ' + convert(nvarchar(4), @nam) +
    N' co doanh thu la: ' + convert(nvarchar(20), @doanhThu)

drop function dbo.SubTotalOfEmp
go