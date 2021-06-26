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
ON Purchasing.PurchaseOrderDetail
TO NhanVien
GO

ALTER ROLE NhanVien
ADD MEMBER NV1

ALTER ROLE NhanVien
ADD MEMBER NV2

ALTER ROLE db_datareader
ADD member QL
GO

-- 1d.Ai có thể xem dữ liệu bảng Purchasing.Vendor? Giải thích. Viết lệnh kiểm tra quyền trên
-- cửa sổ query của user tương ứng

SELECT *
FROM Purchasing.ProductVendor

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

-- 2a.Tạo một transaction tăng lương (Rate) thêm 15% cho các nhân viên làm việc ca
-- (Shift.Name) chiều và tăng 25% lương cho các nhân viên làm việc ca đêm
-- trước khi tăng
SELECT e.BusinessEntityID, s.Name, eh.Rate
FROM HumanResources.EmployeeDepartmentHistory e, HumanResources.Shift s, HumanResources.EmployeePayHistory eh
WHERE e.ShiftID = s.ShiftID 
    and e.BusinessEntityID = eh.BusinessEntityID
    AND s.Name in (N'Night', N'Evening')


BEGIN TRAN
UPDATE HumanResources.EmployeePayHistory
    SET Rate = rate + rate * 0.15
    WHERE BusinessEntityID IN (
        SELECT e.BusinessEntityID
        FROM HumanResources.EmployeeDepartmentHistory e, HumanResources.Shift s
        WHERE e.ShiftID = s.ShiftID
        AND s.Name = N'Evening'
    )

UPDATE HumanResources.EmployeePayHistory
    SET Rate = rate + rate * 0.25
    WHERE BusinessEntityID IN (
        SELECT e.BusinessEntityID
        FROM HumanResources.EmployeeDepartmentHistory e, HumanResources.Shift s
        WHERE e.ShiftID = s.ShiftID
        AND s.Name = N'Night'
    )
COMMIT
GO

-- kiểm tra tăng lương

SELECT e.BusinessEntityID, s.Name, eh.Rate
FROM HumanResources.EmployeeDepartmentHistory e, HumanResources.Shift s, HumanResources.EmployeePayHistory eh
WHERE e.ShiftID = s.ShiftID 
    and e.BusinessEntityID = eh.BusinessEntityID
    AND s.Name in (N'Night', N'Evening')

USE master
ALTER DATABASE AdventureWorks2008R2 SET RECOVERY FULL
GO

BACKUP DATABASE AdventureWorks2008R2  -- file 1
TO disk = N'D:\backup\adv2008back.bak'
WITH FORMAT
GO

-- 2b. Xóa mọi bản ghi trong bảng SalesTerritoryHistory
USE AdventureWorks2008R2
GO

DELETE Sales.SalesTerritoryHistory

-- kiểm tra
SELECT *
FROM Sales.SalesTerritoryHistory

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
SELECT e.BusinessEntityID, s.Name, eh.Rate
FROM HumanResources.EmployeeDepartmentHistory e, HumanResources.Shift s, HumanResources.EmployeePayHistory eh
WHERE e.ShiftID = s.ShiftID 
    and e.BusinessEntityID = eh.BusinessEntityID
    AND s.Name in (N'Night', N'Evening')

-- có tăng

-- kiểm tra bảng SalesTerritoryHistory có bị xóa mọi record
SELECT *
FROM Sales.SalesTerritoryHistory
-- đã xóa

-- kiểm tra số điện thoại mới đã thêm
SELECT *
FROM Person.PersonPhone
WHERE BusinessEntityID = 9651
GO

-- đã thêm 

CREATE TRIGGER procV
ON Production.ProductReview
INSTEAD OF UPDATE
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