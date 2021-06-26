-- 19529651 - Phạm Đăng Đan - DHKTPM15B
USE master
go

use AdventureWorks2008R2
go

-- 1.b. kiểm tra sau phi phần quyền
SELECT * 
from Person.PersonPhone

-- 1.c. nhân viên QL xem lại kết quả NV1 và NV2 đã làm
SELECT * 
from Person.PersonPhone
WHERE BusinessEntityID = 651

SELECT * 
from Person.PersonPhone
WHERE BusinessEntityID = 195

-- 1.d. Ai có thể xem dữ liệu bảng Person.Person? Giải thích. Viết lệnh kiểm tra quyền trên cửa sổ
-- query của user tương ứng

-- QL có quyền xem dữ liệu bảng Person.Person
-- vì QL thuộc về role db_datareader mà role này được cấp quyền
-- xem dữ liệu trên toàn database

SELECT *
FROM Person.Person


