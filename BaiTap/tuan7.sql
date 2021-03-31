-- USE AdventureWorks2008R2
-- GO

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
			select DepartmentID, Name, groupName from inserted
			insert M_Employees
			select EmployeeID, FirstName, MiddleName, LastName, DepartmentID
			from inserted
		end
go

-- test trigger
select * from EmpDepart_View
insert EmpDepart_view values(1, 'Nguyen','Hoang','Huy', 11,'Marketing','Sales')

select * from M_Department
select * from M_Employees

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
-- ( CustomerID int not null primary key, 
-- CustPriority int)
-- create table MSalesOrders 
-- (
-- SalesOrderID int not null primary key, 
-- OrderDate date,
-- SubTotal money, CustomerID int foreign key references MCustomer(CustomerID) )
-- Chèn dữ liệu cho bảng MCustomers, lấy dữ liệu từ bảng Sales.Customer, 
-- nhưng chỉ lấy CustomerID>30100 và CustomerID<30118, cột CustPriority cho 
-- giá trị null.
-- Chèn dữ liệu cho bảng MSalesOrders, lấy dữ liệu từ bảng
-- Sales.SalesOrderHeader, chỉ lấy những hóa đơn của khách hàng có trong bảng 
-- khách hàng.
-- Viết trigger để lấy dữ liệu từ 2 bảng inserted và deleted.
-- Viết câu lệnh kiểm tra việc thực thi của trigger vừa tạo bằng cách chèn thêm hoặc 
-- xóa hoặc update một record trên bảng MSalesOrders


-- 3. Viết một trigger thực hiện trên bảng MEmployees sao cho khi người dùng thực
-- hiện chèn thêm một nhân viên mới vào bảng MEmployees thì chương trình cập 
-- nhật số nhân viên trong cột NumOfEmployee của bảng MDepartment. Nếu tổng 
-- số nhân viên của phòng tương ứng <=200 thì cho phép chèn thêm, ngược lại thì 
-- hiển thị thông báo “Bộ phận đã đủ nhân viên” và hủy giao tác. Các bước thực hiện:
-- Tạo mới 2 bảng MEmployees và MDepartment theo cấu trúc sau:
-- create table MDepartment 
-- (
-- DepartmentID int not null primary key, 
-- Name nvarchar(50),
-- NumOfEmployee int
-- )
-- create table MEmployees 
-- (
-- EmployeeID int not null, 
-- FirstName nvarchar(50), 
-- MiddleName nvarchar(50), 
-- LastName nvarchar(50),
-- DepartmentID int foreign key references MDepartment(DepartmentID), 
-- constraint pk_emp_depart primary key(EmployeeID, DepartmentID)  Chèn dữ liệu cho bảng MDepartment, lấy dữ liệu từ bảng Department, cột 
-- NumOfEmployee gán giá trị NULL, bảng MEmployees lấy từ bảng 
-- EmployeeDepartmentHistory
-- Viết trigger theo yêu cầu trên và viết câu lệnh hiện thực trigger


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


-- 5. Viết một trigger thực hiện trên bảng ProductInventory (lưu thông tin số lượng sản 
-- phẩm trong kho). Khi chèn thêm một đơn đặt hàng vào bảng SalesOrderDetail với 
-- số lượng xác định trong field
-- OrderQty, nếu số lượng trong kho 
-- Quantity> OrderQty thì cập nhật 
-- lại số lượng trong kho 
-- Quantity= Quantity- OrderQty, 
-- ngược lại nếu Quantity=0 thì xuất 
-- thông báo “Kho hết hàng” và đồng 
-- thời hủy giao tác.6. Tạo trigger cập nhật tiền thưởng (Bonus) cho nhân viên bán hàng SalesPerson, khi 
-- người dùng chèn thêm một record mới trên bảng SalesOrderHeader, theo quy định 
-- như sau: Nếu tổng tiền bán được của nhân viên có hóa đơn mới nhập vào bảng 
-- SalesOrderHeader có giá trị >10000000 thì tăng tiền thưởng lên 10% của mức 
-- thưởng hiện tại. Cách thực hiện:
--  Tạo hai bảng mới M_SalesPerson và M_SalesOrderHeader
-- create table M_SalesPerson 
-- (
-- SalePSID int not null primary key, 
-- TerritoryID int,
-- BonusPS money
-- )
-- create table M_SalesOrderHeader 
-- (
-- SalesOrdID int not null primary key, 
-- OrderDate date,
-- SubTotalOrd money,
-- SalePSID int foreign key references M_SalesPerson(SalePSID) )  Chèn dữ liệu cho hai bảng trên lấy từ SalesPerson và SalesOrderHeader chọn 
-- những field tương ứng với 2 bảng mới tạo.
--  Viết trigger cho thao tác insert trên bảng M_SalesOrderHeader, khi trigger 
-- thực thi thì dữ liệu trong bảng M_SalesPerson được cập nhật.