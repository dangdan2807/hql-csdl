USE master

CREATE DATABASE Sales
-- ON
-- PRIMARY
-- (
-- 	NAME = tuan1_data,
-- 	FILENAME ='T:\ThucHanhSQL\tuan1_data.mdf',
-- 	SIZE = 10MB,
-- 	MAXSIZE = 20MB,
-- 	FILEGROWTH = 20%
-- )
-- LOG ON
-- (
-- 	NAME = tuan1_log,
-- 	FILENAME = 'T:\ThucHanhSQL\tuan1_log.ldf',
-- 	SIZE = 10MB,
-- 	MAXSIZE = 20MB,
-- 	FILEGROWTH = 20%
-- )

USE Sales

-- 1. Kiểu dữ liệu tự định nghĩa
EXEC sp_addtype 'Mota', 'NVARCHAR(40)'
EXEC sp_addtype 'IDKH', 'CHAR(10)', 'NOT NULL'
EXEC sp_addtype 'DT', 'CHAR(12)'

-- 2. Tạo table
CREATE TABLE SanPham (
    MaSP CHAR(6) NOT NULL,
    TenSP VARCHAR(20),
    NgayNhap Date,
    DVT CHAR(10),
    SoLuongTon INT,
    DonGiaNhap money,
)

CREATE TABLE HoaDon (
    MaHD CHAR(10) NOT NULL,
    NgayLap Date,
    NgayGiao Date,
    MaKH IDKH,
    DienGiai Mota,
)

CREATE TABLE KhachHang (
    MaKH IDKH,
    TenKH NVARCHAR(30),
    DiaCHi NVARCHAR(40),
    DienThoai DT,
)

CREATE TABLE ChiTietHD (
    MaHD CHAR(10) NOT NULL,
    MaSP CHAR(6) NOT NULL,
    SoLuong INT
)

-- 3. Trong Table HoaDon, sửa cột DienGiai thành nvarchar(100).
ALTER TABLE HoaDon
    ALTER COLUMN DienGiai NVARCHAR(100)

-- 4. Thêm vào bảng SanPham cột TyLeHoaHong float
ALTER TABLE SanPham
    ADD TyLeHoaHong float

-- 5. Xóa cột NgayNhap trong bảng SanPham
ALTER TABLE SanPham
    DROP COLUMN NgayNhap

-- 6. Tạo các ràng buộc khóa chính và khóa ngoại cho các bảng trên
    -- Khoá Chính
ALTER TABLE SanPham ADD CONSTRAINT PK_SanPham
    PRIMARY KEY (MaSP)
ALTER TABLE HoaDon ADD CONSTRAINT PK_HoaDon
    PRIMARY KEY (MaHD)
ALTER TABLE KhachHang ADD CONSTRAINT PK_KhachHang
    PRIMARY KEY (MaKH)
ALTER TABLE ChiTietHD ADD CONSTRAINT PK_ChiTietHD
    PRIMARY KEY (MaHD, MaSP)


    -- Khoá Phụ
ALTER TABLE HoaDon ADD CONSTRAINT FK_HoaDon
    FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH)
    ON DELETE CASCADE ON UPDATE CASCADE
ALTER TABLE ChiTietHD ADD CONSTRAINT FK_CHiTietHD_MaHD
    FOREIGN KEY (MaHD) REFERENCES HoaDon(MaHD)
    ON DELETE CASCADE ON UPDATE CASCADE
ALTER TABLE ChiTietHD ADD CONSTRAINT FK_CHiTietHD_MaSP
    FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
    ON DELETE CASCADE ON UPDATE CASCADE

-- 7. Thêm vào bảng HoaDon các ràng buộc sau:
    -- NgayGiao >= NgayLap
    ALTER TABLE HoaDon ADD CONSTRAINT CK_HoaDon_NgayGiao
        CHECK (NgayGiao >= NgayLap)
    -- MaHD gồm 6 ký tự, 2 ký tự đầu là chữ, các ký tự còn lại là số
    ALTER TABLE HoaDon ADD CONSTRAINT CK_HoaDon_MaHD
        CHECK (MaHD LIKE '[A-Z]{2}\d{4,}')
        -- CHECK (MaHD LIKE '[A-Z]{2}\d{4,}')
    ALTER TABLE HoaDon Drop CONSTRAINT CK_HoaDon_MaHD
    -- Giá trị mặc định ban đầu cho cột NgayLap luôn luôn là ngày hiện hành
    ALTER TABLE HoaDon ADD CONSTRAINT DF_HoaDon_NgayLap
        DEFAULT GETDATE() FOR NgayLap

-- 8. Thêm vào bảng Sản phẩm các ràng buộc sau:
    -- SoLuongTon chỉ nhập từ 0 đến 500
    ALTER TABLE SanPham ADD CONSTRAINT CK_SanPham_SoLuongTon
        CHECK (SoLuongTon BETWEEN 0 AND 500)
    -- DonGiaNhap lớn hơn 0
    ALTER TABLE SanPham ADD CONSTRAINT CK_SanPham_DonGiaNhap
        CHECK (DonGiaNhap > 0)
    -- Giá trị mặc định cho NgayNhap là ngày hiện hành
    ALTER TABLE SanPham
        ADD NgayNhap Date
    ALTER TABLE SanPham ADD CONSTRAINT DF_SanPham_NgayNhap
        DEFAULT GETDATE() FOR NgayNhap
    -- DVT chỉ nhập vào các giá trị ‘KG’, ‘Thùng’, ‘Hộp’, ‘Cái’
    ALTER TABLE SanPham
        ALTER COLUMN DVT NCHAR(10)
    ALTER TABLE SanPham ADD CONSTRAINT CK_SanPham_DVT
        CHECK (DVT IN (N'KG', N'Thùng', N'Cái', N'Hộp'))

