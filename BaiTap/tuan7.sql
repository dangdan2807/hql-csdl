USE AdventureWorks2008R2
GO

-- 1. Tạo một Instead of trigger thực hiện trên view. Thực hiện theo các bước sau:
-- Tạo mới 2 bảng M_Employees và M_Department theo cấu trúc sau: 
-- create table M_Department
-- (
--      DepartmentID int not null primary key, 
--      Name nvarchar(50),
--      GroupName nvarchar(50) 
-- )
-- create table M_Employees 
-- (
--      EmployeeID int not null primary key, 
--      Firstname nvarchar(50),
--      MiddleName nvarchar(50), 
--      LastName nvarchar(50),
--      DepartmentID int foreign key references M_Department(DepartmentID) 
-- ) 
-- Tạo một view tên EmpDepart_View bao gồm các field: EmployeeID,
-- FirstName, MiddleName, LastName, DepartmentID, Name, GroupName, dựa 
-- trên 2 bảng M_Employees và M_Department.
-- Tạo một trigger tên InsteadOf_Trigger thực hiện trên view
-- EmpDepart_View, dùng để chèn dữ liệu vào các bảng M_Employees và 
-- M_Department khi chèn một record mới thông qua view EmpDepart_View.
-- Dữ liệu test:
-- insert EmpDepart_view values(1, 'Nguyen','Hoang','Huy', 11,'Marketing','Sales')

-- tạo table 
create table M_Department
(
	DepartmentID int not null primary key,
	Name nvarchar(50),
	GroupName nvarchar(50)
)

create table M_Employees
(
	EmployeeID int not null primary key,
	Firstname nvarchar(50),
	MiddleName nvarchar(50),
	LastName nvarchar(50),
	DepartmentID int foreign key references M_Department(DepartmentID)
)
GO

-- tạo view
create view EmpDepart_View
as
	select e.EmployeeID, e.FirstName, e.MiddleName, e.LastName,
		d.DepartmentID, d.Name, d.GroupName
	from M_Department as d join M_Employees as e
		on d.DepartmentID = e.DepartmentID
go

-- tạo trigger
create trigger insteadof_trigger on EmpDepart_View
	instead of insert
	as	
		begin
	insert M_Department
	select DepartmentID, Name, groupName
	from inserted

	insert M_Employees
	select EmployeeID, FirstName, MiddleName, LastName, DepartmentID
	from inserted
end
go


-- test trigger
select *
from EmpDepart_View
insert EmpDepart_view
values(1, 'Nguyen', 'Hoang', 'Huy', 11, 'Marketing', 'Sales')

select *
from M_Department
select *
from M_Employees

drop view dbo.EmpDepart_View
drop TRIGGER dbo.insteadof_trigger
drop table dbo.M_Department
drop table dbo.M_Employees

-- 2. Tạo một trigger thực hiện trên bảng MySalesOrders có chức năng thiết lập độ ưu 
-- tiên của khách hàng (CustPriority) khi người dùng thực hiện các thao tác Insert, 
-- Update và Delete trên bảng MySalesOrders theo điều kiện như sau:
-- Nếu tổng tiền Sum(SubTotal) của khách hàng dưới 10,000 $ thì độ ưu tiên của 
-- khách hàng (CustPriority) là 3 Nếu tổng tiền Sum(SubTotal) của khách hàng từ 10,000 $ đến dưới 50000 $ 
-- thì độ ưu tiên của khách hàng (CustPriority) là 2 Nếu tổng tiền Sum(SubTotal) của khách hàng từ 50000 $ trở lên thì độ ưu tiên 
-- của khách hàng (CustPriority) là 1
-- Các bước thực hiện:
-- Tạo bảng MCustomers và MSalesOrders theo cấu trúc 
-- sau: create table MCustomer
-- ( 
--		CustomerID int not null primary key, 
--		CustPriority int
-- )
-- create table MSalesOrders 
-- (
--		SalesOrderID int not null primary key, 
--		OrderDate date,
--		SubTotal money, CustomerID int foreign key references MCustomer(CustomerID) 
--	)
-- Chèn dữ liệu cho bảng MCustomers, lấy dữ liệu từ bảng Sales.Customer, 
-- nhưng chỉ lấy CustomerID>30100 và CustomerID<30118, cột CustPriority cho 
-- giá trị null.
-- Chèn dữ liệu cho bảng MSalesOrders, lấy dữ liệu từ bảng
-- Sales.SalesOrderHeader, chỉ lấy những hóa đơn của khách hàng có trong bảng 
-- khách hàng.
-- Viết trigger để lấy dữ liệu từ 2 bảng inserted và deleted.
-- Viết câu lệnh kiểm tra việc thực thi của trigger vừa tạo bằng cách chèn thêm hoặc 
-- xóa hoặc update một record trên bảng MSalesOrders

