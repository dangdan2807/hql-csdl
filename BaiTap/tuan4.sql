USE AdventureWorks2008R2

-- 1) Viết một batch khai báo biến @tongsoHD chứa tổng số hóa đơn của sản phẩm 
-- có ProductID=’778’; nếu @tongsoHD>500 thì in ra chuỗi “Sản phẩm 778 có 
-- trên 500 đơn hàng”, ngược lại thì in ra chuỗi “Sản phẩm 778 có ít đơn đặt hàng”
DECLARE @tongsoHD int, @masp int
set @masp = 778
set @tongsoHD = (
    select count(*)
from Sales.SalesOrderDetail as ssod
where ssod.ProductID = @masp
)

if @tongsoHD > 500
    print N'Sản phẩm ' + convert(nvarchar(3), @masp) + N' có trên 500 đơn hàng'
else
    print N'Sản phẩm ' + convert(nvarchar(3), @masp) + N' có ít hơn 500 đơn hàng'


select [SalesOrderID], [ProductID]
from [Sales].[SalesOrderDetail] as ssod
where ssod.ProductID = 778
order by ssod.[ProductID]

-- 2) Viết một đoạn Batch với tham số @makh và @n chứa số hóa đơn của khách 
-- hàng @makh, tham số @nam chứa năm lập hóa đơn (ví dụ @nam=2008), nếu
-- @n>0 thì in ra chuỗi: “Khách hàng @makh có @n hóa đơn trong năm 2008” 
-- ngược lại nếu @n=0 thì in ra chuỗi “Khách hàng @makh không có hóa đơn nào 
-- trong năm 2008”
SELECT sc.CustomerID
from Sales.Customer as sc

DECLARE @makh int, @n int, @nam int
set @nam = 2008
set @makh = 11000
set @n = (
    select count(*)
from Sales.SalesOrderHeader as ssoh
where year(ssoh.OrderDate) = @nam and ssoh.CustomerID = @makh
)

if @n > 0
    print N'Khách hàng ' + convert(nvarchar(5), @makh) + N' có ' + convert(nvarchar(6), @n) + N' hoá đơn trong năm ' + convert(nvarchar(4), @nam)
else
    print N'Khách hàng ' + convert(nvarchar(5), @makh) + N' không có hoá đơn nào trong năm ' + convert(nvarchar(4), @nam)


-- 3) Viết một batch tính số tiền giảm cho những hóa đơn (SalesOrderID) có tổng 
-- tiền>100000, thông tin gồm [SalesOrderID], SubTotal=SUM([LineTotal]), 
-- Discount (tiền giảm), với Discount được tính như sau:
-- + Những hóa đơn có SubTotal<100000 thì không giảm,
-- + SubTotal từ 100000 đến <120000 thì giảm 5% của SubTotal
-- + SubTotal từ 120000 đến <150000 thì giảm 10% của SubTotal
-- + SubTotal từ 150000 trở lên thì giảm 15% của SubTotal
-- (Gợi ý: Dùng cấu trúc Case… When …Then …)
select ssod.SalesOrderID, SubTotal=SUM(ssod.LineTotal), Discount = (
        case 
            when SUM(ssod.LineTotal) < 100000 then 0
            when SUM(ssod.LineTotal) between 100000 and 120000 then SUM(ssod.LineTotal) * 0.05
            when SUM(ssod.LineTotal) between 120000 and 150000 then SUM(ssod.LineTotal) * 0.1
            else SUM(ssod.LineTotal) * 0.15
        end
    )
from Sales.SalesOrderDetail as ssod
group by ssod.SalesOrderID
HAVING SUM(ssod.LineTotal) > 100000

-- kiểm tra lại kết quả
select ssod.SalesOrderID, SubTotal=SUM(ssod.LineTotal)
from Sales.SalesOrderDetail as ssod
group by ssod.SalesOrderID
HAVING SUM(ssod.LineTotal) > 100000

-- 4) Viết một Batch với 3 tham số: @mancc, @masp, @soluongcc, chứa giá trị của 
-- các field [ProductID], [BusinessEntityID], [OnOrderQty], với giá trị truyền cho 
-- các biến @mancc, @masp (vd: @mancc=1650, @masp=4), thì chương trình sẽ 
-- gán giá trị tương ứng của field [OnOrderQty] cho biến @soluongcc, nếu
-- @soluongcc trả về giá trị là null thì in ra chuỗi “Nhà cung cấp 1650 không cung 
-- cấp sản phẩm 4”, ngược lại (vd: @soluongcc=5) thì in chuỗi “Nhà cung cấp 1650 
-- cung cấp sản phẩm 4 với số lượng là 5”
-- (Gợi ý: Dữ liệu lấy từ [Purchasing].[ProductVendor])
DECLARE @mancc int, @masp_bai4 int, @soluongcc int
set @mancc = 1650
set @masp_bai4 = 4
set @soluongcc = (
    select ppv.OnOrderQty
    from Production.Product as pp join Purchasing.ProductVendor as ppv
    on pp.ProductID = ppv.ProductID
    where ppv.ProductID = @masp_bai4 and ppv.BusinessEntityID = @mancc
)

if @soluongcc is null
    print N'Nhà cung cấp ' + convert(nvarchar(5), @mancc) + N' không cung cấp sản phẩm có mã: ' + convert(varchar(5), @masp_bai4)
else
    print N'Nhà cung cấp ' + convert(nvarchar(5), @mancc) + N' cấp sản phẩm có mã: ' + convert(varchar(5), @masp_bai4) + N' với số lượng là ' + convert(varchar(5), @soluongcc)

-- 5) Viết một batch thực hiện tăng lương giờ (Rate) của nhân viên trong 
-- [HumanResources].[EmployeePayHistory] theo điều kiện sau: Khi tổng lương 
-- giờ của tất cả nhân viên Sum(Rate)<6000 thì cập nhật tăng lương giờ lên 10%, 
-- nếu sau khi cập nhật mà lương giờ cao nhất của nhân viên >150 thì dừng
go
CREATE view hreph1 as 
    select hreph.BusinessEntityID, hreph.ModifiedDate, hreph.PayFrequency, hreph.Rate, hreph.RateChangeDate
    from HumanResources.EmployeePayHistory as hreph
go

-- kiểm tra kết quả
select * from hreph1


while (
    select sum(rate)
    from hreph1 ) < 7000
    BEGIN
        update hreph1
        set rate = rate * 1.1
        if (select max(rate)
        from hreph1) > 500
            BREAK
        ELSE
            continue
end

drop view hreph1
go