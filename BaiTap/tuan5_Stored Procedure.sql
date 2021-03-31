USE AdventureWorks2008R2
GO

-- 1) Viết một thủ tục tính tổng tiền thu (TotalDue) của mỗi khách hàng trong một 
-- tháng bất kỳ của một năm bất kỳ (tham số tháng và năm) được nhập từ bàn phím, 
-- thông tin gồm: CustomerID, SumOfTotalDue =Sum(TotalDue
CREATE PROC TongThuTien
    @thang int,
    @nam int
as
begin
    select ssoh.CustomerID, SumOfTotalDue =Sum(TotalDue)
    from Sales.SalesOrderHeader as ssoh
    where year(ssoh.OrderDate) = @nam and Month(ssoh.OrderDate) = @thang
    group by ssoh.CustomerID, ssoh.TotalDue
END
GO

EXEC TongThuTien 5, 2008
GO

DROP PROCEDURE TongThuTien
GO

-- 2) Viết một thủ tục dùng để xem doanh thu từ đầu năm cho đến ngày hiện tại của 
-- một nhân viên bất kỳ, với một tham số đầu vào và một tham số đầu ra. Tham số 
-- @SalesPerson nhận giá trị đầu vào theo chỉ định khi gọi thủ tục, tham số 
--  @SalesYTD được sử dụng để chứa giá trị trả về của thủ tục
CREATE PROC ThongKeDoanhThu
    @SalesPerson int,
    @SalesYTD int output
as
BEGIN
    DECLARE @temp varchar(10), @ThoiGian datetime
    set @temp = convert(varchar(10), YEAR(getdate())) + '-01-01'
    set @ThoiGian = convert(datetime, @temp)
    set @SalesYTD = (
    select Doanhthu = sum(ssoh.SubTotal)
    from sales.SalesPerson as ssp join sales.SalesOrderHeader as ssoh
        on ssp.BusinessEntityID = ssoh.SalesPersonID
    where ssoh.SalesPersonID = @SalesPerson and ssoh.OrderDate between @ThoiGian and getdate()
    )
    if @SalesYTD is NULL
        return -1
    else if @SalesYTD > 0
        return @SalesYTD
    else 
        return -1
END

DECLARE @result int, @maNV int
set @maNV = 278
set @result = 0

EXEC ThongKeDoanhThu @maNV, @result output
if @result > 0
    print N'Nhân viên có mã: ' + convert(varchar(4),@maNV) + 
    N' có doanh thu từ đầu năm đến bây giờ là: ' + convert(varchar(20), @result)
else
    print N'Nhân viên có mã: ' + convert(varchar(4),@maNV) + 
    N' có doanh thu từ đầu năm đến bây giờ là: 0'

drop proc ThongKeDoanhThu
go

-- 3) Viết một thủ tục trả về một danh sách ProductID, ListPrice của các sản phẩm có 
-- giá bán không vượt quá một giá trị chỉ định (tham số input @MaxPrice). 
create proc DanhSachSP
    @MaxPrice int
AS
BEGIN
    select pp.ProductID, pp.ListPrice
    from Production.ProductListPriceHistory as pp
    where pp.ListPrice <= @MaxPrice
end
go

EXEC DanhSachSP 1000
drop proc DanhSachSP
GO

-- 4) Viết thủ tục tên NewBonus cập nhật lại tiền thưởng (Bonus) cho 1 nhân viên bán 
-- hàng (SalesPerson), dựa trên tổng doanh thu của nhân viên đó. Mức thưởng mới 
-- bằng mức thưởng hiện tại cộng thêm 1% tổng doanh thu. Thông tin bao gồm 
-- [SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó: 
-- SumOfSubTotal =sum(SubTotal) 
-- NewBonus = Bonus+ sum(SubTotal)*0.01 

-- view
create view v_newBonus
as
    select ssoh.SalesPersonID, ssp.Bonus, ssoh.SubTotal
    from Sales.SalesPerson as ssp join Sales.SalesOrderHeader ssoh
        on ssp.BusinessEntityID = ssoh.SalesPersonID
    GROUP by ssoh.SalesPersonID, ssp.Bonus, ssoh.SubTotal
go

select *
from v_newBonus
where SalesPersonID = 280
go

-- function
create proc NewBonus
    @maNV int
AS
BEGIN
    select v.SalesPersonID, 'New Bonus' = v.Bonus+ sum(v.SubTotal) * 0.01, SumOfSubTotal =sum(v.SubTotal)
    from v_newBonus as v
    where v.SalesPersonID = @maNV
    group by v.SalesPersonID, v.Bonus, v.SubTotal
end
go

EXEC NewBonus 280

drop view v_newBonus
drop proc NewBonus
go

-- 5) Viết một thủ tục dùng để xem thông tin của nhóm sản phẩm (ProductCategory) 
-- có tổng số lượng (OrderQty) đặt hàng cao nhất trong một năm tùy ý (tham số 
-- input), thông tin gồm: ProductCategoryID, Name, SumOfQty. Dữ liệu từ bảng 
-- ProductCategory, ProductSubCategory, Product và SalesOrderDetail.
-- (Lưu ý: dùng Sub Query) 
create view v_NhomSanPham
as
    select ppc.ProductCategoryID, ppc.Name, SumOfQty = sum(ssod.OrderQty), ssoh.OrderDate
    from Sales.SalesOrderHeader as ssoh join Sales.SalesOrderDetail as ssod
        on ssoh.SalesOrderID = ssod.SalesOrderID join Production.Product pp
        on ssod.ProductID = pp.ProductID join Production.ProductSubCategory as ppsc
        on pp.ProductSubcategoryID = ppsc.ProductSubCategoryID join Production.ProductCategory as ppc
        on ppsc.ProductCategoryID = ppc.ProductCategoryID
    group by ppc.ProductCategoryID, ppc.Name, ssoh.OrderDate
