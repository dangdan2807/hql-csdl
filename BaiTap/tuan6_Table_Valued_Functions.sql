USE AdventureWorks2008R2
go

-- 4) Viết hàm SumOfOrder với hai tham số @thang và @nam trả về danh sách các 
-- hóa đơn (SalesOrderID) lập trong tháng và năm được truyền vào từ 2 tham số
-- @thang và @nam, có tổng tiền >70000, thông tin gồm SalesOrderID, OrderDate,
-- SubTotal, trong đó SubTotal =sum(OrderQty*UnitPrice).
CREATE FUNCTION SumOfOrder
(
    @thang int, @nam int
)
returns Table
AS
    return (
        SELECT soh.SalesOrderID, soh.OrderDate, SubTotal = sum(sod.OrderQty * sod.UnitPrice)
from Sales.SalesOrderHeader as soh join Sales.SalesOrderDetail as sod
    on soh.SalesOrderID = sod.SalesOrderID
where month(soh.OrderDate) = 1 and year(soh.OrderDate) = 2008
group by soh.SalesOrderID, soh.OrderDate
having sum(sod.OrderQty * sod.UnitPrice) > 70000
    )
go

DECLARE @thang int, @nam int
set @thang = 1
set @nam = 2008

select *
from dbo.SumOfOrder(@thang, @nam)

drop function dbo.SumOfOrder
go

-- 5) Viết hàm tên NewBonus tính lại tiền thưởng (Bonus) cho nhân viên bán hàng 
-- (SalesPerson), dựa trên tổng doanh thu của mỗi nhân viên, mức thưởng mới bằng 
-- mức thưởng hiện tại tăng thêm 1% tổng doanh thu, thông tin bao gồm 
-- [SalesPersonID], NewBonus (thưởng mới), SumOfSubTotal. Trong đó:
--  SumOfSubTotal =sum(SubTotal),
--  NewBonus = Bonus+ sum(SubTotal)*0.01
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

create function NewBonus()
returns Table
as
    return (
        select v.SalesPersonID, NewBonus = v.Bonus+ sum(v.SubTotal) * 0.01, SumOfSubTotal =sum(v.SubTotal)
from v_newBonus as v
group by v.SalesPersonID, v.Bonus, v.SubTotal
    )
GO

select *
from dbo.NewBonus()

drop function dbo.NewBonus
drop view v_newBonus
go

-- 6) Viết hàm tên SumOfProduct với tham số đầu vào là @MaNCC (VendorID),hàm dùng để tính tổng số lượng (SumOfQty) 
-- và tổng trị giá (SumOfSubTotal)
-- của các sản phẩm do nhà cung cấp @MaNCC cung cấp, thông tin gồm 
-- ProductID, SumOfProduct, SumOfSubTotal
-- (sử dụng các bảng [Purchasing].[Vendor] [Purchasing].[PurchaseOrderHeader] 
-- và [Purchasing].[PurchaseOrderDetail])
create function SumOfProduct
(
    @MaNCC int
)
returns table
as 
    return (
        select c.ProductID, SumOfProduct = SUM(c.OrderQty), SumOfSubTotal = SUM(c.OrderQty * c.UnitPrice)
        from [Purchasing].[Vendor] as a join [Purchasing].PurchaseOrderHeader as b
            on a.BusinessEntityID = b.VendorID join [Purchasing].PurchaseOrderDetail c
            on b.PurchaseOrderID = c.PurchaseOrderID
        where b.VendorID = @MaNCC
        GROUP by c.productID
    )
go

DECLARE @MaNCC int
set @MaNCC = 1658

select *
from dbo.SumOfProduct(@MaNCC)
go

drop function dbo.SumOfProduct
go

-- 7) Viết hàm tên Discount_Func tính số tiền giảm trên các hóa đơn(SalesOrderID), 
-- thông tin gồm SalesOrderID, [SubTotal], Discount; trong đó Discount được tính 
-- như sau:
-- Nếu [SubTotal]<1000 thì Discount=0 
-- Nếu 1000<=[SubTotal]<5000 thì Discount = 5%[SubTotal]
-- Nếu 5000<=[SubTotal]<10000 thì Discount = 10%[SubTotal] 
-- Nếu [SubTotal>=10000 thì Discount = 15%[SubTotal]
create function Discount_Func()
returns Table
as
return (
    select ssod.SalesOrderID, SubTotal=SUM(ssod.LineTotal), Discount = (
        case 
            when SUM(ssod.LineTotal) < 1000 then 0
            when SUM(ssod.LineTotal) between 1000 and 5000 then SUM(ssod.LineTotal) * 0.05
            when SUM(ssod.LineTotal) between 5000 and 10000 then SUM(ssod.LineTotal) * 0.1
            else SUM(ssod.LineTotal) * 0.15
        end
    )
    from Sales.SalesOrderDetail as ssod
    group by ssod.SalesOrderID 
)
go

select *
from dbo.Discount_Func()
go

drop function dbo.Discount_Func
go

-- 8) Viết hàm TotalOfEmp với tham số @MonthOrder, @YearOrder để tính tổng 
-- doanh thu của các nhân viên bán hàng (SalePerson) trong tháng và năm được 
-- truyền vào 2 tham số, thông tin gồm [SalesPersonID], Total, với 
-- Total=Sum([SubTotal])
create function TotalOfEmp
(
    @MonthOrder int,
    @YearOrder int
)
returns Table
as
    return (
        select b.SalesPersonID, Tota = Sum(b.SubTotal)
        from Sales.SalesOrderHeader as b
        where month(b.OrderDate) = @MonthOrder and year(b.OrderDate) = @YearOrder
        group by b.SalesPersonID
    )
GO

DECLARE @thang int, @nam int
set @thang = 1
set @nam = 2008

select * 
from dbo.TotalOfEmp(@thang, @nam)

drop function dbo.TotalOfEmp
go