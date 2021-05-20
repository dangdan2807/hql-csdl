USE master
-- 2. Tạo hai login SQL server Authentication User2 và User3
CREATE LOGIN user2 WITH password = '123456'
CREATE LOGIN user3 WITH password = '123456'
GO

-- 3. Tạo một database user user2 ứng với login User2 và một database user User3
-- ứng với login User3 trên CSDL AdventureWorks2008
USE AdventureWorks2008R2
CREATE USER user2 FOR login user2
CREATE USER user3 FOR login user3
GO

-- 4.Tạo 2 kết nối đến server thông qua login User2 và User3, sau đó thực hiện các 
-- thao tác truy cập CSDL của 2 user tương ứng (VD: thực hiện câu Select). Có thực 
-- hiện được không?
USE AdventureWorks2008R2
GO

GRANT SELECT
ON sales.salesorderheader
TO user2
GO

GRANT SELECT
ON sales.Store
TO user3
GO

--thu hồi quyền đã cấp
REVOKE SELECT
ON sales.salesorderheader
TO  user2

REVOKE SELECT
ON sales.Store
TO  user3

-- 5. Gán quyền select trên Employee cho User2, kiểm tra kết quả. Xóa quyền select 
-- trên Employee cho User2. Ngắt 2 kết nối của User2 và User3
USE AdventureWorks2008R2
GO

-- Lưu ý cấp quyền cho user không phải login
-- Phân biệt user và login
GRANT SELECT
ON HumanResources.Employee
TO User2

--thu hồi quyền đã cấp
REVOKE SELECT
ON HumanResources.Employee
TO  user2

-- 6) Trở lại kết nối của sa, tạo một user-defined database Role tên Employee_Role trên 
-- CSDL AdventureWorks2008, sau đó gán các quyền Select, Update, Delete cho 
-- Employee_Role.
USE AdventureWorks2008R2
GO

-- tạo role
CREATE ROLE Employee_Role
go

-- cấp quyền cho role
GRANT SELECT , INSERT , UPDATE ,DELETE 
ON  HumanResources.Employee
TO Employee_Role
GO
-- 7) Thêm các User2 và User3 vào Employee_Role. Tạo lại 2 kết nối đến server thông 
-- qua login User2 và User3 thực hiện các thao tác sau:

-- thêm MEMBER vào role
ALTER ROLE Employee_Role ADD MEMBER User2
ALTER ROLE Employee_Role ADD MEMBER User3
GO

-- a) Tại kết nối với User2, thực hiện câu lệnh Select để xem thông tin của bảng 
-- Employee
-- b) Tại kết nối của User3, thực hiện cập nhật JobTitle=’Sale Manager’ của nhân 
-- viên có BusinessEntityID=1
-- c) Tại kết nối User2, dùng câu lệnh Select xem lại kết quả.
-- d) Xóa role Employee_Role, (quá trình xóa role ra sao?)

--remove user khỏi role Employee_Role,
ALTER ROLE Employee_Role DROP MEMBER  user2
ALTER ROLE Employee_Role DROP MEMBER  user3

--xóa role Employee_Role
DROP ROLE  Employee_Role
GO