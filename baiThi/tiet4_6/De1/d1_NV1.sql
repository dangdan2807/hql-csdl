-- 19529651 - Phạm Đăng Đan - DHKTPM15B
Use master
go

use AdventureWorks2008R2
go

-- 1.b. kiểm tra sau phi phần quyền
select * FROM Person.PersonPhone
GO

-- 1.c. Nhân viên NV1 sửa số điện thoại của người có BusinessEntityID= 651 thành 123-456-7890
update Person.PersonPhone
set PhoneNumber = N' 123-456-7890'
where BusinessEntityID = 651

-- 1.d. Ai có thể xem dữ liệu bảng Person.Person? Giải thích. Viết lệnh kiểm tra quyền trên cửa sổ
-- query của user tương ứng

-- NV1 không có quyền xem dữ liệu bảng Person.Person
-- vì nhân viên thuộc về role NhanVien mà role này không được cấp quyền
-- xem dữ liệu trên bảng Person.Person

SELECT *
FROM Person.Person