-- tạo table
create table MCustomer
(
	CustomerID int not null primary key,
	CustPriority int
)

create table MSalesOrders
(
	SalesOrderID int not null primary key,
	OrderDate date,
	SubTotal money,
	CustomerID int foreign key references MCustomer(CustomerID)
)
go

-- chèn dữ liệu
INSERT into MCustomer
	(CustomerID, CustPriority)
SELECT sc.CustomerID, null
FROM Sales.Customer as sc
WHERE sc.CustomerID BETWEEN 30101 and 30117

INSERT into MSalesOrders
	(SalesOrderID, OrderDate, SubTotal, CustomerID)
select s.SalesOrderID, s.OrderDate, s.SubTotal, s.CustomerID
from Sales.SalesOrderHeader as s
WHERE s.CustomerID BETWEEN 30101 and 30117

select *
from dbo.MSalesOrders
select *
from dbo.MCustomer
go

--tạo trigger CustPriority

create TRIGGER set_CustPriority on MSalesOrders
for INSERT, UPDATE, DELETE
as
WITH
	CTE
	AS
	(
					SELECT CustomerId
			FROM inserted

		UNION

			SELECT CustomerId
			FROM deleted
	)

	UPDATE Mcustomer
	SET custpriority = (
		case
		when t.Total < 10000 then 3
		when t.Total between 10000 and 49999 then 2
		when t.Total >= 50000 then 1
		end
	)
	from MSalesOrders as c INNER JOIN CTE ON CTE.CustomerId = c.CustomerId
	LEFT JOIN (
		select MsalesOrders.customerID, SUM(SubTotal) Total
	from MsalesOrders inner join CTE
		on CTE.CustomerId = MsalesOrders.CustomerId
	group by MsalesOrders.customerID
	) t ON CTE.CustomerId = t.CustomerId
GO

insert MsalesOrders
values(71847, '2016-01-01', 10000, 30112)

select*
from Mcustomer
where CustomerId=30112

select*
from MSalesOrders
go

drop trigger dbo.set_CustPriority
drop table dbo.MSalesOrders
drop table dbo.MCustomer