GO

select *
from v_NhomSanPham
go

create proc MaxOrderQty
    @nam int
as
BEGIN
    select n.ProductCategoryID, n.Name, n.SumOfQty
    from v_NhomSanPham as n
    where n.SumOfQty = (
        select max(a.SumOfQty)
    from v_NhomSanPham as a
    where year(a.OrderDate) = @nam
    )
end
go

EXEC MaxOrderQty 2008

drop proc MaxOrderQty
go

drop view v_NhomSanPham
go

-- 6) Tạo thủ tục đặt tên là TongThu có tham số vào là mã nhân viên, tham số đầu ra 
-- là tổng trị giá các hóa đơn nhân viên đó bán được. Sử dụng lệnh RETURN để trả 
-- về trạng thái thành công hay thất bại của thủ tục.
create proc TongThu
    @maNV int,
    @NameNV nvarchar(30) output,
    @TongTienBan money output
AS
BEGIN
    set @TongTienBan = (
        select sum(ssoh.TotalDue)
    from Sales.SalesOrderHeader as ssoh
    where ssoh.SalesPersonID = @maNV
    )
    select @NameNV=pp.FirstName + ' ' + pp.MiddleName + ' ' + pp.LastName
    from Person.Person as pp join Sales.SalesPerson as ssp
        on pp.BusinessEntityID = ssp.BusinessEntityID
    where ssp.BusinessEntityID = @maNV
    group by  pp.FirstName + ' ' + pp.MiddleName + ' ' + pp.LastName

    if @TongTienBan < 0
        return -1
    else
        return 1
end
go

DECLARE @kq money, @name nvarchar(30)
EXEC TongThu 280, @name output, @kq output
print N'Nhân viên: ' + @name + N' ||' + N' đã bán: ' + convert(nvarchar(20),@kq)
go

drop proc TongThu
go

-- 7) Tạo thủ tục hiển thị tên và số tiền mua của cửa hàng mua nhiều hàng nhất theo 
-- năm đã cho.
create proc ThongTinCuaHang
    @nam int
as
BEGIN
    select top 1
        ss.Name, MaxOfTotalDue = max(ssoh.TotalDue)
    from Sales.Store as ss join Sales.Customer as sc
        on ss.BusinessEntityID = sc.StoreID join Sales.SalesOrderHeader as ssoh
        on sc.CustomerID = ssoh.CustomerID
    where YEAR(ssoh.OrderDate) = @nam
    group by ss.Name, ssoh.TotalDue
    ORDER BY ssoh.TotalDue Desc
end
GO

EXEC ThongTinCuaHang 2007

drop proc ThongTinCuaHang
GO

-- 8) Viết thủ tục Sp_InsertProduct có tham số dạng input dùng để chèn một mẫu tin 
-- vào bảng Production.Product. Yêu cầu: chỉ thêm vào các trường có giá trị not 
-- null và các field là khóa ngoại.
select pp.ProductID, pp.Name, pp.ProductNumber, pp.MakeFlag, pp.FinishedGoodsFlag, 
    pp.SafetyStockLevel, pp.ReorderPoint, pp.StandardCost, pp.ListPrice, pp.DaysToManufacture, 
    pp.SellStartDate, pp.rowguid, pp.ModifiedDate
from Production.Product as pp
where pp.ProductID = 1

GO

-- 9) Viết thủ tục XoaHD, dùng để xóa 1 hóa đơn trong bảng Sales.SalesOrderHeader 
-- khi biết SalesOrderID. Lưu ý : trước khi xóa mẫu tin trong 
-- Sales.SalesOrderHeader thì phải xóa các mẫu tin của hoá đơn đó trong 
-- Sales.SalesOrderDetail.
create proc XoaHD
    @mahd int
as
BEGIN
    delete from Sales.SalesOrderDetail
    where SalesOrderID = @mahd
    delete from Sales.SalesOrderHeader
    where SalesOrderID = @mahd
end
go

EXEC XoaHD 43660

select *
from Sales.SalesOrderHeader

drop proc XoaHD
GO

-- 10)Viết thủ tục Sp_Update_Product có tham số ProductId dùng để tăng listprice
-- lên 10% nếu sản phẩm này tồn tại, ngược lại hiện thông báo không có sản phẩm
-- này
create proc Sp_Update_Product
    @maSP int
as
BEGIN
    if exists (
        select *
    from Production.Product as pp
    where pp.ProductID = @maSP
    )
        begin
        DECLARE @name Nvarchar(30)
        UPDATE Production.Product
            set ListPrice += ListPrice * 0.1
            where ProductID = @maSP

        select @name = pp.Name
        from Production.Product as pp
        where pp.ProductID = @maSP
        print N'Đã tăng 10% giá sản phẩm ' + @name + N' có mã SP: ' + convert(varchar(4), @maSP)
    end
    ELSE
        print N'Không tồn tại sản phẩm này'
end
go

EXEC Sp_Update_Product 720

select pp.ProductID, pp.Name, pp.ListPrice
from Production.Product as pp
where pp.ProductID = 720

drop proc Sp_Update_Product
go