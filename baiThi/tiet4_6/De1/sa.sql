USE master
GO

-- 1.a. Tạo các login; tạo các user khai thác CSDL AdventureWorks2008R2 cho các nhân viên (tên
-- login trùng tên user)

CREATE LOGIN NV1 WITH PASSWORD = N'123456'
CREATE LOGIN NV2 WITH PASSWORD = N'123456'
CREATE LOGIN QL WITH PASSWORD = N'123456'
GO

USE AdventureWorks2008R2
GO

CREATE USER NV1 FOR login NV1
CREATE USER NV2 FOR login NV2
CREATE USER QL  FOR login QL
GO

-- 1.b. Tạo role NhanVien, phân quyền cho role, thêm các user NV1, NV2, QL vào các role theo
-- phân công ở trên để các nhân viên hoàn thành nhiệm vụ
CREATE ROLE NhanVien
GO

GRANT SELECT, INSERT, DELETE, UPDATE
ON Person.PersonPhone
TO NhanVien
GO

ALTER ROLE NhanVien
ADD MEMBER NV1

ALTER ROLE NhanVien
ADD MEMBER NV2

ALTER ROLE db_datareader
ADD member QL
GO

-- 1.d. Ai có thể xem dữ liệu bảng Person.Person? Giải thích. Viết lệnh kiểm tra quyền trên cửa sổ
-- query của user tương ứng

-- admin (Sa) có quyền xem dữ liệu bảng Person.Person
-- vì là người có quản trị của database

SELECT *
FROM Person.Person

-- 1.e. Các nhân viên quản lý NV1, NV2, QL hoàn thành dự án, admin thu hồi quyền đã cấp. Xóa
-- role NhanVien.

ALTER ROLE NhanVien
DROP MEMBER NV1

ALTER ROLE NhanVien
DROP MEMBER NV2

ALTER ROLE db_datareader
DROP MEMBER QL
GO

DROP ROLE NhanVien
GO

-- 2.a. Tạo một giao tác tăng lương (Rate) thêm 20% cho các nhân viên làm việc ở phòng
-- (Department.Name) ‘Production’ và ‘Production Control’. Tăng lương 15% cho các nhân
-- viên các phòng ban khác.

BEGIN TRAN
UPDATE HumanResources.EmployeePayHistory
    SET Rate = rate + rate * 0.2
    WHERE BusinessEntityID IN (
        SELECT e.BusinessEntityID
FROM HumanResources.EmployeeDepartmentHistory e, HumanResources.Department d
WHERE e.DepartmentID = d.DepartmentID
    AND d.Name IN (N'Production', N'Production Control')
    )

UPDATE HumanResources.EmployeePayHistory
    SET Rate = rate + rate * 0.15
    WHERE BusinessEntityID IN (
        SELECT e.BusinessEntityID
FROM HumanResources.EmployeeDepartmentHistory e, HumanResources.Department d
WHERE e.DepartmentID = d.DepartmentID
    AND d.Name  NOT IN (N'Production', N'Production Control')
    )
COMMIT
GO

USE master
ALTER DATABASE AdventureWorks2008R2 SET RECOVERY FULL
GO

BACKUP DATABASE AdventureWorks2008R2  -- file 1
TO disk = N'D:\backup\adv2008back.bak'
WITH FORMAT
GO

-- 2b. Xóa mọi bản ghi trong bảng PurchaseOrderDetail
USE AdventureWorks2008R2
GO

DELETE Purchasing.PurchaseOrderDetail

-- kiểm tra
SELECT *
FROM Purchasing.PurchaseOrderDetail

BACKUP DATABASE AdventureWorks2008R2  -- file 2
TO disk = N'D:\backup\adv2008back.bak'
WITH DIFFERENTIAL;  
GO

-- 2c. Bổ sung thêm 1 số phone mới (Person.PersonPhone) tùy ý cho nhân viên có mã số nhân viên
-- 9651,  ModifiedDate=getdate().

INSERT INTO Person.PersonPhone
    (BusinessEntityID, ModifiedDate, PhoneNumber, PhoneNumberTypeID)
VALUES
    (9651, GETDATE(), N'123-456-7890', 1)
GO

-- kiểm tra kết quả
SELECT *
FROM Person.PersonPhone
WHERE BusinessEntityID = 9651
GO

BACKUP LOG AdventureWorks2008R2 -- file 3
TO DISK = N'D:\backup\adv2008back.bak'
GO

-- 2d. Xóa CSDL AdventureWorks2008R2. Phục hồi CSDL về trạng thái sau khi thực hiện bước
-- c Kiểm tra xem dữ liệu phục hồi có đạt yêu cầu không (lương có tăng, các bản ghi có bị
-- xóa, có thêm số phone mới)

USE master
GO

DROP DATABASE AdventureWorks2008R2
GO

RESTORE DATABASE  AdventureWorks2008R2   
FROM DISK = N'D:\backup\adv2008back.bak' 
WITH FILE=1, REPLACE, NORECOVERY	
GO

---b2 : dựa trên bản differential backup (FILE =2 )
RESTORE DATABASE  AdventureWorks2008R2   
FROM DISK = N'D:\backup\adv2008back.bak' 
WITH FILE=2, NORECOVERY
GO

--b3 : dựa trên bản log backup 1 (FILE =3)  
RESTORE LOG AdventureWorks2008R2   
FROM DISK = N'D:\backup\adv2008back.bak' 
WITH FILE=3, RECOVERY
GO

-- kiểm tra dữ liệu
USE AdventureWorks2008R2
GO
-- kiểm tra tăng lương
SELECT e.BusinessEntityID, d.Name, eh.Rate
FROM HumanResources.EmployeeDepartmentHistory e, HumanResources.Department d, HumanResources.EmployeePayHistory eh
WHERE e.DepartmentID = d.DepartmentID
and e.BusinessEntityID = eh.BusinessEntityID

-- có tăng

-- kiểm tra bảng PurchaseOrderDetail có bị xóa mọi record
SELECT * 
from Purchasing.PurchaseOrderDetail
-- đã xóa

-- kiểm tra số điện thoại mới đã thêm
SELECT *
FROM Person.PersonPhone
WHERE BusinessEntityID = 9651
GO

-- đã thêm 

-- 3. Viết after trigger trên bảng ProductReview

CREATE TRIGGER procV
ON Production.ProductReview
after UPDATE
AS
BEGIN
    DECLARE @proID INT
    SELECT @proID = i.ProductID
    FROM inserted i

    IF EXISTS (SELECT *
    FROM Production.Product p
    WHERE p.ProductID = @proID)
    BEGIN
        SELECT p.ProductID, p.Color, p.StandardCost, pr.Rating, pr.Comments
        FROM Production.Product p, Production.ProductReview pr
        WHERE p.ProductID = pr.ProductID
            AND p.ProductID = @proID
    END
    ELSE
    BEGIN
        PRINT N'Không có thông tin sản phẩm'
        ROLLBACK
    END
END
GO

-- trường hợp sản phẩm có tồn tại
UPDATE Production.ProductReview
SET Comments = N'1'
WHERE ProductReviewID = 1
GO

-- trường hợp sản phẩm không tồn tại
UPDATE Production.ProductReview
SET Comments = N'1'
WHERE ProductReviewID = 10
GO