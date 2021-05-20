USE master
GO

ALTER DATABASE AdventureWorks2008R2 set RECOVERY FULL

-- 1. Trong SQL Server, tạo thiết bị backup có tên adv2008back lưu trong thư mục 
-- T:\backup\adv2008back.bak

BACKUP DATABASE AdventureWorks2008R2  -- file 1
TO disk = N'D:\backup\adv2008back.bak'
WITH FORMAT
GO
-- 2. Attach CSDL AdventureWorks2008, chọn mode recovery cho CSDL này là full, rồi 
-- thực hiện full backup vào thiết bị backup vừa tạo
RESTORE DATABASE AdventureWorks2008R2
FROM disk = N'D:\backup\adv2008back.bak'
WITH FILE = 1, replace,  RECOVERY
GO

-- 3. Mở CSDL AdventureWorks2008, tạo một transaction giảm giá tất cả mặt hàng xe 
-- đạp trong bảng Product xuống $15 nếu tổng trị giá các mặt hàng xe đạp không thấp 
-- hơn 60%.

USE AdventureWorks2008R2
GO

CREATE VIEW v_product
AS
    SELECT p.productID, p.Name, p.ListPrice
    FROM Production.Product p
GO

BEGIN TRANSACTION

DECLARE @tongSP INT, @tongBike INT

SELECT @tongSP = sum(p.ListPrice)
FROM v_product p

SELECT @tongBike = sum(v.ListPrice)
FROM v_product v
WHERE v.Name LIKE '%bike%'

IF(@tongBike > @tongSP * 0.6)
    BEGIN
        UPDATE v_product
            SET ListPrice = 15
            WHERE Name LIKE '%bike%'
        PRINT N'Đã giảm giá tất cả các mặt hàng bike về giá 15$'
        COMMIT
    END
ELSE
    BEGIN
        PRINT N'Tổng giá trị của mặt hàng xe đạp < tổng giá trị tất cả mặt hàng'
        PRINT N'Không giảm giá các mặt hàng bike'
        ROLLBACK
    END
GO

-- 4. Thực hiện các backup sau cho CSDL AdventureWorks2008, tất cả backup đều lưu 
-- vào thiết bị backup vừa tạo
--  a. Tạo 1 differential backup 
--  b. Tạo 1 transaction log backup
BACKUP DATABASE AdventureWorks2008R2 -- file 2
TO disk = N'D:\backup\adv2008back.bak'
WITH differential

BACKUP LOG AdventureWorks2008R2 -- file 3
TO disk = N'D:\backup\adv2008back.bak'

-- 5. (Lưu ý ở bước 7 thì CSDL AdventureWorks2008 sẽ bị xóa. Hãy lên kế hoạch phục 
-- hồi cơ sở dữ liệu cho các hoạt động trong câu 5, 6). 
-- Xóa mọi bản ghi trong bảng Person.EmailAddress, tạo 1 transaction log backup
delete from Person.EmailAddress

select * 
from Person.EmailAddress

BACKUP LOG AdventureWorks2008R2 -- file 4
TO disk = N'D:\backup\adv2008back.bak'

-- 6. Thực hiện lệnh:
--  a. Bổ sung thêm 1 số phone mới cho nhân viên có mã số business là 10000 như 
--  sau:
--  INSERT INTO Person.PersonPhone VALUES (10000,'123-456-
--  7890',1,GETDATE())
--  b. Sau đó tạo 1 differential backup cho AdventureWorks2008 và lưu vào thiết bị 
--  backup vừa tạo. 
--  c. Chú ý giờ hệ thống của máy. 
--  Đợi 1 phút sau, xóa bảng Sales.ShoppingCartItem

INSERT INTO Person.PersonPhone VALUES (10000,'123-456-7890',1,GETDATE())

select * from Person.PersonPhone p
WHERE p.BusinessEntityID = 10000

BACKUP DATABASE AdventureWorks2008R2 -- file 5
TO disk = N'D:\backup\adv2008back.bak'
WITH differential

Drop TABLE Sales.ShoppingCartItem

BACKUP log AdventureWorks2008R2 -- file 6
TO disk = N'D:\backup\adv2008back.bak'
GO

-- 7. Xóa CSDL AdventureWorks2008
USE master
GO

DROP DATABASE AdventureWorks2008R2
GO

-- 8. Để khôi phục lại CSDL: 
--  a. Như lúc ban đầu (trước câu 3) thì phải restore thế nào? 
--  b. Ở tình trạng giá xe đạp đã được cập nhật và bảng Person.EmailAddress vẫn 
--  còn nguyên chưa bị xóa (trước câu 5) thì cần phải restore thế nào?
--  c. Đến thời điểm đã được chú ý trong câu 6c thì thực hiện việc restore lại CSDL 
--  AdventureWorks2008 ra sao?

-- a
RESTORE DATABASE AdventureWorks2008R2
FROM disk = N'D:\backup\adv2008back.bak'
WITH FILE = 1, replace,  RECOVERY
GO

-- b
DROP DATABASE AdventureWorks2008R2
GO

RESTORE DATABASE AdventureWorks2008R2
FROM disk = N'D:\backup\adv2008back.bak'
WITH FILE = 1, replace,  NORECOVERY
GO

RESTORE DATABASE  AdventureWorks2008R2   
FROM DISK =  'D:\backup\adv2008back.bak' 
WITH  FILE=2 ,  NORECOVERY
GO

RESTORE LOG  AdventureWorks2008R2   
FROM DISK =  'D:\backup\adv2008back.bak' 
WITH  FILE=3 ,  RECOVERY

-- c
DROP DATABASE AdventureWorks2008R2
GO

RESTORE DATABASE AdventureWorks2008R2
FROM disk = N'D:\backup\adv2008back.bak'
WITH FILE = 1, replace,  NORECOVERY
GO

RESTORE DATABASE  AdventureWorks2008R2   
FROM DISK =  'D:\backup\adv2008back.bak' 
WITH  FILE=5 ,  NORECOVERY
GO

RESTORE LOG  AdventureWorks2008R2   
FROM DISK =  'D:\backup\adv2008back.bak' 
WITH  FILE=6 ,  RECOVERY
GO