USE AdventureWorks2008R2
GO

-- 1. Trong SQL Server, tạo thiết bị backup có tên adv2008back lưu trong thư mục 
-- T:\backup\adv2008back.bak

backup database AdventureWorks2008R2
to disk = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\backup\adv2008back.bak'

-- 2. Attach CSDL AdventureWorks2008, chọn mode recovery cho CSDL này là full, rồi 
-- thực hiện full backup vào thiết bị backup vừa tạo
restore database AdventureWorks2008R2
from disk = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\backup\adv2008back.bak'
GO

-- 3. Mở CSDL AdventureWorks2008, tạo một transaction giảm giá tất cả mặt hàng xe 
-- đạp trong bảng Product xuống $15 nếu tổng trị giá các mặt hàng xe đạp không thấp 
-- hơn 60%.
alter view v_product
as
    select p.productID, p.Name, p.ListPrice
    from Production.Product p
go

DECLARE @tongSP int, @tongBike int

select @tongSP = sum(p.ListPrice)
from v_product p

select @tongBike = sum(v.ListPrice)
from v_product v
where v.Name like '%bike%'

if(@tongBike > @tongSP * 0.6)
    BEGIN
        update v_product
        set ListPrice = 15
        where Name like '%bike%'
        print N'Đã giảm giá tất cả các mặt hàng bike về giá 15$'
    end
else
    print N'Tổng giá trị của mặt hàng xe đạp < tổng giá trị tất cả mặt hàng'
    print N'Không giảm giá các mặt hàng bike'
go

-- 4. Thực hiện các backup sau cho CSDL AdventureWorks2008, tất cả backup đều lưu 
-- vào thiết bị backup vừa tạo
--  a. Tạo 1 differential backup 
--  b. Tạo 1 transaction log backup
backup database AdventureWorks2008R2
to disk = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\backup\AdventureWorks2008R2_differential.bak'
with differential


ALTER DATABASE AdventureWorks2008R2
SET RECOVERY FULL
GO

backup log AdventureWorks2008R2
to disk = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\backup\AdventureWorks2008R2_log.bak'

-- 5. (Lưu ý ở bước 7 thì CSDL AdventureWorks2008 sẽ bị xóa. Hãy lên kế hoạch phục 
-- hồi cơ sở dữ liệu cho các hoạt động trong câu 5, 6). 
-- Xóa mọi bản ghi trong bảng Person.EmailAddress, tạo 1 transaction log backup
delete from Person.EmailAddress

select * 
from Person.EmailAddress

drop database AdventureWorks2008R2

-- 6. Thực hiện lệnh:
--  a. Bổ sung thêm 1 số phone mới cho nhân viên có mã số business là 10000 như 
--  sau:
--  INSERT INTO Person.PersonPhone VALUES (10000,'123-456-
--  7890',1,GETDATE())
--  b. Sau đó tạo 1 differential backup cho AdventureWorks2008 và lưu vào thiết bị 
--  backup vừa tạo. 
--  c. Chú ý giờ hệ thống của máy. 
--  Đợi 1 phút sau, xóa bảng Sales.ShoppingCartItem


-- 7. Xóa CSDL AdventureWorks2008


-- 8. Để khôi phục lại CSDL: 
--  a. Như lúc ban đầu (trước câu 3) thì phải restore thế nào? 
--  b. Ở tình trạng giá xe đạp đã được cập nhật và bảng Person.EmailAddress vẫn 
--  còn nguyên chưa bị xóa (trước câu 5) thì cần phải restore thế nào?
--  c. Đến thời điểm đã được chú ý trong câu 6c thì thực hiện việc restore lại CSDL 
--  AdventureWorks2008 ra sao?