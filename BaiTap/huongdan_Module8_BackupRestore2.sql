--Hướng dẫn Module 8. BACKUP VÀ RESTORE DATABASE  (Sinhvien vận dụng làm bài tập Module8)
--Backup => ghi vào thiết bị = Media set , gồm 1 hoặc nhiều file 
--media set = 1 file  T:\backup\abc.bak
--backup 1    T:\backup\abc.bak      => restore from T:\backup\abc.bak 
--backup 2	T:\backup\xyz.bak		=> restore from T:\backup\xyz.bak


--backup 1    T:\backup\abc.bak  FILE =1     => restore from T:\backup\abc.bak   FILE =1
--backup 2	T:\backup\abc.bak  FILE =2		=> restore from T:\backup\abc.bak   FILE =2

--Tóm tắt 
--1. Tạo Thiết bị backup (?): sử dụng một hay nhiều Media Set ? Một Media Set gồm 1 hay nhiều file ?
-- Media Set : một bộ Thiết bị chứa dữ liệu backup. Gồm một hay nhiều file.
-- Mỗi lần thực hiện backup, dữ liệu backup  có thể được lưu vào cùng một Media Set (lần lượt) 
-- hay lưu vào các Media Set khác nhau

--2. Chọn Recovery Mode (?)   khác nhau ? ở thời điểm trước khi thực hiện backup
----Simple Recovery model  : cho phép thực hiện full+differential backup
----Full Recovery model  :cho phép thực hiện full+ differential backup + log backup

--3. Các loại backup : xem lại lý thuyết 
----Full  backup 
----Differential backup
----Transaction Log Backup

--4. Recovery (restore ): phục hồi database dựa trên các bản backup đã có 
-- nguyên tắc : 
--  giả định là phục hồi dựa trên các bản backup đã có , còn database bị hư hỏng (ko thể truy suất) / xóa DB
--  => lệnh restore đầu tiên luôn luôn là phục hồi từ bản Full backup  
--  => full backup là rất quan trọng
--=========================================================================
---------------------------------------------------------------------------
-- GO
---- thực hiện theo bài tập 
----	thiết lập  full recovery mode 
----	backup nhiều lần (3loai)+ có thay đổi trên database 
----	restore (kịch bản)
----    các lần backup đều lưu vào cùng 1 thiết bị => thì khi restore đc nhận diện qua FILE = n
USE master
GO

ALTER DATABASE AdventureWorks2008R2 
SET RECOVERY FULL
GO

USE AdventureWorks2008R2
GO

--t1 : Back up the full AdventureWorks2012 database. (FILE 1)
BACKUP DATABASE AdventureWorks2008R2   
TO DISK = 'D:\backup\AdventureWorks2008R2.bak'   
WITH FORMAT;  
GO

--t2: cập nhật DB  --select * from  production.product where productid  = 1
USE AdventureWorks2008R2
GO

UPDATE production.product
SET standardCost = 10
WHERE productid  = 1 
GO

--t3 : Create a differential database backup.    (File 2 )
BACKUP DATABASE AdventureWorks2008R2   
TO DISK =  'D:\backup\AdventureWorks2008R2.bak'  
WITH DIFFERENTIAL;  
GO

---t4 : database bị xóa 
USE master
GO

DROP DATABASE AdventureWorks2008R2
GO
-- - xóa file .mdf, .ldf, .ndf

---=> kịch bản phục hồi về t1 :
---Restore dựa trên bản full backup
RESTORE DATABASE  AdventureWorks2008R2   
FROM DISK = 'D:\backup\AdventureWorks2008R2.bak'  
WITH  FILE=1 , replace , RECOVERY
GO
--- end			

-- test 
SELECT *
FROM production.product
WHERE productid  = 1
---=> kịch bản phục hồi về t3
GO

---t5 : database bị xóa 
USE master
DROP DATABASE AdventureWorks2008R2
---b1 :Restore dựa trên bản full backup  (FILE =1 )
RESTORE DATABASE  AdventureWorks2008R2   
FROM DISK =  'D:\backup\AdventureWorks2008R2.bak'  
WITH  FILE=1 ,  NORECOVERY
;
---b2 :Restore dựa trên bản differential backup (FILE =2 )
RESTORE DATABASE  AdventureWorks2008R2   
FROM DISK =  'D:\backup\AdventureWorks2008R2.bak'  
WITH  FILE=2 ,  RECOVERY ;		  ---end

GO
--test....

SELECT *
FROM production.product
WHERE productid  = 1
GO

----=> kịch bản 3
--t1 : full backup
--t2 : update
--t3 : differential backup

--t4:
UPDATE production.product
SET standardCost = 20					--tăng 10->20
WHERE productid  = 1
GO

--t5 : 
-- tạo backup log 1      (File = 3)
BACKUP  LOG  AdventureWorks2008R2 
TO DISK = 'D:\backup\AdventureWorks2008R2.bak'

--t6
DELETE FROM Person.EmailAddress
DELETE FROM person.password
--select * from  Person.EmailAddress
--select * from person.password

--t7:  tạo backup log 2  (File = 4)
GO
BACKUP LOG AdventureWorks2008R2
TO DISK = 'D:\backup\AdventureWorks2008R2.bak'

---
--t8: Xóa CSDL 
USE master
DROP DATABASE AdventureWorks2008R2
---

----=> kich bản 3 : phục hồi về t5
---b1 : dựa trên bản full backup  (FILE =1 )
RESTORE DATABASE  AdventureWorks2008R2   
FROM DISK = 'D:\backup\AdventureWorks2008R2.bak'  
WITH  FILE=1 ,  NORECOVERY ;	
GO

---b2 : dựa trên bản differential backup (FILE =2 )
RESTORE DATABASE  AdventureWorks2008R2   
FROM DISK =   'D:\backup\AdventureWorks2008R2.bak'  
WITH  FILE=2 ,  NORECOVERY ;	
GO

--b3 : dựa trên bản log backup 1 (FILE =3)  
RESTORE LOG  AdventureWorks2008R2   
FROM DISK =   'D:\backup\AdventureWorks2008R2.bak'  
WITH  FILE=3 ,  RECOVERY
;
---end

----test...
SELECT *
FROM production.product
WHERE productid  = 1