-- 9. Dùng lệnh T-SQL nhập dữ liệu vào 4 table trên, dữ liệu tùy ý, chú ý các ràng
-- buộc của mỗi Table
    -- Table SanPham
    INSERT INTO SanPham (MaSP, TenSP, NgayNhap, DVT, SoLuongTon, DonGiaNhap, TyLeHoaHong) 
    VALUES ('SP01', 'Dau Goi', '20210201', N'Cái', 100, 25000, 1),
            ('SP02', 'Dau Xa', '20210201', N'Cái', 120, 27000, 1),
            ('SP03', 'Xa Phong', '20210201', N'Hộp', 300, 20000, 2),
            ('SP04', 'Mi 3 Mien', '20210201', N'Thùng', 500, 3000, 5)

    -- Table Khách hàng
    INSERT INTO KhachHang (MaKH, TenKH, DiaCHi, DienThoai)
    VALUES  ('KH01', N'Trần Minh Quang', N'120 Trường Chinh, Q.12, TP.HCM', '0312345678'),
            ('KH02', N'Nguyễn Thị Anh', N'143 Quang Trung, Q.GV, TP.HCM', '0909091234'),
            ('KH03', N'Võ Quang Hùng', N'23 Nguyễn Thái Bình, Q.GV, TP.HCM', '0707123123'),
            ('KH04', N'Bùi Duy Anh', N'03 Quang Trung, Q.GV, TP.HCM', '0505050505')

    -- Table HoaDon
    INSERT INTO HoaDon (MaHD, NgayLap, NgayGiao, MaKH, DienGiai)
    VALUES  ('HD0101', '20210202', '20210202', 'KH01', N'Giao Nhanh'),
            ('HD0102', '20210202', '20210215', 'KH03', N'Giao Thường'),
            ('HD0103', '20210202', '20210203', 'KH02', N'Giao Nhanh'),
            ('HD0104', '20210202', '20210302', 'KH01', N'Giao Thường')

    -- Table ChiTietHD
    INSERT INTO ChiTietHD (MaHD, MaSP, SoLuong)
    VALUES  ('HD0101', 'SP01', 324),
            ('HD0102', 'SP02', 424),
            ('HD0103', 'SP04', 243),
            ('HD0104', 'SP03', 13)

-- 10. Xóa 1 hóa đơn bất kỳ trong bảng HoaDon. Có xóa được không? Tại sao? Nếu
-- vẫn muốn xóa thì phải dùng cách nào?
    -- Không xoá được vì hoa đơn đó có ràng buộc tham chiếu đến bảng ChiTietHD
    -- Nếu Muốn hoá thì trước tiên phải xoá ở bảng ChiTietHD rồi mới xoá ỏ bảng HoaDon

-- 11. Nhập 2 bản ghi mới vào bảng ChiTietHD với MaHD = ‘HD999999999’ và
-- MaHD=’1234567890’. Có nhập được không? Tại sao?
    -- Không thể nhập 2 bản ghi mới vào bảng ChiTietHD
    -- Vì MaHD = ‘HD999999999’ lớn hớn 10 kí tự
    -- MaHD=’1234567890’ không có 2 kí tự đầu tiên là kí tự
    
-- 12. Đổi tên CSDL Sales thành BanHang
EXEC sp_renamedb Sales, BanHang

-- 13. . Tạo thư mục T:\QLBH, chép CSDL BanHang vào thư mục này, bạn có sao
-- chép được không? Tại sao? Muốn sao chép được bạn phải làm gì? Sau khi sao
-- chép, bạn thực hiện Attach CSDL vào lại SQL.
    -- (detach hệ thống sẽ ngắt kết nối tên đã cung cấp và phần còn lại sẽ được giữ nguyên)
    -- Có thể chép được nhưng có khi Attach CSDL có thể bị lỗi vì không Detach CSDL
    -- Để sao chép CSDL cần Detach trước khi chép
    -- database -> Task -> Detach
    -- Vào đường dẫn copy File
    -- C:\Program Files (x86)\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA

-- 14. Tạo bản BackUp cho CSDL BanHang
-- Full/Database
    -- Backup database <TEN DATABASE> to disk = '<DUONG DAN FILE BACKUP + TEN FILE>'
-- Differential/Incremental
    -- Backup database <TEN DATABASE> to
    -- disk = '<DUONG DAN FILE BACK UP + TEN FILE>' with differential
-- Transactional Log/Log
    -- Backup log <TEN DATABASE> to disk = '<DUONG DAN FILE BACKUP + TEN FILE>'
Backup database BanHang to disk = 'C:\Users\Admin\Desktop\dangdan\Workspace\sql\HQT CSDL\BaiTap\backup_tuan1.bak'

-- 15. Xóa CSDL BanHang
USE master
DROP DATABASE BanHang

