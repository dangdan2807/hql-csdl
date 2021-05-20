USE AdventureWorks2008R2
GO

-- 1) Thêm vào bảng Department một dòng dữ liệu tùy ý bằng câu lệnh 
-- INSERT..VALUES…
CREATE TABLE Department
(
    maPhongBan INT PRIMARY KEY,
    tenPhongBan NVARCHAR(100)
)

SELECT *
FROM Department
-- a) Thực hiện lệnh chèn thêm vào bảng Department một dòng dữ liệu tùy ý bằng 
-- cách thực hiện lệnh Begin tran và Rollback, dùng câu lệnh Select * From 
-- Department xem kết quả.
BEGIN TRAN
INSERT INTO dbo.Department
VALUES
    (1, N'pb01')
ROLLBACK
-- dòng insert sẽ được thêm vào bảng nhưng sao đó sẽ bị quay lại thời điểm chưa thêm 

-- b) Thực hiện câu lệnh trên với lệnh Commit và kiểm tra kết quả.
BEGIN TRAN
INSERT INTO dbo.Department
VALUES
    (1, N'pb01')
COMMIT
-- dòng insert sẽ được thêm vào bảng 

SELECT *
FROM dbo.Department

-- 2) Tắt chế độ autocommit của SQL Server (SET IMPLICIT_TRANSACTIONS 
-- ON). Tạo đoạn batch gồm các thao tác:
-- - Thêm một dòng vào bảng Department
-- - Tạo một bảng Test (ID int, Name nvarchar(10))
-- - Thêm một dòng vào Test
-- - ROLLBACK;
-- - Xem dữ liệu ở bảng Department và Test để kiểm tra dữ liệu, giải thích kết 
-- quả.

SET IMPLICIT_TRANSACTIONS ON
GO
INSERT INTO dbo.Department
VALUES
    (2, N'pb02')

CREATE TABLE Test
(
    ID INT PRIMARY KEY,
    Name NVARCHAR(10)
)

INSERT INTO dbo.Test
VALUES
    (1, N'pb01')

ROLLBACK;

SELECT *
FROM dbo.Department

SELECT *
FROM dbo.Test
-- Dữ liệu không tha đổi vì dùng rollback
-- sau khi thực thi thành công cả 3 dòng như gặp rollback nên quay về khi chưa thực hiện 

-- 3) Viết đoạn batch thực hiện các thao tác sau (lưu ý thực hiện lệnh SET 
-- XACT_ABORT ON: nếu câu lệnh T-SQL làm phát sinh lỗi run-time, toàn bộ giao 
-- dịch được chấm dứt và Rollback)
-- - Câu lệnh SELECT với phép chia 0 :SELECT 1/0 as Dummy
-- - Cập nhật một dòng trên bảng Department với DepartmentID=’9’ (id này 
-- không tồn tại)
-- - Xóa một dòng không tồn tại trên bảng Department (DepartmentID =’66’)
-- - Thêm một dòng bất kỳ vào bảng Department
-- - COMMIT;
-- Thực thi đoạn batch, quan sát kết quả và các thông báo lỗi và giải thích kết quả.

SET IMPLICIT_TRANSACTIONS OFF
GO

SET XACT_ABORT ON
GO
BEGIN TRAN
SELECT 1/0 AS Dummy

UPDATE dbo.Department
SET tenPhongBan = N'pb 09'
WHERE maPhongBan = 9

DELETE FROM dbo.Department
WHERE maPhongBan = 6

INSERT INTO dbo.Department
VALUES
    (2, N'pb02')
COMMIT;
GO

-- kiểm tra kết quảs
SELECT *
FROM dbo.Department

-- giải thích: gặp lỗi chia cho 0
-- sau khi chạy đến dòng select 1/0 as Dummy
-- thì phái hiện lỗi và sẽ giao tác bị chấm dứt, rollback lại như chưa thực hiện lệnh

-- 4) Thực hiện lệnh SET XACT_ABORT OFF (những câu lệnh lỗi sẽ rollback, 
-- transaction vẫn tiếp tục) sau đó thực thi lại các thao tác của đoạn batch ở câu 3. Quan 
-- sát kết quả và giải thích kết quả?

SET XACT_ABORT OFF
GO

BEGIN TRAN
SELECT 1/0 AS Dummy

UPDATE dbo.Department
SET tenPhongBan = N'pb 09'
WHERE maPhongBan = 9

DELETE FROM dbo.Department
WHERE maPhongBan = 66

INSERT INTO dbo.Department
VALUES
    (2, N'pb02')
COMMIT;
GO

-- kiểm tra kết quảs
SELECT *
FROM dbo.Department

drop table dbo.Department

-- Lỗi gặp phải: chia cho 0
-- giải thích: sau khi tắt SET XACT_ABORT OFF
-- khi thực hiện dòng lệnh SELECT 1/0 AS Dummy
-- hệ thông báo lỗi và bỏ qua câu lệnh để thực hiện tiếp tục câu lệnh bên dưới
-- khi đến câu update, delete câu lệnh vẫn chạy nhưng không tìm thấy đối tượng để thực hiện
-- câu lệnh insert vẫn chạy bình thường
-- khi commit thì câu lệnh không bị lỗi sẽ được áp dụng