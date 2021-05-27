
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
add MEMBER QL
GO

-- 1d
select *
from Production.Product

-- có thể truy cập Production.Product vì chỉ có quyền sa

-- 1f
REVOKE SELECT, INSERT, UPDATE ,DELETE
ON Production.ProductInventory
TO TN

ALTER ROLE  db_datawriter 
Drop MEMBER QL
GO

Drop USER TN
Drop USER NV
Drop USER QL

Drop LOGIN TN
Drop LOGIN NV
Drop LOGIN QL


-- 2
USE master
GO

-- T1
BACKUP DATABASE AdventureWorks2008R2  -- file 1
TO disk = N'D:\backup\adv2008back.bak'
WITH FORMAT
GO

-- T2
SELECT *
FROM   Production.Product


-- T3
BACKUP DATABASE AdventureWorks2008R2 -- file 2
TO disk = N'D:\backup\adv2008back.bak'
WITH differential

-- T4
delete from Person.EmailAddress

select * 
from Person.EmailAddress

-- T5
BACKUP DATABASE AdventureWorks2008R2 -- file 3
TO disk = N'D:\backup\adv2008back.bak'
WITH differential
GO

-- T6
select * from Person.ContactType

INSERT INTO Person.ContactType
             (Name, ModifiedDate)
VALUES (N'hello', GETDATE())

select * from Person.ContactType p
where ContactTypeID = 21

-- T7
BACKUP LOG AdventureWorks2008R2 -- file 4
TO disk = N'D:\backup\adv2008back.bak'

-- T8
USE master
GO

Drop database AdventureWorks2008R2

-- T9
RESTORE DATABASE AdventureWorks2008R2
FROM disk = N'D:\backup\adv2008back.bak'
WITH FILE = 1, replace,  NORECOVERY
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
use AdventureWorks2008R2
GO

select * from Person.ContactType p
Where p.ContactTypeID = 21