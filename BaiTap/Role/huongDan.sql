--Hướng dẫn Module 6. ROLE - PERMISSION
---------------------------------------------------------------------
--Chú ý : Sử dụng tài khoản sa để thực hiện các lệnh dưới đây.  
--Nhưng khi test ... : cần connect bằng tài khoản đã được cấp quyền để kiểm chứng quyền đã được cấp
--Có thể connect bằng Object Explorer , hoặc Query editor
--Sinh viên vận dụng phần hướng dẫn dưới đây để làm bài tập trang  ...

---------------------------------------------------------------------
--(1) login vào SQL server bằng tài khoản của SQL Server hoặc Windows OS 
--	 -> chọn chế độ xác thực ...
--(2) tạo một SQL Server Login 
--(3) connect vào SQL Server bằng login vừa tạo 
--(4) Login vừa tạo có quyền gì ?
CREATE LOGIN sinhvien WITH PASSWORD = '123456';

-- Xem thông tin	 
SELECT *
FROM SYS.SQL_LOGINS

--(5) Tạo user sinhvien cho Login vừa tạo để thao tác với 2 database  
--(6) User sinhvien có quyền gì trên database ?
USE QuanLyNhanVien
CREATE USER  sinhvien FOR LOGIN  sinhvien   ---tao user (tuongung sinhvien account) tren database hien hanh
--test ...
GO
USE AdventureWorks2008R2
CREATE USER  sinhvien  FOR LOGIN  sinhvien
--test ...
GO
--(7) cấp quyền cho user sinhvien trên database AdventureWorks2008R2 
--Đặt câu hỏi : user sinhvien cần được cấp quyền gì trên database ? 
--  => xác định cách cấp quyền phù hợp
-------
--Cách 1: user sinhvien co quyen thuc hien select tren 1 table
USE AdventureWorks2008R2
GO
GRANT SELECT
ON sales.salesorderheader
TO sinhvien
GO
--test ...
--thu hồi quyền đã cấp
REVOKE SELECT
ON sales.salesorderheader
TO  sinhvien

--Cách 2: user sinhvien co quyen truy van (read) moi table/view trong DB
GO
-- cac fixed database role (co san)
EXEC sp_helprole

GO
USE AdventureWorks2008R2
GO
ALTER ROLE db_datareader ADD MEMBER  sinhvien
-- hoặc dùng :  exec sp_addrolemember  'db_datareader' , sinhvien
GO
--test ...
--remove user sinhvien khỏi role db_datareader
ALTER ROLE db_datareader DROP MEMBER  sinhvien
-- hoặc dùng :  exec sp_droprolemember  'db_datareader' , sinhvien

--Cách 3: user sinhvien co quyen truy van (read) 
-- moi table/view trong DB , nhung loai tru 1 table 
GO
ALTER ROLE db_datareader ADD MEMBER  sinhvien
GO
DENY  SELECT
ON sales.salesorderheader
TO  sinhvien
GO
-- test ...
-- thu hồi quyền đã cấp
REVOKE  SELECT
ON sales.salesorderheader
TO  sinhvien 
GO
ALTER ROLE db_datareader DROP MEMBER  sinhvien
GO

--cách 4: tao user-defined database role 
CREATE ROLE  banhang
GO

ALTER ROLE banhang ADD MEMBER  sinhvien
GO

GRANT SELECT , INSERT , UPDATE ,DELETE 
ON  sales.SalesOrderHeader
TO banhang
GO

GRANT SELECT , INSERT , UPDATE ,DELETE 
ON  sales.SalesOrderDetail
TO banhang
GO

DENY SELECT 
ON sales.Store
TO banhang
GO

ALTER ROLE db_datareader ADD MEMBER  banhang
GO

--test ...
--remove user sinhvien khỏi role banhang
ALTER ROLE banhang DROP MEMBER  sinhvien
--xóa role banhang
DROP ROLE  banhang
GO

--cách 1(bổ sung 1.1) :
GRANT  SELECT 
ON  sales.SalesOrderHeader
TO  sinhvien   WITH GRANT OPTION 	
GO
--- WITH GRANT OPTION : user sinhvien có quyền select trên table sales.SalesOrderHeader
--- và có thể cấp quyền này cho user khác  
---test ... sinhvien cap quyen SELECT tren table cho user HOA
---
-- thu hồi cả quyền mà các user khác được sinhvien cấp
REVOKE  SELECT
ON sales.salesorderheader
TO  sinhvien CASCADE
---test ...
---
--cách 1(bổ sung 1.2) :
GRANT  SELECT ,insert , update, delete
ON  sales.SalesOrderHeader 
TO  sinhvien
---
GRANT  create table, create view
TO  sinhvien



--cách 5 : sinhvien account co toan quyen tren server 
ALTER  SERVER  ROLE   sysadmin  ADD MEMBER  sinhvien
--- login 
-- test ...
-- remove login sinhvien khỏi sysadmin server role
ALTER  SERVER  ROLE   sysadmin  DROP MEMBER  sinhvien







