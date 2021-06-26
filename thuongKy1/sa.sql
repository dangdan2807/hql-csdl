
USE master
GO

-- a
CREATE LOGIN TN WITH password = '123456'
CREATE LOGIN NV WITH password = '123456'
CREATE LOGIN QL WITH password = '123456'
GO

USE AdventureWorks2008R2
GO

CREATE USER TN FOR login TN
CREATE USER NV FOR login NV
CREATE USER QL FOR login QL
GO

-- b
GRANT SELECT, INSERT, UPDATE ,DELETE
ON Production.ProductInventory
TO TN
WITH GRANT OPTION
GO

ALTER ROLE  db_datawriter 
ADD MEMBER QL
GO

-- 1d
SELECT *
FROM Production.Product

-- có thể truy cập Production.Product vì chỉ có quyền sa

-- 1f
REVOKE SELECT, INSERT, UPDATE ,DELETE
ON Production.ProductInventory
TO TN CASCADE

ALTER ROLE  db_datawriter 
DROP MEMBER QL
GO

ALTER LOGIN TN DISABLED
ALTER LOGIN NV DISABLED
ALTER LOGIN QL DISABLED
GO

DROP USER TN
DROP USER NV
DROP USER QL

DROP LOGIN TN
DROP LOGIN NV
DROP LOGIN QL
GO

-- 2
USE master
GO

ALTER DATABASE AdventureWorks2008R2 SET RECOVERY FULL
GO

-- T1
BACKUP DATABASE AdventureWorks2008R2  -- file 1
TO disk = N'D:\backup\adv2008back.bak'
WITH FORMAT
GO

-- T2
SELECT *
FROM Production.Product


-- T3
BACKUP DATABASE AdventureWorks2008R2 -- file 2
TO disk = N'D:\backup\adv2008back.bak'
WITH differential

-- T4
DELETE FROM Person.EmailAddress

SELECT *
FROM Person.EmailAddress

-- T5
BACKUP DATABASE AdventureWorks2008R2 -- file 3
TO disk = N'D:\backup\adv2008back.bak'
WITH differential
GO

-- T6
SELECT *
FROM Person.ContactType

INSERT INTO Person.ContactType
    (Name, ModifiedDate)
VALUES
    (N'hello', GETDATE())

SELECT *
FROM Person.ContactType p
WHERE ContactTypeID = 21

-- T7

BACKUP LOG AdventureWorks2008R2 -- file 4
TO disk = N'D:\backup\adv2008back.bak'

-- T8
USE master
GO

DROP DATABASE AdventureWorks2008R2

-- T9
RESTORE DATABASE AdventureWorks2008R2
FROM disk = N'D:\backup\adv2008back.bak'
WITH FILE = 1, replace, NORECOVERY
GO

RESTORE DATABASE  AdventureWorks2008R2   
FROM DISK =  'D:\backup\adv2008back.bak' 
WITH  FILE=2 ,  NORECOVERY
GO

RESTORE DATABASE  AdventureWorks2008R2   
FROM DISK =  'D:\backup\adv2008back.bak' 
WITH  FILE=3 ,  NORECOVERY
GO

RESTORE LOG  AdventureWorks2008R2   
FROM DISK =  'D:\backup\adv2008back.bak' 
WITH  FILE=4 ,  RECOVERY

-- T10
USE AdventureWorks2008R2
GO

SELECT *
FROM Person.ContactType p
WHERE p.ContactTypeID = 21


SELECT *
FROM Production.ProductReview
GO

CREATE TRIGGER v
on Production.ProductReview
after UPDATE
as
BEGIN
    DECLARE @proID INT
    SELECT @proID = i.ProductID
    from inserted i

    if Exists (select * FROM Production.Product p WHERE p.ProductID = @proID)
    BEGIN
        SELECT p.ProductID, p.Color, p.StandardCost, pr.Rating, pr.Comments
        FROM Production.Product p, Production.ProductReview pr
        WHERE p.ProductID = pr.ProductID
        AND p.ProductID = @proID
    end
    else
    BEGIN
        print N'Không có thông tin sản phẩm'
        ROLLBACK
    end
END
GO

update Production.ProductReview
set Comments = N'1'
where ProductReviewID = 1