-- 3. Viết một trigger thực hiện trên bảng MEmployees sao cho khi người dùng thực
-- hiện chèn thêm một nhân viên mới vào bảng MEmployees thì chương trình cập 
-- nhật số nhân viên trong cột NumOfEmployee của bảng MDepartment. Nếu tổng 
-- số nhân viên của phòng tương ứng <=200 thì cho phép chèn thêm, ngược lại thì 
-- hiển thị thông báo “Bộ phận đã đủ nhân viên” và hủy giao tác. Các bước thực hiện:
-- Tạo mới 2 bảng MEmployees và MDepartment theo cấu trúc sau:
-- create table MDepartment 
-- (
-- 		DepartmentID int not null primary key, 
-- 		Name nvarchar(50),
-- 		NumOfEmployee int
-- )
-- create table MEmployees 
-- (
-- 		EmployeeID int not null, 
-- 		FirstName nvarchar(50), 
-- 		MiddleName nvarchar(50), 
-- 		LastName nvarchar(50),
-- 		DepartmentID int foreign key references MDepartment(DepartmentID), 
-- 		constraint pk_emp_depart primary key(EmployeeID, DepartmentID
-- )  
-- Chèn dữ liệu cho bảng MDepartment, lấy dữ liệu từ bảng Department, cột 
-- NumOfEmployee gán giá trị NULL, bảng MEmployees lấy từ bảng 
-- EmployeeDepartmentHistory
-- Viết trigger theo yêu cầu trên và viết câu lệnh hiện thực trigger

create table MDepartment
(
	DepartmentID int not null primary key,
	Name nvarchar(50),
	NumOfEmployee int
)

create table MEmployees
(
	EmployeeID int not null,
	FirstName nvarchar(50),
	MiddleName nvarchar(50),
	LastName nvarchar(50),
	DepartmentID int foreign key references MDepartment(DepartmentID),
	constraint pk_emp_depart primary key(EmployeeID, DepartmentID)
)
go

insert MDepartment
select [DepartmentID], [Name], null
from [HumanResources].[Department]

insert [Memployees]
select e.[BusinessEntityID], [FirstName], [MiddleName], [LastName], [DepartmentID]
from [HumanResources].[Employee] e join [Person].[Person] p on e.BusinessEntityID=p.BusinessEntityID
	join [HumanResources].[EmployeeDepartmentHistory] h on e.BusinessEntityID=h.BusinessEntityID

select*
from [dbo].[Memployees]
order by [DepartmentID]
go

-- tạo trigger
create trigger kiemTraSLNV on dbo.MEmployees
for INSERT
as 
	DECLARE @slNV int, @DepartID int
	SELECT @DepartID = i.DepartmentID
FROM inserted as i

	SET @slNV = (
		SELECT COUNT(*)
FROM [dbo].[Memployees] e
WHERE e.DepartmentID = @DepartID
		)
	
	if(@slNV > 200)
		BEGIN
	print N'Bộ phận đã đủ nhân viên'
	rollback
end
	else
		begin
	update MDepartment
		set NumOfEmployee = @slNV
		where DepartmentID = @DepartID
end
go

--test trigger
insert [dbo].[Memployees]
values(291, 'Nguyen', 'Hoang', 'Anh', 1),
	(292, 'Nguyen', 'Hoang', 'Thu', 2)

--kiem tra ket qua
select *
from MDepartment

drop trigger dbo.kiemTraSLNV;
drop table dbo.MEmployees
drop table dbo.MDepartment
GO

-- 4. Bảng [Purchasing].[Vendor], chứa thông tin của nhà cung cấp, thuộc tính
-- CreditRating hiển thị thông tin đánh giá mức tín dụng, có các giá trị: 
-- 1 = Superior
-- 2 = Excellent
-- 3 = Above average 
-- 4 = Average
-- 5 = Below average
-- Viết một trigger nhằm đảm bảo khi chèn thêm một record mới vào bảng 
-- [Purchasing].[PurchaseOrderHeader], nếu Vender có CreditRating=5 thì hiển thị 
-- thông báo không cho phép chèn và đồng thời hủy giao tác.
-- Dữ liệu test
-- INSERT INTO Purchasing.PurchaseOrderHeader (RevisionNumber, Status, 
-- EmployeeID, VendorID, ShipMethodID, OrderDate, ShipDate, SubTotal, TaxAmt, 
-- Freight) VALUES ( 2 ,3, 261, 1652, 4 ,GETDATE() ,GETDATE() , 44594.55,
-- ,3567.564, ,1114.8638 );

CREATE trigger Purchasing.CreditRating_trigger on [Purchasing].[PurchaseOrderHeader]
for insert
AS
	if exists (
		select *
from [Purchasing].[PurchaseOrderHeader] as p join inserted as i
	on p.PurchaseOrderID = i.PurchaseOrderID join [Purchasing].[Vendor] as v
	on p.VendorID = v.BusinessEntityID
where v.CreditRating = 5
	)
		BEGIN
	RAISERROR ('A vendor''s credit rating is too low to accept new purchase orders.', 16, 1);
	ROLLBACK TRANSACTION
END
GO

INSERT INTO Purchasing.PurchaseOrderHeader
	(RevisionNumber, Status, EmployeeID, VendorID, ShipMethodID, OrderDate, ShipDate, SubTotal, TaxAmt, Freight)
VALUES
	( 2, 3, 261, 1652, 4 , GETDATE() , GETDATE() , 44594.55, 3567.564, 1114.8638 )

drop trigger Purchasing.CreditRating_trigger
GO

-- 5. Viết một trigger thực hiện trên bảng ProductInventory (lưu thông tin số lượng sản 
-- phẩm trong kho). Khi chèn thêm một đơn đặt hàng vào bảng SalesOrderDetail với 
-- số lượng xác định trong field
-- OrderQty, nếu số lượng trong kho 
-- Quantity> OrderQty thì cập nhật 
-- lại số lượng trong kho 
-- Quantity= Quantity- OrderQty, 
-- ngược lại nếu Quantity=0 thì xuất 
-- thông báo “Kho hết hàng” và đồng 
-- thời hủy giao tác.

-- tạo bảng MProduct
create table MProduct
(
	MProductID int not null primary key,
	ProductName nvarchar(50),
	ListPrice money
)

insert MProduct
	(MProductID, ProductName,ListPrice)
select [ProductID], [Name], [ListPrice]
from [Production].[Product]
where [ProductID]<=710
select*
from MProduct

-- tạo bảng MSalesOrderHeader
create table MSalesOrderHeader
(
	MSalesOrderID int not null primary key,
	OrderDate datetime
)

insert MSalesOrderHeader
select [SalesOrderID], [OrderDate]
from [Sales].[SalesOrderHeader]
where [SalesOrderID] in (select [SalesOrderID]
from [Sales].[SalesOrderDetail]
where [ProductID]<=710)
select*
from MSalesOrderHeader

-- tạo bảng MSalesOrderDetail
create table MSalesOrderDetail
(
	SalesOrderDetailID int IDENTITY(1,1) primary key,
	ProductID int not null foreign key(ProductID) references MProduct(MProductID),
	SalesOrderID int not null foreign key (SalesOrderID) references MSalesOrderHeader(MSalesOrderID),
	OrderQty int
)
insert MSalesOrderDetail
	(ProductID, SalesOrderID,OrderQty)
select [ProductID], [SalesOrderID], [OrderQty]
from [Sales].[SalesOrderDetail]
where [ProductID] in(select MProductID
from MProduct)

-- tạo bảng MProduct_inventory
create table MProduct_inventory
(
	productID int not null primary key,
	quantity smallint
)

insert MProduct_inventory
select [ProductID], sum([Quantity]) as sumofquatity
from [Production].[ProductInventory]
group by [ProductID]
go

-- tạo trigger
create trigger bai5 on MSalesOrderDetail
for insert
AS
begin
	DECLARE @Qty int, @Quantity int, @productID int
	select @qty = i.OrderQty, @productID = i.ProductID
	from inserted i

	select @Quantity =  p.Quantity
	FROM MProduct_inventory p
	WHERE @productID = p.ProductID

	if(@Quantity > @Qty)
	begin
		update MProduct_inventory
				set quantity = @Quantity - @Qty
				where productID = @productID
	end
	ELSE if (@Quantity = 0)
	begin
		print N'Kho hết hàng'
		rollback
	end
end
GO

select*
from MSalesOrderDetail
select*
from MSalesOrderHeader
select*
from MProduct_inventory
where [ProductID]=708

---thuc thi trigger
delete from [MSalesOrderDetail]
insert [dbo].[MSalesOrderDetail]
values(708, 43661, 300)

drop trigger bai5
drop table [MSalesOrderDetail]
drop table [MSalesOrderHeader]
drop table [MProduct_inventory]

-- 6. Tạo trigger cập nhật tiền thưởng (Bonus) cho nhân viên bán hàng SalesPerson, khi 
-- người dùng chèn thêm một record mới trên bảng SalesOrderHeader, theo quy định 
-- như sau: Nếu tổng tiền bán được của nhân viên có hóa đơn mới nhập vào bảng 
-- SalesOrderHeader có giá trị >10000000 thì tăng tiền thưởng lên 10% của mức 
-- thưởng hiện tại. Cách thực hiện:
--  Tạo hai bảng mới M_SalesPerson và M_SalesOrderHeader
-- create table M_SalesPerson 
-- (
-- 		SalePSID int not null primary key, 
-- 		TerritoryID int,
-- 		BonusPS money
-- )
-- create table M_SalesOrderHeader 
-- (
-- 		SalesOrdID int not null primary key, 
-- 		OrderDate date,
-- 		SubTotalOrd money,
-- 		SalePSID int foreign key references M_SalesPerson(SalePSID) 
-- ) 
-- - Chèn dữ liệu cho hai bảng trên lấy từ SalesPerson và SalesOrderHeader chọn 
-- những field tương ứng với 2 bảng mới tạo.
-- - Viết trigger cho thao tác insert trên bảng M_SalesOrderHeader, khi trigger 
-- thực thi thì dữ liệu trong bảng M_SalesPerson được cập nhật.

create table M_SalesPerson
(
	SalePSID int not null primary key,
	TerritoryID int,
	BonusPS money
)

create table M_SalesOrderHeader
(
	SalesOrdID int not null primary key,
	OrderDate date,
	SubTotalOrd money,
	SalePSID int foreign key references M_SalesPerson(SalePSID)
)

insert into M_SalesPerson
select s.BusinessEntityID, s.TerritoryID, s.Bonus
from Sales.SalesPerson as s

insert into M_SalesOrderHeader
select s.SalesOrderID, s.OrderDate, s.SubTotal, s.SalesPersonID
from Sales.SalesOrderHeader as s
go

CREATE trigger bonus_trigger on M_SalesOrderHeader
FOR INSERT
as
	begin
	DECLARE @doanhThu float, @maNV int
	select @maNV= i.SalePSID
	from inserted i

	set @doanhThu=(
		select sum([SubTotalOrd])
	from [dbo].[M_SalesOrderHeader]
	where SalePSID=@maNV
	)

	if (@doanhThu > 10000000)
	begin
		update M_SalesPerson
				set BonusPS += BonusPS * 0.1
				where SalePSID=@maNV
	end
end
go