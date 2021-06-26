Use master
go

use AdventureWorks2008R2
go

-- 1.b. kiểm tra sau phi phần quyền
select * FROM Purchasing.PurchaseOrderDetail
GO

-- 1.c. Nhân viên NV2 xóa đơn hàng có PurchaseOrderDetailID = 195
delete from Purchasing.PurchaseOrderDetail
where PurchaseOrderDetailID = 195

-- 1d.Ai có thể xem dữ liệu bảng Purchasing.Vendor? Giải thích. Viết lệnh kiểm tra quyền trên
-- cửa sổ query của user tương ứng

SELECT * 
FROM Purchasing.ProductVendor

-- 1.e. kiểm tra quyền truy cập NV2
select * FROM Purchasing.PurchaseOrderDetail
GO